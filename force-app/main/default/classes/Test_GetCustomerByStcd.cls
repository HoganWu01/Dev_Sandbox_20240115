@isTest
public with sharing class Test_GetCustomerByStcd {
    @TestSetup
    static void makeData(){

       Account acc = new Account();
       acc.name = 'aaa';
       acc.BeenGroup__c = true ; 
       acc.Officialcode__c = '916523283288373140';
       insert acc;

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'sapgetCustomerByStcd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/getCustomerByStcd';
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
    }

    static testMethod void testGetCustomerByStcd(){

        //Account acc = [SELECT ID,NAME FROM Account WHERE NAME = 'aaa'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new GetCustomerByStcd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_GetCustomerByStcd.getCustomerByStcd('已冻结');
        System.Test.stopTest();

    }


    class GetCustomerByStcd_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "查询成功!","data": [{"kunnr": "0000140005","uname": "黄毅","ktokd": "ZD01","stcd5": "已冻结","name1": "云南华电新能源项目筹备处—冻结","ernam": "A01242"}]}');
			return response;
		}

	}

    static testMethod void testError(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new GetCustomerByStcd_Mock_Error());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_GetCustomerByStcd.getCustomerByStcd('已冻结');
        System.Test.stopTest();

    }

    class GetCustomerByStcd_Mock_Error implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(401);
			response.setStatus('OK');
			response.setBody('{"code": 5003,"message": "异常!"}');
			return response;
		}

	}
}