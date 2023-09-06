/*
 * @Descripttion: 
 * @Author: Hogan
 * @Date: ###### Tue Jul 25 17:15:39 CST 2023
 * @LastEditors: Hogan
 * @LastEditTime: ###### Tue Jul 25 17:15:40 CST 2023
 */
public with sharing class ControllerOppBidSubmit {
    public ControllerOppBidSubmit() {}

    /**
     * @Descripttion: 提交审批流
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> bidSubmit(String recordId,String comment) { 

        System.debug('comment----'+comment);
        
        Map<Object,Object> map_return = new Map<Object,Object>();
        String type = 'S';
        String messages = '提交审批成功!';

        Opportunity opportunity = [SELECT Id, Approvalstatus__c FROM Opportunity WHERE Id =: recordId];
        if (opportunity.Approvalstatus__c!='30') {
            map_return.put('type','A');
            map_return.put('approvalStatus',opportunity.Approvalstatus__c);
            return map_return;
        }

        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
        apsr.setProcessDefinitionNameOrId('ApplyBidApprovalProcess');
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
            type = 'E';       
            messages = '调用审批流失败! 错误信息:'+e.getMessage();    
        }

        map_return.put('messages',messages);
        map_return.put('type',type);
        return map_return;
    }
}