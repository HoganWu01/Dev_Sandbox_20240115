/*
 * @Author:irving
 * @Date: 2021-10-08 17:26:26
 * @LastEditTime: 2022-03-11 18:03:59
 * @LastEditors: Devin
 * @Description: In User Settings Edit
 * @FilePath: \MINGYANG\force-app\main\default\classes\Schedule_OAUser.cls
 */
global class Schedule_SyncResourceOA implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Batch_SyncResourceOA(), 1);
    }
}