trigger ProjectAppLeaderTrigger on Projectapplication__c (after insert,after update,before delete) {
    Trigger__mdt mc = Trigger__mdt.getInstance('ProjectAppLeaderTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new ProjectAppLeaderHandler())
        .Bind(Triggers.Evt.AfterUpdate,new ProjectAppLeaderHandler())
        .Bind(Triggers.Evt.BeforeDelete,new ProjectAppLeaderHandler())
        .Execute();
    }
}