/**
 * Created by zhangwei08330 on 2020/01/18.
 */

@isTest
private class TestUpdateTaskDate {
    static testMethod void TestUpdateTaskDate(){
        Account account = new Account(Name='zhw',Region__c='东南战区');
        insert account;

        Id account_id = [SELECT Id FROM Account WHERE Name = 'zhw'].Id;
        //User的数据不需要自己生成
        Id user_id = [SELECT Id FROM User WHERE Name = 'admin'].Id;

        List<Account> accounts = [SELECT Region__c,Id,Name FROM Account];

        Project__c project = new Project__c(Name='Test', Type__c='陆上', Account__c=account_id, ProjectManager__c=user_id, InitialNumOfMachine__c = 2);
        insert project;

        Id prject_id = [SELECT Id FROM Project__c WHERE Name = 'Test'].Id;

        Integer index = 1;

        ProjectStage__c stage = new ProjectStage__c();
        stage.Project__c = prject_id;
        insert stage;

        ProjectTask__c task = new ProjectTask__c();
        task.Project__c = prject_id;
        task.ProjectStage__c = stage.id;
        task.TaskType__c = '风机交付类';
        task.SubType__c = '主机齐套';
        insert task;

        List<ProjectTask__c> update_pts = new List<ProjectTask__c>();
        List<ProjectTask__c> pts = [SELECT PlannedStartDate__c  FROM ProjectTask__c WHERE Project__c = :prject_id];
        for( ProjectTask__c pt : pts){
            pt.PlannedStartDate__c = Date.today().addDays(index);
            update_pts.add(pt);
            index += 100;
        }
        update update_pts;

        update_pts.clear();
        pts = [SELECT PlannedStartDate__c, Id  FROM ProjectTask__c WHERE Project__c = :prject_id];
        // System.debug('test: ' + pts[0].Id);
        Date day = pts[0].PlannedStartDate__c;
        // System.debug('test: ' + pts[0].PlannedStartDate__c.addDays(1));
        pts[0].PlannedStartDate__c = day.addDays(2);
        // System.debug('test: ' + pts[0].PlannedStartDate__c);
        update_pts.add(pts[0]);
        update update_pts;
        Date d = [SELECT PlannedStartDate__c  FROM ProjectTask__c WHERE Id = :pts[0].Id].PlannedStartDate__c;
        // System.debug('after: ' + d);
    }
}