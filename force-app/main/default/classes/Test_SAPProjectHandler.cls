@isTest
public with sharing class Test_SAPProjectHandler {

    @TestSetup 
    static void setData() {

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '初期运作' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        insert opp;

        Projectapplication__c pac = new Projectapplication__c();
        pac.Oppty__c = opp.id ; 
        pac.Approvalstatus__c  = '30';
        insert pac ; 

        String recTypeIddd = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('ProjectType_RecordType').getRecordTypeId();
        Integrated_Middle_Table__c docMappp = new Integrated_Middle_Table__c();
        docMappp.RecordTypeId = recTypeIddd;
        docMappp.ProjectType__c = '陆上';
        docMappp.RoleName__c = '陆上PMO';
        insert docMappp;


    }


    static testMethod void testSAPProject(){

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user ; 

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = 'celnet'];

        Opportunity opp = [select id,name,StageName,CloseDate from Opportunity where name = 'opp'];

        Contractmanagement__c contract= [select id,ObjectName__c from Contractmanagement__c where ObjectName__c = :opp.id];

        Account acc =  new Account();
        acc.BeenGroup__c = true ; 
        acc.name = 'acc';
        insert acc ; 

        // Contractmanagement__c contract = new Contractmanagement__c();
        contract.Company__c = acc.id ; 
        //contract.ObjectName__c = opp.id ; 
        update contract ; 

        Project__c project = new Project__c();

        project.name = 'test';
        project.InitialNumOfMachine__c = 2 ; 
        project.ProjectCategory__c = 'S1';
        project.StandardProject__c = 'L1-20210808';
        project.ProgramYear__c = 2021;
        project.WBS__c = null ; 
        project.Projectnumber__c = null ; 
        project.Opportunity__c = opp.id ; 
        project.OwnerId = user.id;
        project.ProjectManager__c = user.id ; 
        project.Type__c = '陆上';
        insert project ; 


        


    }


    static testMethod void testSAPProject1(){

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user ; 

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = 'celnet'];

        Opportunity opp = [select id,name,StageName,CloseDate from Opportunity where name = 'opp'];

        Contractmanagement__c contract= [select id,ObjectName__c from Contractmanagement__c where ObjectName__c = :opp.id];

        Account acc =  new Account();
        acc.BeenGroup__c = true ; 
        acc.name = 'acc';
        insert acc ; 

        // Contractmanagement__c contract = new Contractmanagement__c();
        contract.Company__c = acc.id ; 
        //contract.ObjectName__c = opp.id ; 
        update contract ; 


        Project__c project1 = new Project__c();

        project1.name = 'test';
        project1.InitialNumOfMachine__c = 2 ; 
        project1.ProjectCategory__c = 'S1';
        project1.StandardProject__c = 'L1-20210808';
        project1.ProgramYear__c = 2021;
        project1.WBS__c = '1' ; 
        project1.Type__c = '陆上';
        project1.Projectnumber__c = null ; 
        project1.Opportunity__c = opp.id ; 
        project1.OwnerId = user.id;
        project1.ProjectManager__c = user.id ; 
        insert project1 ; 

        project1.WBS__c = '2' ; 
        update project1 ; 
    }
}