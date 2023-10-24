@isTest
public with sharing class Test_RestBasicData {
    @TestSetup
    static void makeData(){
        BasicData__c ba = new BasicData__c();
        ba.name = 'aa';
        ba.BasicNo__c = '11';
        insert ba;
    }

    static testMethod void test_doGet(){

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Success_Mock());
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf('{}');
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Rest_BasicData.doPost();
        System.Test.stopTest();

    }


    class Success_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"status": 200,"errorMessage": "成功!"}');
			return response;
		}

	}

    static testMethod void testError(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Error_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Rest_RptContract.doPost();
        System.Test.stopTest();

    }

    class Error_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(401);
			response.setStatus('OK');
			response.setBody('{"code": 5003,"message": "异常!"}');
			return response;
		}

	}
}