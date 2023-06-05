@isTest
public with sharing class Test_ImportProjectTask {

    static testMethod void testImportProjectTask(){

        
        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        insert user1;

       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.OwnerId = user1.Id;
        insert opp;
        
        Project__c proj = new Project__c();
        proj.name = 'project';
        proj.Opportunity__c = opp.id;
        proj.ProjectManager__c = user.id ; 
        proj.OwnerId = user.id ; 
        proj.Stage__c = '合同商务';
        insert proj ; 

        ProjectTaskBoard__c board = new ProjectTaskBoard__c();
        board.TaskType__c = '陆上';
        board.Department__c = '海上项目管理部';
        board.Description__c = 'dfg';
        board.Status__c = '未开始';
        board.TaskNumber__c = '4';   //编号
        board.TaskOwner__c = user1.id;
        board.PreInterval__c = 0;
        board.PlannedNumOfDays__c = 1;
       // board.Name = '004合同谈判与签订';
        board.Name = '003aaaaaaaa';
        board.ProjectStage__c = '合同商务';
        insert board;

        ProjectTaskBoard__c board5 = new ProjectTaskBoard__c();
        board5.TaskType__c = '陆上';
        board5.Department__c = '海上项目管理部';
        board5.Description__c = 'dfg';
        board5.Status__c = '未开始';
        board5.TaskNumber__c = '5';   //编号
        board5.TaskOwner__c = user.id;
        board5.PreTaskName1__c = board.id;
        board5.PreInterval__c = 0;
        board5.PlannedNumOfDays__c = 1;
        board5.Name = '005组织道路分界点勘核';
        board5.ProjectStage__c = '合同商务';
        insert board5;

        ProjectTaskBoard__c board6 = new ProjectTaskBoard__c();
        board6.TaskType__c = '陆上';
        board6.Department__c = '海上项目管理部';
        board6.Description__c = 'dfg';
        board6.Status__c = '未开始';
        board6.TaskNumber__c = '6';   //编号
        board6.TaskOwner__c = user.id;
        board6.PreTaskName1__c = board.id;
        board6.PreTaskName2__c = board5.id;
        board6.PreInterval__c = 0;
        board6.PlannedNumOfDays__c = 1;
        board6.Name = '006中标利润测算';
        board6.ProjectStage__c = '合同商务';
        insert board6;

        ProjectTaskBoard__c board7 = new ProjectTaskBoard__c();
        board7.TaskType__c = '陆上';
        board7.Department__c = '海上项目管理部';
        board7.Description__c = 'dfg';
        board7.Status__c = '未开始';
        board7.TaskNumber__c = '7';   //编号
        board7.TaskOwner__c = user.id;
        board7.PreTaskName1__c = board.id;
        board7.PreTaskName2__c = board5.id;
        board7.PreTaskName3__c = board6.id;
        board7.PreInterval__c = 0;
        board7.PlannedNumOfDays__c = 1;
        board7.Name = '007传递技术资料需求';
        board7.ProjectStage__c = '合同商务';
        insert board7;

        ProjectTaskBoard__c board8 = new ProjectTaskBoard__c();
        board8.TaskType__c = '陆上';
        board8.Department__c = '海上项目管理部';
        board8.Description__c = 'dfg';
        board8.Status__c = '未开始';
        board8.TaskNumber__c = '7';   //编号
        board8.TaskOwner__c = user.id;
        board8.PreTaskName1__c = board.id;
        board8.PreTaskName2__c = board5.id;
        board8.PreTaskName3__c = board6.id;
        board8.PreTaskName4__c = board7.id;
        board8.PreInterval__c = 0;
        board8.PlannedNumOfDays__c = 1;
        board8.Name = '008微观选址及风资源确认';
        board8.ProjectStage__c = '合同商务';
        insert board8;

        ProjectTaskBoard__c board9 = new ProjectTaskBoard__c();
        board9.TaskType__c = '陆上';
        board9.Department__c = '海上项目管理部';
        board9.Description__c = 'dfg';
        board9.Status__c = '未开始';
        board9.TaskNumber__c = '7';   //编号
        board9.TaskOwner__c = user.id;
        board9.PreTaskName1__c = board.id;
        board9.PreTaskName2__c = board5.id;
        board9.PreTaskName3__c = board6.id;
        board9.PreTaskName4__c = board7.id;
        board9.PreTaskName5__c = board8.id;
        board9.PreInterval__c = 0;
        board9.PlannedNumOfDays__c = 1;
        board9.Name = '009输出地基载荷报告';
        board9.ProjectStage__c = '合同商务';
        insert board9;

        ProjectTaskBoard__c board10 = new ProjectTaskBoard__c();
        board10.TaskType__c = '陆上';
        board10.Department__c = '海上项目管理部';
        board10.Description__c = 'dfg';
        board10.Status__c = '未开始';
        board10.TaskNumber__c = '10';   //编号
        board10.TaskOwner__c = user.id;
        board10.PreTaskName1__c = board.id;
        board10.PreTaskName2__c = board5.id;
        board10.PreTaskName3__c = board6.id;
        board10.PreTaskName4__c = board7.id;
        board10.PreTaskName5__c = board8.id;
        board10.PreTaskName6__c = board9.id;
        board10.PreInterval__c = 0;
        board10.PlannedNumOfDays__c = 1;
        board10.Name = '010输出塔筒招标图纸';
        board10.ProjectStage__c = '合同商务';
        insert board10;

        System.Test.startTest();
        Controller_ImportProjectTask.ImportProjectTask(proj.id,'陆上');
        System.Test.stopTest();
    }


    static testMethod void testImportProjectTask004(){

        
        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        insert user1;

       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.OwnerId = user1.Id;
        insert opp;
        
        Project__c proj = new Project__c();
        proj.name = 'project';
        proj.Opportunity__c = opp.id;
        proj.ProjectManager__c = user.id ; 
        proj.OwnerId = user.id ; 
        proj.Stage__c = '合同商务';
        insert proj ; 

        ProjectTaskBoard__c board = new ProjectTaskBoard__c();
        board.TaskType__c = '陆上';
        board.Department__c = '海上项目管理部';
        board.Description__c = 'dfg';
        board.Status__c = '未开始';
        board.TaskNumber__c = '4';   //编号
        board.TaskOwner__c = user1.id;
        board.PreInterval__c = 0;
        board.PlannedNumOfDays__c = 1;
        board.Name = '004合同谈判与签订';
        board.ProjectStage__c = '合同商务';
        insert board;

        System.Test.startTest();
        Controller_ImportProjectTask.ImportProjectTask(proj.id,'陆上');
        System.Test.stopTest();
    }

    static testMethod void testSelectTaskType() {
        System.Test.startTest();
        Controller_ImportProjectTask.selectTaskType();
        System.Test.stopTest();
    }
}