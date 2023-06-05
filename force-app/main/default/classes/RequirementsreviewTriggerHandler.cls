/*
 * @Descripttion: 业主需求评审单触发器handler
 * @Author: Keiran
 * @Date: 2021-10-19 11:08:00
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-02 14:30:00
 */
public without sharing class RequirementsreviewTriggerHandler {
      /**
	*当装态更改为已驳回（11）时，小铃铛通知对象数据所有人，该申请单需要调整并重新提交
	*/
    public class SendNotifyToOwner implements Triggers.Handler{
    	public void handle() {
    		System.debug('进来了触发器');
    		String subjectTitle = '申请单驳回通知';
    		String body = '申请单需要调整并重新提交';
    		if(Trigger.isAfter && Trigger.isUpdate) {
    			Map<Id, Requirementsreview__c> csMap = (Map<Id, Requirementsreview__c>)Trigger.newMap;
    			List<Requirementsreview__c> csList = Trigger.old;
    			for (String csId : csMap.keySet()) {
    				for (Requirementsreview__c cs : csList) {
    					if (csId == cs.Id) {
    						if (cs.Approvalstatus__c != csMap.get(csId).Approvalstatus__c
    						 && csMap.get(csId).Approvalstatus__c == '11' ) {
    						 	Set<String> rpuser = new Set<String>();
    							rpuser.add(cs.OwnerId);
    							Utils.notifyUsers(rpuser,cs.Id,subjectTitle,body);
    						}
    					}
    				}   			
    			}
    		}
    	}	
}

	/**
	 * @description: 审批状态修改并且审批状态为审批中时锁定对象
	* @param  {*}
	* @return {*}
	*/
	public void autoLockTrigger(List<Requirementsreview__c> schemeList) {
		List<Id> idList = new List<Id>();//锁定记录id集合
		List<Id> idAllList = new List<Id>();
		for (Requirementsreview__c sch : schemeList) {
			if (!Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}	
			idAllList.add(sch.Id);
		}
		for (Demandconfiguration__c mem : [SELECT Id FROM Demandconfiguration__c WHERE Requirementsreview__c IN: idAllList]) {
			if (!Approval.isLocked(mem.Id)) {
				idList.add(mem.Id);
			}
		}
		Approval.lock(idList);//锁定审批单
	}

	/**
	 * @description: 审批状态修改并且审批状态为已驳回时解锁对象
	* @param  {*}
	* @return {*}
	*/
	public void autoUnLockTrigger(List<Requirementsreview__c> schemeList) {
		List<Id> idList = new List<Id>();
		List<Id> idAllList = new List<Id>();
		for (Requirementsreview__c sch : schemeList) {
			if (Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			idAllList.add(sch.Id);
		}
		for (Demandconfiguration__c mem : [SELECT Id FROM Demandconfiguration__c WHERE Requirementsreview__c IN: idAllList]) {
			if (Approval.isLocked(mem.Id)) {
				idList.add(mem.Id);
			}
		}
		Approval.unlock(idList);//解锁审批单
	}
}