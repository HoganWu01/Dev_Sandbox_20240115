global without sharing class ControllerMarketingDevelopment {
    /**
     * @description: 营销资源开发协议 合同审批单
     * @param  {*}
     * @return {*}
     */  
    @AuraEnabled(cacheable=false)
    global static String toCreateMarketingDevelop(Id recordId){
        Interface_Log__c logInfo = new Interface_Log__c();
        ResourceApproval__c resApproval = [SELECT Seal_Org__c,Seal_Safekeep_Dept__c,Approval_Comments__c,Process_Id__c,Id,AgreementFullName__c,	Is_Create_Company__c,AgreementName__c,ResourceArea__c,NewAgreementIntroduction__c,Applicant_Num__c,FileType__c,Agreement_Handler__r.Job_Number__c,Agreement_Handler__c,Agreement_Handler__r.Department_Number__c,ResourceGroup__c,SealApplication__c,Approvalstatus__c
                                          ,(SELECT Id,Document_Category__c,Document_Name__c,Seal_Company__c,Seal_Type__c,Seal_Numble__c FROM Seal_Related_Information__r),Business_Type__c,Investment_Whether__c,ProjectInvestment__r.Process_Id__c
                                           FROM ResourceApproval__c WHERE Id =: recordId];
        RequestBody reqBody = new RequestBody();
        // List<String> fileCategory = new List<String>(); //文档类别
        // List<String> qualityFilename = new List<String>(); //资质文件名称
        List<String> sealCompayName = new List<String>(); //印章归属公司
        List<String> sealName = new List<String>(); //印章类别
        List<String> sealNumber = new List<String>(); //印章数量
        List<String> sealAdmins = new List<String>(); //印章保管员
        String returnId = '';
        if (resApproval.Seal_Related_Information__r.size()==0&&resApproval.SealApplication__c=='是') {
            return 'NoSeal';
        }
        External_System_Param__c ext = External_System_Param__c.getValues('oaMarketingDevelopmentAdd');
        System.debug('ext---'+ext);
        for (Seal_Related_Information__c sealRelInfo : resApproval.Seal_Related_Information__r) {
            // if (sealRelInfo.Document_Category__c!=null) {
            //     fileCategory.add(sealRelInfo.Document_Category__c);
            // }
            // if (sealRelInfo.Document_Name__c!=null) {
            //     qualityFilename.add(sealRelInfo.Document_Name__c);
            // }else {
            //     qualityFilename.add('');
            // }
            if (sealRelInfo.Seal_Company__c!=null) {
                String company = sealRelInfo.Seal_Company__c;
                Integer tempPosition = company.indexOf('+MY+');
                sealCompayName.add(company.substring(0,tempPosition));
                if (tempPosition<0) {
                    sealAdmins.add('A04313');//印章保管员
                }else {
                    sealAdmins.add(company.substring(tempPosition+4));//印章保管员
                }
            }
            if (sealRelInfo.Seal_Type__c!=null) {
                String temp = sealRelInfo.Seal_Type__c;
                sealName.add(temp.substringAfterLast('-'));
            }
            if (sealRelInfo.Seal_Numble__c!=null) {
                sealNumber.add(sealRelInfo.Seal_Numble__c);
            }
        }
        try {
            reqBody.fdId = String.isBlank(resApproval.Process_Id__c)?'':resApproval.Process_Id__c;//流程Id
            reqBody.auditNode = String.isBlank(resApproval.Approval_Comments__c)?'请审批':resApproval.Approval_Comments__c;
            reqBody.docCreator = resApproval.Applicant_Num__c; //创建人
            reqBody.fd_apply_seal = String.isBlank(resApproval.SealApplication__c)?'否':resApproval.SealApplication__c; //是否申请盖章
            reqBody.fd_applyer = resApproval.Applicant_Num__c; //申请人
            // reqBody.fd_file_category = fileCategory; //文档类别
            reqBody.fd_file_type = resApproval.FileType__c; //文件类别
            reqBody.fd_jingban_charge = resApproval.Agreement_Handler__c==null?'':resApproval.Agreement_Handler__r.Department_Number__c; //经办部门设置(部门编码)
            reqBody.fd_project_group = resApproval.ResourceGroup__c==null?'':resApproval.ResourceGroup__c; //资源所属集团
            reqBody.fd_project_group_text = resApproval.ResourceGroup__c==null?'':resApproval.ResourceGroup__c; //资源所属集团
            // reqBody.fd_quality_filaname = qualityFilename; //资质文件名称
            reqBody.fd_seal_compay_name = sealCompayName; //印章归属公司
            reqBody.fd_seal_name = sealName; //印章类别
            reqBody.fd_seal_number = sealNumber; //印章数量
            reqBody.fd_text_description = resApproval.NewAgreementIntroduction__c; //协议内容简介
            reqBody.fd_war_zone = resApproval.ResourceArea__c; //资源所属区域
            reqBody.fd_xieyi_name = resApproval.AgreementName__c; //协议名称,示例值(配套协议)
            reqBody.fd_xieyi_person = resApproval.Agreement_Handler__c==null?'':resApproval.Agreement_Handler__r.Job_Number__c; //协议经办人
            reqBody.fd_xieyi_wholename = resApproval.AgreementFullName__c==null?'':resApproval.AgreementFullName__c; //协议方全称,示例值(配套协议)
            reqBody.fd_seal_org = String.isBlank(resApproval.Seal_Org__c)?'':resApproval.Seal_Org__c;//管理单位 conner
            reqBody.fd_seal_safekeep_dept = String.isBlank(resApproval.Seal_Safekeep_Dept__c)?'':resApproval.Seal_Safekeep_Dept__c;//印章保管部门 conner
            reqBody.fd_seal_admin = sealAdmins;//印章保管员 conner
            reqBody.fd_business_type = resApproval.Business_Type__c;//业务类别 hogan
            reqBody.fd_investment_whether = resApproval.Investment_Whether__c==true?'是':'否';//是否涉及产业投资 hogan
            reqBody.fd_relation_id = resApproval.ProjectInvestment__c==null?'':resApproval.ProjectInvestment__r.Process_Id__c;//产业项目投资评审单 hogan
            reqBody.fd_is_create_company = String.isBlank(resApproval.Is_Create_Company__c)?'':resApproval.Is_Create_Company__c; //是否成立子公司

            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'ControllerMarketingDevelopment',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
            if (response.substring(0,5) == 'Error') {
                return response;
            }else {
                
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                if (resBody.code == 200) {
                    String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
                    //先判断是否是驳回状态，用于更新中间表状态
                    Boolean updateMiddleTableSign = false;
                    String findId = '';
                    if (!String.isBlank(resApproval.Process_Id__c)&&(resApproval.Approvalstatus__c=='11'||resApproval.Approvalstatus__c=='10')) {
                        updateMiddleTableSign = true;
                        findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:resApproval.Id AND RecordTypeId =: recTypeId].Id;
                    }


                    //创建印章审批相关信息的父对象
                    if (resApproval.SealApplication__c=='是' && resApproval.Process_Id__c==null) {
                        Seal_Approval__c sealApp = new Seal_Approval__c();
                        sealApp.Resource_Develop_Agreement__c = resApproval.Id;
                        sealApp.Seal_Org__c = resApproval.Seal_Org__c;//管理单位
                        sealApp.SealKeep__c = resApproval.Seal_Safekeep_Dept__c;//印章保管部门
                        insert sealApp;
                    }
                    ResourceApproval__c updateReq = new ResourceApproval__c();
                    updateReq.Id = resApproval.Id;
                    updateReq.Process_Id__c = resBody.data.fdId;
                    updateReq.Approvalstatus__c = '20';
                    updateReq.ApplicantionNumber__c = resBody.data.docSubject;
                    returnId = resBody.data.fdId;
                    update updateReq;   //更新回流程id

                    //插入数据到集成中间表
                    Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                    if (updateMiddleTableSign) {
                        middleForm.id = findId;
                        middleForm.Approvalstatus__c = '20';//审批状态
                        update middleForm;
                    }else {
                        middleForm.RecordTypeId = recTypeId;//赋值记录类型
                        middleForm.Object_API__c = 'ResourceApproval__c';//对象API
                        middleForm.Mapping_Object_Id__c = resApproval.Id;//对应对象的Id
                        middleForm.Scheme_Type__c = null;//方案类型
                        middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        insert middleForm;
                    }
                    


                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerMarketingDevelopment';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerMarketingDevelopment';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
                }
            }
            return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+returnId+'&loginName='+resApproval.Applicant_Num__c+'&identification=CRM';
        } catch (Exception e) {
            logInfo.RequestURL__c = ext.Request_URL__c;
			logInfo.ClassName__c = 'ControllerMarketingDevelopment';
			logInfo.RequestBody__c = JSON.serialize(reqBody);
			logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
        }
    }

    public class RequestBody {
        public String fdId{get;set;}//已驳回携带流程id
        public String auditNode{get;set;} //审批意见
        public String docCreator{get;set;} //创建人
        public String fd_apply_seal{get;set;} //是否申请盖章
        public String fd_applyer{get;set;} //申请人
        // public List<String> fd_file_category{get;set;}//文档类别
        public String fd_file_type{get;set;}//文件类别
        public String fd_jingban_charge{get;set;}//经办部门设置(部门编码)
        public String fd_project_group{get;set;}//资源所属集团
        public String fd_project_group_text{get;set;}//资源所属集团
        // public List<String> fd_quality_filaname{get;set;}//资质文件名称文档类别为“3”时必填
        public List<String> fd_seal_compay_name{get;set;}//印章归属公司  是否申请盖章为“是”时必填	
        public List<String> fd_seal_name{get;set;}//印章类别  是否申请盖章为“是”时必填
        public List<String> fd_seal_number{get;set;}//盖章数量  是否申请盖章为“是”时必填
        public String fd_text_description{get;set;}//协议内容简介,示例值(配套协议)
        public String fd_war_zone{get;set;}//资源所属区域,示例值(华中大区)
        public String fd_xieyi_name{get;set;}//协议名称,示例值(配套协议)
        public String fd_xieyi_person{get;set;}//协议经办人,示例值(A02323)
        public String fd_xieyi_wholename{get;set;}//协议方全称,示例值(配套协议)
        public String fd_seal_org{get;set;}//管理单位,可用值:集团总裁办,基地,子公司,海上风电子公司,示例值(集团总裁办)	
        public String fd_seal_safekeep_dept{get;set;}//印章保管部门,示例值(总裁办综合部)
        public List<String> fd_seal_admin{get;set;}//印章管理员,是否申请盖章为“是”时必填	
        public String fd_business_type{get;set;}//业务类别(订单类:1资源类:2),可用值:1,2,示例值(1)
        public String fd_investment_whether{get;set;}//是否涉及产业投资,可用值:是,否,示例值(是)
        public String fd_relation_id{get;set;}//产业投资申请ID,示例值(17fe9d179cb0973cae5ec1b48b287dbc)
        public String fd_is_create_company{get;set;}//是否成立子公司（是；否）
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