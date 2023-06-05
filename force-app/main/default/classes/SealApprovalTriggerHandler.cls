/*
 * @Descripttion: 印章审批触发器
 * @Author: Keiran
 * @Date: 2021-10-19 11:08:00
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-24 11:37:26
 */
public without sharing class SealApprovalTriggerHandler {
  /**
	*当装态更改为已驳回（11）时，小铃铛通知对象数据所有人，该申请单需要调整并重新提交
	*/
    public class SendNotifyToOwner implements Triggers.Handler{
    	public void handle() {
    		System.debug('进来了触发器');
    		String subjectTitle = '申请单驳回通知';
    		String body = '申请单需要调整并重新提交';
            String subjectTitle2 = '提示';
            String body2 = '请提交您的印章盖章表单';
    		if(Trigger.isAfter && Trigger.isUpdate) {
    			Map<Id, Seal_Approval__c> csMap = (Map<Id, Seal_Approval__c>)Trigger.newMap;
    			List<Seal_Approval__c> csList = Trigger.old;
    			for (String csId : csMap.keySet()) {
    				for (Seal_Approval__c cs : csList) {
    					if (csId == cs.Id) {
    						if (cs.Approvalstatus__c != csMap.get(csId).Approvalstatus__c
    						 && csMap.get(csId).Approvalstatus__c == '11' ) {
    						 	Set<String> rpuser = new Set<String>();
    							rpuser.add(cs.OwnerId);
    							Utils.notifyUsers(rpuser,cs.Id,subjectTitle,body);
    						}
    					}
    				}
                    if(csMap.get(csId).Process_Id__c != null) {
                        Set<String> rpuser2 = new Set<String>();
                        rpuser2.add(csMap.get(csId).OwnerId);
                        Utils.notifyUsers(rpuser2,csMap.get(csId).Id,subjectTitle2,body2);
                    }    			
    			}
    		}
    	}	
    }

    /**
    *1.当新增印章审批时，找到补充协议审批单下面的印章审批相关信息，
    *  给印章相关信息的印章审批查找字段赋值
    *2.当新增印章审批时，找到资源开发协议审批单下面的印章审批相关信息，
    *  给印章相关信息的印章审批查找字段赋值
    */
    public class AssignToRelaInfo implements Triggers.Handler{
        public void handle() {
            Map<String, String> midMap = new Map<String, String>();
            Map<String, String> ridMap = new Map<String, String>();
            if (Trigger.isAfter && Trigger.isInsert) {
                System.debug('========>>>进来了afterInsert触发器');
                Map<Id, Seal_Approval__c> csMap = (Map<Id, Seal_Approval__c>)Trigger.newMap;
                List<Seal_Approval__c> sealList = csMap.values();
                for (Seal_Approval__c sa : csMap.values()) {

                    if (sa.Marketing_Contract__c!=null) {
                        midMap.put(sa.Marketing_Contract__c,sa.Id);
                    }
                    
                    if (sa.Resource_Develop_Agreement__c!=null) {
                        ridMap.put(sa.Resource_Develop_Agreement__c, sa.Id);
                    }
                    
                }

                List<Seal_Related_Information__c> sriList1 = new List<Seal_Related_Information__c>();

                if (midMap.keySet().size()>0) {
                     sriList1 = [SELECT Id,Name,
                                            Seal_Approval__c,
                                            Marketing_Contract__c,
                                            Resource_Development_Agreement__c
                                            FROM Seal_Related_Information__c 
                                            WHERE Marketing_Contract__c IN:midMap.keySet()];
                }
                
                System.debug('sriList1的长度==' + sriList1.size());
                if (sriList1.size() > 0) {
                    for (Seal_Related_Information__c sri : sriList1) {
                         if (midMap.containsKey(sri.Marketing_Contract__c)) {
                            sri.Seal_Approval__c = midMap.get(sri.Marketing_Contract__c);
                         }                                                   
                    }
                    update sriList1;
                }

                List<Seal_Related_Information__c> sriList2 = new List<Seal_Related_Information__c>();

                if (ridMap.keySet().size()>0) {
                     sriList2 = [SELECT Id,Name,
                                        Seal_Approval__c,
                                        Resource_Development_Agreement__c
                                        FROM Seal_Related_Information__c 
                                        WHERE Resource_Development_Agreement__c IN:ridMap.keySet()];
                }

                System.debug('sriList2的长度==' + sriList2.size());
                if (sriList2.size() > 0) {
                    for (Seal_Related_Information__c sri : sriList2) {
                         if (ridMap.containsKey(sri.Resource_Development_Agreement__c)) {
                            sri.Seal_Approval__c = ridMap.get(sri.Resource_Development_Agreement__c);
                         }                                                   
                    } 
                    update sriList2;  
                }
                                                               
            }
        }
    }

    /**
	 * @description: 获取流程id后解锁子对象
	* @param  {*}
	* @return {*}
	*/
	public void autoUnLockRelateTrigger(List<Seal_Approval__c> schemeList) {
		List<Id> idList = new List<Id>();//锁定记录id集合
		List<Id> idAllList = new List<Id>();
		for (Seal_Approval__c sch : schemeList) {
			// if (!Approval.isLocked(sch.Id)) {
			// 	idList.add(sch.Id);
			// }	
			idAllList.add(sch.Id);
		}
        for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Seal_Approval__c IN:idAllList]) {
			if (Approval.isLocked(seal.Id)) {
				idList.add(seal.Id);
			}
		}
		Approval.unlock(idList);//锁定审批单
	}

    /**
	 * @description: 审批状态修改并且审批状态为审批中时锁定对象
	* @param  {*}
	* @return {*}
	*/
	public void autoLockTrigger(List<Seal_Approval__c> schemeList) {
		List<Id> idList = new List<Id>();//锁定记录id集合
		List<Id> idAllList = new List<Id>();
		for (Seal_Approval__c sch : schemeList) {
			if (!Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}	
			idAllList.add(sch.Id);
		}
        for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Seal_Approval__c IN:idAllList]) {
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
	public void autoUnLockTrigger(List<Seal_Approval__c> schemeList) {
		List<Id> idList = new List<Id>();
		List<Id> idAllList = new List<Id>();
		for (Seal_Approval__c sch : schemeList) {
			if (Approval.isLocked(sch.Id)) {
				idList.add(sch.Id);
			}
			idAllList.add(sch.Id);
		}
        for (Seal_Related_Information__c seal : [SELECT Id FROM Seal_Related_Information__c WHERE Seal_Approval__c IN:idAllList]) {
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
	public void deleteAndUpdateChildTrigger(List<Seal_Approval__c> schemeList){
		List<Id> idList = new List<Id>();
		for (Seal_Approval__c con : schemeList) {
			idList.add(con.Id);
		}
		List<Seal_Related_Information__c> sealRelateList = new List<Seal_Related_Information__c>([SELECT Id FROM Seal_Related_Information__c WHERE Seal_Approval__c IN: idList]);
		delete sealRelateList;
	}
}