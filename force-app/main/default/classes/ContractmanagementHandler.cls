/*
 * @Author: irving
 * @Date: 2021-10-12 17:16:12
 * @LastEditTime: 2021-11-04 15:46:46
 * @LastEditors: Please set LastEditors
 * @Description: 1.复写合同商务字段到商机对应的字段 2.共享合同给大区总经理/大客户总经理/售前项目经理/商机所有人
 */
global without sharing class ContractmanagementHandler implements Triggers.Handler {
   
    public void handle() {

        List<String> contractIds = new List<String>();

        //取消商机只能一个合同商务限制 2022-11-23 by hogan
        // if(Trigger.isBefore && Trigger.isInsert) {
        //     for(Contractmanagement__c management : (List<Contractmanagement__c>)Trigger.new) {
        //         //一个商机只能有一条项目立项记录
        //         if (management.ObjectName__c != null) {
        //             Integer records = [SELECT count() FROM Contractmanagement__c WHERE ObjectName__c =: management.ObjectName__c];
        //             if (records > 0 &&!System.Test.isRunningTest()) {
        //                 management.addError('【商机】只能生成一条【合同商务】!');
        //             }
        //         }
        //     }
        // }

        if (Trigger.isAfter && Trigger.isInsert) {
           System.debug('新增触发器进来了');
            for(Contractmanagement__c Contract : (List<Contractmanagement__c>)Trigger.new) {

               //初版合同编制完成日期
               if(Contract.Firstcontractcompletion__c!=null){
                    contractIds.add(Contract.Id);
                }
                //合同阶段
                if(Contract.Contractstage__c!=null){
                    contractIds.add(Contract.Id);
                }

                //谈判策划会开始日期
                if(Contract.MeetingStartDate__c!=null){
                    contractIds.add(Contract.Id);
                }
               
                
                 //合同签订完成日期
                 if(Contract.ContractSigningEndDate__c!=null){
                    contractIds.add(Contract.Id);
                }

                //合同谈判开始时间
                if(Contract.ContractNegotiationStartDate__c!=null){
                    contractIds.add(Contract.Id);
                }
               
            }
        }

        //合同新建后共享给相关人查看
        // if(Trigger.isAfter && Trigger.isInsert){
        //     List<Contractmanagement__Share> listShare = new List<Contractmanagement__Share>();
        //     for(Contractmanagement__c con : (List<Contractmanagement__c>)Trigger.new) {
        //         //分配给商机所有人
        //         Contractmanagement__Share conShare = new Contractmanagement__Share();
        //         conShare.ParentId = con.Id;
        //         conShare.UserOrGroupId = con.ObjectName__r.OwnerId;
        //         conShare.AccessLevel = 'Read';

        //         // //分配给商机大区总经理
        //         // Contractmanagement__Share conShare1 = new Contractmanagement__Share();
        //         // conShare1.ParentId = con.Id;
        //         // conShare1.UserOrGroupId = con.ObjectName__r.Chiefgeneralmanager__r.Id;
        //         // conShare1.AccessLevel = 'read';

        //         // //分配给商机大客户总经理
        //         // Contractmanagement__Share conShare2 = new Contractmanagement__Share();
        //         // conShare2.ParentId = con.Id;
        //         // conShare2.UserOrGroupId = con.ObjectName__r.Key_Account_General_Manager__r.Id;
        //         // conShare2.AccessLevel = 'read';

        //         // //分配给商机售前项目经理
        //         // Contractmanagement__Share conShare3 = new Contractmanagement__Share();
        //         // conShare3.ParentId = con.Id;
        //         // conShare3.UserOrGroupId = con.ObjectName__r.Pre_Sales_Project_Manager__r.Id;
        //         // conShare3.AccessLevel = 'read';

        //         listShare.add(conShare);
        //         // listShare.add(conShare1);
        //         // listShare.add(conShare2);
        //         // listShare.add(conShare3);
        //     }
        //     System.debug('listShare--------'+listShare);
        //     Database.insert(listShare,true);
        // }

        if (Trigger.isAfter && Trigger.isUpdate) {

            System.debug('更新日期的触发器进来了');
            for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
                Contractmanagement__c oldContract = (Contractmanagement__c)Trigger.oldMap.get(newContract.Id);
                
                 //初版合同编制完成日期
                 if(newContract.Firstcontractcompletion__c!=oldContract.Firstcontractcompletion__c){
                    contractIds.add(newContract.Id);
                }

                 //合同阶段
                 if(newContract.Contractstage__c!=oldContract.Contractstage__c){
                    contractIds.add(newContract.Id);
                }

                //谈判策划会开始日期
                if(newContract.MeetingStartDate__c!=oldContract.MeetingStartDate__c){
                    contractIds.add(newContract.Id);
                }
               
                
                 //合同签订完成日期
                 if(newContract.ContractSigningEndDate__c!=oldContract.ContractSigningEndDate__c){
                    contractIds.add(newContract.Id);
                }

                //合同谈判开始时间
                if(newContract.ContractNegotiationStartDate__c!=oldContract.ContractNegotiationStartDate__c){
                    System.debug('合同谈判开始时间的条件进来了');
                    contractIds.add(newContract.Id);
                }


            }
        }

        if(contractIds.size()>0){
            excute(contractIds);
        }
    }

    public void excute(List<String> contractIds) {

        List<Contractmanagement__c> ContractList = [SELECT ID,
                                                            ObjectName__c,
                                                            StartTime__c,
                                                            Firstcontractcompletion__c,
                                                            Contractstage__c,
                                                            MeetingStartDate__c,
                                                            ContractSigningEndDate__c,
                                                            ContractNegotiationStartDate__c  //合同谈判开始
                                                            FROM Contractmanagement__c
                                                            WHERE ID IN :contractIds];

        System.debug('合同谈判开始时间为'+ContractList[0].ContractNegotiationStartDate__c);

        List<String> oppIds = new List<String>();

        // 商机id 合同id
        Map<String,String> OppContractMap = new Map<String,String>();

        Map<String,Date> ContractCompletionMap = new Map<String,Date>();
        Map<String,String> ContractstageMap = new Map<String,String>();
        Map<String,Date> MeetingStartDateMap = new Map<String,Date>();
        Map<String,Date> ContractEndDateMap = new Map<String,Date>();
        Map<String,Date> ContractNegotiationStartDateMap = new Map<String,Date>();

        for (Contractmanagement__c contract : ContractList) {
            oppIds.add(contract.ObjectName__c);

            OppContractMap.put(contract.ObjectName__c, contract.Id);

            ContractCompletionMap.put(contract.Id, contract.Firstcontractcompletion__c);
            ContractstageMap.put(contract.Id, contract.Contractstage__c);
            MeetingStartDateMap.put(contract.Id, contract.MeetingStartDate__c);
            ContractEndDateMap.put(contract.Id, contract.ContractSigningEndDate__c);
            ContractNegotiationStartDateMap.put(contract.Id, contract.ContractNegotiationStartDate__c);
        }

        

        List<Opportunity> oppList = [SELECT ID,Name,
                                            Completiontime__c,
                                            Contractstage__c,
                                            Startdate__c,
                                            Contractsigning__c,
                                            ContractDate__c,   //合同谈判
                                            StageName 
                                            FROM Opportunity WHERE ID IN :oppIds];

        

        List<Opportunity> updateOpp = new List<Opportunity>();

        for (Opportunity opp : oppList) {
           
            opp.Completiontime__c = ContractCompletionMap.get(OppContractMap.get(opp.Id));
           
            opp.Contractstage__c =  ContractstageMap.get(OppContractMap.get(opp.Id));
            
            opp.Startdate__c =  MeetingStartDateMap.get(OppContractMap.get(opp.Id));
            
            opp.Contractsigning__c =  ContractEndDateMap.get(OppContractMap.get(opp.Id));

            opp.ContractDate__c = ContractNegotiationStartDateMap.get(OppContractMap.get(opp.Id));
            
            updateOpp.add(opp);
        }

        update updateOpp;
    }
}