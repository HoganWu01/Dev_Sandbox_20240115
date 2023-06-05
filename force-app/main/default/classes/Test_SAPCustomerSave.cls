@isTest
public with sharing class Test_SAPCustomerSave  {

    @TestSetup 
    static void setData() {

        External_System_Param__c extsp = new External_System_Param__c();
        extsp.name = 'sapCustomer';
        extsp.Request_URL__c = 'http://61.142.78.7:8001/api/sapCustomer';
        extsp.Request_Source__c = '2';
        extsp.Request_Method__c = 'sapTestAdd';
        extsp.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        extsp.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert extsp ; 

       External_System_Param__c ext = new External_System_Param__c();
       ext.name = 'sapCustomerSave';
       ext.Request_URL__c = 'http://61.142.78.7:8001/api/sapCustomerSave';
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

       Company__c company = new Company__c();
       company.name = 'com';
       company.CompanySelfCode__c = 'Z001';

       insert company ; 

       Account acc = new Account(name='acc');
       acc.CompanyCode__c = company.id;
       acc.ReconciliationSubjects__c = '1122010000';
       acc.PricingProcess__c = '1';
       acc.PriceGroup__c = '01';
       acc.AccountAllocationGroup__c = '01';
       acc.CustomerAccountGroup__c = 'Z001';
       acc.AccountNumber = '0000990663';
       acc.Country__c = 'CN';
       acc.Area__c = '	CN_010';
       acc.Officialcode__c = '123456';
       acc.Shortname__c = '隆多';
       acc.ProductGroup__c = '10';
       acc.Street__c = '昌岗';
       acc.Fax = '';
       acc.TaxType__c = '0';
       acc.Phone = '';
       acc.SalesrOrganization__c = '6001';
       acc.ShippingConditions__c = '01';
       acc.DistributionChannels__c = '90';
       acc.PaymentTerms__c = 'Z003';
       acc.BeenGroup__c = true ; 
       acc.Accounttype__c = '未交易客户';
       insert acc ; 
       
       Account acc2 = new Account(name='acc2');
       acc2.CompanyCode__c = company.id;
       acc2.ReconciliationSubjects__c = '1122010000';
       acc2.PricingProcess__c = '1';
       acc2.PriceGroup__c = '01';
       acc2.AccountAllocationGroup__c = '01';
       acc2.CustomerAccountGroup__c = 'Z001';
       acc2.AccountNumber = '0000990666';
       acc2.Country__c = 'CN';
       acc2.Area__c = '	CN_010';
       acc2.Officialcode__c = 'abcd';
       acc2.Shortname__c = '隆多';
       acc2.ProductGroup__c = '10';
       acc2.Street__c = '昌岗';
       acc2.Fax = '';
       acc2.TaxType__c = '0';
       acc2.Phone = '';
       acc2.SalesrOrganization__c = '6001';
       acc2.ShippingConditions__c = '01';
       acc2.DistributionChannels__c = '90';
       acc2.PaymentTerms__c = 'Z003';
       acc2.BeenGroup__c = true ; 
       acc2.Accounttype__c = '未交易客户';
       insert acc2 ; 

       Controller_SAPCustomerSave.RequestBody r = new Controller_SAPCustomerSave.RequestBody();
       r.taxnum = 'aaa';

       Controller_SAPCustomerSave.ResponseBody res = new Controller_SAPCustomerSave.ResponseBody();
        res.data = 'ddd';

        Controller_SAPCustomerSave.SAPCustomRequestBody sapres = new Controller_SAPCustomerSave.SAPCustomRequestBody();
        sapres.updateDate = '2021-08-01';

        Controller_SAPCustomerSave.SAPResponseBody mmm = new Controller_SAPCustomerSave.SAPResponseBody();
        mmm.message = 'msg';
    }

    static testMethod void testSAPCustomerTaxDuplicateJP(){
        Account acc = new Account();
        acc = [SELECT Id,Name from Account where Name = 'acc'] ;  

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new TaxCheckDuplicateJP_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_SAPCustomerSave.SAPCustomerSave(acc.id);
        System.Test.stopTest();
    }
    
    static testMethod void testSAPCustomerTaxDuplicate(){
        Account acc = new Account();
        acc = [SELECT Id,Name from Account where Name = 'acc'] ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new TaxCheckDuplicate_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;

        Controller_SAPCustomerSave.SAPCustomerSave(acc.id);
        System.Test.stopTest();
    }

    static testMethod void testSAPCustomerTaxDuplicate2(){
        Account acc = new Account();
        acc = [SELECT Id,Name from Account where Name = 'acc2'] ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new TaxCheckDuplicate_Mock2());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;

        Controller_SAPCustomerSave.SAPCustomerSave(acc.id);
        System.Test.stopTest();
    }

    static testMethod void testSAPCustomerSave(){
        Account acc = new Account();
        acc = [SELECT Id,Name from Account where Name = 'acc'] ; 

        String ResponseBody = '{"code": 200,"message": "客户同步成功;","data": ""}';

        Interface_Log__c logInfo = new Interface_Log__c();
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SAPCustomerSave_Mock());

        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;

        Controller_SAPCustomerSave.SyncSAPCustom(ResponseBody, logInfo, acc, true, true);
        System.Test.stopTest();
    }

    static testMethod void testSAPCustomerSave2(){
        Account acc = new Account();
        acc = [SELECT Id,Name from Account where Name = 'acc'] ; 

        String ResponseBody = 'Error';

        Interface_Log__c logInfo = new Interface_Log__c();
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SAPCustomerSave_Mock());

        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;

        Controller_SAPCustomerSave.SyncSAPCustom(ResponseBody, logInfo, acc, true, true);
        System.Test.stopTest();
    }

    class SAPCustomerSave_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "客户同步成功;","data": ""}');
			return response;
		}
	}

    class SAPCustomerAccDuplicate_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data": [{"kunnr": "0000990663","name1Kna1": "新疆明阳新能源产业有限公司","sortl": "新疆明阳","street": "大道10号 新疆吐鲁番市高昌区交河物流园现代","regio": "290","land1": "CN","stcd5": "91650400MA775ANK05"}]}');
			return response;
		}
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

    class TaxCheckDuplicate_Mock2 implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 2000,"message": null,"data": [{"kunnr": "R202244","name1Kna1": "新建测试客户20211210测已交易客户","sortl": "20211210","street": " ","regio": " ","land1": "CN","stcd5": "123456"}]}');
			return response;
		}
	}

    class TaxCheckDuplicateJP_Mock implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": null,"data": [{"kunnr": "R202244","name1Kna1": "新建测试客户20211210测已交易客户","sortl": "20211210","street": " ","regio": " ","land1": "JP","stcd5": "123456"}]}');
			return response;
		}
	}
}