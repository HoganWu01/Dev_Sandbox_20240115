trigger PointTaskStatusTrigger on ProjectTask__c (after insert ,after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('PointTaskStatusTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new PointTaskStatusHandler())
        .Bind(Triggers.Evt.AfterUpdate,new PointTaskStatusHandler())
        .Execute();
    }
}