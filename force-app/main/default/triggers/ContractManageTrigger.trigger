trigger ContractManageTrigger on Contractmanagement__c (before insert,after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('ContractManageTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.beforeInsert,new ContractmanagementHandler())
        .Bind(Triggers.Evt.AfterUpdate,new ContractmanagementHandler())
        .Execute();
    }
}