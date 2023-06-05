/**
 * Created by zhangwei08330 on 2019/9/14.
 */

@isTest
private class TestProjectSchedule {
    static testMethod void TestSchedule(){
        String executeTime = '0 0 11 * * ?';

        Account account = new Account(Name='zhw');
        insert account;

        Id account_id = [SELECT Id FROM Account WHERE Name = 'zhw'].Id;
        //User的数据不需要自己生成
        Id user_id = [SELECT Id FROM User WHERE Name = 'admin'].Id;

        List<Project__c> projects = new List<Project__c>();
        insert new Project__c(Name='Test', Type__c='陆上', Account__c=account_id, ProjectManager__c=user_id, InitialNumOfMachine__c = 10);

        Id projectId = [SELECT Id FROM Project__c WHERE Name = 'Test'].Id;
        System.debug(projectId);
        
        // List<AggregateResult> query_results = [SELECT Count(Id) number FROM ProjectTask__c];
        // for(AggregateResult result : query_results){
        //     System.debug(result.get('number'));
        // } 

        Test.startTest();
        String jobId = System.schedule('ScheduleTest', executeTime, new ProjectSchedule());
        Test.stopTest();
    }
}