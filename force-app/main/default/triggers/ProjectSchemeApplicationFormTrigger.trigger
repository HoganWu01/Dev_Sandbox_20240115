/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-20 16:34:04
 * @Descripttion: 营销项目方案申请单触发器
 */
trigger ProjectSchemeApplicationFormTrigger on Project_Scheme_Application_Form__c(before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
    	.bind(Triggers.Evt.afterupdate, new ProjectSchemeApplicationFormHandler.SendNotifyToOwner())
    	.execute();
	ProjectSchemeApplicationFormHandler proHandler = new ProjectSchemeApplicationFormHandler();
	if (Trigger.isBefore) {
		// if (Trigger.isInsert) {
		// 	List<Project_Scheme_Application_Form__c> schemeInsertList = new List<Project_Scheme_Application_Form__c>();
		// 	for (Project_Scheme_Application_Form__c scheme : (List<Project_Scheme_Application_Form__c>)Trigger.new) {
		// 		//项目所属战区不为空，风能设计院组长为空
		// 		if (scheme.ProjectTheater__c!=null && scheme.Wind_Energy_Design__c==null) {
		// 			schemeInsertList.add(scheme);
		// 		}
		// 	}
		// 	if (schemeInsertList.size()>0) {
		// 		proHandler.autoSetValueTrigger(schemeInsertList);
		// 	}
		// }
		if (Trigger.isUpdate) {
			List<Project_Scheme_Application_Form__c> schemeUpdateList = new List<Project_Scheme_Application_Form__c>();
			for (Project_Scheme_Application_Form__c scheme : (List<Project_Scheme_Application_Form__c>)Trigger.new) {
				//项目所属战区不为空，风能设计院组长为空
				if (scheme.ProjectTheater__c!=null && scheme.Wind_Energy_Design__c==null) {
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
			List<Project_Scheme_Application_Form__c> schemeUpdateList = new List<Project_Scheme_Application_Form__c>();
			List<Project_Scheme_Application_Form__c> schemeUpdate11List = new List<Project_Scheme_Application_Form__c>();
			for (Project_Scheme_Application_Form__c scheme : (List<Project_Scheme_Application_Form__c>)Trigger.new) {
				Project_Scheme_Application_Form__c old = (Project_Scheme_Application_Form__c) Trigger.oldMap.get(scheme.Id);
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