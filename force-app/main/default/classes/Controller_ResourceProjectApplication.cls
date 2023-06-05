/*
 * @Descripttion: 资源立项申请单 新建 控制器
 * @Author: Devin
 * @Date: 2021-11-01 17:05:45
 * @LastEditors: Devin
 * @LastEditTime: 2022-01-10 15:46:30
 */
public without sharing class Controller_ResourceProjectApplication {

    /**
     * @Descripttion: 初始化
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> doInit(String parentId) {

        Map<Object,Object> map_return = new Map<Object,Object>();

        if (String.isNotBlank(parentId) && parentId != 'undefined') {

            try {
                //自动带入字段的值，对应字段：省份>>省份，城市>>城市，区县>>县区，容量>>容量，期数>>期数
                Resource_Development__c development = [SELECT   Id,
                                                                Province__c,//省份
                                                                City__c,//城市
                                                                MW__c//容量（MW）
                                                            FROM 
                                                                Resource_Development__c
                                                            WHERE 
                                                                Id =: parentId
                                                            ];

                ResourceProjectApplication__c pra = new ResourceProjectApplication__c();
                pra.ResourceName__c = development.Id;
                pra.Province__c = development.Province__c;//省份
                pra.City__c = development.City__c;//城市
                pra.Capacity__c = Decimal.valueOf(development.MW__c);//容量（MW）份

                insert pra;

                map_return.put('Messages','创建记录成功!');
                map_return.put('Type','S');
                map_return.put('recordId',pra.Id);
            } catch (Exception e) {
                map_return.put('Messages','创建记录失败, 请联系系统管理员! 错误信息:'+e.getMessage());
                map_return.put('Type','E');
            }
        }

        return map_return;
    }
}