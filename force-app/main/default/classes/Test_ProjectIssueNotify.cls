@isTest
public with sharing class Test_ProjectIssueNotify {

    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='R资源销售'];

        User user = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test11011.com');
        insert user;

        Account account = new Account(Name='zhw',Region__c='东北大区');
        insert account;

        Id account_id = [SELECT Id FROM Account WHERE Name = 'zhw'].Id;
        //User的数据不需要自己生成
        Id user_id = [SELECT Id FROM User WHERE Name = 'admin'].Id;

        List<Account> accounts = [SELECT Region__c,Id,Name FROM Account];

        Project__c project = new Project__c(
            Name='Test', 
            Account__c=account_id, 
            ProjectManager__c=user_id, 
            InitialNumOfMachine__c = 1,
            RegionNew__c = '东北大区'
            );

        insert project;

        ProjectIssue__c proIssue = new ProjectIssue__c(
            Name='Test', 
            Project__c = project.Id,
            IssueOwner__c=user.id, 
            Status__c = '待解决'
        );

        insert proIssue;
        
    }    

    static testMethod void testProjectIssueNotifyHandler(){

        ProjectIssue__c proIssue = [SELECT ID,Status__c,EstimateEndDate__c FROM ProjectIssue__c WHERE Name = 'Test' limit 1];

        proIssue.Status__c = '解决中';
        proIssue.EstimateEndDate__c = Date.today();

        update proIssue;
    }

    static testMethod void testSchedule_ProjectIssueNotify(){

        ProjectIssue__c proIssue = [SELECT ID,Status__c,EstimateEndDate__c FROM ProjectIssue__c WHERE Name = 'Test' limit 1];
        proIssue.Status__c = '解决中';
        proIssue.EstimateEndDate__c = Date.today();
        update proIssue;

        System.Test.startTest();
        System.schedule('每周四17：00','0 0 17 ? * FHU',new Schedule_ProjectIssueNotify());
        System.Test.stopTest();
    }

}