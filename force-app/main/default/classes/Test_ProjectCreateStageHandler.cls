@isTest
public with sharing class Test_ProjectCreateStageHandler {
   
    static testMethod void testCreateStage(){

        Project__c project  = new  Project__c();

        project.name = 'test';
        insert project ; 

        project.name = 'test1';
        update project;

        delete project;

    }
}