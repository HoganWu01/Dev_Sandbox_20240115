/*
 * @Descripttion: 【资源项目方案申请】模块测试类
 * @Author: Devin
 * @Date: 2021-11-05 08:37:04
 * @LastEditors: Devin
 * @LastEditTime: 2022-01-10 15:24:00
 */
@isTest
public with sharing class Test_RPSA {

    /**
     * @Descripttion: Controller_RPSA 测试类 87%
     * @Author: Devin
     * @param {*}
     * @return {*}
    */    
    static testMethod void test_getSchemetype() {
        System.Test.startTest();
        Controller_RPSA.doInit();
        System.Test.stopTest();
    }

    /**
     * @Descripttion: 
     * @Author: Devin
     * @param {*}
     * @return {*}
    */    
    static testMethod void test_saveData() {
        Resource_Development__c rd = new Resource_Development__c();
        rd.Name = '资源开发';
        rd.MW__c = '12';
        rd.ProjectSubmission__c = '正常'; 
        insert rd;
        
        System.Test.startTest();
        Controller_RPSA.saveData(rd.Id,'Survey_Application','Survey_Application');
        System.Test.stopTest();
    }
}