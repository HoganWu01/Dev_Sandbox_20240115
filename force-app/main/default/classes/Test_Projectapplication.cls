/*
 * @Descripttion: 【营销项目立项申请】 【资源立项申请单】测试类
 * @Author: Devin
 * @Date: 2021-11-04 15:35:17
 * @LastEditors: Devin
 * @LastEditTime: ###### Tue Jun 13 09:01:06 CST 2023
 */
@isTest
 public with sharing class Test_Projectapplication {
    @TestSetup 
    static void setData() {
        Opportunity opp = new Opportunity();
        opp.Name = '业务机会';
        opp.StageName = '线索管理';
        opp.CloseDate = System.today();
        opp.Wind_Farm_Project_Name__c = '风场项目名';
        insert opp;

        //简档数据
        Profile manageprofile = [SELECT Id FROM Profile WHERE Name='O项目经理'];

        //用户数据
        User user1 = new User(Alias = '格日图', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = manageprofile.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1110.com');
        insert user1;

        //员工数据
        Employee__c emp = new Employee__c(Job_Number__c = '123456', name = 'aaa', Duty__c = '顾问', Department__c = '小卖部', Department_Number__c = '111', Status__c = '在职');
        insert emp ; 
        
        //初始化集成中间表-总经理
        String recTypeIddd = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('OppSubCompany_RecordType').getRecordTypeId();
        Integrated_Middle_Table__c mid1 = new Integrated_Middle_Table__c(Salesdepartment__c = '西南大区', RecordTypeId = recTypeIddd, General_Manager_Company__c = emp.Id, Pre_Sales_Project_Manager__c = user1.Id);
        insert mid1;

        //初始客户分部总经理
        MarketBidDept__c md = new MarketBidDept__c(DeptPickList__c = '999999', DeptId__c = '999999', General_Manager_Emp__c = emp.Id);
        insert md;
    }

    /**
     * @Descripttion: Controller_Projectapplication 测试类 91%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_doInit() {

        String recordId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;

        System.Test.startTest();
        Controller_Projectapplication.doInit(recordId);
        Controller_Projectapplication.saveData(recordId, System.today(), System.today());
        System.Test.stopTest();
    }

    /**
     * @Descripttion: 资源立项申请单 Controller_ResourceProjectApplication 测试类  84%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    // static testMethod void test_CRPA_doInit() {

    //     Resource_Development__c rd = new Resource_Development__c();
    //     rd.Name = '资源开发';
    //     rd.MW__c = '12';
    //     rd.ProjectSubmission__c = '正常';
    //     insert rd;

    //     System.Test.startTest();
    //     Controller_ResourceProjectApplication.doInit(rd.Id);
    //     System.Test.stopTest();
    // }

    /**
     * @Descripttion: 营销项目立项申请单handler ProjectapplicationTriggerHandler 测试类  84%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_ProjectapplicationTriggerHandler() {

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        User user1 = new User(Alias = 'standt', Email='standar1duser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standa1rduser@test110.com');
        insert user1;
        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.Periods__c = '一八';
        opp.capacity__c = 12;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        insert opp;

        Projectapplication__c proj = new Projectapplication__c();
        // proj.projectleader__c = user1.Id;
        proj.Oppty__c = opp.Id;
        proj.MarketBidDept__c = '999999';
        proj.Salesdepartment__c = '西南大区';
        insert proj;
        
        proj.Approvalstatus__c = '11';
        update proj;
        
    }

    
    /**
     * @Descripttion: 营销项目立项申请单handler ProjectapplicationTriggerHandler  autoSetValueTrigger 测试类  
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_autoSetValueTrigger() {

        Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];
       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        User user1 = new User(Alias = 'standt', Email='standar1duser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standa1rduser@test110.com');
        insert user1;
        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.StageName = '线索管理' ;
        opp.CloseDate = Datetime.now().addMonths(1).date();
        opp.Periods__c = '一八';
        opp.capacity__c = 12;
        opp.OpportunityApprovalStatus__c = '线索转化通过';
        insert opp;

        Projectapplication__c proj = new Projectapplication__c();
        // proj.projectleader__c = user1.Id;
        proj.Oppty__c = opp.Id;
        proj.MarketBidDept__c = '999999';
        proj.Salesdepartment__c = '西南大区';
        insert proj;
        
        proj.Approvalstatus__c = '11';
        update proj;

        proj.Approvalstatus__c = '20';
        update proj;

        List<Projectapplication__c> appLis = new List<Projectapplication__c>();
        appLis.add(proj);
        ProjectapplicationTriggerHandler pt = new ProjectapplicationTriggerHandler();
        pt.autoSetValueTrigger(appLis);
        
    }
}