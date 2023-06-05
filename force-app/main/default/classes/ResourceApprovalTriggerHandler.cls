/*
 * @Descripttion: 资源开发协议资源审批单
 * @Author: Keiran
 * @Date: 2021-10-19 11:08:00
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-23 18:44:37
 */
public without sharing class ResourceApprovalTriggerHandler {
	/**
	*当装态更改为已驳回（11）时，小铃铛通知对象数据所有人，该申请单需要调整并重新提交
	*/
    public class SendNotifyToOwner implements Triggers.Handler{
    	public void handle() {
    		System.debug('进来了触发器');
    		String subjectTitle1 = '申请单驳回通知';
    		String body1 = '申请单需要调整并重新提交';
            // String subjectTitle2 = '提示';
            // String body2 = '请提交您的印章盖章表单';
    		if(Trigger.isAfter && Trigger.isUpdate) {
    			Map<Id, ResourceApproval__c> raMap = (Map<Id, ResourceApproval__c>)Trigger.newMap;
    			List<ResourceApproval__c> raList = Trigger.old;
    			for (String raId : raMap.keySet()) {
    				for (ResourceApproval__c ra : raList) {
    					if (raId == ra.Id) {
    						if (ra.Approvalstatus__c != raMap.get(raId).Approvalstatus__c
    						 && raMap.get(raId).Approvalstatus__c == '11' ) {
    						 	Set<String> rpuser1 = new Set<String>();
    							rpuser1.add(ra.OwnerId);
    							Utils.notifyUsers(rpuser1,ra.Id,subjectTitle1,body1);
    						}
    					}
    				}  
                    // if(raMap.get(raId).Process_Id__c != null) {
                    //     Set<String> rpuser2 = new Set<String>();
                    //     rpuser2.add(raMap.get(raId).OwnerId);
                    //     Utils.notifyUsers(rpuser2,raMap.get(raId).Id,subjectTitle2,body2);
                    // }    			
    			}
    		}
    	}	
}

	/**
	 * @description: 审批状态修改并且审批状态为审批中时锁定对象
	* @param  {*}
	* @return {*}
	*/
	public void autoLockTrigger(List<ResourceApproval__c> schemeList) {
		List<Id> idList = new List<Id>();//锁定记录id集合
		List<Id> idAllList = new List<Id>();
		List<Id> sureList = new List<Id>();
		for (ResourceApproval__c sch : schemeList) {
			if (!Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}	
			idAllList.add(sch.Id);
			if (sch.Approvalstatus__c != '30') {
				sureList.add(sch.Id);
			}
		}
		for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Resource_Development_Agreement__c IN:idAllList]) {
			if (!Approval.isLocked(seal.Id)) {
				idList.add(seal.Id);
			}
		}
		for (Seal_Approval__c seal : [SELECT Id FROM Seal_Approval__c WHERE Resource_Develop_Agreement__c IN:sureList]) {
			if (!Approval.isLocked(seal.Id)) {
				idList.add(seal.Id);
			}
		}
		Approval.lock(idList);//锁定审批单
	}

	/**
	 * @description: 审批状态修改并且审批状态为已驳回时解锁对象
	* @param  {*}
	* @return {*}
	*/
	public void autoUnLockTrigger(List<ResourceApproval__c> schemeList) {
		List<Id> idList = new List<Id>();
		List<Id> idAllList = new List<Id>();
		for (ResourceApproval__c sch : schemeList) {
			if (Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			idAllList.add(sch.Id);
		}
		for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Resource_Development_Agreement__c IN:idAllList]) {
			if (Approval.isLocked(seal.Id)) {
				idList.add(seal.Id);
			}
		}
		for (Seal_Approval__c seal : [SELECT Id FROM Seal_Approval__c WHERE Resource_Develop_Agreement__c IN:idAllList]) {
			if (Approval.isLocked(seal.Id)) {
				idList.add(seal.Id);
			}
		}
		Approval.unlock(idList);//解锁审批单
	}

	/**
	* @description: 如果父对象更新了管理单位或印章保管部门就删除印章相关信息子对象同时修改印章审批对象
	* @param  {*}
	* @return {*}
	*/	
	public void deleteAndUpdateChildTrigger(List<ResourceApproval__c> schemeList){
		List<Id> idList = new List<Id>();
		List<Seal_Approval__c> updateSealList = new List<Seal_Approval__c>();
		Map<Id,ResourceApproval__c> conMap = new Map<Id,ResourceApproval__c>();
		for (ResourceApproval__c con : schemeList) {
			idList.add(con.Id);
			conMap.put(con.Id, con);
		}
		List<Seal_Approval__c> sealFindList = new List<Seal_Approval__c> ([SELECT Id,Resource_Develop_Agreement__c FROM Seal_Approval__c WHERE Resource_Develop_Agreement__c IN: idList]);
		for (Seal_Approval__c seal : sealFindList) {
			if (conMap.containsKey(seal.Resource_Develop_Agreement__c)) {
				Seal_Approval__c newSeal = new Seal_Approval__c();
				newSeal.Id = seal.Id;
				newSeal.Seal_Org__c = conMap.get(seal.Resource_Develop_Agreement__c).Seal_Org__c;
				newSeal.SealKeep__c = conMap.get(seal.Resource_Develop_Agreement__c).Seal_Safekeep_Dept__c;
				updateSealList.add(newSeal);
			}
		}
		List<Seal_Related_Information__c> sealRelateList = new List<Seal_Related_Information__c>([SELECT Id FROM Seal_Related_Information__c WHERE Resource_Development_Agreement__c IN: idList]);
		delete sealRelateList;
		update updateSealList;
	}
}