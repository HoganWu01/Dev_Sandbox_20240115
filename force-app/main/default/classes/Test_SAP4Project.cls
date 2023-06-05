/*
 * @Descripttion: Controller_SAP4Project sap4项目创建和阶段变更 测试类
 * @Author: Hogan
 * @Date: 2023-01-12 08:51:24
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-01-12 14:43:47
 */
@isTest
public with sharing class Test_SAP4Project {
    @TestSetup 
    static void setData() {

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

        User user2 = new User(Alias = '格日图222', Email='standarduser222@testorg.com',EmailEncodingKey='UTF-8', LastName='Test120', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test120.com');
        insert user2;

        //添加客户分部记录
        MarketBidDept__c mb1 = new MarketBidDept__c(Name = '客户一部', General_Manager_User__c = user1.Id, DeptPickList__c = '162092f16daa04f4de53a694724b93ac', DeptId__c = '162092f16daa04f4de53a694724b93ac');
        insert mb1;
        MarketBidDept__c mb2 = new MarketBidDept__c(Name = '客户二部', General_Manager_User__c = user2.Id, DeptPickList__c = '162092f16e0f16e08b24fb54940ac5c7', DeptId__c = '162092f16e0f16e08b24fb54940ac5c7');
        insert mb2;

        //添加大区、售前项目经理记录
        Integrated_Middle_Table__c mid1 = new Integrated_Middle_Table__c(Salesdepartment__c = '西南大区', RecordTypeId = '0122u0000008V2DAAU', OppChiefgeneralmanager__c = user1.Id, Pre_Sales_Project_Manager__c = user1.Id);
        insert mid1;
        Integrated_Middle_Table__c mid2 = new Integrated_Middle_Table__c(Salesdepartment__c = '东北大区', RecordTypeId = '0122u0000008V2DAAU', OppChiefgeneralmanager__c = user2.Id, Pre_Sales_Project_Manager__c = user2.Id);
        insert mid2;

        //外部系统参数数据--sap项目创建
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'sapProjectAdd';
        ext.Request_URL__c = '	/saps4/Sap2CrmApi/sapProjectAdd';
        insert ext ; 

        //外部系统参数数据--sap项目阶段变更
        External_System_Param__c ext2 = new External_System_Param__c();
        ext2.name = 'sapProjectStatus';
        ext2.Request_URL__c = '	/saps4/Sap2CrmApi/sapProjectStatus';
        insert ext2 ; 

        //外部系统参数数据--sap项目名称变更
        External_System_Param__c ext3 = new External_System_Param__c();
        ext3.name = 'sapProjectModify';
        ext3.Request_URL__c = '	/saps4/Sap2CrmApi/sapProjectModify';
        insert ext3 ; 

        //省份数据
        ZProvince__c  zProv = new ZProvince__c(Name = '	CN_190', Province_Code__c = '190', Province__c = '广东');
        insert zProv;

        //接口平台配置数据
        OpenPlatformApi__c open = new OpenPlatformApi__c();
        open.Name = 'GetToken';
        open.Client_Id__c = 'aHI6XXcIxmO5CVfXkPE80sPA';
        open.Client_Secret__c = 'vSaQLaO7Bhp5jK0CGgkoJO4NpO41b4ZZ';
        open.Grant_Type__c = 'client_credentials';
        open.IP__c = 'http://61.142.78.5:8011';
        open.URL__c = 'http://61.142.78.5:8011/admin/oauth/token';
        insert open;

        Opportunity opp  = new Opportunity();
        opp.Name = 'opp';
        opp.ProjectSubmission__c = '正常提报线索';
        opp.Projecttype__c = '陆上项目';
        opp.AccountId = acc.Id;
        opp.Wind_Farm_Project_Name__c = '风场项目名';
        opp.capacity__c = 12;
        opp.StageName ='线索管理';
        opp.Province__c = '广东';
        opp.City__c = '中山';
        opp.CloseDate = System.today();
        opp.Periods__c = '一';
        opp.Close__c = false;
        opp.recordTypeId = '0122u0000008UxEAAU';
        opp.Salesdepartment__c = '西南大区';
        opp.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp.OwnerId = user1.Id;
        opp.OpportunityApprovalStatus__c = '草稿';
        insert opp;
    }


    /**
     * @Descripttion: 项目创建测试类
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_SAP4ProjectAdd() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;

        // opp.Province__c = '';
        // update opp;

        opp.OpportunityApprovalStatus__c = '线索提报通过';
        update opp;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    //去掉省份
    static testMethod void test_SAP4ProjectAdd2() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.Province__c = '';
        opp.OpportunityApprovalStatus__c = '线索提报通过';
        update opp;

        // System.Test.startTest();
        // System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_Mock());
        // RestRequest request = new RestRequest();
		// RestResponse response = new RestResponse();
		// RestContext.response = response;
		// RestContext.request = request;
        // System.Test.stopTest();
    }

    static testMethod void test_SAP4ProjectAdd_Error() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.OpportunityApprovalStatus__c = '线索提报通过';
        update opp;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_ErrorMock());
        RestRequest request1 = new RestRequest();
		RestResponse response1 = new RestResponse();
		RestContext.response = response1;
		RestContext.request = request1;
        System.Test.stopTest();
    }

    static testMethod void test_SAP4ProjectAdd_Error2() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.OpportunityApprovalStatus__c = '线索提报通过';
        update opp;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_ErrorMock2());
        RestRequest request1 = new RestRequest();
		RestResponse response1 = new RestResponse();
		RestContext.response = response1;
		RestContext.request = request1;
        System.Test.stopTest();
    }

    static testMethod void test_SAP4ProjectAdd_Error3() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.OpportunityApprovalStatus__c = '线索提报通过';
        update opp;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_ErrorMock3());
        RestRequest request1 = new RestRequest();
		RestResponse response1 = new RestResponse();
		RestContext.response = response1;
		RestContext.request = request1;
        System.Test.stopTest();
    }

    /**
     * @Descripttion: 标段项目创建测试类
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_SAP4SectionProjectAdd() {
        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;

        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '招投标';
        update opp;

        Contractmanagement__c contract = new Contractmanagement__c();
        //contract.name = 'con';
        contract.ObjectName__c = oppId ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();
        insert contract ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    static testMethod void test_SAP4SectionProjectAdd_Error() {
        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;

        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '招投标';
        update opp;

        Contractmanagement__c contract = new Contractmanagement__c();
        //contract.name = 'con';
        contract.ObjectName__c = oppId ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();
        insert contract ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_ErrorMock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    static testMethod void test_SAP4SectionProjectAdd_Error2() {
        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;

        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '招投标';
        update opp;

        Contractmanagement__c contract = new Contractmanagement__c();
        //contract.name = 'con';
        contract.ObjectName__c = oppId ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();
        insert contract ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_ErrorMock2());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    static testMethod void test_SAP4SectionProjectAdd_Error3() {
        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;

        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '招投标';
        update opp;

        Contractmanagement__c contract = new Contractmanagement__c();
        //contract.name = 'con';
        contract.ObjectName__c = oppId ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();
        insert contract ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_ErrorMock3());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    //省份为空
    static testMethod void test_SAP4SectionProjectAdd_Error4() {
        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;

        Opportunity opp = new Opportunity();
        opp.Id = oppId;

        opp.Province__c = '';
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '招投标';
        update opp;

        Contractmanagement__c contract = new Contractmanagement__c();
        //contract.name = 'con';
        contract.ObjectName__c = oppId ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();
        insert contract ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }


    /**
     * @Descripttion: 修改SAP项目名称测试类
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_SAP4ProjectNameUpdate() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.ProjectNumber__c = 'S1-20220101';

        opp.Periods__c = '二';
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '合同商务';
        opp.Close__c = true;
        update opp;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    /**
     * @Descripttion: 修改SAP项目名称测试类---多合同
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_SAP4ProjectNameUpdate2() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.ProjectNumber__c = 'S1-20220101';

        opp.Periods__c = '二';
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '合同商务';
        opp.Close__c = true;
        update opp;

        Contractmanagement__c contract = new Contractmanagement__c();
        contract.ObjectName__c = oppId ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();
        insert contract ; 

        Contractmanagement__c contract2 = new Contractmanagement__c();
        contract2.ObjectName__c = oppId ; 
        contract2.Firstcontractcompletion__c = Datetime.now().date();
        contract2.Contractstage__c = '初版评审';
        contract2.MeetingStartDate__c = Datetime.now().date();
        contract2.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract2.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();
        insert contract2 ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    static testMethod void test_SAP4ProjectNameUpdate_Error() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.ProjectNumber__c = 'S1-20220101';

        opp.Periods__c = '二';
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '合同商务';
        update opp;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_ErrorMock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    static testMethod void test_SAP4ProjectNameUpdate_Error2() {

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.ProjectNumber__c = 'S1-20220101';

        opp.Periods__c = '二';
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.StageName = '合同商务';
        update opp;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Sap4ProjectAdd_ErrorMock2());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        System.Test.stopTest();
    }

    //模拟正常响应
    class Sap4ProjectAdd_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code":200,"message":"项目创建成功","path":"","data":[{"pspid":"S1-20220079","post1":"大唐河北元创商机驳回测试100MW","obj":"","type":"S","message":"项目创建成功"}],"extra":{},"extraStr":{},"timestamp":"20221217114828","status":{}}');
			return response;
		}
	}

    //模拟响应码500
    class Sap4ProjectAdd_ErrorMock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(500);
			response.setStatus('OK');
			response.setBody('{"code":500,"message":"调用失败","path":"","data":[],"extra":{},"extraStr":{},"timestamp":"20221217114828","status":{}}');
			return response;
		}
	}

    //模拟返回体data为空
    class Sap4ProjectAdd_ErrorMock2 implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code":200,"message":"success","path":"","data":[],"extra":{},"extraStr":{},"timestamp":"20221217114828","status":{}}');
			return response;
		}
	}

     //模拟状态码200，事务码500
     class Sap4ProjectAdd_ErrorMock3 implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code":500,"message":"调用失败","path":"","data":[],"extra":{},"extraStr":{},"timestamp":"20221217114828","status":{}}');
			return response;
		}
	}
    
}