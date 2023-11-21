trigger BasicDataTrigger on BasicData__c (after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('BasicDataTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterUpdate,new BasicDataHandler())
        .Execute();
    }
}