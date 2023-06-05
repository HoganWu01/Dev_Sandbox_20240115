@isTest
public with sharing class Test_OAUser {

    @TestSetup
    static void makeData(){
        InterfaceParam__c ic = new InterfaceParam__c();
        ic.name ='OAUser';
        ic.SyncDate__c = Datetime.now().date();
        insert ic;

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaUser';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaUser';
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

        Employee__c existEmp = new Employee__c();
        existEmp.Job_Number__c = '测试人员1111';
        existEmp.Duty__c = '员工（字）';
        existEmp.Department__c = null ; 
        existEmp.Department_Number__c = '198';
        existEmp.Status__c = '在职';
        existEmp.Gender__c = '男' ; 
        insert existEmp;
        
    }    

    static testMethod void testExistOAUser(){

        Employee__c e = [SELECT ID,NAME FROM Employee__c WHERE Job_Number__c = '测试人员1111'];
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new ExistEmp_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAUser.OAUser();
        System.Test.stopTest();
    }

    static testMethod void testUnExistOAUser(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new UnExistEmp_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAUser.OAUser();
        System.Test.stopTest();
    }

    static testMethod void testError(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Error_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAUser.OAUser();
        System.Test.stopTest();
    }

    static testMethod void testSchedule_OAUser(){

        System.Test.startTest();
        System.schedule('每天早上7点调用','0 0 7 * * ?',new Schedule_OAUser());
        System.Test.stopTest();
    }

    class ExistEmp_Mock implements HttpCalloutMock{

        // Employee__c e = [SELECT ID,NAME FROM Employee__c WHERE Job_Number__c = '测试人员1111'];

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data": [{"oldUserId": "测试人员1111","hrUserName": "测试人员1111","hrUserSex": "男","hrUserDept": "198","hrDeptName": null,"hrGwgrade": "员工（字）","hrUserStatus": "在职","hrTimestamp": "2021-09-19T18:30:31"}]}');
			return response;
		}

	}

    class UnExistEmp_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data": [{"oldUserId": "111111111","hrUserName": "测试人员1111","hrUserSex": "男","hrUserDept": "198","hrDeptName": null,"hrGwgrade": "员工（字）","hrUserStatus": "在职","hrTimestamp": "2021-09-19T18:30:31"}]}');
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