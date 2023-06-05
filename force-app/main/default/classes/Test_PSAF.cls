/*
 * @Descripttion:  【方案申请】模块 测试类
 * @Author: Devin
 * @Date: 2021-11-04 16:28:01
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-04 16:42:30
 */
@isTest
public with sharing class Test_PSAF {
    @TestSetup 
    static void setData() {
        Opportunity opp  = new Opportunity();
        opp.Name = 'opp';
        opp.StageName ='线索管理';
        opp.Wind_Farm_Project_Name__c = '风场项目名';
        opp.CloseDate = System.today();
        opp.Projecttype__c = '陆上项目';
        opp.Periods__c = '一';
        opp.capacity__c = 12;
        insert opp;

    }

    /**
     * @Descripttion: Controller_PSAF 测试类 89%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_getSchemetype() {
        System.Test.startTest();
        Controller_PSAF.getSchemetype();
        System.Test.stopTest();
    }

    /**
     * @Descripttion: 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_saveData() {

        String parentId = [SELECT Id FROM Opportunity WHERE Wind_Farm_Project_Name__c = '风场项目名' LIMIT 1].Id;
        System.Test.startTest();
        Controller_PSAF.saveData(parentId,'Technicalexchange','Schemetype');
        System.Test.stopTest();
    }
}