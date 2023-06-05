/*
 * @Descripttion: 
 * @Author: Keiran
 * @Date: 2021-10-19 11:08:00
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-01 17:47:54
 */
public without sharing class ResourceProjectApplicationTriggerHandler {
     /**
	*当装态更改为已驳回（11）时，小铃铛通知对象数据所有人，该申请单需要调整并重新提交
	*/
    public class SendNotifyToOwner implements Triggers.Handler{
    	public void handle() {
    		System.debug('进来了触发器');
    		String subjectTitle = '申请单驳回通知';
    		String body = '申请单需要调整并重新提交';
    		if(Trigger.isAfter && Trigger.isUpdate) {
    			Map<Id, ResourceProjectApplication__c> csMap = (Map<Id, ResourceProjectApplication__c>)Trigger.newMap;
    			List<ResourceProjectApplication__c> csList = Trigger.old;
    			for (String csId : csMap.keySet()) {
    				for (ResourceProjectApplication__c cs : csList) {
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
	 * @Descripttion: 【资源开发】中【资源项目立项】只允许一条记录
	* @Author: Devin
	* @param {*}
	* @return {*}
	*/	
	public class CheackRecords implements Triggers.Handler{
    	public void handle() {
			if(Trigger.isBefore && Trigger.isInsert) {

				for(ResourceProjectApplication__c project : (List<ResourceProjectApplication__c>)Trigger.new) {
					//一个资源开发只能有一条资源项目立项
					if (project.ResourceName__c != null) {
						Integer records = [SELECT count() FROM ResourceProjectApplication__c WHERE ResourceName__c =: project.ResourceName__c];
						if (records > 0) {
							project.addError('【资源开发】只能生成一条【资源项目立项】!');
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
	public void autoLockTrigger(List<ResourceProjectApplication__c> schemeList) {
		List<Id> idList = new List<Id>();//锁定记录id集合
		List<Id> idAllList = new List<Id>();
		for (ResourceProjectApplication__c sch : schemeList) {
			if (!Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}	
			idAllList.add(sch.Id);
		}
		for (ResourceMember__c mem : [SELECT Id FROM ResourceMember__c WHERE ResourceProjectApplicationName__c IN: idAllList]) {
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
	public void autoUnLockTrigger(List<ResourceProjectApplication__c> schemeList) {
		List<Id> idList = new List<Id>();
		List<Id> idAllList = new List<Id>();
		for (ResourceProjectApplication__c sch : schemeList) {
			if (Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			idAllList.add(sch.Id);
		}
		for (ResourceMember__c mem : [SELECT Id FROM ResourceMember__c WHERE ResourceProjectApplicationName__c IN: idAllList]) {
			if (Approval.isLocked(mem.Id)) {
				idList.add(mem.Id);
			}
		}
		Approval.unlock(idList);//解锁审批单
	}
}