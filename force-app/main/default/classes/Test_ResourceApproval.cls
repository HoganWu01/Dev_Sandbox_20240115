@isTest
public with sharing class Test_ResourceApproval {
    static testMethod void testResourceApproval(){
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaMarketingDevelopmentAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaMarketingDevelopmentAdd';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

       

        ResourceApproval__c rc = new ResourceApproval__c();
        rc.SealApplication__c = '是';
        rc.Seal_Org__c = '基地';
        rc.Seal_Safekeep_Dept__c = '青海基地';
        rc.FileType__c = '';
        rc.AgreementIntroduction__c = '';
        rc.ResourceArea__c = '';
        rc.AgreementName__c = '';
        rc.Approvalstatus__c = '10';
        rc.Process_Id__c = null ;
        rc.Investment_Whether__c = false;
        insert rc ; 
        Seal_Approval__c seal = new Seal_Approval__c();
        seal.Resource_Develop_Agreement__c = rc.Id;
        insert seal;

        Seal_Related_Information__c sc = new Seal_Related_Information__c();
        sc.Document_Category__c = '1';
        sc.Document_Name__c = '111';
        sc.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313';
        sc.Seal_Type__c = '公章';
        sc.Seal_Numble__c = '11';
        sc.Resource_Development_Agreement__c = rc.id ; 
        insert sc ; 

        rc.Seal_Org__c = '基地';
        rc.Seal_Safekeep_Dept__c = '沙洋基地';
        rc.Approvalstatus__c = '11';
        update rc ; 
    }
    static testMethod void testResourceApproval2(){
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaMarketingDevelopmentAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaMarketingDevelopmentAdd';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

       

        ResourceApproval__c rc = new ResourceApproval__c();
        rc.SealApplication__c = '是';
        rc.Seal_Org__c = '基地';
        rc.Seal_Safekeep_Dept__c = '青海基地';
        rc.FileType__c = '';
        rc.AgreementIntroduction__c = '';
        rc.ResourceArea__c = '';
        rc.AgreementName__c = '';
        rc.Approvalstatus__c = '10';
        rc.Process_Id__c = null ;
        rc.Investment_Whether__c = false;
        insert rc ; 
        Seal_Approval__c seal = new Seal_Approval__c();
        seal.Resource_Develop_Agreement__c = rc.Id;
        insert seal;

        Seal_Related_Information__c sc = new Seal_Related_Information__c();
        sc.Document_Category__c = '1';
        sc.Document_Name__c = '111';
        sc.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313';
        sc.Seal_Type__c = '公章';
        sc.Seal_Numble__c = '11';
        sc.Resource_Development_Agreement__c = rc.id ; 
        insert sc ; 

        rc.Seal_Org__c = '基地';
        rc.Seal_Safekeep_Dept__c = '沙洋基地';
        rc.Approvalstatus__c = '20';
        update rc ; 
    }
}