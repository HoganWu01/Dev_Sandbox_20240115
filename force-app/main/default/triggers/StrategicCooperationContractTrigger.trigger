/*
 * @Author: Hogan
 * @Date: 2022-07-23 17:20:00
 * @LastEditors: Hogan
 * @LastEditTime: 2022-07-23 17:20:00
 * @Descripttion: 战略合作协议Trigger类
 */
trigger StrategicCooperationContractTrigger on StrategicCooperationContract__c (before insert, before update, before delete, after insert, after update, after delete ) {
    new Triggers()
    	.bind(Triggers.Evt.afterupdate, new StrategicTriggerHandler.SendNotifyToOwner())
    	.execute();
		StrategicTriggerHandler proHandler = new StrategicTriggerHandler();
    // 锁定或解锁记录
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<StrategicCooperationContract__c> schemeUpdateList = new List<StrategicCooperationContract__c>();
			List<StrategicCooperationContract__c> schemeUpdate11List = new List<StrategicCooperationContract__c>();
			for (StrategicCooperationContract__c scheme : (List<StrategicCooperationContract__c>)Trigger.new) {
				StrategicCooperationContract__c old = (StrategicCooperationContract__c) Trigger.oldMap.get(scheme.Id);
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
			List<StrategicCooperationContract__c> conUpdateList = new List<StrategicCooperationContract__c>();
			for (StrategicCooperationContract__c con : (List<StrategicCooperationContract__c>)Trigger.new) {
				StrategicCooperationContract__c conOld = (StrategicCooperationContract__c)Trigger.oldMap.get(con.Id);
				if ((con.Seal_Org__c != conOld.Seal_Org__c || con.Seal_Safekeep_Dept__c != conOld.Seal_Safekeep_Dept__c)&&String.isNotBlank(con.Seal_Org__c)&&String.isNotBlank(con.Seal_Safekeep_Dept__c)) {
					conUpdateList.add(con);
				}
			}
			if (conUpdateList.size()>0){
				proHandler.deleteChildTrigger(conUpdateList);
			}
		}
	}
}