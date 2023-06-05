@isTest
public with sharing class Test_ResourceToClueHandler {
    static testMethod void testResourceToClue(){

        Profile pro = [SELECT ID,NAME FROM Profile WHERE NAME = '大客户'];

        User user = new User();
        user.Username = 'john@acmeee.com';
        user.LastName = 'www';
        user.Email = 'john@acme.com.sanbox4';
        user.Alias = 'www';
        user.TimeZoneSidKey = 'Asia/Shanghai';
        user.LocaleSidKey = 'zh_CN';
        user.EmailEncodingKey = 'GB2312';
        user.ProfileId = pro.id;
        user.LanguageLocaleKey = 'zh_CN';
        insert user;

        Account acc = new Account();
        acc.name = 'qqq';
        acc.BeenGroup__c = true;
        insert acc ; 

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'OppSubCompany_RecordType'];

        Integrated_Middle_Table__c table = new Integrated_Middle_Table__c();
        table.Salesdepartment__c = '华南';
        table.OppChiefgeneralmanager__c = user.id ; 
        table.RecordTypeId = imtRecordType.id ; 
        insert table ; 

        Resource_Development__c resource = new Resource_Development__c();
        resource.ResourceLeadApprovalState__c = '草稿';
        resource.name = 'aaa';

        resource.Group__c = acc.id;
        resource.MW__c = '2';
        resource.Period__c = '一';
        resource.WindFarmName__c = 'ccc';
        resource.OwnerId = user.id ; 
        resource.SalesDepartment__c = '华南';
        resource.Leadbackgrand__c = 'qwe';
        resource.Province__c = '广东';
        resource.LeadContent__c = 'zzz';
        //resource.City__c = '北京市';
        resource.LeadOwner__c = user.id ; 
        resource.Entrant__c = false ; 
        resource.ProjectSubmission__c = '正常';
        insert resource ; 

        resource.ConvertedToLead__c = true;
        update resource;

        resource.ResourceLeadApprovalState__c = '审批通过';
        resource.ConvertedToLead__c =true  ;
        // resource.Stage__c = '001';
        // resource.Entrant__c = true ; 

        update resource ; 


        // resource.Stage__c = '001';
        // resource.Entrant__c = true ; 
        // update resource ;

    }

    static testMethod void testResourceToClue1(){

        Profile pro = [SELECT ID,NAME FROM Profile WHERE NAME = '大客户'];

        User user = new User();
        user.Username = 'john@acmeee.com';
        user.LastName = 'www';
        user.Email = 'john@acme.com.sanbox4';
        user.Alias = 'www';
        user.TimeZoneSidKey = 'Asia/Shanghai';
        user.LocaleSidKey = 'zh_CN';
        user.EmailEncodingKey = 'GB2312';
        user.ProfileId = pro.id;
        user.LanguageLocaleKey = 'zh_CN';
        insert user;

        Account acc = new Account();
        acc.name = 'qqq';
        acc.BeenGroup__c = true;
        insert acc ; 

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'OppSubCompany_RecordType'];

        Integrated_Middle_Table__c table = new Integrated_Middle_Table__c();
        table.Salesdepartment__c = '华南';
        table.OppChiefgeneralmanager__c = user.id ; 
        table.RecordTypeId = imtRecordType.id ; 
        insert table ; 

        Resource_Development__c resource = new Resource_Development__c();
        resource.ResourceLeadApprovalState__c = '草稿';
        resource.name = 'aaa';

        resource.Group__c = acc.id;
        resource.MW__c = '2';
        resource.Period__c = '一';
        resource.WindFarmName__c = 'ccc';
        resource.OwnerId = user.id ; 
        resource.SalesDepartment__c = '华南';
        resource.Leadbackgrand__c = 'qwe';
        resource.Province__c = '广东';
        resource.LeadContent__c = '';
        //resource.City__c = '北京市';
        resource.LeadOwner__c = user.id ; 
        resource.Entrant__c = false ;
        resource.ProjectSubmission__c = '正常'; 
        insert resource ; 

        resource.ConvertedToLead__c = true;
        update resource;

        resource.ResourceLeadApprovalState__c = '审批通过';
        resource.ConvertedToLead__c =true  ;
        // resource.Stage__c = '001';
        // resource.Entrant__c = true ; 

        update resource ; 


        resource.Stage__c = '001';
        resource.Entrant__c = true ; 
        update resource ;

    }
}