/*
 * @Author: Conner
 * @Date: 2021-12-16 11:14:47
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-21 15:39:17
 * @Descripttion: 商机团队成员触发器
 */
trigger OppTeamMemberTrigger on OpportunityTeamMember (after insert,after delete) {
    ShareCommonTriggerHandler sha = new ShareCommonTriggerHandler();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            List<SObject> objList = new List<SObject>();
            for (SObject obj : Trigger.new) {
                objList.add(obj);
            }
            sha.sharePermissionToChild(objList);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            List<SObject> objList = new List<SObject>();
            for (SObject obj : Trigger.old) {
                objList.add(obj);
            }
            sha.deleteSharePermissionToChild(objList);
        }
    }
}