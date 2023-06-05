/*
 * @Descripttion: OpportunityMembershipController 测试类
 * @Author: Devin
 * @Date: 2021-11-05 08:51:24
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-09 21:34:13
 */
@isTest
public with sharing class Test_OpportunityMembershipController {
    @TestSetup 
    static void setData() {

        Account acc = new Account();
        acc.Name = '广州风机';
        acc.BeenGroup__c = true;
        insert acc;

        Opportunity opp  = new Opportunity();
        opp.Name = 'opp';
        opp.StageName ='初期运作';
        opp.CloseDate = System.today();
        opp.Projecttype__c = '陆上项目';
        opp.Periods__c = '一';
        opp.capacity__c = '12';
        opp.EPC__c = acc.Id;
        insert opp;
    }

    /**
     * @Descripttion: getOpportunityWithContactMembership 测试类 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_getOpportunityWithContactMembership() {
        
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'opp'].Id;
        Contact contact1 = new Contact();
        contact1.LastName = '联系人';
        insert contact1;

        OpportunityContactRole role = new OpportunityContactRole();
        role.ContactId = contact1.Id;
        role.OpportunityId = oppId;
        insert role;

        System.Test.startTest();
        OpportunityMembershipController.getOpportunityWithContactMembership(oppId);
        System.Test.stopTest();
    }

    /**
     * @Descripttion: getAvailableContacts 测试类 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_getAvailableContacts() {
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'opp'].Id;

        Contact contact = new Contact();
        contact.LastName = '联系人';
        insert contact;
        
        OpportunityContactRole role = new OpportunityContactRole();
        role.OpportunityId = oppId;
        role.ContactId = contact.Id;
        insert role;
        
        System.Test.startTest();
        OpportunityMembershipController.getAvailableContacts(oppId);
        System.Test.stopTest();
    }

    /**
     * @Descripttion: removeContact 测试类 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_removeContact() {
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'opp'].Id;

        Contact contact1 = new Contact();
        contact1.LastName = '联系人';
        insert contact1;

        OpportunityContactRole role = new OpportunityContactRole();
        role.ContactId = contact1.Id;
        role.OpportunityId = oppId;
        insert role;
        
        System.Test.startTest();
        OpportunityMembershipController.removeContact(contact1.Id);
        System.Test.stopTest();
    }

    
    /**
     * @Descripttion: addRelation 测试类 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_addRelation() {
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'opp'].Id;

        Contact contact1 = new Contact();
        contact1.LastName = '联系人';
        insert contact1;
        
        System.Test.startTest();
        OpportunityMembershipController.addRelation(oppId,contact1.Id);
        System.Test.stopTest();
    }

    /**
     * @Descripttion: searchContact 测试类 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_searchContact() {

        Contact contact1 = new Contact();
        contact1.LastName = '联系人';
        insert contact1;
        
        System.Test.startTest();
        OpportunityMembershipController.searchContact('联系人');
        System.Test.stopTest();
    }
}