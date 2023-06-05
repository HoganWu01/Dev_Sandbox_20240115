trigger SealApprovalTrigger on Seal_Approval__c(before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
        .bind(Triggers.Evt.afterupdate, new SealApprovalTriggerHandler.SendNotifyToOwner())
        .bind(Triggers.Evt.afterInsert, new SealApprovalTriggerHandler.AssignToRelaInfo())
        .execute();
        SealApprovalTriggerHandler proHandler = new SealApprovalTriggerHandler();
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            List<Seal_Approval__c> schemeUpdateList = new List<Seal_Approval__c>();
            List<Seal_Approval__c> sealUpdateUnlockList = new List<Seal_Approval__c>();
            List<Seal_Approval__c> schemeUpdate11List = new List<Seal_Approval__c>();
            List<Seal_Approval__c> deleteSealList = new List<Seal_Approval__c>();
            for (Seal_Approval__c scheme : (List<Seal_Approval__c>)Trigger.new) {
                Seal_Approval__c old = (Seal_Approval__c) Trigger.oldMap.get(scheme.Id);
                if (scheme.Approvalstatus__c == '10' && scheme.Process_Id__c != null && old.Process_Id__c == null) {
                    sealUpdateUnlockList.add(scheme);
                }
                //审批状态修改并且审批状态为审批中
                if (scheme.Approvalstatus__c!=old.Approvalstatus__c&& (scheme.Approvalstatus__c=='20' || scheme.Approvalstatus__c=='30')) {
                    schemeUpdateList.add(scheme);
                }
                //审批状态修改并且审批状态为已驳回
                if (scheme.Approvalstatus__c!=old.Approvalstatus__c&& (scheme.Approvalstatus__c=='11'||scheme.Approvalstatus__c=='10')) {
                    schemeUpdate11List.add(scheme);
                }
                //印章审批的控制字段修改时,同时流程Id不能为空，删除印章相关信息
                if ((scheme.Seal_Org__c != old.Seal_Org__c || scheme.SealKeep__c != old.SealKeep__c)&&String.isNotBlank(scheme.Seal_Org__c)&&String.isNotBlank(scheme.SealKeep__c)&&String.isNotBlank(scheme.Process_Id__c)) {
					deleteSealList.add(scheme);
				}
            }
            if (sealUpdateUnlockList.size()>0) {
                proHandler.autoUnLockRelateTrigger(sealUpdateUnlockList);
            }
            if (schemeUpdateList.size()>0) {
                proHandler.autoLockTrigger(schemeUpdateList);
            }
            if (schemeUpdate11List.size()>0) {
                proHandler.autoUnLockTrigger(schemeUpdate11List);
            }
            if (deleteSealList.size()>0) {
                proHandler.deleteAndUpdateChildTrigger(deleteSealList);
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