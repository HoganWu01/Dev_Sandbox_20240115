@istest
public with sharing class Test_ContractSupplementTriggerHandler {
   
    static testMethod void TestSendNotifyToOwner(){
        ContractSupplement__c cont = new ContractSupplement__c();
        cont.Approvalstatus__c = '10';
        cont.Salesdepartment__c = '新疆公司';

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
        // cont.Regional_Vice_President__c =  emplpyee1.Id;
        cont.Regional_Vice_President__c = emplpyee2.Id;
        insert cont;
        cont.Approvalstatus__c = '11';
        update cont;
    }
    static testMethod void TestAutoSetValueTrigger(){


        ContractSupplement__c cont = new ContractSupplement__c();
        cont.Approvalstatus__c = '10';
        cont.Salesdepartment__c = '新疆公司';

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
        cont.Approvalstatus__c = '11';
        insert emplpyee2; 

        recordType recordTypeId = [SELECT Id,DeveloperName ,Sobjecttype  FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Supplementary_Agreement_Record_Type'];

        cont.Business_Manager__c = emplpyee.Id;
        cont.Chief_Representative__c = emplpyee.Id;
        // cont.Regional_Vice_President__c =  emplpyee1.Id;
        cont.Regional_Vice_President__c = emplpyee2.Id;
        insert cont;

        Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
        middleForm.Approvalstatus__c = '11';//审批状态
        middleForm.Project_Theater__c  = '新疆公司';

        middleForm.RecordTypeId =  recordTypeId.Id;
        middleForm.Salesdepartment__c = '新疆公司';
        insert middleForm;

        List<ContractSupplement__c> contractList = new List<ContractSupplement__c>();
        contractList.add(cont);

        ContractSupplementTriggerHandler contractSupplementTriggerHandler = new ContractSupplementTriggerHandler();
        contractSupplementTriggerHandler.autoSetValueTrigger(contractList);
    } 

    static testMethod void deleteAndUpdateChildTrigger(){
        recordType recordTypeId = [SELECT Id,DeveloperName ,Sobjecttype  FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Supplementary_Agreement_Record_Type'];
        Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
        middleForm.Approvalstatus__c = '20';//审批状态
        middleForm.Project_Theater__c  = '新疆公司';

        middleForm.RecordTypeId =  recordTypeId.Id;
        middleForm.Salesdepartment__c = '新疆公司';
        insert middleForm;

        ContractSupplement__c cont = new ContractSupplement__c();
        cont.Approvalstatus__c = '10';
        cont.Salesdepartment__c = '新疆公司';
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
        // cont.Regional_Vice_President__c =  emplpyee1.Id;
        cont.Regional_Vice_President__c = emplpyee2.Id;
        insert cont;
        Seal_Approval__c seal = new Seal_Approval__c();
        seal.Marketing_Contract__c = cont.Id;
        insert seal;

        cont.Approvalstatus__c = '20';
        cont.Seal_Safekeep_Dept__c = '沙洋基地';
        update cont;

    }
}