global without sharing class Batch_ProjectIssueNotify implements Database.batchable<SObject> {
    

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,IssueOwner__c FROM ProjectIssue__c where Status__c = '解决中' ]);
    }

    global void execute(Database.BatchableContext BC, List<ProjectIssue__c> proIssueList) {

        ProjectIssueNotifyHandler.notifyFun(proIssueList);

    }

    global void finish(Database.BatchableContext BC) {

    }
}