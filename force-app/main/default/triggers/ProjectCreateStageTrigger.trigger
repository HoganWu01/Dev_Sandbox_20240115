trigger ProjectCreateStageTrigger on Project__c (before insert,after insert,before update,after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('ProjectCreateStageTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.BeforeInsert,new ProjectCreateStageHandler())
        .Bind(Triggers.Evt.AfterInsert,new ProjectCreateStageHandler())
        .Execute();
    }
}