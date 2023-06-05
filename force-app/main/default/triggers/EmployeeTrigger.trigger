trigger EmployeeTrigger on Employee__c (after update,after insert ) {
    Trigger__mdt mc = Trigger__mdt.getInstance('EmployeeTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterUpdate,new EmployeeHandler())
        .Bind(Triggers.Evt.AfterInsert,new EmployeeHandler())
        .Execute();
    }
}