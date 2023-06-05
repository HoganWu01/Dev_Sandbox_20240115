@isTest
public with sharing class Test_SealApprovalTriggerHandler {
    static testMethod void test_SealApprovalTriggerHandler() {
 
        ContractSupplement__c cont = new ContractSupplement__c();
        cont.Approvalstatus__c = '10';
        cont.Salesdepartment__c = '华南区域公司';
        cont.Seal_Org__c = '基地';
        cont.Seal_Safekeep_Dept__c = '青海基地';

        Employee__c emplpyee = new Employee__c();
        emplpyee.Name='首席';
        emplpyee.Status__c = '在职';
        insert emplpyee;

        Employee__c emplpyee1 = new Employee__c();
        emplpyee1.Name='区域分管副总裁';
        insert emplpyee1;

        Employee__c emplpyee2 = new Employee__c();
        emplpyee2.Name='总裁';
        emplpyee2.Status__c = '在职';
        insert emplpyee2; 

        cont.Business_Manager__c = emplpyee.Id;
        cont.Chief_Representative__c = emplpyee.Id;
        cont.Regional_Vice_President__c = emplpyee2.Id;
        insert cont;

        ResourceApproval__c   rrraaaccc = new 	ResourceApproval__c();
        rrraaaccc.AgreementName__c = 'aawweerr';
        rrraaaccc.Seal_Org__c = '基地';
        rrraaaccc.Seal_Safekeep_Dept__c = '青海基地';
        insert rrraaaccc ; 

        Seal_Related_Information__c sri = new Seal_Related_Information__c();
        sri.Marketing_Contract__c = cont.Id;
        sri.Resource_Development_Agreement__c = rrraaaccc.id ; 
        insert sri;

        Seal_Approval__c sealApp = new Seal_Approval__c();
        sealApp.Process_Id__c = '';
        sealApp.Approval_Comments__c = '请审批';
        sealApp.Stamp_Description__c = 'www';
        sealApp.SealCustody__c = '';
        sealApp.Approvalstatus__c = '11';
        sealApp.Marketing_Contract__c = cont.Id;
        sealApp.Resource_Develop_Agreement__c = rrraaaccc.id ; 
        insert sealApp;

        sealApp.Approvalstatus__c = '10';
        sealApp.Process_Id__c = '111';
        sealApp.Approval_Comments__c = 'eee';
        update sealApp;


        sealApp.Approvalstatus__c = '20';
        sealApp.Process_Id__c = '111';
        sealApp.Approval_Comments__c = 'eee';
        update sealApp;


    }
}