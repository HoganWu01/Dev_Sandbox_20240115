@isTest
public with sharing class Test_ProprietorRequireReview {


    static testMethod void testauthenticationUser(){
        Requirementsreview__c rc = new Requirementsreview__c();
        rc.Contractwarrantyperiod__c = '11';
        rc.Configurationcategory__c = '主配置';
        rc.Deliveryrequirements__c = '1';
        rc.ProjectType__c = '陆上';
        rc.FinishDate__c = Date.today();
        rc.CustomerSegment__c = '客户一部';
        insert rc ; 

        System.Test.startTest();
        ControllerProprietorRequireReview.authenticationUser(rc.Id,'Requirementsreview__c');
        System.Test.stopTest();
    }

    static testMethod void testProprietorRequireReview(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaRequirementsReviewAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaRequirementsReviewAdd';
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

        Requirementsreview__c rc = new Requirementsreview__c();
        // rc.Projectname__c = '11';
        rc.Contractwarrantyperiod__c = '11';
        rc.Configurationcategory__c = '主配置';
        rc.Deliveryrequirements__c = '1';
        rc.ProjectType__c = '陆上';
        rc.FinishDate__c = Date.today();
        rc.CustomerSegment__c = '客户一部';
        rc.Country__c = '国内项目';
        rc.Contractmodel__c = '11';
        insert rc ; 

        Demandconfiguration__c dc = new Demandconfiguration__c();
        dc.Originalcontractbrand__c = '11';
        dc.Recommendedbrand__c = '11';
        dc.Configurationname__c = '11';
        dc.Requirementsreview__c = rc.id ; 
        insert dc ; 

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];
        
        Integrated_Middle_Table__c ic = new Integrated_Middle_Table__c();
        ic.Mapping_Object_Id__c = rc.id;
        ic.RecordTypeId = imtRecordType.id;
        insert ic;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new ProprietorRequireReview_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        ControllerProprietorRequireReview.toCreateApprove(rc.id);
        System.Test.stopTest();

    }

    class ProprietorRequireReview_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"data": {"Data": {"1":1},"data": {"1":1},"docSubject": "1","fdId": "1","fdNumber": "1","rtMsg": "1","rtStatus": "1"},"message": "1"}');
			return response;
		}
	}
}