/*
 * @Author: Hogan
 * @Date: ###### Wed Nov 8 17:18:25 CST 2023
 * @LastEditTime: ###### Wed Nov 8 17:18:27 CST 2023
 * @LastEditors: Hogan
 * @Description: In User Settings Edit
 * @FilePath: \MINGYANG\force-app\main\default\classes\Schedule_ProjectIssueNotify.cls
 */
global class Schedule_ProjectIssueNotify implements Schedulable{
    global void execute(SchedulableContext sc) {
        //每周四17：00
    	Batch_ProjectIssueNotify batchProIssue = new Batch_ProjectIssueNotify();
        Database.executeBatch(batchProIssue,100);
    }
}