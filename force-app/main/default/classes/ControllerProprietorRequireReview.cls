/*
 * @Author: Conner
 * @Date: 2021-09-09 14:34:17
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-10 15:37:57
 * @Descripttion: 业主需求评审单
 */

global without sharing class ControllerProprietorRequireReview {
    @AuraEnabled(cacheable=false)
    global static String authenticationUser(Id recordId,String objectName){
        String soql = 'SELECT Id,OwnerId FROM '+objectName+' Where Id =\''+recordId+'\'';
        Sobject findOwnerObj = Database.query(soql);
        if (findOwnerObj.get('OwnerId') != UserInfo.getUserId()) {
            return 'Error';
        }else {
            return 'Success';
        }
    }
    @AuraEnabled(cacheable=false)
    global static String toCreateApprove(Id recordId) {
        Requirementsreview__c req = [SELECT Id,Process_Id__c,Approval_Comments__c,Applicant_Num__c,Owner_Department__c,Applicationsector__c,Marketing_Center__r.Job_Number__c,Regional_Agency__r.Job_Number__c,Business_Manager__r.Job_Number__c,Presidential_System_Room__r.Job_Number__c,Approvalstatus__c,
                                    (SELECT Id,Originalcontractbrand__c,Recommendedbrand__c,Configurationname__c FROM Requirementsreview__r),
                                    Projectcategory__c,Country__c,Group__r.Name,Contractmodel__c,Projectname__c,Contractwarrantyperiod__c,Configurationcategory__c,Deliveryrequirements__c,Salesdepartment__c,ProjectType__c,CustomerSegment__c,FinishDate__c FROM Requirementsreview__c WHERE id =: recordId];
        List<String> original = new List<String>(); //原合同品牌
        List<String> recom = new List<String>(); //推荐品牌
        List<String> config = new List<String>(); //配置名称
        String returnId = '';
        Interface_Log__c logInfo = new Interface_Log__c();
        External_System_Param__c ext = External_System_Param__c.getValues('oaRequirementsReviewAdd');
        RequestBody reqBody = new RequestBody();
        for (Demandconfiguration__c dem : req.Requirementsreview__r) {
            if (dem.Originalcontractbrand__c!=null) {
                original.add(dem.Originalcontractbrand__c);
            }else {
                original.add('无');
            }  
            if (dem.Recommendedbrand__c!=null) {
                recom.add(dem.Recommendedbrand__c);
            }else {
                recom.add('无');
            }  
            if (dem.Configurationname__c!=null) {
                config.add(dem.Configurationname__c);
            }else {
                config.add('无');
            }  
        }
        try {
            reqBody.fdId = String.isBlank(req.Process_Id__c)?'':req.Process_Id__c;//流程Id
            reqBody.auditNode = String.isBlank(req.Approval_Comments__c)?'请审批':req.Approval_Comments__c;
            reqBody.docCreator = req.Applicant_Num__c; //创建人
            reqBody.fd_apply_dept = req.Owner_Department__c==null?'':req.Owner_Department__c;   //部门
            reqBody.fd_applyer = req.Applicant_Num__c; //申请人
            reqBody.fd_brand_asume = original;                  //原合同品牌
            reqBody.fd_brand_suggest = recom;                   //推荐品牌
            reqBody.fd_country_in = String.isBlank(req.Country__c)?'':req.Country__c;             //国别
            reqBody.fd_hetong_type = String.isBlank(req.Contractmodel__c)?'':req.Contractmodel__c;      //合同机型
            reqBody.fd_project_name = req.Projectname__c;       //项目名称
            reqBody.fd_quality_save = req.Contractwarrantyperiod__c;       //合同质保期
            reqBody.fd_range_setting = req.Configurationcategory__c;       //范畴选取
            reqBody.fd_setting_name = config;       //配置名称
            reqBody.fd_submit_request = req.Deliveryrequirements__c;       //交付要求
            reqBody.fd_war_zone = req.Salesdepartment__c!=null?req.Salesdepartment__c:'';       //项目所属区域    
            reqBody.n30 = req.Regional_Agency__r.Job_Number__c; //区域代办处    
            reqBody.n40 = req.Presidential_System_Room__r.Job_Number__c;       //总统系统室
            reqBody.fd_project_type = req.ProjectType__c;       //项目类型
            reqBody.fd_customer_segment = String.isBlank(req.CustomerSegment__c)?'':req.CustomerSegment__c;       //客户分部
            reqBody.fd_finish_date = req.FinishDate__c;         //决策完成时间

            
            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'ControllerProprietorRequireReview',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
            if (response.substring(0,5) == 'Error') {
                return response;
            }else {
                
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                if (resBody.code == 200) {
                    String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
                    //先判断是否是驳回状态，用于更新中间表状态
                    Boolean updateMiddleTableSign = false;
                    String findId = '';
                    if (!String.isBlank(req.Process_Id__c)&&(req.Approvalstatus__c=='11'||req.Approvalstatus__c=='10')) {
                        updateMiddleTableSign = true;
                        findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:req.Id AND RecordTypeId =: recTypeId].Id;
                    }


                    Requirementsreview__c updateReq = new Requirementsreview__c();
                    updateReq.Id = req.Id;
                    updateReq.Process_Id__c = resBody.data.fdId;
                    updateReq.ApplicantionNumber__c = resBody.data.docSubject;
                    returnId = resBody.data.fdId;
                    updateReq.Approvalstatus__c = '20';
                    update updateReq;   //更新回流程id

                    //插入数据到集成中间表
                    Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                    if (updateMiddleTableSign) {
                        middleForm.id = findId;
                        middleForm.Approvalstatus__c = '20';//审批状态
                        update middleForm;
                    }else {
                        middleForm.RecordTypeId = recTypeId;//赋值记录类型
                        middleForm.Object_API__c = 'Requirementsreview__c';//对象API
                        middleForm.Mapping_Object_Id__c = req.Id;//对应对象的Id
                        middleForm.Scheme_Type__c = null;//方案类型
                        middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        insert middleForm;
                    }
                    

                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerProprietorRequireReview';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerProprietorRequireReview';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
                }
            }
            
            return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+returnId+'&loginName='+req.Applicant_Num__c+'&identification=CRM';
        } catch (Exception e) {
            logInfo.RequestURL__c = ext.Request_URL__c;
			logInfo.ClassName__c = 'ControllerProprietorRequireReview';
			logInfo.RequestBody__c = JSON.serialize(reqBody);
			logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
        }
    }

    public class RequestBody {
        public String fdId{get;set;}//已驳回携带流程id
        public String auditNode{get;set;} //审批节点
        public String docCreator{get;set;} //创建人
        public String fd_apply_dept{get;set;} //申请人部门
        public String fd_applyer{get;set;} //姓名
        public List<String> fd_brand_asume{get;set;} //原合同品牌
        public List<String> fd_brand_suggest{get;set;} //推荐品牌
        // public String fd_category{get;set;} //项目类别
        public String fd_country_in{get;set;} //国别
        public String fd_hetong_type{get;set;} //合同机型
        // public String fd_project_group{get;set;} //项目所属集团
        public String fd_project_name{get;set;} //项目名称
        public String fd_quality_save{get;set;} //合同质保期
        public String fd_range_setting{get;set;} //范畴选取
        public List<String> fd_setting_name{get;set;} //配置名称
        public String fd_submit_request{get;set;} //交付要求
        public String fd_war_zone{get;set;} //项目所属区域
        // public String n11{get;set;} //营销中心
        public String n30{get;set;} //区域代办处
        // public String n4{get;set;} //商务经理
        public String n40{get;set;} //总统系统室
        public String fd_project_type{get;set;}//项目类型
        public String fd_customer_segment{get;set;}//客户分部
        public Date fd_finish_date{get;set;}//决策完成时间
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public Data data{get;set;}
    }
    public class Data {
        public String rtStatus{get;set;}
        public String rtMsg{get;set;}
        public String fdId{get;set;}
        public String docSubject{get;set;}
        public String fdNumber{get;set;}
    } 
}