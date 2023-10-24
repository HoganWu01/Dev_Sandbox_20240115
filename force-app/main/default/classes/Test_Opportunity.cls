/*
 * @Descripttion: 【商机】 模块 测试类
 * @Author: Devin
 * @Date: 2021-11-05 08:51:24
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-03-22 14:43:47
 */
@isTest
public with sharing class Test_Opportunity {
    @TestSetup 
    static void setData() {

        //客户数据
        Account acc = new Account();
        acc.Name = '广州风机';
        acc.BeenGroup__c = true;
        insert acc;

        //简档数据
        Profile manageprofile = [SELECT Id FROM Profile WHERE Name='O项目经理'];

        //用户数据
        User user1 = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1110.com');
        insert user1;

        User user2 = new User(Alias = '格日图222', Email='standarduser222@testorg.com',EmailEncodingKey='UTF-8', LastName='Test120', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test120.com');
        insert user2;

        //员工数据
        Employee__c emp = new Employee__c(Job_Number__c = '123456', name = 'aaa', Duty__c = '顾问', Department__c = '小卖部', Department_Number__c = '111', Status__c = '在职');
        insert emp ; 

        String recTypeId1 =Schema.SObjectType.BasicData__c.getRecordTypeInfosByDeveloperName().get('RecordType_BasicData_Sales').getRecordTypeId();
        BasicData__c bd = new BasicData__c(RecordTypeId = recTypeId1, name = 'aaa', ProjectArea__c = 'SR101', BasicNo__c = 'A001');
        insert bd;

        Opportunity opp  = new Opportunity();
        opp.Name = 'opp';
        opp.ProjectSubmission__c = '正常提报线索';
        opp.Projecttype__c = '陆上项目';
        opp.AccountId = acc.Id;
        opp.Wind_Farm_Project_Name__c = '风场项目名';
        opp.capacity__c = 12;
        opp.StageName ='线索管理';
        opp.Province__c = '广东';
        opp.City__c = '中山';
        opp.CloseDate = System.today();
        opp.Periods__c = '一';
        opp.Close__c = false;
        opp.recordTypeId = '0122u0000008UxEAAU';
        opp.MarketBidDept__c = 'KA101';
        opp.ProjectArea__c = 'SR101';
        opp.ProjectDeliveryMarket__c = '01';
        opp.OwnerId = user1.Id;
        opp.OpportunityApprovalStatus__c = '草稿';
        insert opp;
    }

    /**
     * @Descripttion: ControllerBusinessSubmit 测试类 90%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_initApproval() {
        String parentId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        System.Test.startTest();
        ControllerBusinessSubmit.initApproval(parentId);
        System.Test.stopTest();
    }

    /**
     * @Descripttion: 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_businessSubmit() {
        String parentId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        System.Test.startTest();
        ControllerBusinessSubmit.businessSubmit(parentId,'请审批');
        System.Test.stopTest();
    }

        /**
     * @Descripttion: 
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_bidSubmit() {
        Opportunity opp = [SELECT Id,Approvalstatus__c FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1];
        opp.Approvalstatus__c = '30';
        update opp;
        System.Test.startTest();
        ControllerOppBidSubmit.bidSubmit(opp.Id,'请审批');
        System.Test.stopTest();
    }

       /**
     * @Descripttion: 
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */  
    static testMethod void test_bidSubmit2() {
        Opportunity opp = [SELECT Id,Approvalstatus__c FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1];
        System.Test.startTest();
        ControllerOppBidSubmit.bidSubmit(opp.Id,'请审批');
        System.Test.stopTest();
    }


    /**
     * @Descripttion: OpportunityHandler 测试类 81%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_OpportunityHandler() {

        Profile p = [SELECT Id FROM Profile WHERE Name='R资源销售'];

        User user1 = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test11011.com');
        insert user1;

        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'OppSubCompany_RecordType'];

        recordType imtRecordType1 = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'ProjectType_RecordType'];

        Integrated_Middle_Table__c i2 = new Integrated_Middle_Table__c();
		i2.RecordTypeId = imtRecordType1.id;
        i2.ProjectType__c = '陆上';
        i2.RoleName__c = '陆上PMO';
        insert i2  ;

        recordType imtRecordType2 = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'OppWinBid_RecordType'];

        Integrated_Middle_Table__c i1 = new Integrated_Middle_Table__c();
		i1.RecordTypeId = imtRecordType2.id;
        i1.OppWinBidNotify__c = '合同管理专员';
        insert i1  ;

        String oppId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
       
        Opportunity opp = new Opportunity();
        opp.Id = oppId;
        opp.Approvalstatus__c  = '30';
        opp.Approval__c = '是';
        opp.Choose__c = true;
        opp.Approvaltime__c = System.today();
        opp.Date__c = System.today();
        opp.MarketBidDept__c = 'KA101';
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        update opp;

        Projectapplication__c pac = new Projectapplication__c();
        pac.Oppty__c = opp.id ; 
        pac.Approvalstatus__c  = '30';
        insert pac ; 

        Profile ppp = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       

        Profile manageprofile = [SELECT Id FROM Profile WHERE Name='O项目经理'];

        User userrr = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123456@test110.com');
        insert userrr;

        Project__c pro = new Project__c();
        pro.name = 'pro';
        pro.Opportunity__c = oppId ; 
        pro.Type__c = '陆上项目';
        pro.OwnerId = userrr.id;
        pro.ProjectManager__c=userrr.id ; 
        insert pro ; 

        opp.StageName = '中标/赢单';
        opp.ProjectArea__c = 'SR102';
        opp.MarketBidDept__c = 'KA102';

        User user = new User(Alias = '颜芳', Email='yanfang@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='yanfang@test110.com');
        insert user;
        
        opp.Chiefgeneralmanager__c = user.Id;

        opp.OwnerId = user.Id;
        update opp;

        opp.Close__c = true;
        update opp;


    }

    static testMethod void test_shareAuthorityHandler() {

        Profile p = [SELECT Id FROM Profile WHERE Name='R资源销售'];

        User user = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        Opportunity opp1  = new Opportunity();
        opp1.Name = 'opp1';
        opp1.StageName ='线索管理';
        opp1.CloseDate = System.today();
        opp1.Projecttype__c = '陆上项目';
        opp1.Periods__c = '三';
        opp1.capacity__c = 12;
        opp1.Key_Account_General_Manager__c = user.id ; 
        opp1.Chiefgeneralmanager__c = user.id ; 
        opp1.Pre_Sales_Project_Manager__c = user.id;
        opp1.OpportunityApprovalStatus__c='草稿';
        
        insert opp1;

        User user2 = new User(Alias = 'test1111', Email='test1111@testorg.com',EmailEncodingKey='UTF-8', LastName='Test111111', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='test1111122222@test.com');
        insert user2;

        opp1.OpportunityApprovalStatus__c='线索提报审批中';
        opp1.OwnerId = user2.Id;
        update opp1;

        opp1.OpportunityApprovalStatus__c='线索提报通过';
        update opp1;

        opp1.Close__c = true;//测试关闭商机
        update opp1;

        opp1.Close__c = false;//测试重启商机
        update opp1;

        opp1.StageName = '项目立项';
        update opp1;
    }
    
}