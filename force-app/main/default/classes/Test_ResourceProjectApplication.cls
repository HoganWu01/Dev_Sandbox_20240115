@isTest
public with sharing class Test_ResourceProjectApplication {

    @TestSetup 
    static void setData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];

        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standardussder@test110.com');
        insert user; 
    }

     static testMethod void testResourceProjectApplication(){

        ResourceProjectApplication__c r=  new ResourceProjectApplication__c();

        r.Approvalstatus__c = null ; 
        insert r ; 

        r.Approvalstatus__c = '20';
        update r ; 

        r.Approvalstatus__c = '11';
        update r ; 

    }

    static testMethod void testResourceProjectSchemeApplication(){

        User user = [SELECT ID,NAME,Email  FROM USER WHERE UserName ='standardussder@test110.com'];

        Resource_Project_Scheme_Application__c r=  new Resource_Project_Scheme_Application__c();
        r.Node_Personnel__c = user.id ; 
        r.Approvalstatus__c = null ; 
        insert r ; 

        r.Approvalstatus__c = '11';
        update r ; 
    }

    static testMethod void testResourceProjectSchemeApplication1(){

        String recordType = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Project_Scheme_Form_Record_Type').getRecordTypeId();
        Integrated_Middle_Table__c IMT = new Integrated_Middle_Table__c();
        IMT.RecordTypeId = recordType;
        IMT.Project_Area__c = '华南';
        insert IMT;

        User user = [SELECT ID,NAME,Email  FROM USER WHERE UserName ='standardussder@test110.com'];
        Resource_Project_Scheme_Application__c r =  new Resource_Project_Scheme_Application__c();
        r.ProjectArea__c = '新疆公司';
        // r.Wind_Energy_Design__c = null;
        r.Node_Personnel__c = user.id ; 
        r.OwnerUnitName__c = 'hh' ;
        insert r ;
         
        
        // update r;
        List<Resource_Project_Scheme_Application__c> schemeUpdateList = new List<Resource_Project_Scheme_Application__c>();
        schemeUpdateList.add(r);
    }

}