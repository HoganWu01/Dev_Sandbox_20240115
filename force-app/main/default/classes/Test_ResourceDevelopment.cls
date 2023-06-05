@isTest
public with sharing class Test_ResourceDevelopment {
    static testMethod void testResourceDevelopment(){

        Resource_Development__c rdc = new 	Resource_Development__c();
        insert rdc ; 
        System.Test.startTest();
        ResourceDevelopmentController.resourceCloseApproval(rdc.id);
        System.Test.stopTest();
    }
}