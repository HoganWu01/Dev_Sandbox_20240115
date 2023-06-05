/*
 * @Descripttion: 
 * @Author: irving
 * @Date: 2021-10-16 09:55:49
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-01-13 16:25:34
 */
public without sharing class ResourceToClueHandler implements Triggers.Handler {

    public void handle() {

        List<String> resourceIds = new List<String>();

        if (Trigger.isAfter && Trigger.isUpdate) {

            System.debug('资源开发触发器');

            for(Resource_Development__c newResource : (List<Resource_Development__c>)Trigger.new) {
                Resource_Development__c oldResource = (Resource_Development__c)Trigger.oldMap.get(newResource.Id);

                System.debug('newResource.Entrant__c'+newResource.Entrant__c);
                System.debug('oldResource.Entrant__c'+oldResource.Entrant__c);

                if(newResource.ConvertedToLead__c==true &&newResource.ResourceLeadApprovalState__c=='审批通过' &&newResource.ResourceLeadApprovalState__c!=oldResource.ResourceLeadApprovalState__c){
                    System.debug('单条转come???');
                    resourceIds.add(newResource.Id);
                }

                //阶段由线索 进入 入库 时, 提交审批流
                if (newResource.Stage__c == '001' && newResource.Entrant__c && newResource.Entrant__c != oldResource.Entrant__c) {
                    ResourceApproval(newResource.Id);
                }


                if (newResource.Stage__c !=oldResource.Stage__c || newResource.Name !=oldResource.Name  ) {
                    
                    excuteController(newResource.id);
                }
            }
        }


        if (Trigger.isAfter && Trigger.isInsert) {

            for(Resource_Development__c newResource : (List<Resource_Development__c>)Trigger.new) {
                excuteController(newResource.id);
            }

        }

        if(resourceIds.size() > 0){
            excute(resourceIds);
        }
    }

    //新建资源 ||  更新资源名字/阶段
    public void excuteController(String recordId) {
        
        Controller_SaveProjectPoints.SaveProjectPoints(recordId);
    }


    public void excute(List<String> resourceIds) {

        System.debug('资源转线索状态为审批通过进来了');


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
                                                        City__c,
                                                        County__c,
                                                        LeadContent__c                                                       
        FROM Resource_Development__c WHERE ID IN:resourceIds ];

        Lead leadObj = new Lead();

        leadObj.County__c  =resources[0].County__c;

        leadObj.Projectcapacity__c = resources[0].MW__c ;   //项目容量（单位：MW)*
        leadObj.Windfieldprojectname__c = resources[0].WindFarmName__c;  //风场项目名
        leadObj.Numberofperiods__c = resources[0].Period__c ;  //期数
        System.debug('resources[0].Group__c'+resources[0].Group__c);
        leadObj.Group__c = resources[0].Group__c;  //项目所属集团
        leadObj.Company = resources[0].Group__r.NAME;  //公司名字
        leadObj.SalesDepartment__c = resources[0].SalesDepartment__c ;  //所属战区/二级子公司*

        if (String.isNotBlank(resources[0].LeadContent__c)) {
            leadObj.Leadcontent__c = resources[0].LeadContent__c ;  //线索内容
        }else{
            leadObj.Leadcontent__c = '暂无';
        }
       
        leadObj.Leadbackgrand__c = resources[0].Leadbackgrand__c ;  //线索信息背景
        leadObj.Province__c = resources[0].Province__c ;   //省份
        leadObj.City__c = resources[0].City__c ;   //城市
        leadObj.LastName = resources[0].Owner.Name;   //线索联系人名称
        leadObj.OwnerId = resources[0].LeadOwner__c ;  //线索所有人  OwnerId   LeadOwner__c
        leadObj.Leadsource__c = '由资源转化';   //内部推荐---线索来源

        // leadObj.Providerdepartment__c = '资源信息部' ;   //线索内部推荐人部门
        // leadObj.Providername__c = resources[0].Owner.Name ;  //线索内部推荐人姓名

        insert leadObj ; 
        System.debug('添加一条线索成功，ID为'+leadObj.Id);
    }

    /**
     * @Descripttion: 调用 资源开发审批流
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public void ResourceApproval(String recordId) {

        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
        //留言内容和对象ID
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
        }
    }
}