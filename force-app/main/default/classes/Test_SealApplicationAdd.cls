@isTest
public with sharing class Test_SealApplicationAdd {
    @TestSetup
    static void makeData(){

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype  FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaSealApplicationAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaSealApplicationAdd';
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

        Seal_Approval__c sealApp = new Seal_Approval__c();
        sealApp.Process_Id__c = '111';
        
        sealApp.Approval_Comments__c = '请审批';
        
        sealApp.Stamp_Description__c = 'www';
        sealApp.SealCustody__c = '';
        sealApp.Approvalstatus__c = '11';
        insert sealApp;

        Seal_Related_Information__c sealRelInfo = new Seal_Related_Information__c();
        sealRelInfo.Document_Category__c = '1' ; 
        sealRelInfo.Document_Name__c = 'aaa' ; 
        sealRelInfo.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313' ; 
        sealRelInfo.Seal_Type__c = '公章' ; 
        sealRelInfo.Seal_Numble__c = '10' ; 
        sealRelInfo.Seal_Approval__c  = sealApp.id ; 
        insert sealRelInfo ; 

        Integrated_Middle_Table__c imt = new Integrated_Middle_Table__c();
        imt.Mapping_Object_Id__c = sealApp.id ; 
        imt.RecordTypeId = imtRecordType.Id;
        insert imt ; 

    }


    static testMethod void testOAMarketingPlanAdd(){

       Id id = [select id,Process_Id__c,Approval_Comments__c,Approvalstatus__c,Stamp_Description__c,SealCustody__c from Seal_Approval__c where Process_Id__c = '111' ].id;
       
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OASealApplicationAdd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SealApplicationAdd.SealApplicationAdd(id);
        System.Test.stopTest();
    }

    static testMethod void testOAMarketingPlanAddError(){

        Id id = [select id,Process_Id__c,Approval_Comments__c,Approvalstatus__c,Stamp_Description__c,SealCustody__c from Seal_Approval__c where Process_Id__c = '111' ].id;
        
         System.Test.startTest();
         System.test.setMock(HttpCalloutMock.class,new OASealApplicationAdd_MockError());
         RestRequest request = new RestRequest();
         RestResponse response = new RestResponse();
         RestContext.response = response;
         RestContext.request = request;
         Controller_SealApplicationAdd.SealApplicationAdd(id);
         System.Test.stopTest();
     }


    class OASealApplicationAdd_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "流程启动成功！","data": {"rtStatus": "Y","rtMsg": "流程启动成功！","fdId": "17cfe3e1ae4cf55f74e72ee490c8b788","docSubject": "检测前沿开发组_何建斌_印章盖章申请单_2021-11-08_GA-YZGZYWSQ20211108001","fdNumber": "GA-YZGZYWSQ20211108001","Data": null,"data": null}}');
			return response;
		}
	}

    class OASealApplicationAdd_MockError implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": "8888","message": "流程启动成功！","data": {"rtStatus": "Y","rtMsg": "流程启动成功！","fdId": "17cfe3e1ae4cf55f74e72ee490c8b788","docSubject": "检测前沿开发组_何建斌_印章盖章申请单_2021-11-08_GA-YZGZYWSQ20211108001","fdNumber": "GA-YZGZYWSQ20211108001","Data": null,"data": null}}');
			return response;
		}
	}
}