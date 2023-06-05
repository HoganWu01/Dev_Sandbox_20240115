@isTest
public with sharing class Test_Controller_SaveProjectPoints {
    

    @TestSetup
    static void makeData(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaSaveProjectPoints';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/saveProjectPoints';
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


    static testMethod void testSaveProjectPoints006(){

        Resource_Development__c resource = new Resource_Development__c();
        resource.name = '111';
        resource.ResourceNumber__c = 'bianhao';
        resource.Stage__c = '006';
        resource.SyncOASuccess__c= false; 
        insert resource ; 

        resource.name = 'aaa';
        update resource ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new cut_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SaveProjectPoints.SaveProjectPoints(resource.id);
        System.schedule('test','0 0 0 * * ?',new Schedule_SyncResourceOA());
        System.Test.stopTest();

    }

    static testMethod void testSaveProjectPoints007(){

        Resource_Development__c resource = new Resource_Development__c();
        resource.name = '111';
        resource.ResourceNumber__c = 'bianhao';
        resource.Stage__c = '007';
        insert resource ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new cut_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SaveProjectPoints.SaveProjectPoints(resource.id);
        System.Test.stopTest();

    }


    static testMethod void testSaveProjectPointserror(){

        Resource_Development__c resource = new Resource_Development__c();
        resource.name = '111';
        resource.ResourceNumber__c = 'bianhao';
        resource.Stage__c = '007';
        insert resource ; 

        
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new cutError_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SaveProjectPoints.SaveProjectPoints(resource.id);
        Database.executeBatch(new Batch_SyncResourceOA());
        System.Test.stopTest();
    }

  


    class cut_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "已接收！","data": null}');
			return response;
		}

	}


    class cutError_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": "1001","message": "没接收！","data": null}');
			return response;
		}

	}




}