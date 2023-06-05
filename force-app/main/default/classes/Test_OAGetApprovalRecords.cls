@isTest
public with sharing class Test_OAGetApprovalRecords {
    @TestSetup
    static void makeData(){
        InterfaceParam__c ic = new InterfaceParam__c();
        ic.name ='OAApprovalRecords';
        ic.SyncDate__c = Datetime.now().date();
        insert ic;

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaGetApprovalRecords';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getApproveResult';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

        Integrated_Middle_Table__c midTable = new Integrated_Middle_Table__c();

   
    }   


    static testMethod void testOAGetApprovalRecords(){

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAGetApprovalRecords.getApprovalRecords();
        System.Test.stopTest();
    }

    class OAGetApprovalRecords_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": "9999","msg": "CRM调用oa审批记录接口成功！","data": [{"processId": "17c71d86652a0d990bbe79e4fc78fae4","nodeId": "17c71d87059ddeba9c3b7b44f3da0798","parentId": null,"createTime": "2021-10-12 08:24:49","nodeName": "起草节点","handlerId": "111870","actionInfo": "sys-lbpmservice-operation-drafter:lbpmOperations.fdOperType.draft.submit","actionNote": null,"docStatus": "30","childId": ""}]}');
			return response;
		}

	}
}