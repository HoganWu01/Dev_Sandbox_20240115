@isTest
public with sharing class Test_CompanyRegister {
    static testMethod void testCompanyRegister(){
        CompanyRegisterApplication__c cr=  new CompanyRegisterApplication__c();
        cr.Approvalstatus__c = null;
        insert cr ;
        cr.Approvalstatus__c = '11';
        update cr ; 
    }
}