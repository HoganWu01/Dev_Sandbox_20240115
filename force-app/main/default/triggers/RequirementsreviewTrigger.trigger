/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-20 16:38:22
 * @Descripttion: 业主需求评审单触发器
 */
trigger RequirementsreviewTrigger on Requirementsreview__c(before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
    	.bind(Triggers.Evt.afterupdate, new RequirementsreviewTriggerHandler.SendNotifyToOwner())
    	.execute();
	RequirementsreviewTriggerHandler proHandler = new RequirementsreviewTriggerHandler();
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<Requirementsreview__c> schemeUpdateList = new List<Requirementsreview__c>();
			List<Requirementsreview__c> schemeUpdate11List = new List<Requirementsreview__c>();
			for (Requirementsreview__c scheme : (List<Requirementsreview__c>)Trigger.new) {
				Requirementsreview__c old = (Requirementsreview__c) Trigger.oldMap.get(scheme.Id);
				//审批状态修改并且审批状态为审批中
				if (scheme.Approvalstatus__c!=old.Approvalstatus__c&& (scheme.Approvalstatus__c=='20' || scheme.Approvalstatus__c=='30')) {
					schemeUpdateList.add(scheme);
				}
				//审批状态修改并且审批状态为已驳回
				if (scheme.Approvalstatus__c!=old.Approvalstatus__c&& (scheme.Approvalstatus__c=='11'||scheme.Approvalstatus__c=='10')) {
					schemeUpdate11List.add(scheme);
				}
			}
			if (schemeUpdateList.size()>0) {
				proHandler.autoLockTrigger(schemeUpdateList);
			}
			if (schemeUpdate11List.size()>0) {
				proHandler.autoUnLockTrigger(schemeUpdate11List);
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
}