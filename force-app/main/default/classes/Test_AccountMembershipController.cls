@istest
public with sharing class Test_AccountMembershipController {
    static testMethod void test_getAccountWithContactMembership() {
        Account acc = new Account();
        acc.Name = '客户';
        acc.BeenGroup__c = true;
        insert acc;
        AccountMembershipController.getAccountWithContactMembership(acc.Id);
    }

    static testMethod void test_getAvailableContacts() {
        Account acc = new Account();
        acc.Name = '客户';
        acc.BeenGroup__c = true;
        insert acc;
        AccountMembershipController.getAvailableContacts(acc.Id);
    }

    static testMethod void test_removeContact() {
        Account acc = new Account();
        acc.Name = '客户';
        acc.BeenGroup__c = true;
        insert acc;

        Contact contact = new Contact();
        contact.LastName = '11';
        contact.AccountId = acc.Id;
        insert contact;

        AccountMembershipController.removeContact(contact.Id);
    }

    static testMethod void test_searchContact() {
        Account acc = new Account();
        acc.Name = '客户';
        acc.BeenGroup__c = true;
        insert acc;
        AccountMembershipController.searchContact('客户',acc.Id);
    }


   
}