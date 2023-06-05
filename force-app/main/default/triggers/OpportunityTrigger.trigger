trigger OpportunityTrigger on Opportunity (before update,after update, after insert,before insert) {
    Trigger__mdt mc = Trigger__mdt.getInstance('OpportunityTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.BeforeUpdate,new OpportunityHandler())
        .Bind(Triggers.Evt.AfterUpdate,new OpportunityHandler())
        .Bind(TriggerS.Evt.afterInsert, new OpportunityHandler())
        .Bind(TriggerS.Evt.BeforeInsert, new OpportunityHandler())
        .Execute();
    }
}