/*
 * @Author: your name
 * @Date: 2022-10-10 09:00:00
 * @LastEditTime: 2022-10-10 09:00:00
 * @LastEditors: Hogan
 * @Description: Sync MarketBidDept
 * @FilePath: \MINGYANG\force-app\main\default\classes\Schedule_OA_SyncMarketBidDept.cls
 */
global class Schedule_OA_SyncMarketBidDept implements Schedulable{
    global void execute(SchedulableContext sc) {
        //早上7点调用  每天一次
    	Controller_OA_MarketBidDept.OASync();
    }
}