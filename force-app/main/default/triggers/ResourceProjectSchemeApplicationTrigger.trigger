/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-02 15:31:34
 * @Descripttion: 资源项目方案申请单
 */
trigger ResourceProjectSchemeApplicationTrigger on Resource_Project_Scheme_Application__c(before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
    	.bind(Triggers.Evt.afterupdate, new ResourceProjectSchemeApplicationHandler.SendNotifyToOwner())
    	.execute();
	ResourceProjectSchemeApplicationHandler proHandler = new ResourceProjectSchemeApplicationHandler();
	if (Trigger.isBefore) {
		// if (Trigger.isInsert) {
		// 	List<Resource_Project_Scheme_Application__c> schemeInsertList = new List<Resource_Project_Scheme_Application__c>();
		// 	for (Resource_Project_Scheme_Application__c scheme : (List<Resource_Project_Scheme_Application__c>)Trigger.new) {
		// 		//项目所属战区不为空，风能设计院组长为空
		// 		if (scheme.ProjectArea__c!=null && scheme.Wind_Energy_Design__c==null) {
		// 			schemeInsertList.add(scheme);
		// 		}
		// 	}
		// 	if (schemeInsertList.size()>0) {
		// 		proHandler.autoSetValueTrigger(schemeInsertList);
		// 	}
		// }
		if (Trigger.isUpdate) {
			List<Resource_Project_Scheme_Application__c> schemeUpdateList = new List<Resource_Project_Scheme_Application__c>();
			for (Resource_Project_Scheme_Application__c scheme : (List<Resource_Project_Scheme_Application__c>)Trigger.new) {
				//项目所属战区不为空，风能设计院组长为空
				if (scheme.ProjectArea__c!=null && scheme.Wind_Energy_Design__c==null) {
					schemeUpdateList.add(scheme);
				}
			}
			if (schemeUpdateList.size()>0) {
				proHandler.autoSetValueTrigger(schemeUpdateList);
			}
		}
	}
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<Resource_Project_Scheme_Application__c> schemeUpdateList = new List<Resource_Project_Scheme_Application__c>();
			List<Resource_Project_Scheme_Application__c> schemeUpdate11List = new List<Resource_Project_Scheme_Application__c>();
			for (Resource_Project_Scheme_Application__c scheme : (List<Resource_Project_Scheme_Application__c>)Trigger.new) {
				Resource_Project_Scheme_Application__c old = (Resource_Project_Scheme_Application__c) Trigger.oldMap.get(scheme.Id);
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