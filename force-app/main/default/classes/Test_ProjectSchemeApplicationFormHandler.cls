/*
 * @Descripttion:  营销项目方案申请单触发器  测试类
 * @Author: Devin
 * @Date: 2021-11-09 20:42:01
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-09 20:51:37
 */
@isTest
public with sharing class Test_ProjectSchemeApplicationFormHandler {
    /**
     * @Descripttion: ProjectSchemeApplicationFormHandler 测试类 91%
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    static testMethod void test_RClueApprovalHandler() {

        Project_Scheme_Application_Form__c proScheme = new Project_Scheme_Application_Form__c();
        proScheme.Approval_Comments__c = '请审批';
        proScheme.Demandtype__c = '';
        proScheme.City__c = '' ; 
        proScheme.Technicalexchange__c='产品推介' ; 
        proScheme.Demandstatement__c = '新增需求';
        insert proScheme ;

        proScheme.Approvalstatus__c = '11';
        update proScheme;

        ProjectSchemeApplicationFormHandler pa = new ProjectSchemeApplicationFormHandler();
        List<Project_Scheme_Application_Form__c> schemeList = new List<Project_Scheme_Application_Form__c>();
        schemeList.add(proScheme);
        pa.autoSetValueTrigger(schemeList);
        
    }

}