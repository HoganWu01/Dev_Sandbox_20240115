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

        /*
        * @Descripttion: 一级集团变更，同步更新下级客户的一级集团
        * @Author: Hogan
        * @Date: ###### Fri Sep 22 15:26:22 CST 2023
        */
        if (Trigger.isAfter && Trigger.isUpdate) {
            List<String> aIds = new List<String>();
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);

                if ((newAcc.TopGroup__c != oldAcc.TopGroup__c && newAcc.TopGroup__c != '901') //【一级集团】发生变更，且【一级集团】≠“其他”，对其【独立集团简称】=“假”的下级客户（多级）进行【一级集团】的继承赋值。
                    || (newAcc.TopGroup__c != '901' && newAcc.Shortname__c != oldAcc.Shortname__c) //【一级集团】≠“其他”，且【商机客户简称】发生变更。对其【独立集团简称】=“假”的下级客户（多级）进行【商机客户简称】的继承赋值。
                ) { 
                    aIds.add(newAcc.Id);
                }
            }
           
            if(aIds.size() > 0){
                List<Account> upAccList = new List<Account>();
                for(String aId : aIds){
                    Account topAcc = [select id,TopGroup__c from Account where id = :aId];
                    List<String> subAccIds = subAccList(aId);
                    for(String subAccId : subAccIds){
                        Account subAcc = [select id,Parent.Shortname__c from Account where id = :subAccId];
                        Account upAcc = new Account();
                        upAcc.Id = subAccId;
                        upAcc.TopGroup__c = topAcc.TopGroup__c;
                        upAcc.Shortname__c = subAcc.Parent.Shortname__c;
                        upAccList.add(upAcc);
                    }
                }
                update upAccList;
            }
        }

        /*
        * @Descripttion: 商机客户简称自动赋值--After
        * @Author: Hogan
        * @Date: ###### Fri Sep 22 15:26:22 CST 2023
        */
        if (Trigger.isAfter && Trigger.isInsert) {
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account acc = [select id, toLabel(TopGroup__c),Parent.Shortname__c from Account where id =: newAcc.Id];
                Account upAcc = new Account();
                if(newAcc.TopGroup__c != '901' && newAcc.SeparateGroup__c == true && newAcc.ParentId == null){ //【独立集团简称】=“真”，且【上一级公司】为空，使【商机客户简称】只读,且自动赋值=【一级集团】
                    upAcc.Id = acc.Id;
                    upAcc.Shortname__c = acc.TopGroup__c;
                    update upAcc;
                }else if(newAcc.TopGroup__c != '901' &&newAcc.SeparateGroup__c == false){ //【独立集团简称】=“假”，使【商机客户简称】只读,且自动赋值={【上一级公司】}.【商机客户简称】
                    upAcc.Id = acc.Id;
                    upAcc.Shortname__c = acc.Parent.Shortname__c;
                    update upAcc;
                }
            }
        }

        /*
        * @Descripttion: 商机客户简称自动赋值--AfterUpdate
        * @Author: Hogan
        * @Date: ###### Fri Sep 22 15:26:22 CST 2023
        */
        if (Trigger.isAfter && Trigger.isUpdate) {
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);
                if (newAcc.TopGroup__c != oldAcc.TopGroup__c || newAcc.SeparateGroup__c != oldAcc.SeparateGroup__c || newAcc.ParentId != oldAcc.ParentId) { //一级集团或独立集团简称或上一级公司发生变更
                    Account acc = [select id, toLabel(TopGroup__c),Parent.Shortname__c from Account where id =: newAcc.Id];
                    Account upAcc = new Account();
                    if(newAcc.TopGroup__c != '901' && newAcc.SeparateGroup__c == true && newAcc.ParentId == null){ //【独立集团简称】=“真”，且【上一级公司】为空，使【商机客户简称】只读,且自动赋值=【一级集团】
                        upAcc.Id = acc.Id;
                        upAcc.Shortname__c = acc.TopGroup__c;
                        update upAcc;
                    }else if(newAcc.TopGroup__c != '901' &&newAcc.SeparateGroup__c == false){ //【独立集团简称】=“假”，使【商机客户简称】只读,且自动赋值={【上一级公司】}.【商机客户简称】
                        upAcc.Id = acc.Id;
                        upAcc.Shortname__c = acc.Parent.Shortname__c;
                        update upAcc;
                    }
                }
            }
        }
    }

    public static List<String> subAccList(String accId){
        List<String> accIds = new List<String>();
        List<Account> listAcc = [select Id from Account where ParentId =: accId and SeparateGroup__c = false];
        if(listAcc.size()>0){
            for(Account acc : listAcc){
                accIds.add(acc.Id);
                subAccList(acc.Id);
            }
        }
        return accIds;
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