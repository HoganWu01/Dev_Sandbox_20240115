/*
 * @Descripttion: 获取审批记录 定时器
 * @Author: Devin
 * @Date: 2021-11-12 16:08:54
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-12 16:08:54
 */
global with sharing class Schedule_OAGetApprovalRecords implements Schedulable{
    global void execute(SchedulableContext sc) {
        //每天晚上11点调用
        Controller_OAGetApprovalRecords.getApprovalRecords();
    }
}