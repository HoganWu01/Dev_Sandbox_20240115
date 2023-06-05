/*
 * @Descripttion:  【资源开发】触发器 测试类
 * @Author: Devin
 * @Date: 2021-11-09 16:28:01
 * @LastEditors: Devin
 * @LastEditTime: 2022-01-19 11:11:57
 */
@isTest
public with sharing class Test_RClueApprovalHandler {

    /**
     * @Descripttion: RClueApprovalHandler 测试类 78%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_RClueApprovalHandler() {

        Profile p = [SELECT Id FROM Profile WHERE Name='资源销售'];
       
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test110.com');
        insert user;

        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Test110', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,  TimeZoneSidKey='America/Los_Angeles', UserName='standard123user@test110.com');
        insert user1;

        //资源开发
        Resource_Development__c rd = new Resource_Development__c();
        rd.Name = '资源开发';
        rd.OwnerId = user.Id;
        rd.ProjectSubmission__c = '正常';
        insert rd;

        //资源开发
        Resource_Development__c rd1 = new Resource_Development__c();
        rd1.Name = '资源开发';
        rd1.OwnerId = user.Id;
        rd1.ProjectSubmission__c = '正常';
        insert rd1;

        //资源立项申请单
        ResourceProjectApplication__c rpc = new ResourceProjectApplication__c();
        rpc.Approval_Comments__c = '';
        rpc.DebtAssetRatioMax__c = null ; 
        rpc.ConstructionImplementationPlan__c = '建设实施方案';
        rpc.TotalCost__c = 19890;
        rpc.ResourceName__c = rd.Id;
        insert rpc;

        rd.ConvertedToLead__c = true;
        update rd;

        rd.OwnerId = user1.Id;
        rd.ConvertedToLead__c = false;
        update rd;

    }
}