@isTest
public with sharing class Test_RestRptContract {
    @TestSetup
    static void makeData(){

        Interface_Log__c logInfo = new Interface_Log__c();
        logInfo.RequestURL__c = '/RptContract';
        logInfo.ClassName__c = 'Rest_RptContract';
        logInfo.RequestBody__c = '';
        insert logInfo;

        //客户数据
        Account acc = new Account();
        acc.Name = '广州风机';
        acc.BeenGroup__c = true;
        acc.Accounttype__c = '已交易客户';
        insert acc;

        //简档数据
        Profile manageprofile = [SELECT Id FROM Profile WHERE Name='O项目经理'];

        //用户数据
        User user1 = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1110.com');
        insert user1;

        //商机数据
        Opportunity opp  = new Opportunity();
        opp.Name = 'opp';
        opp.ProjectSubmission__c = '正常提报线索';
        opp.ProjectProductType__c = '01';
        opp.AccountId = acc.Id;
        opp.Wind_Farm_Project_Name__c = '风场项目名';
        opp.capacity__c = 12;
        opp.StageName ='招投标';
        opp.Province__c = '广东';
        opp.City__c = '中山';
        opp.CloseDate = System.today();
        opp.Periods__c = '一';
        opp.Close__c = false;
        opp.recordTypeId = '0122u0000008UxEAAU';
        opp.MarketBidDept__c = 'KA101';
        opp.ProjectArea__c = 'SR101';
        opp.ProjectDeliveryMarket__c = '01';
        opp.OwnerId = user1.Id;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        insert opp;

        Contractmanagement__c contract = new Contractmanagement__c();

        contract.TaskStatus__c = '进行中';
        contract.ContractNegotiationStartDate__c = null ; 
        contract.ContractSigningEndDate__c = null ; 
        contract.ObjectName__c  =opp.id;
        contract.Company__c =acc.id ; 
        contract.Approvalstatus__c = '30';
        contract.Process_Id__c = '1111';
        insert contract;

    }

    static testMethod void test_doGet(){

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Success_Mock());
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf('{}');
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Rest_RptContract.doPost();
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