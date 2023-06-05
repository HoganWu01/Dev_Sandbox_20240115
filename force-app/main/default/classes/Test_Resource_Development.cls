/*
 * @Descripttion: 【资源开发】模块 测试类
 * @Author: Devin
 * @Date: 2021-11-05 09:13:39
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-09 19:20:32
 */
@isTest
public with sharing class Test_Resource_Development {
    @TestSetup 
    static void setData() {

        //资源开发
        Resource_Development__c rd = new Resource_Development__c();
        rd.Name = '资源开发';
        insert rd;

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
        stageFile.ResourceId__c = rd.Id;
        insert stageFile;
    }

    /**
     * @Descripttion: ControllerStageFile 测试类 89%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_doInit() {

        String recordId = [SELECT ResourceId__c FROM StageFile__c WHERE DocumenName__c = '文件名'].ResourceId__c;

        //阶段文件
        StageFile__c stageFile1 = new StageFile__c();
        stageFile1.Type__c = 'Riskreport';
        stageFile1.DocumenName__c = '文件名1';
        stageFile1.DocumenLink__c = 'www.com';
        stageFile1.ResourceId__c = recordId;
        insert stageFile1;

        //阶段文件
        StageFile__c stageFile2 = new StageFile__c();
        stageFile2.Type__c = 'Basemap';
        stageFile2.DocumenName__c = '文件名2';
        stageFile2.DocumenLink__c = 'www.com';
        stageFile2.ResourceId__c = recordId;
        insert stageFile2;

        //阶段文件
        StageFile__c stageFile3 = new StageFile__c();
        stageFile3.Type__c = 'ProjectPlanningScenarios';
        stageFile3.DocumenName__c = '文件名3';
        stageFile3.DocumenLink__c = 'www.com';
        stageFile3.ResourceId__c = recordId;
        insert stageFile3;

        //阶段文件
        StageFile__c stageFile4 = new StageFile__c();
        stageFile4.Type__c = 'ResourceDevelopmentProtocols';
        stageFile4.DocumenName__c = 'stageFile4';
        stageFile4.DocumenLink__c = 'www.com';
        stageFile4.ResourceId__c = recordId;
        insert stageFile4;

        //阶段文件
        StageFile__c stageFile5 = new StageFile__c();
        stageFile5.Type__c = 'PreSupportOpinion';
        stageFile5.DocumenName__c = 'stageFile5';
        stageFile5.DocumenLink__c = 'www.com';
        stageFile5.ResourceId__c = recordId;
        insert stageFile5;

        //阶段文件
        StageFile__c stageFile6 = new StageFile__c();
        stageFile6.Type__c = 'Prefeasibilitystudy';
        stageFile6.DocumenName__c = 'stageFile6';
        stageFile6.DocumenLink__c = 'www.com';
        stageFile6.ResourceId__c = recordId;
        insert stageFile6;

        //阶段文件
        StageFile__c stageFile7 = new StageFile__c();
        stageFile7.Type__c = 'MatchScheme';
        stageFile7.DocumenName__c = 'stageFile7';
        stageFile7.DocumenLink__c = 'www.com';
        stageFile7.ResourceId__c = recordId;
        insert stageFile7;

        //阶段文件
        StageFile__c stageFile8 = new StageFile__c();
        stageFile8.Type__c = 'GeneralApprovalDocuments';
        stageFile8.DocumenName__c = 'stageFile8';
        stageFile8.DocumenLink__c = 'www.com';
        stageFile8.ResourceId__c = recordId;
        insert stageFile8;

        //阶段文件
        StageFile__c stageFile9 = new StageFile__c();
        stageFile9.Type__c = 'GovernmentRequiredReport';
        stageFile9.DocumenName__c = 'stageFile5';
        stageFile9.DocumenLink__c = 'www.com';
        stageFile9.ResourceId__c = recordId;
        insert stageFile9;

        //阶段文件
        StageFile__c stageFile10 = new StageFile__c();
        stageFile10.Type__c = 'Feasibilitystudy';
        stageFile10.DocumenName__c = 'stageFile5';
        stageFile10.DocumenLink__c = 'www.com';
        stageFile10.ResourceId__c = recordId;
        insert stageFile10;

        //阶段文件
        StageFile__c stageFile11 = new StageFile__c();
        stageFile11.Type__c = 'ApprovalApprovalDocuments';
        stageFile11.DocumenName__c = 'stageFile5';
        stageFile11.DocumenLink__c = 'www.com';
        stageFile11.ResourceId__c = recordId;
        insert stageFile11;
        
        System.Test.startTest();
        ControllerStageFile.doInit(recordId);
        ControllerStageFile fi = new ControllerStageFile();
        ControllerStageFile.SFVO sfvo = new ControllerStageFile.SFVO();
        System.Test.stopTest();
    }

    static testMethod void test_saveSF() {

        String recordId = [SELECT ResourceId__c FROM StageFile__c WHERE DocumenName__c = '文件名'].ResourceId__c;
        System.Test.startTest();
        ControllerStageFile.saveSF('222','资料信息','Application',recordId);
        System.Test.stopTest();
    }
    
    static testMethod void test_deleteDocument() {

        String recordId = [SELECT documentId__c FROM StageFile__c WHERE DocumenName__c = '文件名'].documentId__c;
        System.Test.startTest();
        ControllerStageFile.deleteDocument(recordId);
        System.Test.stopTest();
    }

    static testMethod void test_deleteDocumentError() {

        String recordId = [SELECT ResourceId__c FROM StageFile__c WHERE DocumenName__c = '文件名'].ResourceId__c;

        System.Test.startTest();
        Map<Object,Object> map_return = new Map<Object,Object>();
        map_return = ControllerStageFile.deleteDocument(recordId);
        System.AssertEquals('E', map_return.get('Type'));
        System.Test.stopTest();
    }

    static testMethod void test_deleteOnlyDocument() {

        String recordId = [SELECT documentId__c FROM StageFile__c WHERE DocumenName__c = '文件名'].documentId__c;
        System.Test.startTest();
        ControllerStageFile.deleteOnlyDocument(recordId);
        System.Test.stopTest();
    }

    static testMethod void test_deleteOnlyDocumentError() {

        System.Test.startTest();
        ControllerStageFile.deleteOnlyDocument(null);
        System.Test.stopTest();
    }

    static testMethod void test_downloadDocument() {

        String recordId = [SELECT ResourceId__c FROM StageFile__c WHERE DocumenName__c = '文件名'].ResourceId__c;
        System.Test.startTest();
        ControllerStageFile.downloadDocument(recordId);
        System.Test.stopTest();
    }
    
    static testMethod void test_downloadDocumentError() {

        System.Test.startTest();
        Map<Object,Object> map_return = new Map<Object,Object>();
        try {
            map_return = ControllerStageFile.downloadDocument('1223');
        } catch (Exception e) {
            System.AssertEquals('E', map_return.get('Type'));
        }
        System.Test.stopTest();
    }

    static testMethod void test_downloadDocumentNull() {

        System.Test.startTest();
        ControllerStageFile.downloadDocument('recordId');
        System.Test.stopTest();
    }

}