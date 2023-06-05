/*
 * @Author: irving
 * @Date: 2021-09-27 16:13:00
 * @LastEditTime: 2022-01-24 11:06:54
 * @LastEditors: Please set LastEditors
 * @Description: 手动创合同商务，项目编号为空，触发SAP标段项目创建接口
 */
global without sharing class ProjectCreateHandler implements Triggers.Handler {

    public void handle(){

        if (Trigger.isBefore && Trigger.isInsert) {

            for(Contractmanagement__c contract : (List<Contractmanagement__c>)Trigger.new) {
                if (contract.ObjectName__c != null) {
                    Opportunity opp = [select StageName from Opportunity where id =: contract.ObjectName__c];
                    if ( 
                        opp.StageName != '招投标' 
                        && opp.StageName != '中标/赢单' 
                        && opp.StageName != '合同商务' 
                        && opp.StageName != 'Closed Won') {
                            contract.addError('商机进入“招投标”后才能新建标段合同！');
                        }
                }else {
                    contract.addError('请选择商机！');
                }
            }
        }

        if (Trigger.isAfter && Trigger.isInsert) {

            for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
                //项目编号为空，新建SAP标段项目
                if (String.isBlank(newContract.WBS__c) || String.isEmpty(newContract.WBS__c)) {
                    Controller_SAP4Project.SAP4SectionProjectAdd(newContract.ObjectName__c, newContract.Id);
                }

            }
        }

        //合同商务项目名称更新，同时更新SAP项目名称
        if (Trigger.isAfter && Trigger.isUpdate) {

            for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
                Contractmanagement__c oldContract = (Contractmanagement__c)Trigger.oldMap.get(newContract.Id);
                if(newContract.Objectname2__c != oldContract.Objectname2__c && String.isNotBlank(newContract.WBS__c)){
                    //更新SAP项目名称
                    Controller_SAP4Project.SAP4ProjectNameUpdate(newContract.Objectname2__c, newContract.WBS__c, newContract.OpportunityName__c);
                }
            }
        }

        //合同商务相关字段更新，同时更新到项目对象
        if (Trigger.isAfter && Trigger.isUpdate) {

            //--------需要处理  2022-12-13

            // for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
            //     Contractmanagement__c oldContract = (Contractmanagement__c)Trigger.oldMap.get(newContract.Id);
            //     if(newContract.Objectname2__c != oldContract.Objectname2__c && String.isNotBlank(WBS__c)){
            //         //更新SAP项目名称
            //         Controller_SAP4Project.SAP4ProjectNameUpdate(newContract.Objectname2__c, newContract.WBS__c);
            //     }
            // }
        }
        
    }
}