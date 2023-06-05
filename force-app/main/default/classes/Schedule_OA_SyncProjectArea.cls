/*
 * @Author: your name
 * @Date: 2022-10-09 15:00:00
 * @LastEditTime: 2022-10-09 15:00:00
 * @LastEditors: Hogan
 * @Description: Sync Project Investment
 * @FilePath: \MINGYANG\force-app\main\default\classes\Schedule_OA_SyncProjectArea.cls
 */
global class Schedule_OA_SyncProjectArea implements Schedulable{
    global void execute(SchedulableContext sc) {
        //早上7点调用  每天一次
    	Controller_OA_ProjectArea.OASync();
    }
}