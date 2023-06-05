@isTest
public with sharing class Test_Requirementsreview {

    static testMethod void testRequirementsreview(){

        Requirementsreview__c rc = new Requirementsreview__c();
        rc.Approvalstatus__c = null ; 
        rc.FinishDate__c = Date.today();
        rc.ProjectType__c = '陆上';
        insert rc ; 
        rc.Approvalstatus__c = '11';
        update rc ;
    }
}