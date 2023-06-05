/*
 * @Descripttion: 
 * @Author: irving
 * @Date: 2022-1-6 09:55:49
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-01-12 16:01:52
 */
public without sharing class BatchRTC {

    private class BatchRTCException extends Exception{}
    
    public ApexPages.StandardSetController stdCntrlr {get; set;}
    
    public BatchRTC(ApexPages.StandardSetController controller){
        System.debug('BatchRTC构造器方法');
        stdCntrlr = controller;
    }

    public List<ResponseEntityClass> selectedList { get; set; }


     /**
     * @Descripttion: 初始化加载页面数据
     * @Author: irving
     * @param {*}
     * @return {*}
     */    
    @RemoteAction
    public static String showData(String RListStr){

        System.debug('RListStr==='+RListStr);

        System.debug('点击按钮加载页面数据');
        ResponseClass response = new ResponseClass();

        Map<Object,Object> return_map = new Map<Object,Object>();

        LastResponseEntityClass entity = new LastResponseEntityClass();

        try {

            List<ResponseEntityClass>  selectedList = new List<ResponseEntityClass>();

            String recTypeId =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('ProvinceArea_RecordType').getRecordTypeId();

            List<Integrated_Middle_Table__c> tableList = [SELECT Id,
                                                                Area__c,
                                                                Province__c ,
                                                                ProvinceAreaOwner__c
                                                                FROM Integrated_Middle_Table__c 
                                                                WHERE RecordTypeId =:recTypeId ];

            Map<String,String> provinceAreaMap = new Map<String,String>();

            Map<String,String> provinceOwner = new Map<String,String>();

            for (Integrated_Middle_Table__c table : tableList) {
                provinceAreaMap.put(table.Province__c, table.Area__c);
                provinceOwner.put(table.Province__c, table.ProvinceAreaOwner__c);
            }

            String ss = RListStr.deleteWhitespace().remove('[').remove(']');

            String[] rId = ss.split(',');

            System.debug('rId数量==='+rId.size());

            List<Resource_Development__c> resources = [SELECT 
                                                            ID,
                                                            Name, 
                                                            Group__c,
                                                            Group__r.NAME,                                                         
                                                            Province__c                                                        
                                                            FROM Resource_Development__c WHERE ID IN:rId ];

            System.debug('resources==='+resources);
            System.debug('resources数量==='+resources.size());

            for (Resource_Development__c resource : resources) {
                ResponseEntityClass vo = new ResponseEntityClass();
                vo.Id = resource.Id ; 
                vo.ResourceName = resource.Name ; 
                vo.customerProvince = resource.Province__c ; 
                if (resource.Group__c!=null) {
                    vo.GroupName = resource.Group__r.NAME ; 
                }else{
                    vo.GroupName = '';
                }
                
                if (provinceAreaMap.keySet().contains(resource.Province__c)) {
                    vo.customerArea = provinceAreaMap.get(resource.Province__c);
                }else{
                    vo.customerArea = '';
                }
                if (provinceOwner.keySet().contains(resource.Province__c)) {
                    vo.customerprovinceOwnerName = selectNameById(provinceOwner.get(resource.Province__c));
                }else{
                   // vo.customerprovinceOwnerName = provinceOwner.get(resource.Province__c);
                }
                
               
                selectedList.add(vo);

                //System.debug('selectedList展示的==='+selectedList);
                //System.debug('selectedList展示的资源数量==='+selectedList.size());

                return_map.put('data', selectedList);

                
                entity.entites = selectedList ; 
                

            }


            
        } catch (Exception e) {
            
            System.debug('-----exception:'+e.getStackTraceString()+e.getMessage());
            //throw new BatchRTCException(e.getMessage());
            response.messge = e.getMessage();
            response.type = 'E';
        }

        
        response.data = entity ; 
        response.messge = '';
        response.type = 'S';

        //return return_map;
        return Json.serialize(response);
    }

 /**
     * @Descripttion: 点击按钮资源转订单
     * @Author: irving
     * @param {*}
     * @return {*}
     */    
    @RemoteAction
    public static void BRTC(String RListStr){

        System.debug('RListStr=='+RListStr);

        SavePoint sp = Database.setSavepoint();

        try {

            String recTypeId =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('ProvinceArea_RecordType').getRecordTypeId();

            List<Integrated_Middle_Table__c> tableList = [SELECT Id,
                                                                Area__c,
                                                                Province__c ,
                                                                ProvinceAreaOwner__c
                                                                FROM Integrated_Middle_Table__c 
                                                                WHERE RecordTypeId =:recTypeId ];

            Map<String,String> provinceAreaMap = new Map<String,String>();

            Map<String,String> provinceOwner = new Map<String,String>();

            for (Integrated_Middle_Table__c table : tableList) {
                provinceAreaMap.put(table.Province__c, table.Area__c);
                provinceOwner.put(table.Province__c, table.ProvinceAreaOwner__c);
            }

            String ss = RListStr.deleteWhitespace().remove('[').remove(']');

            String[] rId = ss.split(',');

            List<Resource_Development__c> resources = [SELECT 
                                                            ID,
                                                            Name,
                                                            MW__c,   //预计容量（MW）
                                                            LeadOwner__c,
                                                            Period__c,    //期数
                                                            WindFarmName__c,  //风场项目名
                                                            OwnerId,
                                                            Owner.Name,
                                                            Group__c,
                                                            Group__r.NAME,
                                                            SalesDepartment__c,
                                                            Leadbackgrand__c,
                                                            Province__c,
                                                            LeadContent__c,
                                                            County__c,
                                                            ResourceLeadApprovalState__c , 
                                                            City__c
                                                            FROM Resource_Development__c WHERE ID IN:rId ];

            System.debug('resources=='+resources);

            if(resources.isEmpty()){
                return ;
            }


            List<Lead> leadList = new List<Lead>();

            for (Resource_Development__c resource : resources) {
                Lead leadObj = new Lead();

                if (resource.ResourceLeadApprovalState__c=='审批通过') {
                    continue ; 
                }

                if (resource.Group__c!=null &&String.isNotBlank(resource.Group__c)) {
                    leadObj.Group__c = resource.Group__c;  //项目所属集团
                    leadObj.Company = resource.Group__r.NAME;  //公司名字
                }else{
                    continue ; 
                }

                if (provinceAreaMap.keySet().contains(resource.Province__c)) {
                    leadObj.SalesDepartment__c =provinceAreaMap.get(resource.Province__c)  ;   //mapping表的区域--所属战区/二级子公司*
                }else{
                    continue ; 
                }

                if (provinceOwner.keySet().contains(resource.Province__c)) {
                    leadObj.OwnerId = provinceOwner.get(resource.Province__c) ;  //  mapping的人 
                }else{
                    continue ; 
                }

                if (String.isNotBlank(resource.LeadContent__c)) {
                    leadObj.Leadcontent__c = resource.LeadContent__c ;  //线索内容
                }else{
                    leadObj.Leadcontent__c = '暂无';
                }


                leadObj.County__c  = resource.County__c ;  //  区县--县

                leadObj.Projectcapacity__c = resource.MW__c ;   //项目容量（单位：MW)*
                leadObj.Windfieldprojectname__c = resource.WindFarmName__c;  //风场项目名
                leadObj.Numberofperiods__c = resource.Period__c ;  //期数
                leadObj.Leadbackgrand__c = resource.Leadbackgrand__c ;  //线索信息背景
                leadObj.City__c = resource.City__c ;   //城市
                leadObj.LastName = resource.Owner.Name;   //线索联系人名称
                leadObj.Leadsource__c = '由资源转化';   //内部推荐---线索来源
                // leadObj.Providerdepartment__c = '资源信息部' ;   //线索内部推荐人部门
                // leadObj.Providername__c = resource.Owner.Name ;  //线索内部推荐人姓名

                if (leadObj.SalesDepartment__c!=null &&String.isNotBlank(leadObj.SalesDepartment__c) &&leadObj.OwnerId!=null &&String.isNotBlank(leadObj.OwnerId) &&leadObj.Group__c!=null &&String.isNotBlank(leadObj.Group__c)) {
                    leadList.add(leadObj);
                    System.debug('添加成功');
                }
                
            }

            System.debug('leadList=='+leadList);

            

            if (leadList.size()>0) {
                  insert leadList ; 
                 System.debug('插入数据成功');

                 List<Id> ridList = new List<Id>();

                 for (Resource_Development__c resource : resources) {
                    ridList.add(resource.Id);    //资源id
                     resource.ResourceLeadApprovalState__c = '审批通过';
                     resource.Stage__c = '007';
                 }

                 update resources ; 
                 Approval.lock(ridList);   //锁定资源id
                 System.debug('跟新资源状态为审批通过');
                
            }else{
                Database.rollback(sp);
                throw new BatchRTCException('批量转数据失败,请检查数据');
            }


            //测试
            // Lead l = new Lead();
            // l.Group__c = '001p000000ygWHJAA2';
            // l.Company = '中美二级公司';
            // l.SalesDepartment__c = '华北';
            // l.OwnerId = '0052v00000di3lJAAQ';
            // l.Leadcontent__c = '暂无';
            // l.Projectcapacity__c = '1';
            // l.Windfieldprojectname__c = '集中式风电';
            // l.Numberofperiods__c = '一';
            // l.Leadbackgrand__c = null;
            // l.City__c = '天津市';
            // l.LastName = 'Chen Cong';
            // l.Leadsource__c = '内部推荐';
            // l.Providerdepartment__c = '资源信息部';
            // l.Providername__c = 'Chen Cong';
            // insert l  ;
            // System.debug('添加成功');

          


            
        } catch (Exception e) {

            System.debug('exception=>:'+e.getStackTraceString()+'错误信息'+e.getMessage()+'错误行数'+e.getLineNumber());
            Database.rollback(sp);
            throw new BatchRTCException(e.getMessage());
            
        }



    }

    public static String selectNameById(String ownerId){
        User user = [select id,name from User where id = :ownerId] ; 
        String name = '';
        if (user!=null) {
            name = user.name ; 
        }
        return name; 
    }


    // @RemoteAction
    // public static String searchGroupData(String groupData){
    //     System.debug('回车查数据');
    //     CutResponseEntityClass cutCls = new CutResponseEntityClass();
    //     ResponseClass response = new ResponseClass();
    //     response.type = 'S';
    //     response.messge = '';
    //     String data = '';
    //     List<Map<String,String>> mapList = new List<Map<String,String>>();
    //     Map<String,String> cutMap = new Map<String,String>();
    //     if (String.isBlank(groupData)) {
    //         response.type = 'E';
    //         response.messge = '输入为空';
    //         return Json.serialize(response); 
    //     }
    //     List<Account> accList = [SELECT ID,NAME FROM Account WHERE NAME LIKE: '%'+groupData+'%'];
    //     for (Account acc : accList) {
    //         cutMap.put('value', acc.name);
    //         mapList.add(cutMap);
    //     }
    //     cutCls.entites = mapList ; 
    //     response.data = cutCls ; 
    //     return Json.serialize(response);
    // }

    public class LastResponseEntityClass {
        public List<ResponseEntityClass> entites  = new List<ResponseEntityClass>(); 
     }

     public class CutResponseEntityClass {
        public List<Map<String,String>> entites  = new List<Map<String,String>>(); 
     }

    

    public class ResponseEntityClass {
        public String Id { get; set; } 
        public String ResourceName { get; set; } 
        public String GroupName { get; set; } 
        public String customerProvince { get; set; } 
        public String customerArea { get; set; }
        public String customerprovinceOwnerName { get; set; }
        
     }

     public class ResponseClass {
        public String type;//成功:S 失败:E
        public String messge; 
        public Object data ;
    }

    
}