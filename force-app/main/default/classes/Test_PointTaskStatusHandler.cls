@isTest
public with sharing class Test_PointTaskStatusHandler {
    static testMethod void testPointTaskStatus(){

       
        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user1 = new User(Alias = 'standt', Email='standarduser@tesdtorg.com',EmailEncodingKey='UTF-8', LastName='Testdf110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarddfuser@test110.com');
        insert user1;

       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user; 

        System.runAs(user1) {
            Opportunity opp  = new Opportunity();
            opp.name = 'opp';
            opp.Completiontime__c = Datetime.now().date();
            opp.Contractstage__c = '初版评审';
            opp.Startdate__c = Datetime.now().date();
            opp.Contractsigning__c = Datetime.now().date();
            opp.ContractDate__c = Datetime.now().date();
            opp.OwnerId = user1.Id;
            opp.StageName ='线索管理';
    
            opp.CloseDate = Datetime.now().date();
            insert opp;
    
            Project__c project = new Project__c();
            project.name = 'aaa';
            project.Opportunity__c = opp.id;
            project.ProjectManager__c = user.id ; 
            project.OwnerId = user.id ; 
            
            insert project;
    
            ProjectStage__c stage1 = new ProjectStage__c(Name='合同商务',Project__c=project.id, Number__c='1');
            insert stage1 ; 
    
            ProjectTask__c task = new ProjectTask__c();
            task.name = '004合同谈判与签订';
            task.Status__c = '进行中';
            task.PlannedStartDate__c = Datetime.now().date();
            task.Project__c = project.id;
            task.ActualStartDate__c = Datetime.now().date();
            task.ActualEndDate__c = Datetime.now().date();
            task.ProjectStage__c = stage1.id ; 
            task.TaskOwner__c = user1.Id;
            insert task ; 
    
            task.Status__c = '未开始';
            update task;
    
            // task.Status__c = '已完成';
            // update task;
        }
    }
}