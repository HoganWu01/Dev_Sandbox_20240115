/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-23 18:34:20
 * @Descripttion: 营销合同补充协议审批单
 */
trigger ContractSupplementTrigger on ContractSupplement__c(before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
    	.bind(Triggers.Evt.afterupdate, new ContractSupplementTriggerHandler.SendNotifyToOwner())
    	.execute();
	ContractSupplementTriggerHandler conHandler = new ContractSupplementTriggerHandler();
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			List<ContractSupplement__c> conInsertList = new List<ContractSupplement__c>();
			for (ContractSupplement__c con : (List<ContractSupplement__c>)Trigger.new) {
				//战区不为空，区域代表为空或者分管副总裁为空
				if (con.Country__c=='国内项目' && con.Salesdepartment__c!=null && (con.Regional_Vice_President__c==null||con.Chief_Representative__c==null)) {
					conInsertList.add(con);
				}
			}
			if (conInsertList.size()>0) {
				conHandler.autoSetValueTrigger(conInsertList);
			}
		}
		if (Trigger.isUpdate) {
			List<ContractSupplement__c> conUpdateList = new List<ContractSupplement__c>();
			List<ContractSupplement__c> schemeUpdateList = new List<ContractSupplement__c>();
			List<ContractSupplement__c> schemeUpdate11List = new List<ContractSupplement__c>();
			for (ContractSupplement__c con : (List<ContractSupplement__c>)Trigger.new) {
				ContractSupplement__c old = (ContractSupplement__c) Trigger.oldMap.get(con.Id);
				//战区不为空，区域代表为空或者分管副总裁为空
				if (con.Country__c=='国内项目' && con.Salesdepartment__c!=null && (con.Regional_Vice_President__c==null||con.Chief_Representative__c==null)) {
					conUpdateList.add(con);
				}
				//审批状态修改并且审批状态为审批中
				if (con.Approvalstatus__c!=old.Approvalstatus__c&& (con.Approvalstatus__c=='20' || con.Approvalstatus__c=='30')) {
					schemeUpdateList.add(con);
				}
				//审批状态修改并且审批状态为已驳回
				if (con.Approvalstatus__c!=old.Approvalstatus__c&& (con.Approvalstatus__c=='11'||con.Approvalstatus__c=='10')) {
					schemeUpdate11List.add(con);
				}
			}
			if (conUpdateList.size()>0) {
				conHandler.autoSetValueTrigger(conUpdateList);
			}
			if (schemeUpdateList.size()>0) {
				conHandler.autoLockTrigger(schemeUpdateList);
			}
			if (schemeUpdate11List.size()>0) {
				conHandler.autoUnLockTrigger(schemeUpdate11List);
			}
		}
	}
	ShareCommonTriggerHandler sha = new ShareCommonTriggerHandler();
    if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			List<SObject> objList = new List<SObject>();
			for (SObject obj : Trigger.new) {
				objList.add(obj);
			}
			sha.sharePermissionToParent(objList);
		}
    }
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<ContractSupplement__c> conUpdateList = new List<ContractSupplement__c>();
			for (ContractSupplement__c con : (List<ContractSupplement__c>)Trigger.new) {
				ContractSupplement__c conOld = (ContractSupplement__c)Trigger.oldMap.get(con.Id);
				if ((con.Seal_Org__c != conOld.Seal_Org__c || con.Seal_Safekeep_Dept__c != conOld.Seal_Safekeep_Dept__c)&&String.isNotBlank(con.Seal_Org__c)&&String.isNotBlank(con.Seal_Safekeep_Dept__c)) {
					conUpdateList.add(con);
				}
			}
			if (conUpdateList.size()>0){
				conHandler.deleteAndUpdateChildTrigger(conUpdateList);
			}
		}
	}
}