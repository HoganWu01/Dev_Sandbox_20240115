@isTest
public with sharing class Test_SAPProjectAdd {

    @TestSetup 
    static void setData() {

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        insert user1;

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '初期运作' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        OPP.OwnerId = user1.ID ; 
        insert opp;

        Projectapplication__c pac = new Projectapplication__c();
        pac.Oppty__c = opp.id ; 
        pac.Approvalstatus__c  = '30';
        insert pac ; 

    }



    @isTest
    static void test_Controller_SAPProjectAdd(){

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = '郑耿昭'];
       
        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        //UserRole role = [SELECT ID,NAME FROM UserRole WHERE NAME = '陆上PMO'];

        // UserRole userrole = new UserRole();
        // userrole.Name = '陆上PMO';
        // insert userrole ; 
 
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'ProjectType_RecordType'];

        Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
		i.RecordTypeId = imtRecordType.id;
        i.ProjectType__c = '陆上';
        i.RoleName__c = '陆上PMO' ; 
        insert i  ;

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'sapProjectAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/sapProjectAdd';
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

        //Project__c project = [select id,name from Project__c where name = 'pro'];

        Opportunity opp = [select id,name from Opportunity where name = 'opp'];

        Account acc = new Account();
        acc.BeenGroup__c = true ; 
        acc.name = 'acc';
        insert acc ; 

        Contractmanagement__c contract1 =[select id,name,ObjectName__c,Company__c from Contractmanagement__c where ObjectName__c =:opp.id ];

        delete contract1 ; 

        Contractmanagement__c contract = new Contractmanagement__c();

        contract.TaskStatus__c = '未开始';
        contract.Contractname__c = 'aaa';
        contract.ContractNegotiationStartDate__c = Datetime.now().date();
        contract.ContractNegotiationEndDate__c = Datetime.now().addDays(1).date();
        contract.ObjectName__c = opp.id ; 
        contract.Company__c = acc.id ; 
        //update contract ; 
        insert contract;

        Project__c project = new Project__c();
        project.ProjectManager__c=user.id ; 
        project.name = 'pro';
        project.Type__c = '陆上';
        project.Opportunity__c = opp.id ; 
        project.WBS__c = null;
        project.Projectnumber__c = null;
        project.InitialNumOfMachine__c = 2;
        project.ProjectCategory__c = 'S1';
        project.StandardProject__c = 'L1-20120000';
        project.ProgramYear__c = 2021;
        project.OwnerId = USER.ID;
        insert project;

       

		System.Test.startTest();
		System.test.setMock(HttpCalloutMock.class,new ProjectCreate_SAP_Mock());
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
		
        Controller_SAPProjectAdd.SAPProjectAdd(project.id,'aaa');

		System.Test.stopTest();

        Controller_SAPProjectAdd.RequestBody  reqqq= new Controller_SAPProjectAdd.RequestBody();
        reqqq.pfrom = 1 ; 
        reqqq.plfaz = '2021-12-12';
        reqqq.plsez = '2021-12-13';

        Controller_SAPProjectAdd.Data d = new Controller_SAPProjectAdd.Data();
        d.message = 'msg';
        d.obj = '2';
        d.type = 'S';

    }

    @isTest
    static void test_Controller_SAPProjectAddError(){

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = '郑耿昭'];
        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        //UserRole role = [SELECT ID,NAME FROM UserRole WHERE NAME = '陆上PMO'];

        // UserRole userrole = new UserRole();
        // userrole.name = '陆上PMO';
        // insert userrole ; 
       
        // User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        // insert user1;

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'ProjectType_RecordType'];

        Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
		i.RecordTypeId = imtRecordType.id;
        i.ProjectType__c = '陆上';
        i.RoleName__c = '陆上PMO';
        insert i  ;

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'sapProjectAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/sapProjectAdd';
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

        //Project__c project = [select id,name from Project__c where name = 'pro'];

        Opportunity opp = [select id,name from Opportunity where name = 'opp'];

        // Opportunity opp = new Opportunity();
        // opp.name = 'opp';
        // opp.StageName = '初期运作' ;
        // opp.CloseDate = Datetime.now().addMonths(1).date();
        // OPP.OwnerId = user1.ID ; 
        // insert opp;

        Account acc = new Account();
        acc.BeenGroup__c = true ; 
        acc.name = 'acc';
        insert acc ; 

        Contractmanagement__c contract =[select id,name,ObjectName__c,Company__c from Contractmanagement__c where ObjectName__c =:opp.id ];

        // contract.TaskStatus__c = '未开始';
        // contract.Contractname__c = 'aaa';
        // contract.ContractNegotiationStartDate__c = Datetime.now().date();
        // contract.ContractNegotiationEndDate__c = Datetime.now().addDays(1).date();
        // contract.ObjectName__c = opp.id ; 
        // contract.Company__c = acc.id ; 
        //update contract ; 
        //insert contract;

        Project__c project = new Project__c();
        project.ProjectManager__c=user.id ; 
        project.name = 'pro';
        project.Type__c = '陆上';
        project.Opportunity__c = opp.id ; 
        project.WBS__c = null;
        project.Projectnumber__c = null;
        project.InitialNumOfMachine__c = 2;
        project.ProjectCategory__c = 'S1';
        project.StandardProject__c = 'L1-20120000';
        project.ProgramYear__c = 2021;
        project.OwnerId = USER.ID;
        insert project;

        // Contractmanagement__c contract = new Contractmanagement__c();

        // contract.TaskStatus__c = '已完成';
        // contract.Contractname__c = 'aaa';
        // contract.ContractNegotiationStartDate__c = Datetime.now().date();
        // contract.ContractNegotiationEndDate__c = Datetime.now().addDays(1).date();
        // contract.ObjectName__c = opp.id ; 

        //insert contract;

       

        

		System.Test.startTest();
		System.test.setMock(HttpCalloutMock.class,new ProjectCreateError_SAP_Mock());
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
		
        Controller_SAPProjectAdd.SAPProjectAdd(project.id,'aaa');

		System.Test.stopTest();

    }



    

    class ProjectCreate_SAP_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "项目创建成功","data": [{"MESSAGE": "","PSPID": "S1-20210028","OBJ": "","POST1": "CRMTEST001","TYPE": "S"}]}');
			return response;
		}
	}

    class ProjectCreateError_SAP_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('Error');
			return response;
		}
	}
}