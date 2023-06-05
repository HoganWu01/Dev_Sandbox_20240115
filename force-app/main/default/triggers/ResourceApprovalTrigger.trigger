/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-23 18:38:01
 * @Descripttion: 资源开发协议资源审批单
 */
trigger ResourceApprovalTrigger on ResourceApproval__c(before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
    	.bind(Triggers.Evt.afterupdate, new ResourceApprovalTriggerHandler.SendNotifyToOwner())
    	.execute();
		ResourceApprovalTriggerHandler proHandler = new ResourceApprovalTriggerHandler();
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<ResourceApproval__c> schemeUpdateList = new List<ResourceApproval__c>();
			List<ResourceApproval__c> schemeUpdate11List = new List<ResourceApproval__c>();
			for (ResourceApproval__c scheme : (List<ResourceApproval__c>)Trigger.new) {
				ResourceApproval__c old = (ResourceApproval__c) Trigger.oldMap.get(scheme.Id);
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
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<ResourceApproval__c> conUpdateList = new List<ResourceApproval__c>();
			for (ResourceApproval__c con : (List<ResourceApproval__c>)Trigger.new) {
				ResourceApproval__c conOld = (ResourceApproval__c)Trigger.oldMap.get(con.Id);
				if ((con.Seal_Org__c != conOld.Seal_Org__c || con.Seal_Safekeep_Dept__c != conOld.Seal_Safekeep_Dept__c)&&String.isNotBlank(con.Seal_Org__c)&&String.isNotBlank(con.Seal_Safekeep_Dept__c)) {
					conUpdateList.add(con);
				}
			}
			if (conUpdateList.size()>0){
				proHandler.deleteAndUpdateChildTrigger(conUpdateList);
			}
		}
	}
}