/*
 * @Author: Conner
 * @Date: 2021-10-16 10:52:49
 * @LastEditors: Hogan 增加草稿10状态的更新
 * @LastEditTime: 2022-07-25 11:45:00
 * @Descripttion: 获取审批记录
 * Schedule_OAGetApprovalRecords schedule = new Schedule_OAGetApprovalRecords();
 * String sch = '0 0 * * * ?';
 * system.schedule('每小时获取审批记录', sch, schedule);
 */
global without sharing class Controller_OAGetApprovalRecords {
    @AuraEnabled(cacheable=false)
    global static String callGetApprovalRecords(String recordId){
        String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        System.debug('recTypeId==='+recTypeId);
        List<String> findProIdList = new List<String>();//存储所有状态为审批中的流程Id
        Map<String,Integrated_Middle_Table__c> docMap = new Map<String,Integrated_Middle_Table__c>(); //根据流程Id，找到对象名字
        //查找集成中间表的记录，查找有多少审批状态是20或10的
        List<Integrated_Middle_Table__c> middleTableList = new List<Integrated_Middle_Table__c>([SELECT Id,Is_Upload_File__c,Require_Type__c,Contract_Business_Id__c,Approval_Parent_Id__c,Scheme_Type__c,Process_Id__c,Approvalstatus__c,Is_International__c,Object_API__c,Mapping_Object_Id__c FROM Integrated_Middle_Table__c WHERE (Approvalstatus__c = '20' OR Approvalstatus__c = '10' OR Approvalstatus__c = '11') AND RecordTypeId =: recTypeId AND Mapping_Object_Id__c =: recordId]);
        for (Integrated_Middle_Table__c form : middleTableList) {
            if (form.Process_Id__c!=null) {
                findProIdList.add(form.Process_Id__c);
                docMap.put(form.Process_Id__c,form);
            }
        }
        //查找接口参数表
        // InterfaceParam__c param = new InterfaceParam__c();
        // param = [SELECT Id,Name,SyncDate__c,Approval_Record_Datetime__c FROM InterfaceParam__c WHERE Name = 'OAApprovalRecords'];
        Interface_Log__c logInfo = new Interface_Log__c();
        RequestBody reqBody = new RequestBody();  
        Boolean isAtt = false;
        External_System_Param__c ext = External_System_Param__c.getValues('oaGetApprovalRecords');
        try {
            String nowTime = String.valueOf('2021-01-01 00:00:00');
            // if (param != null && param.Approval_Record_Datetime__c != null) {
            //     reqBody.startDate = String.valueOf(param.Approval_Record_Datetime__c); 
            // }else {
                reqBody.startDate = String.valueOf(nowTime); 
            // }
            String findProId = '';
            for (String temp : findProIdList) {
                findProId += (temp+',');
            }
            //by hogan
            if(findProIdList.size()>0){
                findProId = findProId.substring(0,findProId.length()-1);
            }
            reqBody.fdIdStr = findProId;
            
            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
            System.debug('>>>>>>>>>>>>response'+response);
            if(response.substring(0,5) != 'Error'){
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                if (resBody.code == 200) {
                    Map<String,Data> nodeMap = new Map<String,Data>();//如果是结束节点则存储结束节点，如果是驳回状态则存储驳回状态。
                    Map<String,Data> nodeInMap = new Map<String,Data>();//存一个审批中的节点 conner上线后新增
                    Map<String,Data> childGetMap = new Map<String,Data>();//父流程创建了子流程
                    List<Id> sealContractParentIdList = new List<Id>();//存印章审批子表单的营销合同补充协议对象Id
                    List<Id> sealResourceParentIdList = new List<Id>();//存印章审批子表单的资源开发协议对象Id
                    List<Id> sealStrategicParentIdList = new List<Id>();//存印章审批子表单的战略合作协议对象Id by hogan
                    if (resBody?.data != null) {
                        for (Data returnData : resBody.data) {
                            if (returnData.docStatus=='20'&&!nodeMap.containsKey(returnData.processId) && docMap.get(returnData.processId).Object_API__c != 'Contractmanagement__c') {
                                nodeInMap.put(returnData.processId, returnData);//审批中状态随便存一个,会签除外
                            }
                            if ((returnData.docStatus=='11'||returnData.docStatus=='10')&&!nodeMap.containsKey(returnData.processId) && docMap.get(returnData.processId).Object_API__c != 'Contractmanagement__c') {
                                nodeMap.put(returnData.processId, returnData);//驳回状态或草稿状态则随便存一个，会签除外
                            }
                            if (returnData.nodeName=='结束节点') {
                                nodeMap.put(returnData.processId, returnData);//如果是结束节点则保存
                            }
                            //不是合同商务
                            if (returnData?.childId != null && String.isNotBlank(returnData.childId) && docMap.get(returnData.processId).Object_API__c != 'Contractmanagement__c') {
                                childGetMap.put(returnData.processId, returnData);
                                //营销合同补充协议 国际印章审批除外
                                if (docMap.get(returnData.processId).Object_API__c=='ContractSupplement__c'&&docMap.get(returnData.processId).Is_International__c==false) {
                                    sealContractParentIdList.add(docMap.get(returnData.processId).Mapping_Object_Id__c); //营销合同补充协议的Id
                                }
                                //资源开发协议、资源审批单
                                if (docMap.get(returnData.processId).Object_API__c=='ResourceApproval__c') {
                                    sealResourceParentIdList.add(docMap.get(returnData.processId).Mapping_Object_Id__c);
                                }
                                //战略合作协议/合同审批单 by hogan
                                if (docMap.get(returnData.processId).Object_API__c=='StrategicCooperationContract__c') {
                                    sealStrategicParentIdList.add(docMap.get(returnData.processId).Mapping_Object_Id__c); //战略合作协议的Id
                                }
                            }
                        }
                    }
                    // System.debug('批量iD'+sealContractParentIdList);
                    //soql 营销合同补充协议
                    // List<ContractSupplement__c> findContractList = new List<ContractSupplement__c>([SELECT Process_Id__c,(SELECT Id FROM Marketing_Contract_Seal_App__r) From ContractSupplement__c WHERE Id IN: sealContractParentIdList]);
                    // // System.debug('是否找到合同商务'+findContractList);
                    // Map<String,String> contractAndSealMap = new Map<String,String>();//存营销合同补充协议的流程Id以及印章审批的Id
                    // for (ContractSupplement__c tempContract : findContractList) {
                    //     contractAndSealMap.put(tempContract.Process_Id__c, tempContract.Marketing_Contract_Seal_App__r[0].Id);
                    // }
                    // //soql 资源开发协议、资源审批单
                    // List<ResourceApproval__c> findResourceList = new List<ResourceApproval__c>([SELECT Process_Id__c,(SELECT Id FROM Resource_Seal__r) From ResourceApproval__c WHERE Id IN: sealResourceParentIdList]);
                    // Map<String,String> resourceAndSealMap = new Map<String,String>();//存资源开发协议、资源审批单的流程Id以及印章审批的Id
                    // for (ResourceApproval__c tempRes : findResourceList) {
                    //     resourceAndSealMap.put(tempRes.Process_Id__c, tempRes.Resource_Seal__r[0].Id);
                    // }
                    //soql 战略合作协议/合同审批单 by hogan
                    List<StrategicCooperationContract__c> findStrategicList = new List<StrategicCooperationContract__c>([SELECT Process_Id__c From StrategicCooperationContract__c WHERE Id IN: sealStrategicParentIdList]);
                    List<ContractSupplement__c> findContractList = new List<ContractSupplement__c>([SELECT Process_Id__c From ContractSupplement__c WHERE Id IN: sealContractParentIdList]);
                    List<ResourceApproval__c> findResourceList = new List<ResourceApproval__c>([SELECT Process_Id__c From ResourceApproval__c WHERE Id IN: sealResourceParentIdList]);
                        
                    //处理更新中间表的状态和时间节点
                    //同时准备批量更新Org的主表单
                    //-------------更新Process_Id__c-----------------
                    List<Integrated_Middle_Table__c> updateMiddleTableList = new List<Integrated_Middle_Table__c>();
                    //conner 上线后新增 存储上传附件的中间表
                    List<Integrated_Middle_Table__c> updateMiddleTableFileList = new List<Integrated_Middle_Table__c>();
                    //-------------更新-----------------
                    Map<String,List<sObject>> objectUpdateMap = new Map<String,List<sObject>>();//准备更新中间表对应的主表单 key:对象名
                    //-------------更新-----------------
                    Map<Id,Opportunity> updateOppMap = new Map<Id,Opportunity>();//将项目方案的时间更新回商机 key:商机的Id
                    //-------------更新-----------------
                    Map<Id,Contractmanagement__c> updateContractMap = new Map<Id,Contractmanagement__c>();//将会签审批的时间更新回合同商务 key:合同商务的Id
                    //-------------更新-----------------
                    Map<Id,Resource_Development__c> updateResDevMap = new Map<Id,Resource_Development__c>();//将资源项目方案的时间更新回资源开发 key:资源开发的Id
                    if (nodeInMap.size()>0) {
                        for (String updateData : nodeInMap.keySet()) {
                            if (docMap.get(updateData).Is_Upload_File__c != nodeInMap.get(updateData).crmFileUploadType) {
                                Integrated_Middle_Table__c upForm = new Integrated_Middle_Table__c();
                                upForm.Process_Id__c = nodeInMap.get(updateData).processId;//流程Id有索引
                                upForm.Approvalstatus__c = nodeInMap.get(updateData).docStatus;
                                upForm.Is_Upload_File__c = nodeInMap.get(updateData).crmFileUploadType;//conner 上线后新增
                                updateMiddleTableFileList.add(upForm);//更新了中间表
                            }
                        }
                    }
                    if (nodeMap.size()>0) {
                        
                        for (Data updateData : nodeMap.values()) {
                            Integrated_Middle_Table__c upForm = new Integrated_Middle_Table__c();
                            upForm.Process_Id__c = updateData.processId;//流程Id有索引
                            upForm.Approvalstatus__c = updateData.docStatus;
                            if (upForm.Approvalstatus__c=='11'||upForm.Approvalstatus__c=='10') {//Hogan 新增（之前手动刷新没有同步“上传附件”字段）
                                upForm.Is_Upload_File__c = 'N';
                            }
                            if (updateData.nodeName=='结束节点') {
                                upForm.Final_Approval_Date__c = Datetime.valueOf(updateData.createTime).date();
                                upForm.End_Set_Time__c = Datetime.valueOf(updateData.createTime);
                            }
                            updateMiddleTableList.add(upForm);//更新了中间表
                        }
                        
                        //根据流程Id找到中间表对应的对象
                        for (String proId : nodeMap.keySet()) {
                            if (docMap.containsKey(proId)) {
                                List<sObject> findSobjectList = new List<sObject>();
                                if (objectUpdateMap.containsKey(docMap.get(proId).Object_API__c)) {
                                    findSobjectList = objectUpdateMap.get(docMap.get(proId).Object_API__c);//使用已存在的待更新对象集合
                                }
                                String objectAPI = docMap.get(proId).Object_API__c;
                                Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectAPI);
                                // 创建对象类型的引用
                                Sobject genericObject = convertType.newSObject();
                                genericObject.put('Id', docMap.get(proId).Mapping_Object_Id__c);
                                genericObject.put('Approvalstatus__c', nodeMap.get(proId).docStatus);
                                if((String)genericObject.get('Is_Upload_File__c')!=null||(String)genericObject.get('Is_Upload_File__c')==''){
                                    genericObject.put('Is_Upload_File__c', nodeMap.get(proId).crmFileUploadType);//Hogan 新增（之前手动刷新没有同步“上传附件”字段）
                                }
                                String getStatus = nodeMap.get(proId).docStatus;
                                if (getStatus == '30' && docMap.get(proId).Scheme_Type__c == '投标项目方案路堪'&& docMap.get(proId).Object_API__c == 'Project_Scheme_Application_Form__c') {
                                    Opportunity oppUpdate = new Opportunity();
                                    if (updateOppMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                        oppUpdate = updateOppMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                    }
                                    oppUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                    oppUpdate.RoadCompleteTime__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//投标项目方案路堪完成日期
                                    updateOppMap.put(docMap.get(proId).Approval_Parent_Id__c, oppUpdate);
                                    
                                }
                                if (getStatus == '30' && docMap.get(proId).Scheme_Type__c == '微观选址'&& docMap.get(proId).Object_API__c == 'Project_Scheme_Application_Form__c') {
                                    // Contractmanagement__c contractUpdate = new Contractmanagement__c();
                                    // if (updateContractMap.containsKey(docMap.get(proId).Contract_Business_Id__c)) {
                                    //     contractUpdate = updateContractMap.get(docMap.get(proId).Contract_Business_Id__c);
                                    // }
                                    // contractUpdate.Id = docMap.get(proId).Contract_Business_Id__c;
                                    // contractUpdate.CompleteTime__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//微观选址及风资源完成日期
                                    // updateContractMap.put(docMap.get(proId).Contract_Business_Id__c, contractUpdate);
                                    Opportunity oppUpdate = new Opportunity();
                                    if (updateOppMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                        oppUpdate = updateOppMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                    }
                                    oppUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                    oppUpdate.CompletionDate__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//微观选址及风资源完成日期
                                    updateOppMap.put(docMap.get(proId).Approval_Parent_Id__c, oppUpdate);
                                }
                                if (getStatus == '30' && docMap.get(proId).Scheme_Type__c == '安全性复核'&& docMap.get(proId).Object_API__c == 'Project_Scheme_Application_Form__c') {
                                    Opportunity oppUpdate = new Opportunity();
                                    if (updateOppMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                        oppUpdate = updateOppMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                    }
                                    oppUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                    oppUpdate.CompletionDate2__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//机组安全性复核完成日期
                                    updateOppMap.put(docMap.get(proId).Approval_Parent_Id__c, oppUpdate);
                                }
                                //更新合同商务的会签审批结束日期
                                if (getStatus == '30' && docMap.get(proId).Object_API__c == 'Contractmanagement__c') {
                                    Contractmanagement__c contractUpdate = new Contractmanagement__c();
                                    if (updateContractMap.containsKey(docMap.get(proId).Mapping_Object_Id__c)) {
                                        contractUpdate = updateContractMap.get(docMap.get(proId).Mapping_Object_Id__c);
                                    }
                                    contractUpdate.Id = docMap.get(proId).Mapping_Object_Id__c;
                                    contractUpdate.EndDate__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//会签审批完成日期
                                    updateContractMap.put(docMap.get(proId).Mapping_Object_Id__c, contractUpdate);
                                }
                                //更新资源开发的完成设备道路踏勘申请
                                if (getStatus == '30' && docMap.get(proId).Object_API__c == 'Resource_Project_Scheme_Application__c' && docMap.get(proId).Require_Type__c == '设备运输道路踏勘') {
                                    Resource_Development__c resDevUpdate = new Resource_Development__c();
                                    if (updateResDevMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                        resDevUpdate = updateResDevMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                    }
                                    resDevUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                    resDevUpdate.EquipmentRoadExploration__c = true;//完成设备运输道路踏勘
                                    updateResDevMap.put(docMap.get(proId).Approval_Parent_Id__c, resDevUpdate);
                                }
                                //更新资源开发的完成立项
                                if (getStatus == '30' && docMap.get(proId).Object_API__c == 'ResourceProjectApplication__c') {
                                    Resource_Development__c resDevUpdate = new Resource_Development__c();
                                    if (updateResDevMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                        resDevUpdate = updateResDevMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                    }
                                    resDevUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                    resDevUpdate.MakeAProject__c = true;//完成立项
                                    updateResDevMap.put(docMap.get(proId).Approval_Parent_Id__c, resDevUpdate);
                                }
                                findSobjectList.add(genericObject);
                                objectUpdateMap.put(docMap.get(proId).Object_API__c, findSobjectList);//对象api 对应要更新的对象
                            }
                        }
                    }
                    //处理父流程开始创建子流程的问题
                    //-------------更新-----------------
                    List<Seal_Approval__c> updateSealList = new List<Seal_Approval__c>();//更新印章审批增加流程Id
                    List<StrategicCooperationContract__c> updateStrategicList = new List<StrategicCooperationContract__c>();//更新战略合作协议增加印章盖章URL by hogan
                    List<ContractSupplement__c> updateContractList = new List<ContractSupplement__c>();
                    List<ResourceApproval__c> updateResourceList = new List<ResourceApproval__c>();
                    // System.debug('获取到的'+childGetMap);
                    if (childGetMap.size()>0) {
                        // for (String temp : contractAndSealMap.keySet()) {
                        //     Seal_Approval__c upSeal = new Seal_Approval__c();
                        //     upSeal.Id = contractAndSealMap.get(temp);
                        //     upSeal.Process_Id__c = childGetMap.get(temp).childId;//子流程Id
                        //     updateSealList.add(upSeal);
                        // }
                        // for (String temp : resourceAndSealMap.keySet()) {
                        //     Seal_Approval__c upSeal = new Seal_Approval__c();
                        //     upSeal.Id = resourceAndSealMap.get(temp);
                        //     upSeal.Process_Id__c = childGetMap.get(temp).childId;//子流程Id
                        //     updateSealList.add(upSeal);
                        // }
                        // by hogan
                        for (StrategicCooperationContract__c stra : findStrategicList){
                            String childId = childGetMap.get(stra.Process_Id__c).childId; //by hogan 子流程Id
                            // String userId = UserInfo.getUserId();
                            // User currUser = [SELECT Id,Job_Number__c FROM User WHERE Id =: userId];
                            // String jobNumber = String.isBlank(currUser.Job_Number__c) ? null : currUser.Job_Number__c;
                            // stra.Seal_Id__c = 'http://ekptest.mywind.com.cn/km/review/km_review_main/kmReviewMain.do?method=view&fdId='+childId+'&loginName={!$User.Job_Number__c}&identification=CRM';
                            stra.Seal_Id__c = childId;
                            updateStrategicList.add(stra);
                        }
                        for (ContractSupplement__c stra : findContractList){
                            stra.Seal_Id__c = childGetMap.get(stra.Process_Id__c).childId;
                            updateContractList.add(stra);
                        }
                        for (ResourceApproval__c stra : findResourceList){
                            stra.Seal_Id__c = childGetMap.get(stra.Process_Id__c).childId;
                            updateResourceList.add(stra);
                        }
                    }
                    
                    for (List<sObject> obj : objectUpdateMap.values()) {
                        update obj;//更新主对象
                    }
                    // system.debug('打印要更新的子对象'+updateSealList);
                    update updateSealList;//更新子对象

                    update updateOppMap.values();//更新商机

                    update updateContractMap.values();//更新合同商务

                    update updateResDevMap.values();//更新资源开发

                    update updateStrategicList;//更新战略合作协议/合同审批单 by hogan
                    update updateContractList;
                    update updateResourceList;
                    //更新获取审批记录的时间
                    // InterfaceParam__c newParam = new InterfaceParam__c();
                    // newParam.Id = param.Id;
                    // newParam.Approval_Record_Datetime__c = Datetime.valueOf(nowTime);
                    // update newParam;

                    upsert updateMiddleTableFileList Process_Id__c;//更新中间表上传附件标识
                    upsert updateMiddleTableList Process_Id__c;//更新中间表
                    
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAGetApprovalRecords';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    if (response.length()>130000) {
                        logInfo.RespondBody__c = '见附件';
                        isAtt = true;
                    }else {
                        logInfo.RespondBody__c = response;
                    }

                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = ''; 

                    insert logInfo ; 
                }else{
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAGetApprovalRecords';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';

                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
                }
                //insert logInfo ; 
                if (isAtt) {
                    Attachment insertAtt = new Attachment();
                    insertAtt.ParentId = logInfo.Id;
                    insertAtt.Body = Blob.valueOf(Json.serialize(resBody));
                    insertAtt.Name = 'ResponseBody.txt';
                    insertAtt.ContentType = 'text/plain';
                    insert insertAtt;
                }
                return 'Success';
            }else {
                return response;
            }
            
        }catch(Exception e){
            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_OAGetApprovalRecords';
            logInfo.RequestBody__c = JSON.serialize(reqBody);
            logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
        }
    }
    /**
     * @description: 删除昨天的集成中间表 
     * String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
     * List<Integrated_Middle_Table__c> middleTableList = new List<Integrated_Middle_Table__c>([SELECT Id FROM Integrated_Middle_Table__c WHERE CreatedDate < TODAY AND RecordTypeId =: recTypeId]);
     * delete  middleTableList;
     * @param  {*}
     * @return {*}
     */    
    @future(callout=true)
    global static Void getApprovalRecords(){
        String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
        System.debug('recTypeId==='+recTypeId);
        List<String> findProIdList = new List<String>();//存储所有状态为审批中的流程Id
        Map<String,Integrated_Middle_Table__c> docMap = new Map<String,Integrated_Middle_Table__c>(); //根据流程Id，找到对象名字
        //查找集成中间表的记录，查找有多少审批状态是20或10的 conner 上线后新增
        List<Integrated_Middle_Table__c> middleTableList = new List<Integrated_Middle_Table__c>([SELECT Id,Is_Upload_File__c,Require_Type__c,Contract_Business_Id__c,Approval_Parent_Id__c,Scheme_Type__c,Process_Id__c,Approvalstatus__c,Is_International__c,Object_API__c,Mapping_Object_Id__c FROM Integrated_Middle_Table__c WHERE (Approvalstatus__c = '20' OR Approvalstatus__c = '10' OR Approvalstatus__c = '11') AND RecordTypeId =: recTypeId]);
        // for (Integrated_Middle_Table__c form : middleTableList) {
        //     if (form.Process_Id__c!=null) {
        //         findProIdList.add(form.Process_Id__c);
        //         docMap.put(form.Process_Id__c,form);
        //     }
        // }
        String findProId = '';
        Integer j=100;
        for(Integer i=0; i<middleTableList.size(); i++){
            Integrated_Middle_Table__c form = middleTableList.get(i);
            if (form.Process_Id__c!=null) {
                docMap.put(form.Process_Id__c,form);
                if (j>0) {
                    findProId += (form.Process_Id__c+',');
                    j--;
                } else {
                    findProId = findProId.substring(0,findProId.length()-1);
                    findProIdList.add(findProId);
                    findProId='';
                    j=100;
                }
            }
        }
        if(middleTableList.size()<100 && findProId.length()>0){
            findProId = findProId.substring(0,findProId.length()-1);
            findProIdList.add(findProId);
        }
        //查找接口参数表
        InterfaceParam__c param = new InterfaceParam__c();
        param = [SELECT Id,Name,SyncDate__c,Approval_Record_Datetime__c FROM InterfaceParam__c WHERE Name = 'OAApprovalRecords'];
        
        RequestBody reqBody = new RequestBody();  
        Boolean isAtt = false;
        External_System_Param__c ext = External_System_Param__c.getValues('oaGetApprovalRecords');
        try {
            String nowTime = String.valueOf(Datetime.now());
            if (param != null && param.Approval_Record_Datetime__c != null) {
                reqBody.startDate = String.valueOf(param.Approval_Record_Datetime__c); 
            }else {
                reqBody.startDate = String.valueOf(nowTime); 
            }
            // String findProId = '';
            // for (String temp : findProIdList) {
            //     findProId += (temp+',');
            // }
            // reqBody.fdIdStr = findProId;
            // String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

            List<String> responseList = new List<String>();//存储每次调用结果
            for(Integer i=0;i<findProIdList.size();i++){
                reqBody.fdIdStr = findProIdList.get(i);
                String response = Utils.callOut2(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OAGetApprovalRecords',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
                responseList.add(response);
            }

            //处理更新中间表的状态和时间节点
            //同时准备批量更新Org的主表单
            //-------------更新Process_Id__c-----------------
            List<Integrated_Middle_Table__c> updateMiddleTableList = new List<Integrated_Middle_Table__c>();
            //conner 上线后新增 存储上传附件的中间表
            List<Integrated_Middle_Table__c> updateMiddleTableFileList = new List<Integrated_Middle_Table__c>();
            //-------------更新-----------------
            Map<String,List<sObject>> objectUpdateMap = new Map<String,List<sObject>>();//准备更新中间表对应的主表单 key:对象名
            //-------------更新-----------------
            Map<Id,Opportunity> updateOppMap = new Map<Id,Opportunity>();//将项目方案的时间更新回商机 key:商机的Id
            //-------------更新-----------------
            Map<Id,Contractmanagement__c> updateContractMap = new Map<Id,Contractmanagement__c>();//将会签审批的时间更新回合同商务 key:合同商务的Id
            //-------------更新-----------------
            Map<Id,Resource_Development__c> updateResDevMap = new Map<Id,Resource_Development__c>();//将资源项目方案的时间更新回资源开发 key:资源开发的Id
            //处理父流程开始创建子流程的问题
            //-------------更新-----------------
            List<Seal_Approval__c> updateSealList = new List<Seal_Approval__c>();//更新印章审批增加流程Id
            List<StrategicCooperationContract__c> updateStrategicList = new List<StrategicCooperationContract__c>();//更新战略合作协议增加印章盖章URL by hogan
            List<ContractSupplement__c> updateContractList = new List<ContractSupplement__c>();
            List<ResourceApproval__c> updateResourceList = new List<ResourceApproval__c>();

            for(String response : responseList){
                Interface_Log__c logInfo = new Interface_Log__c();
                if(response.substring(0,5) != 'Error'){
                    ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                    if (resBody.code == 200) {
                        Map<String,Data> nodeMap = new Map<String,Data>();//如果是结束节点则存储结束节点，如果是驳回状态则存储驳回状态。
                        Map<String,Data> nodeInMap = new Map<String,Data>();//存一个审批中的节点 conner上线后新增
                        Map<String,Data> childGetMap = new Map<String,Data>();//父流程创建了子流程
                        List<Id> sealContractParentIdList = new List<Id>();//存印章审批子表单的营销合同补充协议对象Id
                        List<Id> sealResourceParentIdList = new List<Id>();//存印章审批子表单的资源开发协议对象Id
                        List<Id> sealStrategicParentIdList = new List<Id>();//存印章审批子表单的战略合作协议对象Id by hogan
                        if (resBody?.data != null) {
                            for (Data returnData : resBody.data) {
                                if (returnData.docStatus=='20'&&!nodeMap.containsKey(returnData.processId) && docMap.get(returnData.processId).Object_API__c != 'Contractmanagement__c') {
                                    nodeInMap.put(returnData.processId, returnData);//审批中状态随便存一个,会签除外
                                }
                                //驳回或草稿的时候新增修改附件上传标识
                                if ((returnData.docStatus=='11'||returnData.docStatus=='10')&&!nodeMap.containsKey(returnData.processId) && docMap.get(returnData.processId).Object_API__c != 'Contractmanagement__c') {
                                    nodeMap.put(returnData.processId, returnData);//驳回状态则随便存一个，会签除外
                                }
                                if (returnData.nodeName=='结束节点') {
                                    nodeMap.put(returnData.processId, returnData);//如果是结束节点则保存
                                }
                                //不是合同商务
                                if (returnData?.childId != null && String.isNotBlank(returnData.childId) && docMap.get(returnData.processId).Object_API__c != 'Contractmanagement__c') {
                                    childGetMap.put(returnData.processId, returnData);
                                    //营销合同补充协议 国际印章审批除外
                                    if (docMap.get(returnData.processId).Object_API__c=='ContractSupplement__c'&&docMap.get(returnData.processId).Is_International__c==false) {
                                        sealContractParentIdList.add(docMap.get(returnData.processId).Mapping_Object_Id__c); //营销合同补充协议的Id
                                    }
                                    //资源开发协议、资源审批单
                                    if (docMap.get(returnData.processId).Object_API__c=='ResourceApproval__c') {
                                        sealResourceParentIdList.add(docMap.get(returnData.processId).Mapping_Object_Id__c);
                                    }
                                    //战略合作协议/合同审批单 by hogan
                                    if (docMap.get(returnData.processId).Object_API__c=='StrategicCooperationContract__c') {
                                        sealStrategicParentIdList.add(docMap.get(returnData.processId).Mapping_Object_Id__c); //战略合作协议的Id
                                    }
                                }
                            }
                        }
                        // System.debug('批量iD'+sealContractParentIdList);
                        //soql 营销合同补充协议
                        // List<ContractSupplement__c> findContractList = new List<ContractSupplement__c>([SELECT Process_Id__c,(SELECT Id FROM Marketing_Contract_Seal_App__r) From ContractSupplement__c WHERE Id IN: sealContractParentIdList]);
                        // System.debug('????是否找到合同商务'+findContractList);
                        // Map<String,String> contractAndSealMap = new Map<String,String>();//存营销合同补充协议的流程Id以及印章审批的Id
                        // for (ContractSupplement__c tempContract : findContractList) {
                        //     if(tempContract.Marketing_Contract_Seal_App__r!=null && tempContract.Marketing_Contract_Seal_App__r.size() > 0){
                        //         System.debug('??????tempContract'+tempContract.Marketing_Contract_Seal_App__r[0]);
                        //         contractAndSealMap.put(tempContract.Process_Id__c, tempContract.Marketing_Contract_Seal_App__r[0].Id);
                        //     }
                        // }
                        // //soql 资源开发协议、资源审批单
                        // List<ResourceApproval__c> findResourceList = new List<ResourceApproval__c>([SELECT Process_Id__c,(SELECT Id FROM Resource_Seal__r) From ResourceApproval__c WHERE Id IN: sealResourceParentIdList]);
                        // Map<String,String> resourceAndSealMap = new Map<String,String>();//存资源开发协议、资源审批单的流程Id以及印章审批的Id
                        // for (ResourceApproval__c tempRes : findResourceList) {
                        //     resourceAndSealMap.put(tempRes.Process_Id__c, tempRes.Resource_Seal__r[0].Id);
                        // }
                        //soql 战略合作协议/合同审批单 by hogan
                        List<StrategicCooperationContract__c> findStrategicList = new List<StrategicCooperationContract__c>([SELECT Process_Id__c From StrategicCooperationContract__c WHERE Id IN: sealStrategicParentIdList]);
                        List<ContractSupplement__c> findContractList = new List<ContractSupplement__c>([SELECT Process_Id__c From ContractSupplement__c WHERE Id IN: sealContractParentIdList]);
                        List<ResourceApproval__c> findResourceList = new List<ResourceApproval__c>([SELECT Process_Id__c From ResourceApproval__c WHERE Id IN: sealResourceParentIdList]);
                        

                        if (nodeInMap.size()>0) {
                            for (String updateData : nodeInMap.keySet()) {
                                if (docMap.get(updateData).Is_Upload_File__c != nodeInMap.get(updateData).crmFileUploadType) {
                                    Integrated_Middle_Table__c upForm = new Integrated_Middle_Table__c();
                                    upForm.Process_Id__c = nodeInMap.get(updateData).processId;//流程Id有索引
                                    upForm.Approvalstatus__c = nodeInMap.get(updateData).docStatus;
                                    upForm.Is_Upload_File__c = nodeInMap.get(updateData).crmFileUploadType;//conner 上线后新增
                                    updateMiddleTableFileList.add(upForm);//更新了中间表
                                }
                            }
                        }
                        if (nodeMap.size()>0) {
                            
                            for (Data updateData : nodeMap.values()) {
                                Integrated_Middle_Table__c upForm = new Integrated_Middle_Table__c();
                                upForm.Process_Id__c = updateData.processId;//流程Id有索引
                                upForm.Approvalstatus__c = updateData.docStatus;
                                if (upForm.Approvalstatus__c=='11'||upForm.Approvalstatus__c=='10') {
                                    upForm.Is_Upload_File__c = updateData.crmFileUploadType;//conner 上线后新增
                                }
                                if (updateData.nodeName=='结束节点') {
                                    upForm.Final_Approval_Date__c = Datetime.valueOf(updateData.createTime).date();
                                    upForm.End_Set_Time__c = Datetime.valueOf(updateData.createTime);
                                }
                                updateMiddleTableList.add(upForm);//更新了中间表
                            }
                            
                            //根据流程Id找到中间表对应的对象
                            for (String proId : nodeMap.keySet()) {
                                if (docMap.containsKey(proId)) {
                                    List<sObject> findSobjectList = new List<sObject>();
                                    if (objectUpdateMap.containsKey(docMap.get(proId).Object_API__c)) {
                                        findSobjectList = objectUpdateMap.get(docMap.get(proId).Object_API__c);//使用已存在的待更新对象集合
                                    }
                                    String objectAPI = docMap.get(proId).Object_API__c;
                                    Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectAPI);
                                    // 创建对象类型的引用
                                    Sobject genericObject = convertType.newSObject();
                                    genericObject.put('Id', docMap.get(proId).Mapping_Object_Id__c);
                                    genericObject.put('Approvalstatus__c', nodeMap.get(proId).docStatus);
                                    String getStatus = nodeMap.get(proId).docStatus;
                                    if (getStatus == '30' && docMap.get(proId).Scheme_Type__c == '投标项目方案路堪'&& docMap.get(proId).Object_API__c == 'Project_Scheme_Application_Form__c') {
                                        Opportunity oppUpdate = new Opportunity();
                                        if (updateOppMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                            oppUpdate = updateOppMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                        }
                                        oppUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                        oppUpdate.RoadCompleteTime__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//投标项目方案路堪完成日期
                                        updateOppMap.put(docMap.get(proId).Approval_Parent_Id__c, oppUpdate);
                                        
                                    }
                                    if (getStatus == '30' && docMap.get(proId).Scheme_Type__c == '微观选址'&& docMap.get(proId).Object_API__c == 'Project_Scheme_Application_Form__c') {
                                        // Contractmanagement__c contractUpdate = new Contractmanagement__c();
                                        // if (updateContractMap.containsKey(docMap.get(proId).Contract_Business_Id__c)) {
                                        //     contractUpdate = updateContractMap.get(docMap.get(proId).Contract_Business_Id__c);
                                        // }
                                        // contractUpdate.Id = docMap.get(proId).Contract_Business_Id__c;
                                        // contractUpdate.CompleteTime__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//微观选址及风资源完成日期
                                        // updateContractMap.put(docMap.get(proId).Contract_Business_Id__c, contractUpdate);
                                        Opportunity oppUpdate = new Opportunity();
                                        if (updateOppMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                            oppUpdate = updateOppMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                        }
                                        oppUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                        oppUpdate.CompletionDate__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//微观选址及风资源完成日期
                                        updateOppMap.put(docMap.get(proId).Approval_Parent_Id__c, oppUpdate);
                                    }
                                    if (getStatus == '30' && docMap.get(proId).Scheme_Type__c == '安全性复核'&& docMap.get(proId).Object_API__c == 'Project_Scheme_Application_Form__c') {
                                        Opportunity oppUpdate = new Opportunity();
                                        if (updateOppMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                            oppUpdate = updateOppMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                        }
                                        oppUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                        oppUpdate.CompletionDate2__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//机组安全性复核完成日期
                                        updateOppMap.put(docMap.get(proId).Approval_Parent_Id__c, oppUpdate);
                                    }
                                    //更新合同商务的会签审批结束日期
                                    if (getStatus == '30' && docMap.get(proId).Object_API__c == 'Contractmanagement__c') {
                                        Contractmanagement__c contractUpdate = new Contractmanagement__c();
                                        if (updateContractMap.containsKey(docMap.get(proId).Mapping_Object_Id__c)) {
                                            contractUpdate = updateContractMap.get(docMap.get(proId).Mapping_Object_Id__c);
                                        }
                                        contractUpdate.Id = docMap.get(proId).Mapping_Object_Id__c;
                                        contractUpdate.EndDate__c = Datetime.valueOf(nodeMap.get(proId).createTime).date();//会签审批完成日期
                                        updateContractMap.put(docMap.get(proId).Mapping_Object_Id__c, contractUpdate);
                                    }
                                    //更新资源开发的完成设备道路踏勘申请
                                    if (getStatus == '30' && docMap.get(proId).Object_API__c == 'Resource_Project_Scheme_Application__c' && docMap.get(proId).Require_Type__c == '设备运输道路踏勘') {
                                        Resource_Development__c resDevUpdate = new Resource_Development__c();
                                        if (updateResDevMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                            resDevUpdate = updateResDevMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                        }
                                        resDevUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                        resDevUpdate.EquipmentRoadExploration__c = true;//完成设备运输道路踏勘
                                        updateResDevMap.put(docMap.get(proId).Approval_Parent_Id__c, resDevUpdate);
                                    }
                                    //更新资源开发的完成立项
                                    if (getStatus == '30' && docMap.get(proId).Object_API__c == 'ResourceProjectApplication__c') {
                                        Resource_Development__c resDevUpdate = new Resource_Development__c();
                                        if (updateResDevMap.containsKey(docMap.get(proId).Approval_Parent_Id__c)) {
                                            resDevUpdate = updateResDevMap.get(docMap.get(proId).Approval_Parent_Id__c);
                                        }
                                        resDevUpdate.Id = docMap.get(proId).Approval_Parent_Id__c;
                                        resDevUpdate.MakeAProject__c = true;//完成立项
                                        updateResDevMap.put(docMap.get(proId).Approval_Parent_Id__c, resDevUpdate);
                                    }
                                    findSobjectList.add(genericObject);
                                    objectUpdateMap.put(docMap.get(proId).Object_API__c, findSobjectList);//对象api 对应要更新的对象
                                }
                            }
                        }
                        // System.debug('获取到的'+childGetMap);
                        if (childGetMap.size()>0) {
                            // for (String temp : contractAndSealMap.keySet()) {
                            //     Seal_Approval__c upSeal = new Seal_Approval__c();
                            //     upSeal.Id = contractAndSealMap.get(temp);
                            //     upSeal.Process_Id__c = childGetMap.get(temp).childId;//子流程Id
                            //     updateSealList.add(upSeal);
                            // }
                            // for (String temp : resourceAndSealMap.keySet()) {
                            //     Seal_Approval__c upSeal = new Seal_Approval__c();
                            //     upSeal.Id = resourceAndSealMap.get(temp);
                            //     upSeal.Process_Id__c = childGetMap.get(temp).childId;//子流程Id
                            //     updateSealList.add(upSeal);
                            // }
                            // by hogan
                            for (StrategicCooperationContract__c stra : findStrategicList){
                                // stra.Seal_Id__c = 'http://ekptest.mywind.com.cn/km/review/km_review_main/kmReviewMain.do?method=view&fdId='+childGetMap.get(stra.Process_Id__c).childId+'&loginName={!$User.Job_Number__c}&identification=CRM';
                                stra.Seal_Id__c = childGetMap.get(stra.Process_Id__c).childId;
                                updateStrategicList.add(stra);
                            }
                            for (ContractSupplement__c stra : findContractList){
                                stra.Seal_Id__c = childGetMap.get(stra.Process_Id__c).childId;
                                updateContractList.add(stra);
                            }
                            for (ResourceApproval__c stra : findResourceList){
                                stra.Seal_Id__c = childGetMap.get(stra.Process_Id__c).childId;
                                updateResourceList.add(stra);
                            }
                        }
                        //更新获取审批记录的时间
                        InterfaceParam__c newParam = new InterfaceParam__c();
                        newParam.Id = param.Id;
                        newParam.Approval_Record_Datetime__c = Datetime.valueOf(nowTime);
                        update newParam;

                        logInfo.RequestURL__c = ext.Request_URL__c;
                        logInfo.ClassName__c = 'Controller_OAGetApprovalRecords';
                        logInfo.RequestBody__c = JSON.serialize(reqBody);
                        if (response.length()>130000) {
                            logInfo.RespondBody__c = '见附件';
                            isAtt = true;
                        }else {
                            logInfo.RespondBody__c = response;
                        }                  
                        logInfo.IsSuccess__c = true;
                        logInfo.ErrorMessage__c = '';         
                    }else{
                        logInfo.RequestURL__c = ext.Request_URL__c;
                        logInfo.ClassName__c = 'Controller_OAGetApprovalRecords';
                        logInfo.RequestBody__c = JSON.serialize(reqBody);
                        logInfo.RespondBody__c = response;
                        logInfo.IsSuccess__c = false;
                        logInfo.ErrorMessage__c = '';
                    }
                    insert logInfo ; 
                    if (isAtt) {
                        Attachment insertAtt = new Attachment();
                        insertAtt.ParentId = logInfo.Id;
                        insertAtt.Body = Blob.valueOf(Json.serialize(resBody));
                        insertAtt.Name = 'ResponseBody.txt';
                        insertAtt.ContentType = 'text/plain';
                        insert insertAtt;
                    }
                }
            }
            
            for (List<sObject> obj : objectUpdateMap.values()) {
                update obj;//更新主对象
            }
            // system.debug('打印要更新的子对象'+updateSealList);
            update updateSealList;//更新子对象

            update updateOppMap.values();//更新商机

            update updateContractMap.values();//更新合同商务

            update updateResDevMap.values();//更新资源开发

            update updateStrategicList;//更新战略合作协议/合同审批单 by hogan
            update updateContractList;
            update updateResourceList;

            upsert updateMiddleTableFileList Process_Id__c;//更新中间表上传附件标识
            upsert updateMiddleTableList Process_Id__c;//更新中间表
        }catch(Exception e){
            Interface_Log__c logInfo = new Interface_Log__c();
            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_OAGetApprovalRecords';
            logInfo.RequestBody__c = JSON.serialize(reqBody);
            logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
        }
    }
    
    public class RequestBody {
        public String startDate{get;set;}   //时间,示例值(2021-08-01 00:00:00)
        public String fdIdStr{get;set;}   //时间,示例值(2021-08-01 00:00:00)
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String processId{get;set;}  //流程Id
        // public String nodeId{get;set;}     //审批记录行Id
        // public String parentId{get;set;}   //父流程Id
        public String createTime{get;set;} //记录时间
        public String nodeName{get;set;}  //节点名称
        // public String handlerId{get;set;}   //操作者
        // public String actionInfo{get;set;} //操作
        // public String actionNote{get;set;}  //处理意见
        public String docStatus{get;set;}  //文档状态
        public String childId{get;set;}  //子节点Id 只有在OA父流程创建子流程节点的时候才有值
        public String crmFileUploadType{get;set;}  //附件上传节点，如果为N就是未上传
    }
}