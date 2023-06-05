/**
 * Created by zhangwei08330 on 2019/9/14.
 */

@isTest
private class TestProjectTrigger {
    static testMethod void TestProjectTrigger(){
        Account account = new Account(Name='zhw',Region__c='华南战区');
        insert account;

        Id account_id = [SELECT Id FROM Account WHERE Name = 'zhw'].Id;
        //User的数据不需要自己生成
        Id user_id = [SELECT Id FROM User WHERE Name = 'admin'].Id;

        List<Account> accounts = [SELECT Region__c,Id,Name FROM Account];

        Project__c project = new Project__c(
            Name='Test', 
            Type__c='海上', 
            Account__c=account_id, 
            ProjectManager__c=user_id, 
            InitialNumOfMachine__c = 1,
            RegionNew__c = '华南战区'
            );

        insert project;

        Integer interval = Date.today().daysBetween(Date.newInstance(2019, 12, 12));
        System.debug(interval);
        Date day = Date.today().addDays(30);
        System.debug(day);

        // Project__c p = [SELECT Id FROM Project__c WHERE Name='Test'];

        // List<ProjectTask__c> projectTaskList = [SELECT Id,Name,PreTaskNumber__c FROM ProjectTask__c WHERE Project__c = :p.Id and PreTask__c = Null];
        // for(ProjectTask__c ps : projectTaskList){
        //     System.debug(ps.Name + ' ' + ps.PreTaskNumber__c);
        // }

    }
}