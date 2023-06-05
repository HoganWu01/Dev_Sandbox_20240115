trigger MatterSelectedImpellerTrigger on Matter_Selected_Impeller__c (after insert) {

    Trigger__mdt mc = Trigger__mdt.getInstance('MatterSelectedImpellerTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new MatterSelectedImpellerHandler())
        .Execute();
    }
}