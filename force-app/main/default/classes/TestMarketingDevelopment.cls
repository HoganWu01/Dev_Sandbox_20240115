@isTest
public with sharing class TestMarketingDevelopment {
    static testMethod void testProprietorRequireReview(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaMarketingDevelopmentAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaMarketingDevelopmentAdd';
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

        ResourceApproval__c rc = new ResourceApproval__c();
        rc.SealApplication__c = '否';
        rc.FileType__c = '';
        rc.AgreementIntroduction__c = '';
        rc.ResourceArea__c = '';
        rc.AgreementName__c = '';
        rc.Approvalstatus__c = '11';
        rc.Process_Id__c = null ;
        rc.Business_Type__c = '2';
        rc.Investment_Whether__c = false;
        insert rc ; 

        Seal_Related_Information__c sc = new Seal_Related_Information__c();
        sc.Document_Category__c = '1';
        sc.Document_Name__c = '111';
        sc.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313';
        sc.Seal_Type__c = '公章';
        sc.Seal_Numble__c = '11';
        sc.Resource_Development_Agreement__c = rc.id ; 
        insert sc ; 
        

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
        ControllerMarketingDevelopment.toCreateMarketingDevelop(rc.id);
        System.Test.stopTest();

    }

    static testMethod void testProprietorRequireReview1(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaMarketingDevelopmentAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaMarketingDevelopmentAdd';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

       

        ResourceApproval__c rc = new ResourceApproval__c();
        rc.SealApplication__c = '是';
        rc.Seal_Org__c = '基地';
        rc.Seal_Safekeep_Dept__c = '青海基地';
        rc.FileType__c = '';
        rc.AgreementIntroduction__c = '';
        rc.ResourceArea__c = '';
        rc.AgreementName__c = '';
        rc.Approvalstatus__c = '11';
        rc.Process_Id__c = null ;
        rc.Business_Type__c = '2';
        rc.Investment_Whether__c = false;
        insert rc ; 

        Seal_Related_Information__c sc = new Seal_Related_Information__c();
        sc.Document_Category__c = '1';
        sc.Document_Name__c = '111';
        sc.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313';
        sc.Seal_Type__c = '公章';
        sc.Seal_Numble__c = '11';
        sc.Resource_Development_Agreement__c = rc.id ; 
        insert sc ; 
        

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
        ControllerMarketingDevelopment.toCreateMarketingDevelop(rc.id);
        System.Test.stopTest();

    }

    class ProprietorRequireReview_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "流程启动成功！","data": {"rtStatus": "Y","rtMsg": "流程启动成功！","fdId": "17d04b3b98d9e690c169b1947e398e78","docSubject": "检测前沿开发组_何建斌_营销资源开发协议/合同审批单_2021-11-09_MS-FZYXYHQ-20211109002","fdNumber": "MS-FZYXYHQ-20211109002","Data": null,"data": null}}');
			return response;
		}
	}
}