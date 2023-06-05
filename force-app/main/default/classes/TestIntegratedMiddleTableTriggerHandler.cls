@isTest
private class TestIntegratedMiddleTableTriggerHandler{

	@isTest static void middleTable() {
		Projectapplication__c pro = new Projectapplication__c();
		insert pro;
		Integrated_Middle_Table__c middle = new Integrated_Middle_Table__c();
		middle.Is_Upload_File__c = 'N';
		middle.Mapping_Object_Id__c = pro.Id;
		middle.Object_API__c = 'Projectapplication__c';
		insert middle;

		middle.Is_Upload_File__c = 'Y';
		update middle;
	}
}