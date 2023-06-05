/*
 * @Author: Conner
 * @Date: 2021-12-20 16:42:34
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-24 11:25:16
 * @Descripttion: 印章相关信息触发器
 */
trigger SealRelatedInformationTrigger on Seal_Related_Information__c (before insert,after insert) {
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
	SealRelatedInformationTriggerHandler sealRelated = new SealRelatedInformationTriggerHandler();
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			sealRelated.autoSetValueTrigger((List<Seal_Related_Information__c>)Trigger.new);
		}
	}
}