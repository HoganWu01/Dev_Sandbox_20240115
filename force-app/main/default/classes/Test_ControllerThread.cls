@isTest
public with sharing class Test_ControllerThread {

    static testMethod void testControllerThread(){

        Profile p = [SELECT Id FROM Profile WHERE Name='S大客户经理'];
       
        User user = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        Account acc = new Account();
        acc.Name = '客户';
        acc.BeenGroup__c = true;
        insert acc;

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'OppSubCompany_RecordType'];

        Integrated_Middle_Table__c table = new Integrated_Middle_Table__c();
        table.RecordTypeId = imtRecordType.id;
        table.Salesdepartment__c = '新疆公司';
        table.OppChiefgeneralmanager__c = user.id ; 
        table.Pre_Sales_Project_Manager__c = user.id;
        insert table;

        Integrated_Middle_Table__c table2 = new Integrated_Middle_Table__c();
        table2.RecordTypeId = imtRecordType.id;
        table2.Salesdepartment__c = '新疆公司';
        table2.OppChiefgeneralmanager__c = user.id ; 
        table2.Pre_Sales_Project_Manager__c = user.id;
        insert table2;

        Lead lead = new Lead();
        lead.LastName = 'lll';
        lead.Company = 'aaa';
        lead.Approval__c = false ; 
        lead.Gender__c = acc.Id;
        lead.Status = 'Contacted';
        lead.Approvalstatus__c = '草稿';
        lead.OwnerId = user.Id;
        lead.ExecutiveGeneralManage__c = user.id ; 
        lead.ChiefGeneralManager__c = user.id ; 
        lead.SalesDepartment__c='新疆公司';
        insert lead ; 

        lead.Approval__c = true ; 
        lead.AllowModificationStage__c = true;
        lead.Approvalstatus__c = '审批中';
        lead.SalesDepartment__c='新疆公司';
        update lead ; 

        Set<Lead> leadSet = new Set<Lead>();
        leadSet.add(lead);

        LeadHandler leadHand = new LeadHandler();

        System.Test.startTest();
        Controller_Thread.getThread(lead.id);
        Controller_Thread.approveLead(lead.id,'aaa');
        leadHand.createOpportunity(leadSet);
        System.Test.stopTest();


    }
}