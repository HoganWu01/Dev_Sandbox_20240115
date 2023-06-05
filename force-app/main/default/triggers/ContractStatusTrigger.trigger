trigger ContractStatusTrigger on Contractmanagement__c (after insert,after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('ContractStatusTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterInsert,new ContractStatusHandler())
        .Bind(Triggers.Evt.AfterUpdate,new ContractStatusHandler())
        .Execute();
    }
    ShareCommonTriggerHandler sha = new ShareCommonTriggerHandler();
    if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			List<SObject> objList = new List<SObject>();
			for (SObject obj : Trigger.new) {
				objList.add(obj);
			}
			sha.sharePermissionToParent(objList);
		}
    }
}