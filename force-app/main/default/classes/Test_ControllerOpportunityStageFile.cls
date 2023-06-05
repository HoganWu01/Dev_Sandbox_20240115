@isTest
public with sharing class Test_ControllerOpportunityStageFile {
    @TestSetup 
    static void setData() {

        //商机
        Opportunity opp  = new Opportunity();
        opp.Name = 'opp';
        opp.StageName ='线索管理';
        opp.CloseDate = System.today();
        opp.Projecttype__c = '陆上项目';
        opp.Periods__c = '一';
        opp.capacity__c = 12;
        insert opp;

        ContentVersion contentVersion_1 = new ContentVersion(
                                                                Title = 'Penguins',
                                                                PathOnClient = 'Penguins.jpg',
                                                                VersionData = Blob.valueOf('Test Content'),
                                                                IsMajorVersion = true
                                                            );
        insert contentVersion_1;
          
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];

        //阶段文件
        StageFile__c stageFile = new StageFile__c();
        stageFile.documentId__c = contentVersion_2.ContentDocumentId;
        stageFile.Type__c = 'Application';
        stageFile.DocumenName__c = '文件名';
        stageFile.DocumenLink__c = 'www.com';
        stageFile.ResourceId__c = opp.Id;
        insert stageFile;
    }

    static testMethod void test_doInit() {

        String recordId = [SELECT Id FROM Opportunity WHERE Name = 'opp'].Id;

        System.Test.startTest();
        ControllerOpportunityStageFile.doInit(recordId);
        System.Test.stopTest();
    }

    static testMethod void test_saveWinFile() {

        String recordId = [SELECT Id FROM Opportunity WHERE Name = 'opp'].Id;

        System.Test.startTest();
        ControllerOpportunityStageFile.saveWinFile('222','资料信息','WinFile',recordId);
        System.Test.stopTest();
    }

    static testMethod void test_deleteDocument() {

        String recordId = [SELECT documentId__c FROM StageFile__c WHERE DocumenName__c = '文件名'].documentId__c;
        System.Test.startTest();
        ControllerOpportunityStageFile.deleteDocument(recordId);
        System.Test.stopTest();
    }

    static testMethod void deleteOnlyDocument() {

        String recordId = [SELECT documentId__c FROM StageFile__c WHERE DocumenName__c = '文件名'].documentId__c;
        System.Test.startTest();
        ControllerOpportunityStageFile.deleteOnlyDocument(recordId);
        System.Test.stopTest();
    }
}