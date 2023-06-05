/*
 * @Descripttion: 【项目任务】模块测试类 
 * @Author: Devin
 * @Date: 2021-11-04 15:49:31
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-08 17:50:41
 */
@isTest
public with sharing class Test_ProjectTask {
    @TestSetup 
    static void setData() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        User user1 = new User(Alias = 'standt', Email='standar1duser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standa1rduser@test110.com');
        insert user1;

        Opportunity opp  = new Opportunity();
        opp.name = 'opp';
        opp.Completiontime__c = Datetime.now().date();
        opp.Contractstage__c = '初版评审';
        opp.Startdate__c = Datetime.now().date();
        opp.Contractsigning__c = Datetime.now().date();
        opp.ContractDate__c = Datetime.now().date();
        opp.StageName ='线索管理';
        opp.OwnerId = user1.Id;

        opp.CloseDate = Datetime.now().date();
        insert opp;

        Project__c project = new Project__c();
        project.Name = '广东中山';
        project.Opportunity__c = opp.id;
        project.ProjectManager__c = user.Id;
        insert project;

        ProjectStage__c stage = new ProjectStage__c();
        stage.Project__c = project.Id;
        insert stage;

        ProjectTask__c task = new ProjectTask__c();
        task.Name = '001合同谈判与签订';
        task.Status__c = '未开始';
        task.PlannedStartDate__c = Datetime.now().date();
        task.Project__c = project.id;
        task.ActualStartDate__c = Datetime.now().date();
        task.ActualEndDate__c = Datetime.now().date();
        task.ProjectStage__c = stage.Id;
        
        insert task ;  
    }

    /**
     * @Descripttion: Controller_ProjectTaskLookup 测试类 80%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_fetchRecords() {
        ProjectTask__c task = [SELECT Id,Project__c FROM ProjectTask__c WHERE Name = '001合同谈判与签订'];
        System.Test.startTest();
        Controller_ProjectTaskLookup.fetchRecords('ProjectTask__c','Name','001','','');
        Controller_ProjectTaskLookup.fetchRecords('ProjectTask__c','Name','001',task.Id,'');
        Controller_ProjectTaskLookup.fetchRecords('ProjectTask__c','Name','001',task.Id,task.Project__c);
        System.Test.stopTest();
    }
}