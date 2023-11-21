@isTest
public with sharing class Test_ContractStatusHandler {
    static testMethod void testContractStatus(){

        Profile p = [SELECT Id FROM Profile WHERE Name like '%项目经理%' limit 1];

       // UserRole role = [SELECT ID,NAME FROM UserRole WHERE NAME = '陆上PMO'];

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user; 

        Account acc = new Account();
        acc.Name = '广州风机';
        acc.BeenGroup__c = true;
        acc.TopGroup__c = 'TG101';
        acc.Accounttype__c = '已交易客户';
        insert acc;

        Account acc1 = new Account();
        acc1.Name = '广州风机子级客户';
        acc1.BeenGroup__c = false;
        acc1.TopGroup__c = 'TG101';
        acc1.ParentId = acc.Id;
        acc1.Accounttype__c = '已交易客户';
        insert acc1;

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = 'celnet'];

        Opportunity opp  = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理';
        opp.CloseDate = Datetime.now().date();
        opp.ContractSignedCompany__c = acc.id;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        insert opp;

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'ProjectType_RecordType'];

        Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
		i.RecordTypeId = imtRecordType.id;
        i.ProjectType__c = '陆上项目';
        i.RoleName__c = '陆上PMO';
        insert i  ;

        opp.StageName = '招投标';
        update opp;

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
        project.ProjectProductType__c = '01';
        project.Contract__c = contract.Id;
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