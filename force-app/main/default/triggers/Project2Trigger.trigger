trigger Project2Trigger on Project__c (before insert,after insert,before update,after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('Project2Trigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.BeforeInsert,new Project2Handler())
        .Bind(Triggers.Evt.AfterInsert,new Project2Handler())
        .Bind(Triggers.Evt.AfterUpdate,new ProjectNotifyHandler())
        .Execute();
    }

}