@isTest
public with sharing class Test_MarketingProjectInitiation {
    static testMethod void testProprietorRequireReview(){

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaMarketingProjectAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaMarketingProjectAdd';
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

        Account acc = new Account();
        acc.BeenGroup__c =true ; 
        acc.name = 'acc';
        insert acc ; 

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.Periods__c = '一八';
        opp.capacity__c = 12;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        insert opp;

        Projectapplication__c pc = new Projectapplication__c();
        pc.Oppty__c = opp.Id;
        pc.Background__c = 'a';
        pc.Projectadvantage__c = '';
        pc.Designinstitute__c = '';
        pc.Chiefdesigner__c = 'c';
        pc.Avewindspeed__c = '';
        pc.Approvedmodel__c = '';
        pc.Projectmaturityanalysis__c = '';
        pc.Province__c = '广东';
        pc.City__c = '中山';
        pc.Precommunication__c = '';
        pc.Chiefdesignerphone__c = '111';
        pc.Approvaltime__c = Datetime.now().date();
       // pc.Support2__c = 'erji';
        pc.Group__c = acc.id ; 
        pc.Stage__c = '';
        pc.Evalutionrulekey__c='机型选比重要性';
        insert pc ; 

        Matter_Selected_Impeller__c msc = new Matter_Selected_Impeller__c();
        msc.Powergeneration__c = 1;
        msc.Name = 'msc';
        msc.quotedprice__c = 1;
        msc.Economicrank__c = 1;
        msc.Application__c = pc.id  ;
        insert msc ; 

        Matter_Selected_Impeller__c msc1 = new Matter_Selected_Impeller__c();
        msc1.Powergeneration__c = 1;
        msc1.Name = 'msc';
        msc1.quotedprice__c = 1;
        msc1.Economicrank__c = 1;
        msc1.Application__c = pc.id  ;
        insert msc1 ; 

        Competitor__c cc = new Competitor__c();
        cc.Advantage__c = '';
        cc.Competitivemodel__c = '';
        cc.Name = '';
        cc.Pre_Com_Content__c = '11';
        cc.Is_Pre_Communicate__c = '';
        cc.Powergeneration__c = 1;
        cc.Application__c = pc.id ; 
        insert cc; 
        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];
        
        Integrated_Middle_Table__c ic = new Integrated_Middle_Table__c();
        ic.Mapping_Object_Id__c = pc.id;
        ic.RecordTypeId = imtRecordType.id;
        insert ic;

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new ProprietorRequireReview_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        ControllerMarketingProjectInitiation.toCreateApproveMarketing(pc.id);
        System.Test.stopTest();

    }

    class ProprietorRequireReview_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "流程启动成功！","data": {"rtStatus": "Y","rtMsg": "流程启动成功！","fdId": "17d0492ea9d0d7eabdd53a142b7a2835","docSubject": "风电一期_检测前沿开发组_何建斌_项目立项申请_2021-11-09_MF-DDXMLX20211109003","fdNumber": "MF-DDXMLX20211109003","Data": null,"data": null}}');
			return response;
		}
	}
}