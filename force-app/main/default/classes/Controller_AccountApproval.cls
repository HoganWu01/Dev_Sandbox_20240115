/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-10-08 14:53:17
 * @LastEditors: Devin
 * @LastEditTime: 2021-10-14 22:13:04
 */
public with sharing class Controller_AccountApproval {
    
    @AuraEnabled
    public static List<String> initAccount(String recordId) {

        Account account = [SELECT Id,Name,Officialcode__c,Country__c,Area__c,ApplicationReason__c FROM Account WHERE Id =: recordId];

        List<String> accList = new List<String>();
        if (String.isBlank(account.Name)) {
            accList.add('客户全称');
        } 
        if (String.isBlank(account.Officialcode__c)) {
            accList.add('统一社会信息证代码（三证合一）');
        } 
        if (String.isBlank(account.Country__c)) {
            accList.add('国家');
        } 
        if (String.isBlank(account.Area__c)) {
            accList.add('地区');
        } 
        if (String.isBlank(account.ApplicationReason__c)) {
            accList.add('申请原因');
        } 

        return accList;
    }

    @AuraEnabled
    public static Map<Object,Object> accountApproval(String recordId,String approveComment) {

        Map<Object,Object> map_return = new Map<Object,Object>();

        String type = 'S';
        String messages = '提交审批成功!';

        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
        apsr.setProcessDefinitionNameOrId('Sales_Account_SAP_Approval');
        //留言内容和对象ID
        apsr.setComments(approveComment);
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
            messages = '调用审批流失败,请联系系统管理员!错误信息:'+e.getMessage();      
        }

        map_return.put('messages',messages);
        map_return.put('type',type);

        System.debug('map_return---'+map_return);

        return map_return;
    }
}