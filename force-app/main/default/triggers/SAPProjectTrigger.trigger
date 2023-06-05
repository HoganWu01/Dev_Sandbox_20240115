trigger SAPProjectTrigger on Project__c (after insert,after update) {

    Trigger__mdt mc = Trigger__mdt.getInstance('SAPProjectTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new SAPProjectHandler())
        .Bind(Triggers.Evt.AfterUpdate,new SAPProjectHandler())
        .Execute();
    }
}