@isTest
public with sharing class Test_Contractmanagement {
    static testMethod void testContractmanage(){

        Opportunity opp  = new Opportunity();
        opp.name = 'opp';
        opp.Completiontime__c = Datetime.now().date();
        opp.Contractstage__c = '初版评审';
        opp.Startdate__c = Datetime.now().date();
        opp.Contractsigning__c = Datetime.now().date();
        opp.ContractDate__c = Datetime.now().date();
        opp.StageName ='招投标';
        opp.CloseDate = Datetime.now().date();
        insert opp;

        Contractmanagement__c contract = new Contractmanagement__c();
        //contract.name = 'con';
        contract.ObjectName__c = opp.id ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();

        insert contract ; 

        contract.Firstcontractcompletion__c = Datetime.now().addDays(1).date();
        contract.Contractstage__c = '合同谈判';
        contract.MeetingStartDate__c = Datetime.now().addDays(1).date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(2).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(3).date();

        update contract ; 
    }

    static testMethod void testContractmanage1(){
        Opportunity opp  = new Opportunity();
        opp.name = 'opp';
        opp.Completiontime__c = Datetime.now().date();
        opp.Contractstage__c = '初版评审';
        opp.Startdate__c = Datetime.now().date();
        opp.Contractsigning__c = Datetime.now().date();
        opp.ContractDate__c = Datetime.now().date();
        opp.StageName ='招投标';

        opp.CloseDate = Datetime.now().date();
        insert opp;

        Contractmanagement__c contract = new Contractmanagement__c();
       
        contract.ObjectName__c = opp.id ; 
        contract.Firstcontractcompletion__c = Datetime.now().date();
        contract.Contractstage__c = '初版评审';
        contract.MeetingStartDate__c = Datetime.now().date();
        contract.ContractSigningEndDate__c = Datetime.now().addDays(1).date();
        contract.ContractNegotiationStartDate__c = Datetime.now().addDays(2).date();

        insert contract ; 
    }
}