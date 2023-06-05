trigger CompetitorTrigger on Competitor__c (after insert) {

    Trigger__mdt mc = Trigger__mdt.getInstance('CompetitorTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new CompetitorHandler())
        .Execute();
    }
}