/*
 * @Author: Conner
 * @Date: 2021-12-29 14:02:52
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-29 14:53:15
 * @Descripttion: 集成中间表触发器handler
 */
public with sharing class IntegratedMiddleTableTriggerHandler {
    /**
     * @description: 当集成中间表的上传附件标识字段有更新时，修改集成中间表对应的对象的值
     * @param  {*}
     * @return {*}
     */    
    public void updateParentTrigger(List<Integrated_Middle_Table__c> objList){
        Map<String,List<sObject>> objectUpdateMap = new Map<String,List<sObject>>();//准备更新中间表对应的主表单 key:对象名

        //devin 2022-04-02 去除对象Id重复
        Set<String> objectIdSet = new Set<String>();
        for (Integrated_Middle_Table__c obj : objList) {
            List<sObject> findSobjectList = new List<sObject>();
            if (objectUpdateMap.containsKey(obj.Object_API__c)) {
                findSobjectList = objectUpdateMap.get(obj.Object_API__c);//使用已存在的待更新对象集合
            }
            String objectAPI = obj.Object_API__c;
            Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectAPI);
            // 创建对象类型的引用

            if(!objectIdSet.contains(obj.Mapping_Object_Id__c)) {

                Sobject genericObject = convertType.newSObject();
                genericObject.put('Id', obj.Mapping_Object_Id__c);
                genericObject.put('Is_Upload_File__c', obj.Is_Upload_File__c);
                findSobjectList.add(genericObject);
                objectUpdateMap.put(obj.Object_API__c, findSobjectList);

                objectIdSet.add(obj.Mapping_Object_Id__c);
            }
        }
        for (List<sObject> obj : objectUpdateMap.values()) {
            update obj;//更新主对象
        }
    }
}