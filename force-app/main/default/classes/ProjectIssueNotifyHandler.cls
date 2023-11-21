/*
 * @Descripttion: 督办问题处理类Handler
 * @Author: Hogan
 * @Date: ###### Wed Nov 8 15:31:32 CST 2023
 * @LastEditors: Please set LastEditors
 * @LastEditTime: ###### Wed Nov 8 15:31:34 CST 2023
 */
public without sharing class ProjectIssueNotifyHandler implements Triggers.Handler {

    public void handle() {

        if (Trigger.isAfter && Trigger.isInsert) {
            List<ProjectIssue__c> tempProList = new List<ProjectIssue__c>();
            for(ProjectIssue__c newProIssue : (List<ProjectIssue__c>)Trigger.new) {
                //问题状态为‘待解决’，触发提醒
                if (newProIssue.Status__c == '待解决') {
                    tempProList.add(newProIssue);
                }
            }
            if (tempProList.size()>0) {
                notifyFun(tempProList);
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            List<ProjectIssue__c> tempProList = new List<ProjectIssue__c>();
            for(ProjectIssue__c newProIssue : (List<ProjectIssue__c>)Trigger.new) {
                ProjectIssue__c oldProIssue = (ProjectIssue__c)Trigger.oldMap.get(newProIssue.Id);

                //问题状态变更为‘待解决’，触发提醒
                if (newProIssue.Status__c != oldProIssue.Status__c && newProIssue.Status__c == '待解决'){
                    tempProList.add(newProIssue);
                }
            }
            if (tempProList.size()>0) {
                notifyFun(tempProList);
            }
        }
    }

    public static void notifyFun(List<ProjectIssue__c> proIssueList){
        for(ProjectIssue__c proIssue : proIssueList) {
            Set<String> userIdSet = new Set<String>();
            //小铃铛通知
            userIdSet.add(proIssue.IssueOwner__c);//通知责任人

            System.debug('小铃铛通知');
            if (userIdSet.size()>0) {
                String content = '您有新的督办问题待解决，督办问题名称：【'+ proIssue.Name +'】，请及时跟进处理。';
                Utils.notifyUsers(userIdSet, proIssue.id, '督办问题通知',content );
            }
        }
    }

}