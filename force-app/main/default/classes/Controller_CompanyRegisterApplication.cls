/*
 * @Descripttion: 子公司投资与注册变更事前申请 新建 控制器
 * @Author: Devin
 * @Date: 2021-11-02 09:46:34
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-23 14:34:10
 */
public without sharing class Controller_CompanyRegisterApplication {

    /**
     * @Descripttion: 初始化
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> doInit(String parentId) {

        Map<Object,Object> map_return = new Map<Object,Object>();

        List<RecordType> recordTypeList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'CompanyRegisterApplication__c'];
        map_return.put('recordType',recordTypeList);
        return map_return;
    }

    /**
     * @Descripttion: 保存
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> doSave(String parentId,String recordTypeId) {

        Map<Object,Object> map_return = new Map<Object,Object>();

        if (String.isNotBlank(parentId) && parentId != 'undefined') {

            try {
                //新建时需要从【资源开发】详细信息中带入字段的值，字段包括：项目名称>>项目名称
                Resource_Development__c development = [SELECT   Id,
                                                                ProjectName__c//项目名称
                                                            FROM 
                                                                Resource_Development__c
                                                            WHERE 
                                                                Id =: parentId
                                                            ];

                CompanyRegisterApplication__c cra = new CompanyRegisterApplication__c();
                cra.ResourceDevelopmentaName__c = development.Id;
                cra.ProjectName__c = development.ProjectName__c;//项目名称
                cra.RecordTypeId = recordTypeId;//记录类型Id

                insert cra;

                map_return.put('Messages','创建记录成功!');
                map_return.put('Type','S');
                map_return.put('recordId',cra.Id);
            } catch (Exception e) {
                map_return.put('Messages','创建记录失败, 请联系系统管理员! 错误信息:'+e.getMessage());
                map_return.put('Type','E');
            }
        }

        return map_return;
    }
}