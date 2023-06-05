@isTest
public with sharing class Test_BatchRTC {
   

    static testMethod void testBatchRTC(){

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test11011.com');
        insert user1;

       

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'ProvinceArea_RecordType'];

		Integrated_Middle_Table__c i = new Integrated_Middle_Table__c();
		i.RecordTypeId = imtRecordType.id;
        i.Province__c = '河南';
        i.Area__c = '华北';
        i.ProvinceAreaOwner__c = user1.id;
        insert i  ;



        recordType imtRecordType1 = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'OppSubCompany_RecordType'];

		Integrated_Middle_Table__c ii = new Integrated_Middle_Table__c();
        ii.RecordTypeId = imtRecordType1.id;
        ii.OppChiefgeneralmanager__c = user1.id;
        ii.Salesdepartment__c = '华北';
        insert ii  ;

        Account acc = new Account();
        acc.BeenGroup__c = true ; 
        acc.name = 'acc';
        insert acc ; 

        Resource_Development__c resource = new Resource_Development__c();
        resource.Group__c = acc.id ; 
        resource.Province__c = '河南';

        resource.Name = 're';
        resource.MW__c = '1';
        resource.LeadOwner__c = user1.id ; 
        resource.Period__c = '一';
        resource.WindFarmName__c = '猪母山';
        resource.SalesDepartment__c = '云南公司';
        resource.Leadbackgrand__c = 'aaa';
        resource.LeadContent__c = 'aaa';
        resource.City__c = '宁波市';
        resource.OwnerId = user1.id ; 
        insert resource ; 

        String RListStr = '['+resource.id+']';

        BatchRTC.showData(RListStr);

        BatchRTC.BRTC(RListStr);

    }
}