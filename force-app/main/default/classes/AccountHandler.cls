/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-27 08:25:22
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-12-13 14:27:44
 */
global without sharing class AccountHandler implements Triggers.Handler {
    
    public void handle() {

        List<String> notifyAccId = new List<String>();


        //irving 2021/12/08   
        if (Trigger.isAfter && Trigger.isInsert) {
            for(Account acc : (List<Account>)Trigger.new) {

                notifyAccId.add(acc.id);
            }
        }

        // if (notifyAccId.size()>0) {
        //     notifyMethod(notifyAccId);
        // }

        //更新之前  after--before  irving
        if (Trigger.isBefore && Trigger.isUpdate) {
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);

                if (newAcc.Accounttype__c =='已交易客户' && newAcc.SysSAP__c && newAcc.SysSAP__c != oldAcc.SysSAP__c) {
                    newAcc.addError('已同步SAP,类型为已交易客户，请刷新!');
                }
            }
        }
        
        List<String> accIds = new List<String>();
        //更新之后
        if (Trigger.isAfter && Trigger.isUpdate) {

            System.debug('触发器进来了');
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);

                if (newAcc.SysSAP__c && newAcc.SysSAP__c != oldAcc.SysSAP__c) {
                    accIds.add(newAcc.Id);
                }
            }
           
            if(accIds.size() > 0){
                Execute(accIds);
            }
        }

        if (notifyAccId.size()>0) {
            notifyMethod(notifyAccId);
        }
    }

    public static void Execute(List<String> accIds){

        Account acc = [select id,Accounttype__c from Account where id = :accIds[0]];
        System.debug('Accounttype__c--------'+acc.Accounttype__c);
        if (acc.Accounttype__c != '已交易客户') {
            System.debug('excute执行客户主数据维护控制器');
            //调用sap接口查三证合一是否已经存在  如果没有存在  则可以直接创建  
            // Controller_TaxCheckDuplicate.TaxCheckDuplicate(accIds[0]);
            Controller_SAPCustomerSave.SAPCustomerSave(accIds[0]); 
        }

        //---------------Devin 2021-12-01  把SysSap 修改为 False--------------
        List<Account> upAccList = new List<Account>();

        for (String accId : accIds) {
            Account upAcc = new Account();
            upAcc.Id = accId;
            upAcc.SysSAP__c = false;
            upAccList.add(upAcc);
        }
        update upAccList;
    }

    public static void notifyMethod(List<String> notifyAccId){

        //List<Account> accList = [select id,Accounttype__c,Officialcode__c from Account where id in:notifyAccId];

        //调用sap接口查三证合一是否已经存在  如果没有存在  则可以直接创建  
        Controller_TaxCheckDuplicate.TaxCheckDuplicate(notifyAccId[0]);
        //存在，直接拉取数据回来更新到该客户上--写在接口里
    }
}