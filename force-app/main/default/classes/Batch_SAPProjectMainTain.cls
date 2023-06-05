/*
 * @Author: irving
 * @Date: 2021-10-11 08:31:00
 * @LastEditTime: 2021-11-19 11:32:10
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 */
global without sharing class Batch_SAPProjectMainTain implements Database.batchable<SObject>,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,Projectnumber__c,Ownedcompany__c FROM Project__c WHERE Projectnumber__c!=NULL]);
    }

    global void execute(Database.BatchableContext BC, List<Project__c> projectList) {

        //Controller_SAPProjectMainTain.SAPProjectMainTain(projectList);

    }

    global void finish(Database.BatchableContext BC) {

    }
}