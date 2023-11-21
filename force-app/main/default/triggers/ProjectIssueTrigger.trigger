trigger ProjectIssueTrigger on ProjectIssue__c (after insert, after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('ProjectIssueTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new ProjectIssueNotifyHandler())
        .Bind(Triggers.Evt.AfterUpdate,new ProjectIssueNotifyHandler())
        .Execute();
    }
}