/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-02 15:31:59
 * @Descripttion: 资源立项申请单触发器
 */
trigger ResourceProjectApplicationTrigger on ResourceProjectApplication__c(before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
    	.bind(Triggers.Evt.afterupdate, new ResourceProjectApplicationTriggerHandler.SendNotifyToOwner())
    	.bind(Triggers.Evt.beforeinsert, new ResourceProjectApplicationTriggerHandler.CheackRecords())
    	.execute();
	ResourceProjectApplicationTriggerHandler proHandler = new ResourceProjectApplicationTriggerHandler();
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<ResourceProjectApplication__c> schemeUpdateList = new List<ResourceProjectApplication__c>();
			List<ResourceProjectApplication__c> schemeUpdate11List = new List<ResourceProjectApplication__c>();
			for (ResourceProjectApplication__c scheme : (List<ResourceProjectApplication__c>)Trigger.new) {
				ResourceProjectApplication__c old = (ResourceProjectApplication__c) Trigger.oldMap.get(scheme.Id);
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
}