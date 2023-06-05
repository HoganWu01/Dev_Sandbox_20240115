/*
 * @Author: Conner
 * @Date: 2021-12-29 11:49:13
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-29 15:39:22
 * @Descripttion: 集成中间表触发器
 */
trigger IntegratedMiddleTableTrigger on Integrated_Middle_Table__c (after update) {
    IntegratedMiddleTableTriggerHandler tabHandler = new IntegratedMiddleTableTriggerHandler();
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            List<Integrated_Middle_Table__c> objList = new List<Integrated_Middle_Table__c>();
			for (Integrated_Middle_Table__c obj : (List<Integrated_Middle_Table__c>)Trigger.new) {
				Integrated_Middle_Table__c objOld = (Integrated_Middle_Table__c)Trigger.oldMap.get(obj.Id);
                //更新的附件上传节点标识不等于旧值
				if (obj.Is_Upload_File__c != objOld.Is_Upload_File__c) {
					objList.add(obj);
				}
			}
			if (objList.size()>0){
                tabHandler.updateParentTrigger(objList);
			}
        }
    }
}