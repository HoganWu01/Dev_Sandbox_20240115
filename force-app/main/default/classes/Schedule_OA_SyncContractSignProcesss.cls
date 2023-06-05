/*
 * @Author: your name
 * @Date: 2022-10-10 09:00:00
 * @LastEditTime: 2022-10-10 09:00:00
 * @LastEditors: Hogan
 * @Description: Sync ContractSignProcesss
 * @FilePath: \MINGYANG\force-app\main\default\classes\Schedule_OA_SyncContractSignProcesss.cls
 */
global class Schedule_OA_SyncContractSignProcesss implements Schedulable{
    global void execute(SchedulableContext sc) {
        //早上7点调用  每天一次
    	Controller_OA_ContractSignProcesss.OASync('','');
    }
}