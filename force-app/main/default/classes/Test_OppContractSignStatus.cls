@isTest
public with sharing class Test_OppContractSignStatus {
    @TestSetup
    static void makeData(){

        Interface_Log__c logInfo = new Interface_Log__c();
        logInfo.RequestURL__c = '/OppContractSignStatus';
        logInfo.ClassName__c = 'Rest_OppContractSignStatus';
        logInfo.RequestBody__c = '';
        insert logInfo;

        //客户数据
        Account acc = new Account();
        acc.Name = '广州风机';
        acc.BeenGroup__c = true;
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
        opp.Projecttype__c = '陆上项目';
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
        opp.Salesdepartment__c = '西南大区';
        opp.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp.OwnerId = user1.Id;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        insert opp;

        Contractmanagement__c cm=new Contractmanagement__c();
        cm.Contractname__c='合同';
        cm.WBS__c='123';
        cm.Approvalstatus__c='10';
        cm.DifferentCountries__c='国内非关联方';
        cm.WBS__c='S1-00010001';
        cm.TaskStatus__c='进行中';
        cm.ObjectName__c=opp.Id;
        insert cm;
    }

    static testMethod void test_doGet(){

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OppContractSignStatus_Mock());
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf('{"projectNumber":"S1-00010001"}');
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Rest_OppContractSignStatus.doPost();
        System.Test.stopTest();

    }


    class OppContractSignStatus_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"status": 200,"errorMessage": "查询成功!","data":[{"projectNumber":"S1-00010001","accountName":"中电建","accountShortName":"中电建","marketBidDept":"客户一部","taskStatus":"进行中"}]}');
			return response;
		}

	}

    static testMethod void testError(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OppContractSignStatus_Mock_Error());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Rest_OppContractSignStatus.doPost();
        System.Test.stopTest();

    }

    class OppContractSignStatus_Mock_Error implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(401);
			response.setStatus('OK');
			response.setBody('{"code": 5003,"message": "异常!"}');
			return response;
		}

	}
}