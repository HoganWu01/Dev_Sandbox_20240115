/*
 * @Author: irving
 * @Date: 2021-10-11 08:47:58
 * @LastEditTime: 2021-12-11 21:06:54
 * @LastEditors: Please set LastEditors
 * @Description: 每天7点调用  从SAP拉取客户数据更新到CRM客户
 */
global  class Schedule_SAPCustomerUpdate implements Schedulable {
    global void execute(SchedulableContext sc) {
    	//Database.executeBatch(new Batch_SAPCustomerUpdate(), 200);
        Controller_SAPCustomerUpdate.SAPCustomerUpdate();
    }
}