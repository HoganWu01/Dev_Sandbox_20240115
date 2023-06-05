@isTest
public with sharing class Test_SAPGetCustomerNum {

    @TestSetup
    static void makeData(){

        Account acc = new Account();
        acc.name = 'aaa';
        acc.CustomerAccountGroup__c = '	ZD01';
        acc.BeenGroup__c = true ; 
        insert acc ; 

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'sapgetCustomerNum';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getCustomerNum';
        ext.Request_Source__c = '2';
        ext.Request_Method__c = 'sapTestAdd';
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

    static testMethod void testSAPGetCustomerNum(){

        //Account acc = [SELECT ID,NAME,CustomerAccountGroup__c FROM Account WHERE NAME = 'aaa'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SAPGetCustomerNum_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SAPGetCustomerNum.getCustomerNum('ZD01');
        System.Test.stopTest();

    }

    static testMethod void testSAPGetCustomerNum1(){

        //Account acc = [SELECT ID,NAME,CustomerAccountGroup__c FROM Account WHERE NAME = 'aaa'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SAPGetCustomerNum_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SAPGetCustomerNum.getAccGroupList();
        System.Test.stopTest();

    }

    static testMethod void testSAPGetCustomerNumError(){

        //Account acc = [SELECT ID,NAME,CustomerAccountGroup__c FROM Account WHERE NAME = 'aaa'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SAPGetCustomerNumError_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SAPGetCustomerNum.getCustomerNum('ZD01');
        System.Test.stopTest();

    }


    class SAPGetCustomerNum_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "查找成功!","data": "0000990663"}');
			return response;
		}

	}


    class SAPGetCustomerNumError_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('Errorrr');
			return response;
		}

	}
}