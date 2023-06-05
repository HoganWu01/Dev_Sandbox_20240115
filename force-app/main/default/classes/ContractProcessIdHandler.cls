/*
 * @Author: zxg
 * @Date: 2021-11-12 17:30:00
 * @LastEditTime: 2022-11-12 17:30:00
 * @LastEditors: Please set LastEditors
 * @Description: 更新合同商务-会签审批流程ID
 */
public without sharing class ContractProcessIdHandler implements Triggers.Handler{
    public void handle() {

        //修改关联OA历史合同流程
        List<String> contractOAIds = new List<String>();

        if (Trigger.isAfter && Trigger.isUpdate) {

            System.debug('更新触发器进来了');
            for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
                Contractmanagement__c oldContract = (Contractmanagement__c)Trigger.oldMap.get(newContract.Id);
                
                //合同商务关联OA历史合同流程不为空，更新会签审批流程ID
                if (newContract.OAProcessTheme__c!=null &&newContract.OAProcessTheme__c!=oldContract.OAProcessTheme__c) {
                    System.debug('进入准备修改会签审批流程ID');
                    contractOAIds.add(newContract.Id);
                }
            }
        }

        if(contractOAIds.size()>0){
            excute(contractOAIds);
        }

    }

    public void excute(List<String> contractIds) {
        List<Contractmanagement__c> ContractList = [SELECT ID,
                                                    OAProcessTheme__c,   //查找（OA历史流程）
                                                    Process_Id__c FROM Contractmanagement__c WHERE ID IN :contractIds];

        List<Contractmanagement__c> updateContract  = new List<Contractmanagement__c>();
        
        for (Contractmanagement__c con : ContractList) {
            List<ContractSignProcesss__c> cspList=[SELECT Id,Process_Id__c from ContractSignProcesss__c where Id=:con.OAProcessTheme__c];
            if(cspList.size()>0){
                //更新合同商务的会签流程Id
                con.Process_Id__c = cspList.get(0).Process_Id__c;
                updateContract.add(con);
            }    
        }
        //更新合同商务
        update updateContract ; 
    }


}