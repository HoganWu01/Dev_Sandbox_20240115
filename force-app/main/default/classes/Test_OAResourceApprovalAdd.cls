@isTest
public with sharing class Test_OAResourceApprovalAdd {
    @TestSetup
    static void makeData(){
       

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaResourceApprovalAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaResourceApprovalAdd';
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

        ResourceMember__c rc = new ResourceMember__c();
        //rc.ProjectDivision__c = '项目分工';
        //rc.Department__c = '';
        //rc.Name_Project_Member__c = '';
        //rc.Position__c = '';
        insert rc ; 

        List<String> divisionLaborsList = new List<String>();//项目分工

        ResourceProjectApplication__c rpc = new ResourceProjectApplication__c();
        rpc.Approval_Comments__c = '';
        //rpc.Applicant_Num__c = '';
        rpc.DebtAssetRatioMax__c = null ; 
        //rpc.Owner_Department__c = '';
        //rpc.Applicant_Num__c = '';
        rpc.ProjectBackground__c = '';
       // rpc.City__c = '中山';
        rpc.ConstructionImplementationPlan__c = '建设实施方案';
        rpc.TotalCost__c = 19890;
        rpc.ResponseMeasures__c = '应对措施';
        rpc.ApplyerDepartment__c = '华北大区';
        rpc.Electrovalency__c = 0.38 ; 
        rpc.ConstructionPeriodInterest__c = 19890 ; 
        rpc.InvestmentPerKW__c = 20000;
        rpc.TotalInternetPower__c = 280979  ;
        rpc.PowerTotalProfits__c = 19890 ; 
        //rpc.ProjectName__c = '中山xx光伏项目';
        rpc.ProjectIntroduce__c = '项目介绍';
        rpc.ProjectType__c = '风电项目';
        rpc.Capacity__c = 2;
        rpc.Province__c = '广东';
        rpc.OwnInvestmentIRR__c = 13 ; 
        rpc.AllIRR__c = 9 ; 
        rpc.RiskAssessment__c = '风险评估';
        rpc.PowerTotalSalesRevenue__c = 10786;
        //rpc.SalesTax__c = '';
        rpc.ExpectedStrategicSignificance__c='项目的预期战略意义';
        rpc.ProjectArea__c = '能源技术公司';
        insert rpc;
    }
    
    static testMethod void testOAGetApprovalRecords(){

        String id = [SELECT ID,NAME FROM ResourceProjectApplication__c WHERE ProjectArea__c= '能源技术公司' ].Id ; 

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new OAGetApprovalRecords_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OAResourceApprovalAdd.ResourceApprovalAdd(id);
        System.Test.stopTest();
    }

    class OAGetApprovalRecords_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "流程启动成功！","data": {"rtStatus": "Y","rtMsg": "流程启动成功！","fdId": "17cfd83253bee8288134e6a4aaf9a63f","docSubject": "中山xx光伏项目_检测前沿开发组_何建斌_资源立项申请单_2021-11-08_ZYLXSQ20211108093","fdNumber": "ZYLXSQ20211108093","Data": null,"data": null}}');
			return response;
		}

	}
}