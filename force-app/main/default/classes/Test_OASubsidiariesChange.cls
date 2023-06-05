@isTest
public with sharing class Test_OASubsidiariesChange {

	@TestSetup
    static void makeData(){

		External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaSubsidiariesChange';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaSubsidiariesChange';
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

		Controller_OASubsidiariesChange.Data d = new Controller_OASubsidiariesChange.Data();

		d.fdNumber = '123';
		d.rtMsg = '123';
		d.rtStatus = 'Y';

		Controller_OASubsidiariesChange.ResponseBody r = new Controller_OASubsidiariesChange.ResponseBody();

		r.message='222';

	}


    static testMethod void testSubsidiariesChange(){

		ResourceProjectApplication__c cc = new ResourceProjectApplication__c();
		cc.ApplicantionNumber__c = 'TZYZCBG20211115034';
		insert cc ; 

        CompanyRegisterApplication__c companyRegister = new CompanyRegisterApplication__c();
		companyRegister.CorrespondingProjectApplication__c = cc.id ; 
        companyRegister.Approval_Comments__c = '请审批';
        companyRegister.SigningAgreement__c = '是';
        companyRegister.ApprovalReason__c = '1';
		companyRegister.EquityAcquisitionDescription__c = 'aaa';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.EquityRatio__c = 0.2;
		companyRegister.EquityCounterparty__c = 'a';
		companyRegister.CapitalAddress__c = '中山';
		companyRegister.CompanyRegistrationDescription__c = 'qqq';
		companyRegister.ChangeManagementCompanyName__c = 'ddd';
		companyRegister.ChangeManagementInstrusction__c = 'q';
		//companyRegister.SubsidiaryChangeManagementCategory__c = '2';
		companyRegister.LogoutCompanyName__c = 'LogoutCompanyName__c';
		companyRegister.EquityWriteoffsNotes__c = 'eee';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.CapitalChangeDescription__c = 'uuu';
		companyRegister.ChangeSubsidiaryCapitalReason__c = 'ppp';
		companyRegister.InvestmentProjectApplicationType__c = '1';
		companyRegister.SoleProprietorshipOrJointVenture__c = '否';
		companyRegister.RegisterCapital__c = '8';
		companyRegister.CompanyName_Registered__c = 'ccc';
		companyRegister.ProjectName__c = 'ccc';
		//companyRegister.CorrespondingOANumber__c = 'TZYZCBG20211115034';
		companyRegister.SubsidiaryInvestmentsApplicationCause__c = 'sss';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.EquityTransferCompanyName__c = 'ccc';
		companyRegister.Field1__c = 'ccc';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.Approvalstatus__c='11';
		insert companyRegister;

		recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];

		Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
        i.Mapping_Object_Id__c = companyRegister.id ; 
		i.RecordTypeId = imtRecordType.id;
        insert i  ;

		System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SubsidiariesChange_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OASubsidiariesChange.OASubsidiariesChange(companyRegister.id);
        System.Test.stopTest();
        
    }


	static testMethod void testSubsidiariesChange1(){

		ResourceProjectApplication__c cc = new ResourceProjectApplication__c();
		cc.ApplicantionNumber__c = 'TZYZCBG20211115034';
		insert cc ; 

        CompanyRegisterApplication__c companyRegister = new CompanyRegisterApplication__c();
		companyRegister.CorrespondingProjectApplication__c = cc.id ; 
        companyRegister.Approval_Comments__c = '请审批';
        companyRegister.SigningAgreement__c = '是';
        companyRegister.ApprovalReason__c = '1';
		companyRegister.EquityAcquisitionDescription__c = 'aaa';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.EquityRatio__c = 0.2;
		companyRegister.EquityCounterparty__c = 'a';
		companyRegister.CapitalAddress__c = '中山';
		companyRegister.CompanyRegistrationDescription__c = 'qqq';
		companyRegister.ChangeManagementCompanyName__c = 'ddd';
		companyRegister.ChangeManagementInstrusction__c = 'q';
		//companyRegister.SubsidiaryChangeManagementCategory__c = '2';
		companyRegister.LogoutCompanyName__c = 'LogoutCompanyName__c';
		companyRegister.EquityWriteoffsNotes__c = 'eee';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.CapitalChangeDescription__c = 'uuu';
		companyRegister.ChangeSubsidiaryCapitalReason__c = 'ppp';
		companyRegister.InvestmentProjectApplicationType__c = '1';
		companyRegister.SoleProprietorshipOrJointVenture__c = '否';
		companyRegister.RegisterCapital__c = '8';
		companyRegister.CompanyName_Registered__c = 'ccc';
		companyRegister.ProjectName__c = 'ccc';
		//companyRegister.CorrespondingOANumber__c = 'TZYZCBG20211115034';
		companyRegister.SubsidiaryInvestmentsApplicationCause__c = 'sss';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.EquityTransferCompanyName__c = 'ccc';
		companyRegister.Field1__c = 'ccc';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.Approvalstatus__c='10';
		insert companyRegister;

		recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];

		Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
        i.Mapping_Object_Id__c = companyRegister.id ; 
		i.RecordTypeId = imtRecordType.id;
        insert i  ;

		System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new SubsidiariesChange_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OASubsidiariesChange.OASubsidiariesChange(companyRegister.id);
        System.Test.stopTest();
        

    }


    class SubsidiariesChange_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "流程启动成功！","data": {"rtStatus": "Y","rtMsg": "流程启动成功！","fdId": "17d22a89d5e57471ae1e25d4465939f3","docSubject": "检测前沿开发组_何建斌_子公司投资与注册变更事前申请_TZYZCBG20211115033","fdNumber": "TZYZCBG20211115033","Data": null}}');
			return response;
		}

	}

	static testMethod void testResponseError(){

		ResourceProjectApplication__c cc = new ResourceProjectApplication__c();
		cc.ApplicantionNumber__c = 'TZYZCBG20211115034';
		insert cc ; 

        CompanyRegisterApplication__c companyRegister = new CompanyRegisterApplication__c();
		companyRegister.CorrespondingProjectApplication__c = cc.id ; 
        companyRegister.Approval_Comments__c = '请审批';
        companyRegister.SigningAgreement__c = '是';
        companyRegister.ApprovalReason__c = '1';
		companyRegister.EquityAcquisitionDescription__c = 'aaa';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.EquityRatio__c = 0.2;
		companyRegister.EquityCounterparty__c = 'a';
		companyRegister.CapitalAddress__c = '中山';
		companyRegister.CompanyRegistrationDescription__c = 'qqq';
		companyRegister.ChangeManagementCompanyName__c = 'ddd';
		companyRegister.ChangeManagementInstrusction__c = 'q';
		//companyRegister.SubsidiaryChangeManagementCategory__c = '2';
		companyRegister.LogoutCompanyName__c = 'LogoutCompanyName__c';
		companyRegister.EquityWriteoffsNotes__c = 'eee';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.CapitalChangeDescription__c = 'uuu';
		companyRegister.ChangeSubsidiaryCapitalReason__c = 'ppp';
		companyRegister.InvestmentProjectApplicationType__c = '1';
		companyRegister.SoleProprietorshipOrJointVenture__c = '否';
		companyRegister.RegisterCapital__c = '8';
		companyRegister.CompanyName_Registered__c = 'ccc';
		companyRegister.ProjectName__c = 'ccc';
		//companyRegister.CorrespondingOANumber__c = 'TZYZCBG20211115034';
		companyRegister.SubsidiaryInvestmentsApplicationCause__c = 'sss';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.EquityTransferCompanyName__c = 'ccc';
		companyRegister.Field1__c = 'ccc';
		companyRegister.ProjectName__c = 'ccc';
		companyRegister.Approvalstatus__c='10';
		insert companyRegister;

		recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];

		Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
        i.Mapping_Object_Id__c = companyRegister.id ; 
		i.RecordTypeId = imtRecordType.id;
        insert i  ;

		System.Test.startTest();
		System.test.setMock(HttpCalloutMock.class,new SubsidiariesChange_Mock_Error());
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
		Controller_OASubsidiariesChange.OASubsidiariesChange(companyRegister.id);
		System.Test.stopTest();
        

    }
	
	class SubsidiariesChange_Mock_Error implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 401,"message": "异常！","data": {}}');
			return response;
		}

	}
}