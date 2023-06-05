@isTest
public with sharing class Test_ContractProcessIdHandler {
    static testMethod void testContractProcessId(){

        Account acc = new Account();
        acc.name = '中国华能集团有限公司';
        acc.Shortname__c = '华能';
        acc.Officialcode__c='9111000010001002XD';
        acc.BeenGroup__c = true ; 
        acc.Accounttype__c='已交易客户';
        insert acc ; 

        Contractmanagement__c contract = new Contractmanagement__c();
        contract.Company__c =acc.id ; 
        contract.DifferentCountries__c = '国内非关联方';
        contract.ContractNegotiationStartDate__c = null ; 
        contract.ContractSigningEndDate__c = null ; 
        
        insert contract;

        ContractSignProcesss__c csp=new ContractSignProcesss__c();
        csp.Process_Id__c='1234';
        csp.FlowTheme__c='流程主题';
        insert csp;

        contract.OAProcessTheme__c = csp.id; 
        update contract;

    }
}