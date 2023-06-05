@isTest
public with sharing class Test_AccountLayerShip {
    static testMethod void testAccountLayerShip(){

        Account acc = new Account();
        acc.name = 'aaa';
        acc.parentId = null ; 
        acc.BeenGroup__c = true ; 
        insert acc ; 

        Account acc1 = new Account();
        acc1.name = 'bbb';
        acc1.parentId = acc.id ; 
        acc1.BeenGroup__c = false ; 
        insert acc1 ; 

        Account acc2 = new Account();
        acc2.name = 'ccc';
        acc2.parentId = acc1.id ; 
        acc2.BeenGroup__c = false ; 
        insert acc2 ; 


        System.Test.startTest();
        AccountLayerShipController.getAccountWithLayership(acc1.id);
        AccountLayerShipController.getAvailableAccount(acc.id);
        AccountLayerShipController.removeAccount(acc.id);
        AccountLayerShipController.searchAccount(acc.id);
        System.Test.stopTest();

    }
}