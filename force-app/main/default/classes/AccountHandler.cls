/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-27 08:25:22
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-12-13 14:27:44
 */
global without sharing class AccountHandler implements Triggers.Handler {
    
    public static List<Account> subAccList = new List<Account>();
    public static List<Account> finalAccList = new List<Account>();
    public static Map<Integer,String> accMap = new Map<Integer,String>();

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
        * @Descripttion: 插入之前，判断“一级集团只允许有一个最高级客户”
        * @Author: Hogan
        * @Date: ###### Tue Oct 24 16:48:22 CST 2023
        */
        if (Trigger.isBefore && Trigger.isInsert) {
            for(Account newAcc : (List<Account>)Trigger.new) {
                if (newAcc.BeenGroup__c == true && newAcc.ParentId == null) { 
                    List<Account> listAcc = [SELECT Id FROM Account WHERE BeenGroup__c = true and ParentId = NULL and TopGroup__c =: newAcc.TopGroup__c ];
                    if (listAcc.size() > 0) {
                        newAcc.addError('一个一级集团，只允许有一个最高级集团客户。');
                    }
                }
            }
        }

        /*
        * @Descripttion: 更新之前，判断“一级集团只允许有一个最高级客户”
        * @Author: Hogan
        * @Date: ###### Tue Oct 24 16:48:22 CST 2023
        */
        if (Trigger.isBefore && Trigger.isUpdate) {
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);
                if ((newAcc.TopGroup__c != oldAcc.TopGroup__c || newAcc.BeenGroup__c != oldAcc.BeenGroup__c || newAcc.ParentId != oldAcc.ParentId) && newAcc.BeenGroup__c == true && newAcc.ParentId == null) { 
                    List<Account> listAcc = [SELECT Id FROM Account WHERE id != :newAcc.Id and BeenGroup__c = true and ParentId = NULL and TopGroup__c =: newAcc.TopGroup__c ];
                    if (listAcc.size() > 0) {
                        newAcc.addError('一个一级集团，只允许有一个最高级集团客户。');
                    }
                }
            }
        }

        /*
        * @Descripttion: 【一级集团】发生变更，所有 下级客户（多级）进行【一级集团】的继承赋值。
        * @Author: Hogan
        * @Date: ###### Fri Sep 22 15:26:22 CST 2023
        */
        if (Trigger.isAfter && Trigger.isUpdate) {
            List<Account> tempList = new List<Account>();
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);

                if (newAcc.TopGroup__c != oldAcc.TopGroup__c) { 
                    tempList.add(newAcc);
                }
            }
           
            if(tempList.size() > 0){
                for(Account act : tempList){
                    List<Account> upAccList = new List<Account>();
                    List<String> aIds = new List<String>();
                    aIds.add(act.Id);
                    subAccList(aIds);
                    if (!accMap.isEmpty()) {
                        List<Integer> aList = new List<Integer>();
                        aList.addAll(accMap.keySet());
                        aList.sort();
                        //so here you will get sorted total base on key
                        for(Integer a: aList)
                        {
                            System.debug( '::::::::::::: ' + accMap.get(a)) ;
                            Account upAcc = new Account();
                            upAcc.Id = accMap.get(a);
                            upAcc.TopGroup__c = act.TopGroup__c;
                            upAccList.add(upAcc);
                        }
                    }
                    
                    
                    // List<String> subAccIds = subAccList(act.Id);
                    // for(String subAccId : subAccIds){
                    //     Account upAcc = new Account();
                    //     upAcc.Id = subAccId;
                    //     upAcc.TopGroup__c = act.TopGroup__c;
                    //     upAccList.add(upAcc);
                    // }
                    System.debug('upAccList一级集团变更=============' + upAccList);
                    update upAccList;
                }
            }
        }

        

        /*
        * @Descripttion: 【一级集团】≠“其他”，且【商机客户简称】发生变更。对其【独立集团简称】=“假”的下级客户（多级）进行【商机客户简称】的继承赋值。
        * @Author: Hogan
        * @Date: ###### Wed Oct 25 16:57:48 CST 2023
        */
        // if (Trigger.isAfter && Trigger.isUpdate) {
        //     List<Account> tempList = new List<Account>();
        //     for(Account newAcc : (List<Account>)Trigger.new) {
        //         Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);

        //         if (newAcc.TopGroup__c != 'TG901' && newAcc.Shortname__c != oldAcc.Shortname__c) { 
        //             tempList.add(newAcc);
        //         }
        //     }
           
        //     if(tempList.size() > 0){
        //         List<Account> upAccList = new List<Account>();
        //         for(Account act : tempList){
        //             List<String> aIds = new List<String>();
        //             aIds.add(act.Id);
        //             System.debug('idddddddddddd=============' + act.Id);
        //             subAccListBeen(aIds);
        //             System.debug('finalAccList=============' + finalAccList);
        //             if (finalAccList.size()>0) {
        //                 for(Account subAcc : finalAccList){
        //                     Account upAcc = new Account();
        //                     upAcc.Id = subAcc.Id;
        //                     upAcc.Shortname__c = subAcc.Parent.Shortname__c;
        //                     upAccList.add(upAcc);
        //                 }
        //             }
        //         }
        //         List<String> li = new List<String>();
        //         for (Account aa : upAccList) {
        //             li.add(aa.Name);
        //         }
        //         System.debug('>>>>>>>>>>>>>>>'+upAccList);
        //         update upAccList;
        //     }
        // }

        /*
        * @Descripttion: 商机客户简称自动赋值--After
        * @Author: Hogan
        * @Date: ###### Fri Sep 22 15:26:22 CST 2023
        */
        if (Trigger.isAfter && Trigger.isInsert) {
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account acc = [select id, toLabel(TopGroup__c),Parent.Shortname__c from Account where id =: newAcc.Id];
                Account upAcc = new Account();
                if(newAcc.TopGroup__c != 'TG901' && newAcc.BeenGroup__c == true && newAcc.ParentId == null){ //【独立集团简称】=“真”，且【上一级公司】为空，使【商机客户简称】只读,且自动赋值=【一级集团】
                    upAcc.Id = acc.Id;
                    upAcc.Shortname__c = acc.TopGroup__c;
                    update upAcc;
                }else if(newAcc.TopGroup__c != 'TG901' &&newAcc.BeenGroup__c == false){ //【独立集团简称】=“假”，使【商机客户简称】只读,且自动赋值={【上一级公司】}.【商机客户简称】
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
                if (newAcc.TopGroup__c != oldAcc.TopGroup__c || newAcc.BeenGroup__c != oldAcc.BeenGroup__c || newAcc.ParentId != oldAcc.ParentId) { //一级集团或独立集团简称或上一级公司发生变更
                    System.debug('88888888888888888' + newAcc.Name + '----' + newAcc.TopGroup__c + '-----' + oldAcc.TopGroup__c);
                    Account acc = [select id, toLabel(TopGroup__c),Parent.Shortname__c from Account where id =: newAcc.Id];
                    Account upAcc = new Account();
                    if(newAcc.TopGroup__c != 'TG901' && newAcc.BeenGroup__c == true && newAcc.ParentId == null){ //【独立集团简称】=“真”，且【上一级公司】为空，使【商机客户简称】只读,且自动赋值=【一级集团】
                        upAcc.Id = acc.Id;
                        upAcc.Shortname__c = acc.TopGroup__c;
                        update upAcc;
                    }else if(newAcc.TopGroup__c != 'TG901' && newAcc.BeenGroup__c == false){ //【独立集团简称】=“假”，使【商机客户简称】只读,且自动赋值={【上一级公司】}.【商机客户简称】
                        upAcc.Id = acc.Id;
                        upAcc.Shortname__c = acc.Parent.Shortname__c;
                        update upAcc;
                    }
                }
            }
        }

        /*
        * @Descripttion: 【一级集团】≠“其他”，且【商机客户简称】发生变更。对其【独立集团简称】=“假”的下级客户（多级）进行【商机客户简称】的继承赋值。
        * @Author: Hogan
        * @Date: ###### Wed Oct 25 16:57:48 CST 2023
        */
        if (Trigger.isAfter && Trigger.isUpdate) {
            List<Account> tempList = new List<Account>();
            for(Account newAcc : (List<Account>)Trigger.new) {
                Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);

                if (newAcc.TopGroup__c != 'TG901' && newAcc.Shortname__c != oldAcc.Shortname__c) { 
                    tempList.add(newAcc);
                }
            }
           
            if(tempList.size() > 0){
                List<Account> upAccList = new List<Account>();
                for(Account act : tempList){
                    subFun(act.Id);
                }
            }
        }
    }

    public static void subFun(String aid){
        List<Account> upAccList = new List<Account>();
        List<String> aIds = new List<String>();
        aIds.add(aid);
        finalAccList = new List<Account>();
        subAccListBeen(aIds);
        if (finalAccList.size()>0) {
            System.debug('upAccList=============start' + upAccList + '====aid' + aid);
            for(Account subAcc : finalAccList){
                Account upAcc = new Account();
                upAcc.Id = subAcc.Id;
                upAcc.Shortname__c = subAcc.Parent.Shortname__c;
                upAccList.add(upAcc);
            }
        }
        if (upAccList.size()!=0) {
            System.debug('upAccList=============end' + upAccList);
            update upAccList;       
        }
    }

    //查找下级客户
    public static Integer i = 1;
    public static void subAccList(List<String> ids){
        List<String> accIds = new List<String>();
        List<Account> listAcc = [select Id from Account where ParentId IN: ids];
        if(listAcc.size() != 0){
            List<String> strs = new List<String>();
            for (Account temp : listAcc) {
                strs.add(temp.Id);
                accMap.put(i, temp.Id);
                i++;
            }
            // subAccList(strs);
        }
    }

    // 查找独立集团简称为false的下级客户
    private static void subAccListBeen(List<String> ids) {
        List<Account> accs = [SELECT Id, Parent.Shortname__c FROM Account where ParentId IN: ids and BeenGroup__c = false];
        if (accs.size() != 0) {
            List<String> strs = new List<String>();
            for (Account temp : accs) {
                strs.add(temp.Id);
            }
            finalAccList.addAll(accs);
            // subAccListBeen(strs);
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