@isTest
public with sharing class Test_ProjectInvestment {

    @TestSetup
    static void makeData(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaProjectInvestmentList';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaProjectInvestmentList';
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

        // Employee__c existEmp = new Employee__c();
        // existEmp.Job_Number__c = '测试人员1111';
        // existEmp.Duty__c = '员工（字）';
        // existEmp.Department__c = null ; 
        // existEmp.Department_Number__c = '198';
        // existEmp.Status__c = '在职';
        // existEmp.Gender__c = '男' ; 
        // insert existEmp;
        
    }    

    static testMethod void testSyncProjectInvestment(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Res_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OA_ProjectInvestment.OASync();
        System.Test.stopTest();
    }

    static testMethod void testError(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Error_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OA_ProjectInvestment.OASync();
        System.Test.stopTest();
    }

    static testMethod void testSchedule_ProjectInvestment(){

        System.Test.startTest();
        System.schedule('每天早上7点调用','0 0 7 * * ?',new Schedule_OA_SyncProjectInvestment());
        System.Test.stopTest();
    }

    class Res_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data": [{"fdId":"1802c30fec5f202d8bd3bf645afa5c76","docSubject":"产业建设部_何存军_奇巧檶_产业投资项目评审单_CYTZ20220415004","userId":"A08164"}]}');
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