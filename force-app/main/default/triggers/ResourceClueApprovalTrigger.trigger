trigger ResourceClueApprovalTrigger on Resource_Development__c (before insert,after update) {

    Trigger__mdt mc = Trigger__mdt.getInstance('ResourceClueApprovalTrigger');
    if (mc == null || mc.IsActive__c) {
         new triggers()
        .Bind(Triggers.Evt.BeforeInsert,new RClueApprovalHandler())
        .Bind(Triggers.Evt.AfterUpdate,new RClueApprovalHandler())
        .Execute();
    }
}