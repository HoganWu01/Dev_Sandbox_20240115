public with sharing class SealRelatedInformationTriggerHandler {
    public void autoSetValueTrigger(List<Seal_Related_Information__c> objList){
        //印章相关信息新增时，自动携带营销合同补充协议/资源开发协议的值
        List<Id> contractIdList = new List<Id>();
        Map<Id,ContractSupplement__c> conMap = new Map<Id,ContractSupplement__c>();
        Map<Id,ResourceApproval__c> resMap = new Map<Id,ResourceApproval__c>();
        List<Id> resIdList = new List<Id>();
        for (Seal_Related_Information__c obj : objList) {
            if (obj.Marketing_Contract__c != null) {
                contractIdList.add(obj.Marketing_Contract__c);
            }else {
                resIdList.add(obj.Resource_Development_Agreement__c);
            }
        }
        if (contractIdList.size()>0) {
            for (ContractSupplement__c con : [SELECT Id,Seal_Org__c,Seal_Safekeep_Dept__c,(SELECT id FROM Marketing_Contract_Seal_App__r) FROM ContractSupplement__c WHERE Id IN: contractIdList]) {
                conMap.put(con.Id, con);
            }
        }
        if (resIdList.size()>0) {
            for (ResourceApproval__c res : [SELECT Id,Seal_Org__c,Seal_Safekeep_Dept__c,(SELECT id FROM Resource_Seal__r) FROM ResourceApproval__c WHERE Id IN: resIdList]) {
                resMap.put(res.Id, res);
            }
        }
        for (Seal_Related_Information__c obj : objList) {
            if (obj.Marketing_Contract__c != null) {
                // //管理单位
                // obj.Seal_Org__c = conMap.get(obj.Marketing_Contract__c).Seal_Org__c;
                // //印章保管部门
                // obj.Seal_Safekeep_Dept__c = conMap.get(obj.Marketing_Contract__c).Seal_Safekeep_Dept__c;
                if (conMap.get(obj.Marketing_Contract__c)?.Marketing_Contract_Seal_App__r!=null&&conMap.get(obj.Marketing_Contract__c).Marketing_Contract_Seal_App__r.size()>0) {
                    obj.Seal_Approval__c = conMap.get(obj.Marketing_Contract__c).Marketing_Contract_Seal_App__r[0].Id;
                }
                
            }else {
                // obj.Seal_Org__c = resMap.get(obj.Resource_Development_Agreement__c).Seal_Org__c;
                // obj.Seal_Safekeep_Dept__c = resMap.get(obj.Resource_Development_Agreement__c).Seal_Safekeep_Dept__c;
                if (resMap.get(obj.Resource_Development_Agreement__c)?.Resource_Seal__r!=null&&resMap.get(obj.Resource_Development_Agreement__c).Resource_Seal__r.size()>0) {
                    obj.Seal_Approval__c = resMap.get(obj.Resource_Development_Agreement__c).Resource_Seal__r[0].Id;
                }
            }
        }
    }
}