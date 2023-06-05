@isTest
public with sharing class Test_TaxCheckDuplicate {

    @TestSetup 
    static void setData() {

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'sapCustomer';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/sapCustomer';
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

        Controller_TaxCheckDuplicate.SAPResponseBody d = new Controller_TaxCheckDuplicate.SAPResponseBody();

        d.message = 'www';

        Controller_TaxCheckDuplicate.SAPCustomRequestBody s = new Controller_TaxCheckDuplicate.SAPCustomRequestBody();

        s.kunnr = '123';
        s.updateDate = '2021-12-12';

    }
      
    static testMethod void testTaxCheckDuplicate(){
        Account acc = new Account();
        acc.BeenGroup__c=true;
        acc.name = 'aaa';
        acc.Area__c = 'CN_290';
        acc.Street__c = 'S' ;
        acc.Country__c = 'CN';
        acc.AccountNumber = '';
        acc.Accounttype__c = '未交易客户';
        acc.Officialcode__c = '123456';
        insert acc ;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new TaxCheckDuplicate_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_TaxCheckDuplicate.TaxCheckDuplicate(acc.id);
        System.Test.stopTest();

        

    }

    static testMethod void testTaxCheckDuplicateerror(){
        Account acc = new Account();
        acc.BeenGroup__c=true;
        acc.name = 'aaa';
        acc.Area__c = 'CN_290';
        acc.Street__c = 'S' ;
        acc.Country__c = 'CN';
        acc.AccountNumber = '';
        acc.Accounttype__c = '未交易客户';
        acc.Officialcode__c = '123456';
        insert acc ;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new TaxCheckDuplicateError_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_TaxCheckDuplicate.TaxCheckDuplicate(acc.id);
        System.Test.stopTest();

    }


    class TaxCheckDuplicate_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data": [{"kunnr": "R202244","name1Kna1": "新建测试客户20211210测已交易客户","sortl": "20211210","street": " ","regio": " ","land1": "CN","stcd5": "123456"}]}');
			return response;
		}
	}

    class TaxCheckDuplicateError_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('Errorerrorrrr');
			return response;
		}
	}
}