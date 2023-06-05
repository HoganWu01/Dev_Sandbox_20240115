@isTest
public with sharing class Test_OA_MarketBidDept {
    @TestSetup
    static void makeData(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaMarketBidDeptList';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaMarketBidDeptList';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

        OpenPlatformApi__c open = new OpenPlatformApi__c();
        open.Name = 'GetToken';
        open.Client_Id__c = 'aHI6XXcIxmO5CVfXkPE80sPA';
        open.Client_Secret__c = 'vSaQLaO7Bhp5jK0CGgkoJO4NpO41b4ZZ';
        open.Grant_Type__c = 'client_credentials';
        open.IP__c = 'http://61.142.78.5:8011';
        open.URL__c = 'http://61.142.78.5:8011/admin/oauth/token';
        insert open;
    }    

    static testMethod void testOA_MarketBidDept(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Res_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OA_MarketBidDept.OASync();
        System.Test.stopTest();
    }

    static testMethod void testError(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Error_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OA_MarketBidDept.OASync();
        System.Test.stopTest();
    }

    static testMethod void testSchedule_OA_SyncMarketBidDept(){

        System.Test.startTest();
        System.schedule('每天早上7点调用','0 0 7 * * ?',new Schedule_OA_SyncMarketBidDept());
        System.Test.stopTest();
    }

    class Res_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data":[{"fdCountryType":"国内","fdDeptId":"162092f16daa04f4de53a694724b93ac","fdDeptName":"客户一部"},{"fdCountryType":"国内","fdDeptId":"162092f16e0f16e08b24fb54940ac5c7","fdDeptName":"客户二部"}]}');
			return response;
		}

	}

    class Error_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": "2001","message": null,"data": []}');
			return response;
		}

	}
}