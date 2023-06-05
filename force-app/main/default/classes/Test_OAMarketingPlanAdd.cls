@isTest
public with sharing class Test_OAMarketingPlanAdd {
    @TestSetup
    static void makeData(){
       
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaMarketingPlanAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaMarketingPlanAdd';
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

        Project_Scheme_Application_Form__c proScheme = new Project_Scheme_Application_Form__c();
        proScheme.Approval_Comments__c = '请审批';
        //proScheme.Applicant_Num__c = '1';
        proScheme.Aftermarketornot__c = '';
        //proScheme.Owner_Department__c = '';
        //proScheme.Owner_Title__c = '销售经理';
        //proScheme.Applicant_Num__c = '';
        proScheme.Demandtype__c = '';
        //proScheme.City__c = '' ; 
        proScheme.Technicalexchange__c='产品推介' ; 
        proScheme.Demandstatement__c = '新增需求';
        insert proScheme ; 

        Resource_Project_Scheme_Application__c proScheme1 = new Resource_Project_Scheme_Application__c();
        proScheme1.Aftermarketornot__c = '';
        proScheme1.Demandtype__c = '';
       // proScheme1.City__c = '';
        proScheme1.TechnicalCommunicationType__c='方案交流';
        proScheme1.Requirement_Description__c = '新增需求';
        //proScheme1.ResourceProjectName__c = '';
        proScheme1.Resource_Development__c = '自主开发';
        insert proScheme1 ; 

        Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
        i.Mapping_Object_Id__c = proScheme1.id ; 
        insert i  ;

    }

    static testMethod void testOAMarketingPlanAdd(){

        String id = [SELECT ID,NAME,Technicalexchange__c FROM Project_Scheme_Application_Form__c WHERE Technicalexchange__c= '产品推介'].Id ;
        //String id1 = [SELECT ID,NAME,Technicalexchange__c FROM Project_Scheme_Application_Form__c WHERE City__c= '中山'].Id ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAMarketingPlanAdd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAMarketingPlanAdd.MarketingPlanAdd(id);
        System.Test.stopTest();
    }

    static testMethod void testOAMarketingPlanAdd1(){

        String id1 = [SELECT ID,NAME FROM Resource_Project_Scheme_Application__c WHERE TechnicalCommunicationType__c= '方案交流'].Id ; 

        Integrated_Middle_Table__c imt = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:id1][0];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAMarketingPlanAdd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAMarketingPlanAdd.ResourcesPlanAdd(id1);
        System.Test.stopTest();
    }

    class OAMarketingPlanAdd_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "流程启动成功！","data": {"rtStatus": "Y","rtMsg": "流程启动成功！","fdId": "17cfd929407ed9799f4cf3849c1bcd43","docSubject": "_检测前沿开发组_何建斌_营销项目方案申请单_2021-11-08_MF-XMFASQB20211108001","fdNumber": "MF-XMFASQB20211108001","Data": null,"data": null}}');
			return response;
		}

	}
}