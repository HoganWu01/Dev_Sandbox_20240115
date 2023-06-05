trigger ResourceToClueTrigger on Resource_Development__c (after insert,after update) {

    Trigger__mdt mc = Trigger__mdt.getInstance('ResourceToClueTrigger');
    if (mc == null || mc.IsActive__c) {
         new triggers()
        .Bind(Triggers.Evt.AfterUpdate,new ResourceToClueHandler())
        .Bind(Triggers.Evt.AfterInsert,new ResourceToClueHandler())
        .Execute();
    }
}