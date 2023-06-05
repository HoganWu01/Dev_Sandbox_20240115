@isTest
public with sharing class ProjectApplication_Test {

    static testMethod void test_initApproval() {
        
        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        insert opp;

        Projectapplication__c proj = new Projectapplication__c();
        proj.Oppty__c = opp.Id;
        insert proj;

        Matter_Selected_Impeller__c msi = new Matter_Selected_Impeller__c();
        msi.Application__c = proj.Id;
        insert msi;
        
        Competitor__c competitor = new  Competitor__c();
        competitor.Application__c = proj.Id;
        insert competitor;


        String oppId = opp.Id;
        ProjectApplication.initApproval(oppId);

    }
}