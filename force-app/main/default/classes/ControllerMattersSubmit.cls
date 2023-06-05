/*
 * @Descripttion: 
 * @Author: Hogan
 * @Date: 2023-04-24 16:00:00
 * @LastEditors: Hogan
 * @LastEditTime: 2023-04-24 16:00:00
 */
public without sharing class ControllerMattersSubmit {
    public ControllerMattersSubmit() {}

    /**
     * @Descripttion: 结项审批初始化
     * @Author: Devin
     * @param {*}
     * @return {*}
     */   
    @AuraEnabled 
    public static Map<Object,Object> initApprovalCompletion(String recordId) {
        SupervisoryMatters__c matters = [SELECT  
                                         Id,
                                         ActualCompletionDate__c,  //实际完成日期
                                         CompletionDescription__c //完成情况说明
                                    FROM 
                                        SupervisoryMatters__c	
                                    WHERE 
                                        Id =: recordId
                                        ];
        
        Map<Object,Object> map_return = new Map<Object,Object>();

        map_return.put('actualCompletionDate',matters.ActualCompletionDate__c);
        map_return.put('completionDescription',matters.CompletionDescription__c);
        
        return map_return;
    }

     /**
     * @Descripttion: 延期审批初始化
     * @Author: Devin
     * @param {*}
     * @return {*}
     */   
    @AuraEnabled 
    public static Map<Object,Object> initApprovalExtension(String recordId) {
        SupervisoryMatters__c matters = [SELECT  
                                         Id,
                                         ExtensionReason_Temp__c,  //申请延期原因
                                         PlanCompletionDate_Temp__c //计划完成日期变更
                                    FROM 
                                        SupervisoryMatters__c	
                                    WHERE 
                                        Id =: recordId
                                        ];
        
        Map<Object,Object> map_return = new Map<Object,Object>();

        map_return.put('extensionReasonTemp',matters.ExtensionReason_Temp__c);
        map_return.put('planCompletionDateTemp',matters.PlanCompletionDate_Temp__c);
        
        return map_return;
    }

     /**
     * @Descripttion: 提交结项审批
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static void completionSubmit(String recordId,String comment,Date actualCompletionDate,String completionDescription) { 

        System.debug('recordId----'+recordId);

        SupervisoryMatters__c matters = [select id from SupervisoryMatters__c where Id =: recordId];
        matters.ActualCompletionDate__c = actualCompletionDate;
        matters.CompletionDescription__c = completionDescription;
        // Approval.unlock(matters.id);//解锁
        update matters;

        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
        apsr.setProcessDefinitionNameOrId('MattersFinishProcessV6');
        //留言内容和对象ID
        apsr.setComments(comment);
        apsr.setObjectId(recordId);
        apsr.setSubmitterId(UserInfo.getUserId());
        // 是否跳过标准
        apsr.setSkipEntryCriteria(true);
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

    /**
     * @Descripttion: 提交延期审批
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static void extensionSubmit(String recordId,Date planCompletionDateTemp,String extensionReasonTemp) { 

        System.debug('recordId----'+recordId);

        SupervisoryMatters__c matters = [select id from SupervisoryMatters__c where Id =: recordId];
        matters.PlanCompletionDate_Temp__c = planCompletionDateTemp;
        matters.ExtensionReason_Temp__c = extensionReasonTemp;
        update matters;
        
        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
        apsr.setProcessDefinitionNameOrId('MattersExtensionProcessV2');
        //留言内容和对象ID
        // apsr.setComments(comment);
        apsr.setObjectId(recordId);
        apsr.setSubmitterId(UserInfo.getUserId());
        // 是否跳过标准
        apsr.setSkipEntryCriteria(true);
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