@isTest
public with sharing class Test_ContractStatusHandler {
    static testMethod void testContractStatus(){

        Profile p = [SELECT Id FROM Profile WHERE Name='项目经理'];

       // UserRole role = [SELECT ID,NAME FROM UserRole WHERE NAME = '陆上PMO'];

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user; 

        Account acc = new Account();
        acc.name = 'acc';
        acc.BeenGroup__c = true ; 
        insert acc ; 

        Account acc1 = new Account();
        acc1.name = 'acc1';
        acc1.BeenGroup__c = true ; 
        insert acc1 ; 

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = 'celnet'];

        Opportunity opp  = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理';
        opp.CloseDate = Datetime.now().date();
        opp.ContractSignedCompany__c = acc.id;
        // opp.name = 'opp';
        // opp.Completiontime__c = Datetime.now().date();
        // opp.Contractstage__c = '初版评审';
        // opp.Startdate__c = Datetime.now().date();
        // opp.Contractsigning__c = Datetime.now().date();
        // opp.ContractDate__c = Datetime.now().date();
        // opp.StageName ='线索管理';

        // opp.CloseDate = Datetime.now().date();
        insert opp;

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'ProjectType_RecordType'];

        Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
		i.RecordTypeId = imtRecordType.id;
        i.ProjectType__c = '陆上';
        i.RoleName__c = '陆上PMO';
        insert i  ;

        Contractmanagement__c contract = new Contractmanagement__c();

        contract.TaskStatus__c = '进行中';
        contract.ContractNegotiationStartDate__c = null ; 
        contract.ContractSigningEndDate__c = null ; 
        contract.ObjectName__c  =opp.id;
        contract.Company__c =acc.id ; 
        insert contract;

        Project__c project = new Project__c();
        project.name = 'aaa';
        project.Opportunity__c = opp.id;
        //project.OwnerId = user.id;
        project.ProjectManager__c = user.id;
        project.Type__c = '陆上';
        insert project;

        ProjectStage__c stage1 = new ProjectStage__c(Name='合同商务',Project__c=project.id, Number__c='1');
        insert stage1 ; 

        ProjectTask__c task = new ProjectTask__c(name='004合同谈判与签订',Status__c='未开始');
        task.PlannedStartDate__c=Datetime.now().date();
        task.ActualStartDate__c = Datetime.now().date();
        task.ActualEndDate__c = Datetime.now().addDays(3).date();
        task.ProjectStage__c = stage1.id ; 
        task.Project__c = project.id ; 
        insert task;

        contract.TaskStatus__c = '未开始';
        contract.Company__c = acc1.id ; 
        update contract;

        // contract.TaskStatus__c = '已完成';
        // update contract;
    }
}