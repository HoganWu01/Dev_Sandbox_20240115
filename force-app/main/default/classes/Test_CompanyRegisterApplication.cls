/*
 * @Descripttion: 【子公司投资与注册变更事前申请】模块触发器
 * @Author: Devin
 * @Date: 2021-11-04 15:19:19
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-12-20 14:19:52
 */
@isTest
public with sharing class Test_CompanyRegisterApplication {

    /**
     * @Descripttion: Controller_CompanyRegisterApplication 测试类 82%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_doInit() {
        Resource_Development__c rd = new Resource_Development__c();
        rd.Name = '资源开发';
        insert rd;
        System.Test.startTest();
        Controller_CompanyRegisterApplication.doInit(rd.Id);
        Controller_CompanyRegisterApplication.doSave(rd.id, '123123');
        System.Test.stopTest();
    }
}