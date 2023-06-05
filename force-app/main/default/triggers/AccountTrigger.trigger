/*
 * @Descripttion: 客户触发器
 * @Author: Devin
 * @Date: 2021-09-27 08:23:49
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-12-08 18:17:35
 */
trigger AccountTrigger on Account (before update,after update,after insert ) {
    Trigger__mdt mc = Trigger__mdt.getInstance('AccountTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.BeforeUpdate,new AccountHandler())
        .Bind(Triggers.Evt.AfterUpdate,new AccountHandler())
        .Bind(Triggers.Evt.AfterInsert,new AccountHandler())
        .Execute();
    }
}