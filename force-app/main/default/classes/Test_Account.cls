/*
 * @Descripttion: 【客户】模块测试类
 * @Author: Devin
 * @Date: 2021-11-04 15:06:44
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-04 15:19:41
 */
@isTest
public with sharing class Test_Account {

    @TestSetup 
    static void setData() {
        Account acc = new Account();
        acc.Name = '广州风机';
        acc.BeenGroup__c = true;
        insert acc;
    }


    /**
     * @Descripttion: AccountHandler 测试类 100%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_AccountHandler() {
 
        String accId = [SELECT Id FROM Account WHERE Name = '广州风机'].Id;
        Account acc = new Account();
        acc.Id = accId;
        acc.SysSAP__c = true;
        System.Test.startTest();
        update acc;
        System.Test.stopTest();
    }

    /**
     * @Descripttion: Controller_AccountApproval  测试类 88%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_initAccount() {
        String accId = [SELECT Id FROM Account WHERE Name = '广州风机'].Id;
        System.Test.startTest();
        Controller_AccountApproval.initAccount(accId);
        Controller_AccountApproval.accountApproval(accId,'审批留言');
        System.Test.stopTest();
    }
}