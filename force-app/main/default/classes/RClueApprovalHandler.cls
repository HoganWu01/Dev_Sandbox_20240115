/*
 * @Descripttion: 【资源开发】 触发器
 * @Author: Devin
 * @Date: 2021-10-16 09:55:49
 * @LastEditors: Devin
 * @LastEditTime: 2022-01-12 16:45:02
 */
public without sharing class RClueApprovalHandler implements Triggers.Handler{
    
    public void handle() {

        if (Trigger.isBefore && Trigger.isInsert) {

            //当前时间
            Date currentDay = System.toDay();
            String dayString =  DateTime.newInstance(currentDay.year(),currentDay.month(),currentDay.day()).format('YYYYMMDD');
            String daySoql = '%'+dayString+'%';

            //查询出最新一条记录
            List<Resource_Development__c> latelyRecordList = new List<Resource_Development__c>();
            latelyRecordList = [SELECT  Id,
                                        ResourceNumber__c 
                                    FROM 
                                        Resource_Development__c 
                                    WHERE 
                                        ResourceNumber__c != null 
                                    AND 
                                        ResourceNumber__c LIKE: daySoql  
                                    ORDER BY 
                                        ResourceNumber__c DESC
                                    limit 1];
            
            //例子: RPCS202201120001
            Decimal numberCode = 0;
            if (latelyRecordList != null && !latelyRecordList.isEmpty()) {

                numberCode = Decimal.valueof(latelyRecordList[0].ResourceNumber__c.substring(12, latelyRecordList[0].ResourceNumber__c.length()));
            }

            //自动编号  每天从新计算
            System.debug('numberCode----'+numberCode);
            for(Resource_Development__c resource : (List<Resource_Development__c>)Trigger.new) {

                if (numberCode > 0) {

                    String numberString = '';
                    
                    numberCode += 1;

                    if (String.valueOf(numberCode).length() == 1) {
                        numberString += '000' + numberCode;
                    } else if (String.valueOf(numberCode).length() == 2) {
                        numberString += '00' + numberCode;
                    } else if (String.valueOf(numberCode).length() == 3) {
                        numberString += '0' + numberCode;
                    } else {
                        numberString += numberCode;
                    }

                    System.debug('numberString---'+numberString);
                    resource.ResourceNumber__c = 'RPCS' + dayString + numberString;
                } else {
                    resource.ResourceNumber__c = 'RPCS' + dayString + '0001';
                    numberCode += 1;
                }
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {

            List<String> rdOwnerIdList = new List<String>();

            for(Resource_Development__c newResource : (List<Resource_Development__c>)Trigger.new) {
                Resource_Development__c oldResource = (Resource_Development__c)Trigger.oldMap.get(newResource.Id);
 
                if((newResource.ConvertedToLead__c == true && newResource.ConvertedToLead__c != oldResource.ConvertedToLead__c)||(newResource.Reserve__c == true && newResource.Reserve__c!=oldResource.Reserve__c)
                ||(newResource.Regulations__c == true && newResource.Regulations__c!=oldResource.Regulations__c)||(newResource.Approved__c == true && newResource.Approved__c!=oldResource.Approved__c)
                ||(newResource.Construction__c == true && newResource.Construction__c!=oldResource.Construction__c)){
                    excute(newResource.Id);
                }

                //OwnerId 发生改变时
                if (newResource.OwnerId != oldResource.OwnerId) {
                    rdOwnerIdList.add(newResource.Id);
                }
            }

            if (rdOwnerIdList.size() > 0) {
                shareToRdDepend(rdOwnerIdList);
            }
        }
    }


    /**
     * @Descripttion: 提交审批流
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public void excute(String resourceId) {

        System.debug('资源审批excute');
        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();

        apsr.setObjectId(resourceId);
        apsr.setSubmitterId(UserInfo.getUserId());
        //提交审批结果
        Approval.ProcessResult result ;

        result = Approval.process(apsr);

        if(result.isSuccess()){
            System.debug('调用commit审批过程成功！');
        }
    }

    /**
     * @Descripttion: 资源开发的Owner发生改变时，资源项目方案申请、资源开发协议、资源审批单、资源立项申请单、子公司投资与注册变更事前申请 共享给资源开发的Owner
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public void shareToRdDepend(List<String> rdOwnerIdList) {

        List<Resource_Development__c> rdList = new List<Resource_Development__c>();

        rdList = [SELECT    Id,
                            OwnerId,
                            (SELECT Id,OwnerId FROM Resource_Development_Name__r),//资源开发协议、资源审批单
                            (SELECT Id,OwnerId FROM ResourceName__r),//资源立项申请单
                            (SELECT Id,OwnerId FROM ResourceDevelopmentaName__r)//子公司投资与注册变更事前申请
                        FROM 
                            Resource_Development__c 
                        WHERE 
                            Id IN: rdOwnerIdList
                        ];
        
        //资源开发协议、资源审批单
        List<ResourceApproval__Share> resourceApprovalShareList = new List<ResourceApproval__Share>();
        //资源立项申请单
        List<ResourceProjectApplication__Share> rpaShareList = new List<ResourceProjectApplication__Share>();
        //子公司投资与注册变更事前申请
        List<CompanyRegisterApplication__Share> craShareList = new List<CompanyRegisterApplication__Share>();
 
        for(Resource_Development__c rd : rdList) {
 
            //资源开发协议、资源审批单
            for (ResourceApproval__c resourceApproval : rd.Resource_Development_Name__r) {
                
                if (resourceApproval.OwnerId != rd.OwnerId) {
                    ResourceApproval__Share resourceApprovalShare = new ResourceApproval__Share();
                    resourceApprovalShare.ParentId = resourceApproval.Id;
                    resourceApprovalShare.UserOrGroupId = rd.OwnerId;//分配给商机所有人
                    resourceApprovalShare.AccessLevel = 'Edit';
                    resourceApprovalShareList.add(resourceApprovalShare);
                }
            }
 
            //资源立项申请单
            for (ResourceProjectApplication__c rpa : rd.ResourceName__r) {

                if (rpa.Id != rd.OwnerId) {
                    ResourceProjectApplication__Share rpaShare = new ResourceProjectApplication__Share();
                    rpaShare.ParentId = rpa.Id;
                    rpaShare.UserOrGroupId = rd.OwnerId;//修改所有人
                    rpaShare.AccessLevel = 'Edit';
                    rpaShareList.add(rpaShare);
                }
            }

            //子公司投资与注册变更事前申请
            for (CompanyRegisterApplication__c cra : rd.ResourceDevelopmentaName__r) {

                if (cra.Id != rd.OwnerId) {
                    CompanyRegisterApplication__Share craShare = new CompanyRegisterApplication__Share();
                    craShare.ParentId = cra.Id;
                    craShare.UserOrGroupId = rd.OwnerId;//修改所有人
                    craShare.AccessLevel = 'Edit';
                    craShareList.add(craShare);
                }
            }
        }
 
        insert resourceApprovalShareList;//资源开发协议、资源审批单
        insert rpaShareList;//资源立项申请单
        insert craShareList;//子公司投资与注册变更事前申请

    }
}