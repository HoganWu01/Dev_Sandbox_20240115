/*
 * @Author: irving
 * @Date: 2021-10-15 10:53:11
 * @LastEditTime: 2021-10-25 16:19:01
 * @LastEditors: Please set LastEditors
 * @Description: 标段项目创建，调用Sap项目创建接口
 */
trigger ContractSAPProTrigger on Contractmanagement__c (after insert, after update, before insert) {

    Trigger__mdt mc = Trigger__mdt.getInstance('ContractSAPProTrigger');
    if (mc == null || mc.IsActive__c) {
         new triggers()
        .Bind(Triggers.Evt.AfterUpdate,new ProjectCreateHandler())
        .bind(Triggers.Evt.AfterInsert, new ProjectCreateHandler())
        .bind(Triggers.Evt.BeforeInsert, new ProjectCreateHandler())
        .Execute();
    }
}