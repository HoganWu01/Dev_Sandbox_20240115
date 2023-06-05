/*
 * @Author: Conner
 * @Date: 2021-12-17 14:38:19
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-22 10:29:51
 * @Descripttion: 子对象新增时，共享记录给父对象的指定用户
 */
public without sharing class ShareCommonTriggerHandler {
    /**
     * @description: 相关父对象删除后删除子对象的共享记录(记录的删除)
     * ShareCommonTriggerHandler sha = new ShareCommonTriggerHandler();
     *  if (Trigger.isAfter) {
     *      if (Trigger.isDelete) {
     *          List<SObject> objList = new List<SObject>();
     *           for (SObject obj : Trigger.old) {
     *               objList.add(obj);
     *           }
     *           sha.deleteSharePermissionToChild(objList);
     *       }
     *  }
     */    
    public void deleteSharePermissionToChild(List<Sobject> objIdList){
        Map<String,String> objectAPIMap = new Map<String,String>();
        objectAPIMap.put('Project_Scheme_Application_Form__c','Oppty__c');//营销项目方案
        objectAPIMap.put('Projectapplication__c','Oppty__c');//项目立项
        objectAPIMap.put('Contractmanagement__c','ObjectName__c');//合同商务
        objectAPIMap.put('Requirementsreview__c','Contractmanagement__r.ObjectName__c');//业主需求
        objectAPIMap.put('Demandconfiguration__c','Requirementsreview__r.Contractmanagement__r.ObjectName__c');//业主需求配置
        objectAPIMap.put('ContractSupplement__c','Contractname__r.ObjectName__c');//营销合同
        objectAPIMap.put('Seal_Approval__c','Marketing_Contract__r.Contractname__r.ObjectName__c');//印章审批
        objectAPIMap.put('Seal_Related_Information__c','Marketing_Contract__r.Contractname__r.ObjectName__c');//印章相关信息
        for (Sobject obj : objIdList) {
            List<Id> allIdList = new List<Id>();
            allIdList.add((Id)obj.get('OpportunityId'));
            //变量1:需要根据实际情况替换为相应的字段API
            ShareCommonTriggerHandler.deleteShareRecordUtil((Id)obj.get('UserId'),objectAPIMap,allIdList);
        }
    }
    /**
     * @description: 相关父对象新建后共享记录给子对象(相关记录的新增)
     * ShareCommonTriggerHandler sha = new ShareCommonTriggerHandler();
     *  if (Trigger.isAfter) {
     *      if (Trigger.isInsert) {
     *          List<SObject> objList = new List<SObject>();
     *           for (SObject obj : Trigger.new) {
     *               objList.add(obj);
     *           }
     *           sha.sharePermissionToChild(objList);
     *       }
     *  }
     */    
    public void sharePermissionToChild(List<Sobject> objIdList){
        Map<String,String> objectAPIMap = new Map<String,String>();
        objectAPIMap.put('Project_Scheme_Application_Form__c','Oppty__c');//营销项目方案
        objectAPIMap.put('Projectapplication__c','Oppty__c');//项目立项
        objectAPIMap.put('Contractmanagement__c','ObjectName__c');//合同商务
        objectAPIMap.put('Requirementsreview__c','Contractmanagement__r.ObjectName__c');//业主需求
        objectAPIMap.put('Demandconfiguration__c','Requirementsreview__r.Contractmanagement__r.ObjectName__c');//业主需求配置
        objectAPIMap.put('ContractSupplement__c','Contractname__r.ObjectName__c');//营销合同
        objectAPIMap.put('Seal_Approval__c','Marketing_Contract__r.Contractname__r.ObjectName__c');//印章审批
        objectAPIMap.put('Seal_Related_Information__c','Marketing_Contract__r.Contractname__r.ObjectName__c');//印章相关信息
        objectAPIMap.put('SupervisoryMatters__c','Opportunity__c');//督办事项
        for (Sobject obj : objIdList) {
            List<Id> allIdList = new List<Id>();
            allIdList.add((Id)obj.get('OpportunityId'));
            //变量1:需要根据实际情况替换为相应的字段API
            ShareCommonTriggerHandler.shareRecordUtil((Id)obj.get('UserId'),objectAPIMap,allIdList,'Read');
        }
    }
    /**
     * @description: 子对象触发器进来的方法（demo）
     * 触发器（Trigger）代码demo
     * ShareCommonTriggerHandler sha = new ShareCommonTriggerHandler();
     *  if (Trigger.isAfter) {
     *      if (Trigger.isInsert) {
     *          List<SObject> objList = new List<SObject>();
     *           for (SObject obj : Trigger.new) {
     *               objList.add(obj);
     *           }
     *           sha.sharePermissionToParent(objList);
     *       }
     *  }
     */    
    public void sharePermissionToParent(List<Sobject> objIdList){
        List<Id> allIdList = new List<Id>();
        Map<String,String> objectAPIMap = new Map<String,String>();
        objectAPIMap.put('Project_Scheme_Application_Form__c','Oppty__c');//营销项目方案
        objectAPIMap.put('Projectapplication__c','Oppty__c');//项目立项
        objectAPIMap.put('Contractmanagement__c','ObjectName__c');//合同商务
        objectAPIMap.put('Requirementsreview__c','Contractmanagement__r.ObjectName__c');//业主需求
        objectAPIMap.put('Demandconfiguration__c','Requirementsreview__r.Contractmanagement__r.ObjectName__c');//业主需求配置
        objectAPIMap.put('ContractSupplement__c','Contractname__r.ObjectName__c');//营销合同
        objectAPIMap.put('Seal_Approval__c','Marketing_Contract__r.Contractname__r.ObjectName__c');//印章审批
        objectAPIMap.put('Seal_Related_Information__c','Marketing_Contract__r.Contractname__r.ObjectName__c');//印章相关信息
        objectAPIMap.put('SupervisoryMatters__c','Opportunity__c');//督办事项
        for (Sobject obj : objIdList) {
            allIdList.add((Id)obj.get('Id'));
        }
        ShareCommonTriggerHandler.shareRecordToParentUtil('UserId','OpportunityTeamMember','OpportunityId', objectAPIMap, allIdList, 'Read');
    }

    /**
     * @description: 子对象新增后共享记录给父对象
     * @param  {userField:目标对象的用户查找字段(不可向上查找)}
     * @param  {objectAPI:目标对象API(父级触发器的对象API)}
     * @param  {conditionAPI:筛选条件的API(不可向上查找)}
     * @param  {objectAPIMap:{key:要共享记录的源对象API,value:子对象对应的查找字段API}}
     * @param  {allIdList:所有子对象的Id}
     * @param  {accessLevel:访问权限(可选择值:Read,Edit,All)}
     */
    @future
    public static void shareRecordToParentUtil(String userField,String objectAPI,String conditionAPI,Map<String,String> objectAPIMap,List<Id> allIdList,String accessLevel){
        if (allIdList.size()>0) {
            Map<String,List<String>> parentChildIdMap = new Map<String,List<String>>();//存放父对象的Id以及子对象的集合
            String objName = allIdList[0].getSObjectType().getDescribe().getName();
            String objShareName = '';//共享对象API
            List<sObject> insertShareList = new List<sObject>();//共享对象集合
            String fieldParent = objectAPIMap.get(objName);
            if (objName.endsWith('__c')) {
                objShareName = objName.substring(0,objName.length()-1)+'Share';
            }else {
                objShareName = objName+'Share';
            }
            String soql = 'SELECT Id,'+fieldParent+' FROM '+objName+' WHERE Id IN: allIdList';
            List<Sobject> findParentList = Database.query(soql);
            // List<String> splitField = fieldParent.split('\\.');
            // Integer sizeSplit = splitField.size();
            for (SObject obj : findParentList) {
                // switch on sizeSplit{
                //     when 1 {
                //         List<String> tempChildList = new List<String>();
                //         if (getRecord(obj,fieldParent)!=null) {
                //             if (parentChildIdMap.containsKey((String)obj.get(splitField[0]))) {
                //                 tempChildList = parentChildIdMap.get((String)obj.get(splitField[0]));
                //             }
                //             tempChildList.add((String)obj.get('Id'));
                //             parentChildIdMap.put((String)obj.get(splitField[0]), tempChildList);
                //         }
                //     }
                //     when 2 {
                //         List<String> tempChildList = new List<String>();
                //         if (getRecord(obj,fieldParent)!=null) {
                //             if (parentChildIdMap.containsKey((String)obj.getSobject(splitField[0]).get(splitField[1]))) {
                //                 tempChildList = parentChildIdMap.get((String)obj.getSobject(splitField[0]).get(splitField[1]));
                //             }
                //             tempChildList.add((String)obj.get('Id'));
                //             parentChildIdMap.put((String)obj.getSobject(splitField[0]).get(splitField[1]), tempChildList);
                //         }
                //     }
                //     when 3 {
                //         List<String> tempChildList = new List<String>();
                //         if (getRecord(obj,fieldParent)!=null) {
                //             if (parentChildIdMap.containsKey((String)obj.getSobject(splitField[0]).getSobject(splitField[1]).get(splitField[2]))) {
                //                 tempChildList = parentChildIdMap.get((String)obj.getSobject(splitField[0]).getSobject(splitField[1]).get(splitField[2]));
                //             }
                //             tempChildList.add((String)obj.get('Id'));
                //             parentChildIdMap.put((String)obj.getSobject(splitField[0]).getSobject(splitField[1]).get(splitField[2]), tempChildList);
                //         }
                //     }
                //     when 4 {
                //         List<String> tempChildList = new List<String>();
                //         if (getRecord(obj,fieldParent)!=null) {
                //             if (parentChildIdMap.containsKey((String)obj.getSobject(splitField[0]).getSobject(splitField[1]).getSobject(splitField[2]).get(splitField[3]))) {
                //                 tempChildList = parentChildIdMap.get((String)obj.getSobject(splitField[0]).getSobject(splitField[1]).getSobject(splitField[2]).get(splitField[3]));
                //             }
                //             tempChildList.add((String)obj.get('Id'));
                //             parentChildIdMap.put((String)obj.getSobject(splitField[0]).getSobject(splitField[1]).getSobject(splitField[2]).get(splitField[3]), tempChildList);
                //         }
                //     }
                // }
                List<String> tempChildList = new List<String>();
                if (getRecord(obj,fieldParent)!=null) {
                    if (parentChildIdMap.containsKey((String)getRecord(obj,fieldParent))) {
                        tempChildList = parentChildIdMap.get((String)getRecord(obj,fieldParent));
                    }
                    tempChildList.add((String)obj.get('Id'));
                    parentChildIdMap.put((String)getRecord(obj,fieldParent), tempChildList);
                }
            }
            Set<String> parentIdList = parentChildIdMap.keySet();
            String soqlShareUser = 'SELECT Id,'+userField+','+conditionAPI+' FROM '+objectAPI+' WHERE '+conditionAPI+' IN: parentIdList';
            List<Sobject> findUserList = Database.query(soqlShareUser);//找到的存放的user的对象
            Map<String,List<String>> userConditionMap = new Map<String,List<String>>();//Key:查找条件的Id,Value:用户Id
            if (findUserList.size()>0) {
                for (SObject obj : findUserList) {
                    List<String> tempIdList = new List<String>();
                    if (userConditionMap.containsKey((String)obj.get(conditionAPI))) {
                        tempIdList = userConditionMap.get((String)obj.get(conditionAPI));
                    }
                    tempIdList.add((String)obj.get(userField));
                    userConditionMap.put((String)obj.get(conditionAPI),tempIdList);
                }
                //使用查找条件的Id
                for (Id conditionId : userConditionMap.keySet()) {
                    if (parentChildIdMap.containsKey(conditionId)) {
                        //子对象的集合
                        for (Id childId : parentChildIdMap.get(conditionId)) {
                            if (userConditionMap.containsKey(conditionId)) {
                                //用户Id
                                for (Id userId : userConditionMap.get(conditionId)) {
                                    Schema.SObjectType stdShareType = Schema.getGlobalDescribe().get(objShareName);
                                    SObject stdShare = stdShareType.newSObject();
                                    stdShare.put('ParentId', childId); 
                                    stdShare.put('UserOrGroupId', userId); 
                                    stdShare.put('AccessLevel', accessLevel); 
                                    stdShare.put('RowCause', 'Manual');
                                    insertShareList.add(stdShare);
                                }
                            }
                        }
                    }
                }
                Database.insert(insertShareList,false);
            }
        }
    }

    /**
     * @description: 批量共享子对象给指定用户或用户组(工具类一直在启用着，不好添加)
     * @param {userOrGroupId:用户或者用户组的Id(可选触发器对象的查找字段,不可向上查找)}
     * @param {objectAPI:{key:要共享记录的源对象API,value:子对象对应的查找字段API(向上查找四级)}}
     * @param {targetId:用于筛选源对象记录的目标最高父级对象Id}
     * @param {accessLevel:访问权限(可选择值:Read,Edit,All)}
     * 限制：1、一个父对象下面选中的共享的子记录数，最好不要大于200
     * 2、子对象对应的查找字段API不要向上查找超过四级
     * 3、请确保用户至少有对象的查看权限
     */
    @future
    public static void shareRecordUtil(Id userOrGroupId,Map<String,String> objectAPI,List<Id> targetId,String accessLevel){
        if (userOrGroupId!=null) {
            //动态soql拼接
            List<String> soqlList = new List<String>(); //存动态soql的集合
            List<Sobject> allObjectList = new List<Sobject>();//存所有object的集合
            List<Id> allIdList = new List<Id>();//存所有Id的集合
            List<Id> allSureIdList = new List<Id>();//存符合筛选条件的Id的集合
            Map<String,String> shareObjectMap = new Map<String,String>();//key:对象的api,value:对象的共享API
            Map<String,List<Sobject>> insertShareMap = new Map<String,List<Sobject>>();//key:对象API,value:共享对象的集合
            for (String obj : objectAPI.keySet()) {
                String temp = 'SELECT Id FROM '+obj+' WHERE '+objectAPI.get(obj)+' IN: targetId';
                soqlList.add(temp);
                if (obj.endsWith('__c')) {
                    shareObjectMap.put(obj, obj.substring(0,obj.length()-1)+'Share');
                }else {
                    shareObjectMap.put(obj, obj+'Share');
                }
                
            }
            for (String soql : soqlList) {
                allObjectList.addAll(Database.query(soql));
            }
            for (Sobject obj : allObjectList) {
                String temp = (String)obj.get('Id');
                allIdList.add(temp);
            }
            if (allIdList.size()<200) {
                if (accessLevel=='Read') {
                    for (UserRecordAccess access : [SELECT RecordId,HasReadAccess FROM UserRecordAccess WHERE UserId=:userOrGroupId AND RecordId IN :allIdList limit 200]) {
                        if (access.HasReadAccess==false) {
                            allSureIdList.add(access.RecordId);
                        }
                        
                    }
                }else {
                    if (accessLevel=='Edit') {
                        for (UserRecordAccess access : [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:userOrGroupId AND RecordId IN :allIdList limit 200]) {
                            if (access.HasEditAccess==false) {
                                allSureIdList.add(access.RecordId);
                            }    
                        }
                    }else {
                        for (UserRecordAccess access : [SELECT RecordId,HasAllAccess FROM UserRecordAccess WHERE UserId=:userOrGroupId AND RecordId IN :allIdList limit 200]) {
                            if (access.HasAllAccess==false) {
                                allSureIdList.add(access.RecordId);
                            }    
                        }
                    }
                }
            }else {
                allSureIdList.addAll(allIdList);//超过200条就跳过优化
            }
            for (Id objId : allSureIdList) {
                String objName = shareObjectMap.get(objId.getSObjectType().getDescribe().getName());
                Schema.SObjectType stdShareType = Schema.getGlobalDescribe().get(objName);
                SObject stdShare = stdShareType.newSObject();
                stdShare.put('ParentId', objId); 
                stdShare.put('UserOrGroupId', userOrGroupId); 
                stdShare.put('AccessLevel', accessLevel); 
                stdShare.put('RowCause', 'Manual');
                List<sObject> findSobjectList = new List<sObject>();
                if (insertShareMap.containsKey(objName)) {
                    findSobjectList = insertShareMap.get(objName);
                }
                findSobjectList.add(stdShare);
                insertShareMap.put(objName, findSobjectList);
            }
            for ( List<sObject> obj : insertShareMap.values()) {
                Database.insert(obj,false);
            }
        }   
    }

    /**
     * @description: 批量删除指定用户或用户组共享的子对象
     * @param {userOrGroupId:用户或者用户组的Id(可选触发器对象的查找字段,不可向上查找)}
     * @param {objectAPI:{key:要共享记录的源对象API,value:子对象对应的查找字段API(向上查找四级)}}
     * @param {targetId:用于筛选源对象记录的目标最高父级对象Id（启用了多个异步方法，集合实际只有一个记录）}
     * 限制：
     * 1、子对象对应的查找字段API不要向上查找超过四级
     */
    @future
    public static void deleteShareRecordUtil(Id userOrGroupId,Map<String,String> objectAPI,List<Id> targetId){
        if (userOrGroupId!=null) {
            List<String> soqlList = new List<String>(); //存动态soql的集合
            Map<String,String> shareObjectMap = new Map<String,String>();//key:对象的api,value:对象共享API的soql
            Map<String,List<String>> shareListObjectMap = new Map<String,List<String>>();//key:对象的api,value:对象的id集合
            Map<String,List<Sobject>> deleteShareMap = new Map<String,List<Sobject>>();//key:对象API,value:共享对象的集合
            for (String obj : objectAPI.keySet()) {
                String temp = 'SELECT Id FROM '+obj+' WHERE '+objectAPI.get(obj)+' IN: targetId';
                soqlList.add(temp);
                if (obj.endsWith('__c')) {
                    shareObjectMap.put(obj, 'SELECT Id FROM '+obj.substring(0,obj.length()-1)+'Share'+' WHERE ParentId IN: shareTargetId AND RowCause = \'Manual\' AND UserOrGroupId = \''+userOrGroupId+'\'');
                }else {
                    shareObjectMap.put(obj, 'SELECT Id FROM '+obj+'Share'+' WHERE ParentId IN: shareTargetId AND RowCause = \'Manual\' AND UserOrGroupId = \''+userOrGroupId+'\'');
                }
            }
            List<Sobject> allObjectList = new List<Sobject>();//存所有object的集合
            for (String soql : soqlList) {
                allObjectList.addAll(Database.query(soql));
            }
            for (Sobject obj : allObjectList) {
                String temp = (String)obj.get('Id');
                String shareObjName = obj.getSObjectType().getDescribe().getName();//对象api
                List<String> shareIdTempList = new List<String>();
                if (shareListObjectMap.containsKey(shareObjName)) {
                    shareIdTempList = shareListObjectMap.get(shareObjName);
                }
                shareIdTempList.add(temp);
                shareListObjectMap.put(shareObjName, shareIdTempList);
                //存一个 对象名：查找的记录Id的map
            }
            for (String objName : shareListObjectMap.keySet()) {
                List<String> shareTargetId = shareListObjectMap.get(objName);
                deleteShareMap.put(objName, Database.query(shareObjectMap.get(objName)));//查找到筛选后的共享对象记录
            }
            for (List<Sobject> obj : deleteShareMap.values()) {
                Database.Delete(obj, false);
            }
        }
    }

    public static Object getRecord(SObject record, String field)
    {
        if (record == null) return null;
        if (!field.contains('.')) return record.get(field);
        return getRecord(
            record.getSObject(field.substringBefore('.')),
            field.substringAfter('.')
        );
    }
}