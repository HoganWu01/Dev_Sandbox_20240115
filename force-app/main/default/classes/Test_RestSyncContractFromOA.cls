@isTest
public with sharing class Test_RestSyncContractFromOA {
    @TestSetup
    static void makeData(){

        Interface_Log__c logInfo = new Interface_Log__c();
        logInfo.RequestURL__c = '/SyncContractStatus';
        logInfo.ClassName__c = 'Rest_SyncContractFromOA';
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

        //员工数据
        Employee__c emp = new Employee__c(Job_Number__c = 'A00001', name = 'aaa', Duty__c = '顾问', Department__c = '小卖部', Department_Number__c = '111', Status__c = '在职');
        insert emp ; 

          //初始化集成中间表-总经理
        String recTypeIddd = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('OppSubCompany_RecordType').getRecordTypeId();
        Integrated_Middle_Table__c mid1 = new Integrated_Middle_Table__c(Salesdepartment__c = '西南大区', RecordTypeId = recTypeIddd, General_Manager_Company__c = emp.Id, Pre_Sales_Project_Manager__c = user1.Id);
        insert mid1;

        //初始客户分部总经理
        MarketBidDept__c md = new MarketBidDept__c(DeptPickList__c = '999999', DeptId__c = '999999', General_Manager_Emp__c = emp.Id);
        insert md;
        
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
        request.requestBody = Blob.valueOf('{"processId":"1111","taskStatus":"已完成","signingEndDate":"2023-06-19"}');
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Rest_SyncContractFromOA.doPost();
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
        Rest_SyncContractFromOA.doPost();
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