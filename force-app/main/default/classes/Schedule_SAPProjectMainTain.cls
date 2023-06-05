/*
 * @Author: irving
 * @Date: 2021-10-11 08:47:58
 * @LastEditTime: 2021-11-19 11:32:53
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 */
global  class Schedule_SAPProjectMainTain implements Schedulable{
    global void execute(SchedulableContext sc) {
    	//Database.executeBatch(new Batch_SAPProjectMainTain(), 200);
        Controller_SAPProjectMainTain.SAPProjectMainTain();
    }
}