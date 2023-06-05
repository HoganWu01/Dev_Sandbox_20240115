@isTest
public with sharing class Test_ShareCommonTriggerHandler {
    @isTest
    static void testShareCommon(){
        Opportunity opp = new Opportunity();
        opp.Name = '测试商机';
        opp.StageName = '线索管理';
        opp.CloseDate = Date.today();
        opp.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp;
        OpportunityTeamMember oppMem = new OpportunityTeamMember();
        oppMem.OpportunityId = opp.Id;
        oppMem.UserId = UserInfo.getUserId();
        oppMem.OpportunityAccessLevel = 'Read';
        insert oppMem;

        Projectapplication__c proApp = new Projectapplication__c();
        proApp.Oppty__c = opp.Id;
        insert proApp;

        delete oppMem;
    }
    @isTest
    static void testShareCommonUnDelete(){
        Opportunity opp = new Opportunity();
        opp.Name = '测试商机';
        opp.StageName = '线索管理';
        opp.CloseDate = Date.today();
        opp.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp;
        OpportunityTeamMember oppMem = new OpportunityTeamMember();
        oppMem.OpportunityId = opp.Id;
        oppMem.UserId = UserInfo.getUserId();
        oppMem.OpportunityAccessLevel = 'Read';
        insert oppMem;

        Projectapplication__c proApp = new Projectapplication__c();
        proApp.Oppty__c = opp.Id;
        insert proApp;

        opp.StageName = '招投标';
        update opp;

        Contractmanagement__c contract = new Contractmanagement__c();
        //contract.name = 'con';
        contract.ObjectName__c = opp.id ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();

        insert contract ; 

        ContractSupplement__c conSu = new ContractSupplement__c();
        conSu.Contractname__c = contract.Id;
        conSu.Country__c = '国内非关联方';
        insert conSu;
    }

    @isTest
    static void testChildObj(){
        Demandconfiguration__c de = new Demandconfiguration__c();
        de.Originalcontractbrand__c = 'test';
        insert de;
        Seal_Related_Information__c sr = new Seal_Related_Information__c();
        sr.Seal_Numble__c = '1';
        insert sr;
    }
}