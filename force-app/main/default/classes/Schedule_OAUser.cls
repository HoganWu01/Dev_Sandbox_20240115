/*
 * @Author: your name
 * @Date: 2021-10-08 17:26:26
 * @LastEditTime: 2021-11-12 16:19:16
 * @LastEditors: Devin
 * @Description: In User Settings Edit
 * @FilePath: \MINGYANG\force-app\main\default\classes\Schedule_OAUser.cls
 */
global class Schedule_OAUser implements Schedulable{
    global void execute(SchedulableContext sc) {
        //早上7点调用  每天一次
    	Controller_OAUser.OAUser();
    }
}