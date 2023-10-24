/*
 * @Descripttion: 营销项目方案申请单触发器
 * @Author: Keiran
 * @Date: 2021-10-19 11:08:00
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-01 17:26:20
 */
public without sharing class ProjectSchemeApplicationFormHandler {
    /**
	*当装态更改为已驳回（11）时，小铃铛通知对象数据所有人，该申请单需要调整并重新提交
	*/
    public class SendNotifyToOwner implements Triggers.Handler{
    	public void handle() {
    		System.debug('进来了触发器');
    		String subjectTitle = '申请单驳回通知';
    		String body = '申请单需要调整并重新提交';
    		if(Trigger.isAfter && Trigger.isUpdate) {
    			Map<Id, Project_Scheme_Application_Form__c> csMap = (Map<Id, Project_Scheme_Application_Form__c>)Trigger.newMap;
    			List<Project_Scheme_Application_Form__c> csList = Trigger.old;
    			for (String csId : csMap.keySet()) {
    				for (Project_Scheme_Application_Form__c cs : csList) {
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
	public void autoLockTrigger(List<Project_Scheme_Application_Form__c> schemeList) {
		List<Id> idList = new List<Id>();
		for (Project_Scheme_Application_Form__c sch : schemeList) {
			if (!Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			
		}
		Approval.lock(idList);//锁定审批单
	}

	/**
	 * @description: 审批状态修改并且审批状态为已驳回时解锁对象
	* @param  {*}
	* @return {*}
	*/
	public void autoUnLockTrigger(List<Project_Scheme_Application_Form__c> schemeList) {
		List<Id> idList = new List<Id>();
		for (Project_Scheme_Application_Form__c sch : schemeList) {
			if (Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			
		}
		Approval.unlock(idList);//解锁审批单
	}
}