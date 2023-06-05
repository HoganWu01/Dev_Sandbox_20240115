/*
 * @Descripttion: 战略合作协议/合同审批单
 * @Author: Hogan
 * @Date: 2022-07-25 11:00:00
 * @LastEditors: Hogan
 * @LastEditTime: 2022-07-25 11:00:00
 */
public without sharing class StrategicTriggerHandler {
	/**
	*当装态更改为已驳回（11）时，小铃铛通知对象数据所有人，该申请单需要调整并重新提交
	*/
    public class SendNotifyToOwner implements Triggers.Handler{
    	public void handle() {
    		System.debug('进来了触发器');
    		String subjectTitle1 = '《战略合作协议/合同审批单》驳回/撤回通知';
            // String subjectTitle2 = '提示';
            // String body2 = '请提交您的印章盖章表单';
    		if(Trigger.isAfter && Trigger.isUpdate) {
    			Map<Id, StrategicCooperationContract__c> raMap = (Map<Id, StrategicCooperationContract__c>)Trigger.newMap;
    			List<StrategicCooperationContract__c> raList = Trigger.old;
    			for (String raId : raMap.keySet()) {
    				for (StrategicCooperationContract__c ra : raList) {
    					if (raId == ra.Id) {
    						if (ra.Approvalstatus__c != raMap.get(raId).Approvalstatus__c
    						 && (raMap.get(raId).Approvalstatus__c == '11' || raMap.get(raId).Approvalstatus__c == '10') ) {
    						 	Set<String> rpuser1 = new Set<String>();
    							rpuser1.add(ra.OwnerId);
								String body1 = '战略申请单：“'+raMap.get(raId).Name + '”需要调整并重新提交！';
    							Utils.notifyUsers(rpuser1,ra.Id,subjectTitle1,body1);
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
	public void autoLockTrigger(List<StrategicCooperationContract__c> schemeList) {
		List<Id> idList = new List<Id>();//锁定记录id集合
		List<Id> idAllList = new List<Id>();
		for (StrategicCooperationContract__c sch : schemeList) {
			if (!Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}	
			idAllList.add(sch.Id);
		}
		for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Strategic_Cooperation_Contract__c IN:idAllList]) {
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
	public void autoUnLockTrigger(List<StrategicCooperationContract__c> schemeList) {
		List<Id> idList = new List<Id>();
		List<Id> idAllList = new List<Id>();
		for (StrategicCooperationContract__c sch : schemeList) {
			if (Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			idAllList.add(sch.Id);
		}
		for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Strategic_Cooperation_Contract__c IN:idAllList]) {
			if (Approval.isLocked(seal.Id)) {
				idList.add(seal.Id);
			}
		}
		Approval.unlock(idList);//解锁审批单
	}

	/**
	* @description: 如果父对象更新了管理单位或印章保管部门就删除印章相关信息子对象
	* @param  {*}
	* @return {*}
	*/	
	public void deleteChildTrigger(List<StrategicCooperationContract__c> schemeList){
		List<Id> idList = new List<Id>();
		for (StrategicCooperationContract__c con : schemeList) {
			idList.add(con.Id);
		}
		List<Seal_Related_Information__c> sealRelateList = new List<Seal_Related_Information__c>([SELECT Id FROM Seal_Related_Information__c WHERE Strategic_Cooperation_Contract__c IN: idList]);
		delete sealRelateList;
	}
}