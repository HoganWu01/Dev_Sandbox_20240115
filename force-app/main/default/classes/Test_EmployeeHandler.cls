@isTest
public with sharing class Test_EmployeeHandler {


    static testMethod void test_Employee() {
 
        Employee__c e = new Employee__c();
        e.Job_Number__c = '123456';
        e.name = 'aaa';
        e.Duty__c = '顾问';
        e.Department__c = '小卖部';
        e.Department_Number__c = '111';
        e.Status__c = '在职';
        insert e ; 

        Profile p = [SELECT Id FROM Profile WHERE Name='资源销售'];

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        user.Job_Number__c = '123456';
        user.Title = '开发';
        user.Department = '开发部门';
        insert user;

        e.Duty__c = '销售';
        update e ; 

        e.Status__c = '离职';
        update e; 
    }
}