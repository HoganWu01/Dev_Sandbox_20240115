trigger MattersTrigger on SupervisoryMatters__c (after insert, after update) {
    Trigger__mdt mc = Trigger__mdt.getInstance('MattersTrigger');
    if (mc == null || mc.IsActive__c) {
        new triggers()
        .Bind(Triggers.Evt.AfterUpdate,new MattersHandler())
        .Bind(Triggers.Evt.AfterInsert,new MattersHandler())
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