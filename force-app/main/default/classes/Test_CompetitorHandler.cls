@isTest
public with sharing class Test_CompetitorHandler {

    static testMethod void testCompetitorHandler(){

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        insert user1;

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.OwnerId = user1.ID ; 
        insert opp;

        Competitor__c c = new Competitor__c();
        c.ObjectName__c = opp.id ; 
        c.Is_Pre_Communicate__c = '否';
        c.OwnerId = user1.ID ; 
        c.name = 'ccc';
        c.Competitivemodel__c = '111';
        c.Competitor_Strategy__c = '111';
        c.Advantage__c = '111';
        c.Price__c = 11;
        insert c ; 


    }

    static testMethod void testCompetitorHandler1(){

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        insert user1;

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.OwnerId = user1.ID ; 
        insert opp;

        Projectapplication__c pc = new Projectapplication__c();
        pc.Oppty__c = opp.id ; 
        insert pc ; 


        Competitor__c c = new Competitor__c();
        c.Application__c = pc.id ; 
        c.Is_Pre_Communicate__c = '否';
        c.OwnerId = user1.ID ; 
        c.name = 'ccc';
        c.Competitivemodel__c = '111';
        c.Competitor_Strategy__c = '111';
        c.Advantage__c = '111';
        c.Price__c = 11;
        insert c ; 


    }
}