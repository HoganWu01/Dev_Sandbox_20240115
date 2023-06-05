/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-23 18:45:38
 * @Descripttion: 营销合同补充协议触发器
 */
public without sharing class ContractSupplementTriggerHandler {
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
    			Map<Id, ContractSupplement__c> csMap = (Map<Id, ContractSupplement__c>)Trigger.newMap;
    			List<ContractSupplement__c> csList = Trigger.old;
    			for (String csId : csMap.keySet()) {
    				for (ContractSupplement__c cs : csList) {
    					if (csId == cs.Id) {
    						if (cs.Approvalstatus__c != csMap.get(csId).Approvalstatus__c
    						 && csMap.get(csId).Approvalstatus__c == '11' ) {
    						 	Set<String> rpuser1 = new Set<String>();
    							rpuser1.add(cs.OwnerId);
    							Utils.notifyUsers(rpuser1,cs.Id,subjectTitle1,body1);
    						}
    					}
    				} 
                    // if(csMap.get(csId).Process_Id__c != null) {
                    //     Set<String> rpuser2 = new Set<String>();
                    //     rpuser2.add(csMap.get(csId).OwnerId);
                    //     Utils.notifyUsers(rpuser2,csMap.get(csId).Id,subjectTitle2,body2);
                    // }	
    			}
    		}
    	}	
}
	/**
	 * @description: 战区不为空，区域代表为空或者分管副总裁为空时查找中间表
	* @param  {*}
	* @return {*}
	*/	
	public void autoSetValueTrigger(List<ContractSupplement__c> contractList){
		String recordType = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Supplementary_Agreement_Record_Type').getRecordTypeId();
		System.debug('recordType-----'+recordType);
		//存储 key:战区 和 value:营销合同补充协议申请单中间表
		Map<String,Integrated_Middle_Table__c> areaWindMap = new Map<String,Integrated_Middle_Table__c>();
		for (Integrated_Middle_Table__c form : [SELECT Id,Project_Theater__c,Chief_Representative__c,Regional_Vice_President__c FROM Integrated_Middle_Table__c WHERE RecordTypeId =: recordType]) {
			areaWindMap.put(form.Project_Theater__c,form);
		}
		for (ContractSupplement__c con : contractList) {
			//战区
			if (areaWindMap.containsKey(con.Salesdepartment__c)) {
				if (con?.Chief_Representative__c==null) {
					if (areaWindMap.get(con.Salesdepartment__c)?.Chief_Representative__c!=null) {
						//首席代表
						con.Chief_Representative__c = areaWindMap.get(con.Salesdepartment__c).Chief_Representative__c;
					}else {
						con.addError('无法匹配到战区对应的首席代表，请手动填写');
					}
				}
				if (con?.Regional_Vice_President__c==null) {
					if (areaWindMap.get(con.Salesdepartment__c)?.Regional_Vice_President__c!=null) {
						//区域分管副总裁
						con.Regional_Vice_President__c = areaWindMap.get(con.Salesdepartment__c).Regional_Vice_President__c;
					}else {
						con.addError('无法匹配到战区对应的区域分管副总裁，请手动填写');
					}
				}
			}else {
				con.addError('无法匹配到战区对应的首席代表/区域分管副总裁，请手动填写');
			}
		}
	}

	/**
	 * @description: 审批状态修改并且审批状态为审批中时锁定对象
	* @param  {*}
	* @return {*}
	*/
	public void autoLockTrigger(List<ContractSupplement__c> schemeList) {
		List<Id> idList = new List<Id>();//锁定记录id集合
		List<Id> idAllList = new List<Id>();
		List<Id> sureList = new List<Id>();
		for (ContractSupplement__c sch : schemeList) {
			if (!Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}	
			idAllList.add(sch.Id);
			if (sch.Approvalstatus__c != '30') {
				sureList.add(sch.Id);
			}
		}
		for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Marketing_Contract__c IN:idAllList]) {
			if (!Approval.isLocked(seal.Id)) {
				idList.add(seal.Id);
			}
		}
		for (Seal_Approval__c seal : [SELECT Id FROM Seal_Approval__c WHERE Marketing_Contract__c IN:sureList]) {
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
	public void autoUnLockTrigger(List<ContractSupplement__c> schemeList) {
		List<Id> idList = new List<Id>();
		List<Id> idAllList = new List<Id>();
		for (ContractSupplement__c sch : schemeList) {
			if (Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			idAllList.add(sch.Id);
		}
		for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Marketing_Contract__c IN:idAllList]) {
			if (Approval.isLocked(seal.Id)) {
				idList.add(seal.Id);
			}
		}
		for (Seal_Approval__c seal : [SELECT Id FROM Seal_Approval__c WHERE Marketing_Contract__c IN:idAllList]) {
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
	public void deleteAndUpdateChildTrigger(List<ContractSupplement__c> schemeList){
		List<Id> idList = new List<Id>();
		List<Seal_Approval__c> updateSealList = new List<Seal_Approval__c>();
		Map<Id,ContractSupplement__c> conMap = new Map<Id,ContractSupplement__c>();
		for (ContractSupplement__c con : schemeList) {
			idList.add(con.Id);
			conMap.put(con.Id, con);
		}
		List<Seal_Approval__c> sealFindList = new List<Seal_Approval__c> ([SELECT Id,Marketing_Contract__c FROM Seal_Approval__c WHERE Marketing_Contract__c IN: idList]);
		for (Seal_Approval__c seal : sealFindList) {
			if (conMap.containsKey(seal.Marketing_Contract__c)) {
				Seal_Approval__c newSeal = new Seal_Approval__c();
				newSeal.Id = seal.Id;
				newSeal.Seal_Org__c = conMap.get(seal.Marketing_Contract__c).Seal_Org__c;
				newSeal.SealKeep__c = conMap.get(seal.Marketing_Contract__c).Seal_Safekeep_Dept__c;
				updateSealList.add(newSeal);
			}
		}
		List<Seal_Related_Information__c> sealRelateList = new List<Seal_Related_Information__c>([SELECT Id FROM Seal_Related_Information__c WHERE Marketing_Contract__c IN: idList]);
		delete sealRelateList;
		update updateSealList;
	}
}