@istest
public with sharing class Test_Controller_RestartOpportunity {
    static testMethod void testControllerThread() {

        //商机
        Opportunity opp  = new Opportunity();
        opp.Name = 'opp';
        opp.StageName ='线索管理';
        opp.CloseDate = System.today();
        opp.Projecttype__c = '陆上项目';
        opp.Periods__c = '一';
        opp.capacity__c = 12;
        insert opp;
        
        System.Test.startTest();
        Controller_RestartOpportunity.restartOpportunity(opp.Id);
        System.Test.stopTest();
    }
}