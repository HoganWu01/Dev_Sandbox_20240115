trigger ContractProcessIdTrigger on Contractmanagement__c (after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('ContractProcessIdTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterUpdate,new ContractProcessIdHandler())
        .Execute();
    }
}