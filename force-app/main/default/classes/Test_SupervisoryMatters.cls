/*
 * @Descripttion: 【督办事项】 测试类
 * @Author: Hogan
 * @Date: 2023-05-05 08:51:24
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-05-05 08:51:24
 */
@isTest
public with sharing class Test_SupervisoryMatters {
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

        //添加客户分部记录
        MarketBidDept__c mb1 = new MarketBidDept__c(Name = '客户一部', General_Manager_User__c = user1.Id, DeptPickList__c = '162092f16daa04f4de53a694724b93ac', DeptId__c = '162092f16daa04f4de53a694724b93ac');
        insert mb1;
        MarketBidDept__c mb2 = new MarketBidDept__c(Name = '客户二部', General_Manager_User__c = user2.Id, DeptPickList__c = '162092f16e0f16e08b24fb54940ac5c7', DeptId__c = '162092f16e0f16e08b24fb54940ac5c7');
        insert mb2;

        //添加大区、售前项目经理记录
        Integrated_Middle_Table__c mid1 = new Integrated_Middle_Table__c(Salesdepartment__c = '西南大区', RecordTypeId = '0122u0000008V2DAAU', OppChiefgeneralmanager__c = user1.Id, Pre_Sales_Project_Manager__c = user1.Id);
        insert mid1;
        Integrated_Middle_Table__c mid2 = new Integrated_Middle_Table__c(Salesdepartment__c = '东北大区', RecordTypeId = '0122u0000008V2DAAU', OppChiefgeneralmanager__c = user2.Id, Pre_Sales_Project_Manager__c = user2.Id);
        insert mid2;

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
        opp.Salesdepartment__c = '西南大区';
        opp.MarketBidDept__c = '162092f16daa04f4de53a694724b93ac';
        opp.OwnerId = user1.Id;
        opp.OpportunityApprovalStatus__c = '商机提报通过';
        insert opp;

        SupervisoryMatters__c matters = new SupervisoryMatters__c();
        matters.name = '督办测试';
        matters.Opportunity__c = opp.Id;
        matters.ApprovalStatus__c = '0';
        matters.MattersStatus__c = '0';
        matters.ChargeDept__c = '采购部';
        insert matters;

        MattersCollaboration__c mattersColl = new MattersCollaboration__c();
        mattersColl.SupervisoryMatters__c = matters.Id;
        mattersColl.Collaborators__c = user1.Id;
        insert mattersColl;
    }

    /**
     * @Descripttion: ControllerMattersSubmit 测试类
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_initApprovalCompletion() {
        String parentId = [SELECT Id FROM SupervisoryMatters__c WHERE name = '督办测试' LIMIT 1].Id;
        System.Test.startTest();
        ControllerMattersSubmit.initApprovalCompletion(parentId);
        System.Test.stopTest();
    }

    /**
     * @Descripttion: ControllerMattersSubmit 测试类
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_initApprovalExtension() {
        String parentId = [SELECT Id FROM SupervisoryMatters__c WHERE name = '督办测试' LIMIT 1].Id;
        System.Test.startTest();
        ControllerMattersSubmit.initApprovalExtension(parentId);
        System.Test.stopTest();
    }

    /**
     * @Descripttion: ControllerMattersSubmit 测试类
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_completionSubmit() {
        String parentId = [SELECT Id FROM SupervisoryMatters__c WHERE name = '督办测试' LIMIT 1].Id;
        System.Test.startTest();
        ControllerMattersSubmit.completionSubmit(parentId,'请审批', Datetime.now().date(),'完成情况说明');
        System.Test.stopTest();
    }

       /**
     * @Descripttion: ControllerMattersSubmit 测试类
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_extensionSubmit() {
        String parentId = [SELECT Id FROM SupervisoryMatters__c WHERE name = '督办测试' LIMIT 1].Id;
        System.Test.startTest();
        ControllerMattersSubmit.extensionSubmit(parentId, Datetime.now().date(),'延期原因');
        System.Test.stopTest();
    }
    
       /**
     * @Descripttion: MattersHandler 测试类
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_updateTrigger() {
        SupervisoryMatters__c matters = [SELECT Id,MattersStatus__c FROM SupervisoryMatters__c WHERE name = '督办测试' LIMIT 1];
        matters.MattersStatus__c = '1';
        update matters;

        matters.MattersStatus__c = '0';
        update matters;

        matters.ChargeDept__c = '销售大区';
        matters.ProjectArea__c = '18682430bad7ffb1d9bf0b54ffdbebc0';
        update matters;

        matters.ChargeDept__c = '客户分部';
        matters.ResponsibilityBidDept__c = '162092f16daa04f4de53a694724b93ac';
        update matters;
    }

    /**
     * @Descripttion: Schedule_MattersExpirationMonitor 测试类
     * @Author: Hogan
     * @param {*}
     * @return {*}
     */   
    @IsTest static void test_Schedule_SAPCustomerUpdate(){
        SupervisoryMatters__c matters = [SELECT Id,MattersStatus__c FROM SupervisoryMatters__c WHERE name = '督办测试' LIMIT 1];
        matters.MattersStatus__c = '1';
        matters.PlanCompletionDate__c = Datetime.now().date();
        update matters;

        Schedule_MattersExpirationMonitor ss = new Schedule_MattersExpirationMonitor();
        ss.execute(null);

        Schedule_MattersExpirationMonitor2 sss = new Schedule_MattersExpirationMonitor2();
        sss.execute(null);

        Schedule_MattersExpirationMonitor3 ssss = new Schedule_MattersExpirationMonitor3();
        ssss.execute(null);

        // Schedule_MattersExpirationMonitor4 sssss = new Schedule_MattersExpirationMonitor4();
        // sssss.execute(null);


        matters.PlanCompletionDate__c = Datetime.now().date()-1;
        update matters;

        Schedule_MattersExpirationMonitor ss1 = new Schedule_MattersExpirationMonitor();
        ss1.execute(null);

        Schedule_MattersExpirationMonitor2 sss1 = new Schedule_MattersExpirationMonitor2();
        sss1.execute(null);

        Schedule_MattersExpirationMonitor3 ssss1 = new Schedule_MattersExpirationMonitor3();
        ssss1.execute(null);

        matters.PlanCompletionDate__c = Datetime.now().date()+3;
        update matters;

        Schedule_MattersExpirationMonitor4 sssss1 = new Schedule_MattersExpirationMonitor4();
        sssss1.execute(null);
    }
}