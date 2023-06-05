@isTest
public with sharing class Test_MatterSelectedImpellerHandler {

    static testMethod void testMatterSelectedImpellerHandler(){

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        insert user1;

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.OwnerId = user1.ID ; 
        insert opp;

        Matter_Selected_Impeller__c c = new Matter_Selected_Impeller__c();
        c.Name__c = opp.id ; 
        c.OwnerId = user1.ID ; 
        c.name = 'ccc';
        c.Powergeneration__c = 111;
        c.Economicrank__c = 111;
        c.quotedprice__c = 111;
        insert c ; 


    }

    static testMethod void testMatterSelectedImpellerHandler1(){

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        insert user1;

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.Periods__c = '一八';
        opp.capacity__c = 12;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        opp.OwnerId = user1.ID ; 
        insert opp;

        Projectapplication__c pc = new Projectapplication__c();
        pc.Oppty__c = opp.id ; 
        insert pc ; 

        Matter_Selected_Impeller__c c = new Matter_Selected_Impeller__c();
        c.Application__c = pc.Id;
        c.OwnerId = user1.ID ; 
        c.name = 'ccc';
        c.Powergeneration__c = 111;
        c.Economicrank__c = 111;
        c.quotedprice__c = 111;
        insert c ; 


    }
}