@isTest
public with sharing class Test_SAPProjectMainTain {

    @TestSetup 
    static void setData() {

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user; 

        InterfaceParam__c ifc = new InterfaceParam__c();
        ifc.name = 'sapProject';
        ifc.SyncDate__c = Datetime.now().date();
        insert ifc ; 

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'sapProject';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/sapProject';
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

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        OPP.OwnerId = user.ID ; 
        insert opp;

        Projectapplication__c pac = new Projectapplication__c();
        pac.Oppty__c = opp.id ; 
        pac.Approvalstatus__c  = '30';
        insert pac ; 

        Project__c project = new Project__c();
        project.name = 'test';
        project.Projectnumber__c = 'S1-20200013';
        project.WBS__c = 'S1-20200013';
        project.ProjectManager__c = user.id ; 
        project.Opportunity__c = opp.id ; 
        insert project ; 

        Controller_SAPProjectMainTain.Data d = new Controller_SAPProjectMainTain.Data();
        d.aedat = '20211009';
        d.astna = 'aa';
        d.astnr = '00000000';
        d.plfaz = '20210914';
        d.prctr = 'MY1000';
        
    }

    static testMethod void testSAPProjectMainTain(){

        List<Project__c> proList = [SELECT ID,name,Projectnumber__c,ProjectManager__c FROM Project__c];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SAPProjectMainTain_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SAPProjectMainTain.SAPProjectMainTain();
        System.Test.stopTest();
    }

    static testMethod void testSAPProjectMainTainNoData(){

        List<Project__c> proList = [SELECT ID,name,Projectnumber__c,ProjectManager__c FROM Project__c];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SAPProjectMainTainNoData_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SAPProjectMainTain.SAPProjectMainTain();
        System.Test.stopTest();
    }

    static testMethod void testSAPProjectMainTainError(){

        List<Project__c> proList = [SELECT ID,name,ProjectManager__c FROM Project__c];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SAPProjectMainTainError_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SAPProjectMainTain.SAPProjectMainTain();
        System.Test.stopTest();
    }

    static testMethod void test_Batch_SAPProjectMainTain(){

        System.Test.startTest();
        Database.executeBatch(new Batch_SAPProjectMainTain());
        System.Test.stopTest();
    }

    static testMethod void test_Schedule_SAPProjectMainTain(){

        System.Test.startTest();
        String jobId = System.schedule('Schedule_SAPProjectMainTain', '0 0 11 * * ?', new Schedule_SAPProjectMainTain());
        System.Test.stopTest();
    }


    //    /api/sapProject
    class SAPProjectMainTain_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data": [{"pspid": "S1-20200013","post1": "粤水电西藏布达拉宫","vernr": "00000000","verna": " ","astnr": "00000000","astna": " ","vbukr": "6000","werks": " ","prctr": "MY1000","plfaz": "20200801","plsez": "20451231","aedat": "20211102"}]}');
			return response;
		}
	}

    class SAPProjectMainTainError_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(404);
			response.setStatus('OK');
			response.setBody('Error');
			return response;
		}
	}

    class SAPProjectMainTainNoData_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data": []}');
			return response;
		}
	}

    
}