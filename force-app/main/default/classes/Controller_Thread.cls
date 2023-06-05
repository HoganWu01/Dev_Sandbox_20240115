public with sharing class Controller_Thread {
    public Controller_Thread() {

    }
    @AuraEnabled
    public static List<String> getThread(String recordId) {
        system.debug('recordId==='+ recordId);
        List<String> idList = new List<String>();
        idList.add(recordId);
        List<Lead> leads= [SELECT 
                                    Id,
                                    Prebuildstartdate__c,//（预计）建设计划时间 
                                    Projectname__c,//项目名称
                                    Projectcapacity__c,//项目容量
                                    SalesDepartment__c,//所属战区/二级子公司 
                                    ChiefGeneralManager__c,//总经理/首席代表 
                                    Group__c,//项目所属集团
                                    ExecutiveGeneralManage__c,//执行总经理
                                    Subcompany__c,//客户二级公司
                                    Leadlevel__c,//线索等级
                                    Province__c,//省份
                                    City__c,//城市
                                    Leadcontent__c,//线索内容
                                    Leadbackgrand__c,//线索信息背景
                                    Leadsource__c, //线索来源
                                    Name, //关键联系人姓名
                                    Approvedornot__c, //项目是否核准
                                    Expectedapptime__c, //（预计）核准时间
                                    Customer_Side_Approved__c, //客户侧是否立项-进入当年建设盘子
                                    ExpectedBidtime__c //（预计）招标时间
                                FROM 
                                    Lead 
                                where 
                                    Id IN: idList];
        List<String> leadList = new List<String>();
        for (Lead le : leads) {
            if (le.Prebuildstartdate__c == null) {
                leadList.add('（预计）建设计划时间');
            }
            if (le.Projectname__c == null) {
                leadList.add('项目名称');
            }
            if (le.Projectcapacity__c == null) {
                leadList.add('项目容量');
            }
            if (le.SalesDepartment__c == null) {
                leadList.add('所属战区/二级子公司');
            }
            if (le.ChiefGeneralManager__c == null) {
                leadList.add('总经理/首席代表');
            }
            if (le.Group__c == null) {
                leadList.add('项目所属集团');
            }
            if (le.ExecutiveGeneralManage__c == null) {
                leadList.add('执行总经理');
            }
            if (le.Subcompany__c == null) {
                leadList.add('客户二级公司');
            }
            if (le.Leadlevel__c == null) {
                leadList.add('线索等级');
            }
            if (le.Province__c == null) {
                leadList.add('省份');
            }
            if (le.City__c == null) {
                leadList.add('城市');
            }
            if (le.Leadcontent__c == null) {
                leadList.add('线索内容');
            }
            if (le.Leadbackgrand__c == null) {
                leadList.add('线索信息背景');
            }
            if (le.Leadsource__c == null) {
                leadList.add('线索来源');
            }
            if (le.Name == null) {
                leadList.add('关键联系人姓名');
            }
            if (le.Approvedornot__c == null) {
                leadList.add('项目是否核准');
            }
            if (le.Expectedapptime__c == null) {
                leadList.add('（预计）核准时间');
            }
            if (le.Customer_Side_Approved__c == null) {
                leadList.add('客户侧是否立项-进入当年建设盘子');
            }
            if (le.ExpectedBidtime__c == null) {
                leadList.add('（预计）招标时间');
            }
        }
        return leadList; 
    } 

    /**
     * @Descripttion: 提交线索审批
     * @Author: Devin
     * @param {*}
     * @return {*}
     */     
    @AuraEnabled
    public static Map<Object,Object> approveLead(String recordId,String approveComment) {
        System.debug('approveComment---------------'+approveComment);

        Map<Object,Object> map_return = new Map<Object,Object>();

        String type = 'S';
        String messages = '提交审批成功!';

        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
        apsr.setComments(approveComment);
        apsr.setObjectId(recordId);
        apsr.setSubmitterId(UserInfo.getUserId());
        //提交审批结果
        Approval.ProcessResult rt;
        try{
            rt = Approval.process(apsr);
            if(rt.isSuccess()){
                System.debug('调用commit审批过程成功！');
            }
        }catch(Exception e){
            System.debug('调用commit审批过程产生异常：' + e.getMessage()); 
            type = 'E';      
            messages = '调用审批流失败,请联系系统管理员!错误信息:'+e.getMessage();         
        }

        map_return.put('messages',messages);
        map_return.put('type',type);

        System.debug('map_return---'+map_return);

        return map_return;
        
    }
}