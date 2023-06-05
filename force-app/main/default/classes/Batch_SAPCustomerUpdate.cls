global without sharing class Batch_SAPCustomerUpdate implements Database.batchable<SObject>,Database.AllowsCallouts {
    

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,CompanyCode__c,ReconciliationSubjects__c,PricingProcess__c,PriceGroup__c,CustomerAccountGroup__c,AccountNumber,Country__c,Area__c,Shortname__c,ProductGroup__c,Officialcode__c,Street__c,TaxType__c,SalesrOrganization__c,ShippingConditions__c,DistributionChannels__c,PaymentTerms__c FROM Account ]);
    }

    global void execute(Database.BatchableContext BC, List<Account> accList) {

        //Controller_SAPCustomerUpdate.SAPCustomerUpdate(accList);

    }

    global void finish(Database.BatchableContext BC) {

    }
}