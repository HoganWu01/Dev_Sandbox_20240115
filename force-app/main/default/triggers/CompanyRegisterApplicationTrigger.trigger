/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-02 15:32:35
 * @Descripttion: 子公司投资与注册触发器
 */
trigger CompanyRegisterApplicationTrigger on CompanyRegisterApplication__c(before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
    	.bind(Triggers.Evt.afterupdate, new CompanyRegisterApplicationHandler.SendNotifyToOwner())
    	.execute();
	CompanyRegisterApplicationHandler proHandler = new CompanyRegisterApplicationHandler();
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<CompanyRegisterApplication__c> schemeUpdateList = new List<CompanyRegisterApplication__c>();
			List<CompanyRegisterApplication__c> schemeUpdate11List = new List<CompanyRegisterApplication__c>();
			for (CompanyRegisterApplication__c scheme : (List<CompanyRegisterApplication__c>)Trigger.new) {
				CompanyRegisterApplication__c old = (CompanyRegisterApplication__c) Trigger.oldMap.get(scheme.Id);
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