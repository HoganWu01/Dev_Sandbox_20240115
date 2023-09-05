@istest
public with sharing class Test_ProjectAppLeaderHandler {
    /*static testMethod void testAfterInsert(){

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        User user1 = new User(Alias = 'standt', Email='standar1duser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standa1rduser@test110.com');
        insert user1;
        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '项目立项' ;
        opp.OpportunityApprovalStatus__c = '商机提报通过';
        opp.CloseDate = Datetime.now().addMonths(1).date();
        insert opp;

        Projectapplication__c proj = new Projectapplication__c();
        // proj.projectleader__c = user1.Id;
        proj.Oppty__c = opp.Id;
        insert proj;

    }
    static testMethod void testAfterUpdate(){
        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        User user1 = new User(Alias = 'standt', Email='standar1duser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standa1rduser@test110.com');
        insert user1;
        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '项目立项' ;
        opp.OpportunityApprovalStatus__c = '商机提报通过';
        opp.CloseDate = Datetime.now().addMonths(1).date();
        insert opp;

        Projectapplication__c proj = new Projectapplication__c();
        // proj.projectleader__c = user1.Id;
        proj.Oppty__c = opp.Id;
        insert proj;
        proj.Communication__c = '很好';
        update proj;

    }*/
}