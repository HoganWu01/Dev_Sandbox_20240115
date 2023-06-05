trigger LeadTrigger on Lead (after insert,after update,before insert ) {
    Trigger__mdt mc = Trigger__mdt.getInstance('LeadTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new LeadHandler())
        .Bind(Triggers.Evt.AfterUpdate,new LeadHandler())
        .Bind(Triggers.Evt.BeforeInsert,new LeadHandler())
        .Execute();
    }
}