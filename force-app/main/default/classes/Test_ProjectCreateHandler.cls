@isTest
public with sharing class Test_ProjectCreateHandler {

    @TestSetup static void setData(){
        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = '郑耿昭'];

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user; 

        User user1 = new User(Alias = 'standt', Email='standar1duser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standa1rduser@test110.com');
        insert user1;

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.Periods__c = '一八';
        opp.capacity__c = 12;
        opp.OwnerId =  user1.Id;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        insert opp;

        Projectapplication__c pac = new Projectapplication__c();
        pac.Oppty__c = opp.id ; 
        pac.Approvalstatus__c  = '30';
        insert pac ; 

        opp.StageName = '招投标';
        update opp;

        Contractmanagement__c contract = new Contractmanagement__c();

        contract.TaskStatus__c = '进行中';
        contract.Contractname__c = 'aaa';
        contract.ObjectName__c = opp.id ; 

        insert contract;

        opp.StageName = '中标/赢单';
        update opp;

        Contractmanagement__c contract2 = new Contractmanagement__c();

        contract2.TaskStatus__c = '进行中';
        contract2.Contractname__c = 'bbb';
        contract2.ObjectName__c = opp.id ; 

        insert contract2;

        opp.StageName = '合同商务';
        update opp;

        Contractmanagement__c contract3 = new Contractmanagement__c();

        contract3.TaskStatus__c = '进行中';
        contract3.Contractname__c = 'ccc';
        contract3.ObjectName__c = opp.id ; 

        insert contract3;

        // contract.TaskStatus__c = '已完成';
        // update contract;

        Project__c project = new Project__c();
        project.ProjectManager__c=user.id ; 
        project.name = 'pro';
        project.Opportunity__c = opp.id ; 
        project.WBS__c = null;
        project.Projectnumber__c = null;
        project.InitialNumOfMachine__c = 2;
        project.ProjectCategory__c = 'S1';
        project.StandardProject__c = 'L1-20120000';
        project.ProgramYear__c = 2021;
        project.OwnerId = user.id;
        insert project;
    }

    @isTest
    static void test_Controller_ProjectCreate(){

        Contractmanagement__c contract =[select id,name from Contractmanagement__c where Contractname__c = 'aaa'];

        contract.Approvalstatus__c='30';

        update contract ; 

        contract.TaskStatus__c = '已完成';
        update contract;
	}

    @isTest
    static void test_Controller_ProjectUpdate(){

        Project__c pro =[select id,name from Project__c where name = 'pro'];

        pro.name='proNameUpdate';

        update pro ; 
	}

    
}