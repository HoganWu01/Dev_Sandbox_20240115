global without sharing class ControllerStrategicCooperationContract {
    /**
     * @description: 战略合作协议/合同审批单 create by hogan
     * @date: 2023-4-4
     * @param  {*}
     * @return {*}
     */  
    @AuraEnabled(cacheable=false)
    global static string toCreateStrategicCooperationContract(Id recordId){
        Interface_Log__c logInfo = new Interface_Log__c();
        StrategicCooperationContract__c resApproval = [
            SELECT Name, Flow_Start_Date__c, Apply_Dept_Number__c, Contract_Code__c, Sign_Type__c, Applicant_Num__c,
            Sign_Unit_Account__c, Sign_Unit_Res_Acc__c, Chose_Area__c,Chose_Area_Other__c, Is_New_Industry__c, Industry_Type__c, Process_Id__c,
            Other_Industry__c, Is_Investment__c, Industry_Order__c, Design__c, Introduction__c, Other_Design__c,
            Desc__c, Is_Apply_Seal__c, Seal_Org__c, Seal_Safekeep_Dept__c, Industry_Order__r.Process_Id__c,Industry_Order__r.Name,
            Sign_Unit_Account__r.Name, Sign_Unit_Res_Acc__r.Name, Approvalstatus__c, Approval_Comments__c, Cooperation_Background__c,
            (SELECT Id,Document_Category__c,Document_Name__c,Seal_Company__c,Seal_Type__c,Seal_Numble__c FROM Seal_Related_Strategic__r)
        FROM StrategicCooperationContract__c WHERE Id =: recordId
        ];
        RequestBody reqBody = new RequestBody();
        List<String> sealCompayName = new List<String>(); //印章归属公司
        List<String> sealName = new List<String>(); //印章类别
        List<String> sealNumber = new List<String>(); //印章数量
        List<String> sealAdmins = new List<String>(); //印章保管员
        String returnId = '';
        //判断盖章记录和申请复选框是否统一
        if (resApproval.Seal_Related_Strategic__r.size()==0&&resApproval.Is_Apply_Seal__c==true) {
            return 'NoSeal';
        }
        External_System_Param__c ext = External_System_Param__c.getValues('oaStrategicCooperationContractAdd');
        for (Seal_Related_Information__c sealRelInfo : resApproval.Seal_Related_Strategic__r) {
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
            reqBody.auditNode = String.isBlank(resApproval.Approval_Comments__c)?'请审批':resApproval.Approval_Comments__c;//审批意见
            reqBody.docCreator = resApproval.Applicant_Num__c; //所有人工号
            reqBody.fd_apply_seal = resApproval.Is_Apply_Seal__c==true?'是':'否'; //是否申请盖章
            reqBody.fd_applyer = resApproval.Applicant_Num__c; //申请人
            reqBody.fd_chose_area = String.isBlank(resApproval.Chose_Area__c)?'':resApproval.Chose_Area__c; //合作涉及区域
            reqBody.fd_other_area = String.isBlank(resApproval.Chose_Area_Other__c)?'':resApproval.Chose_Area_Other__c; //合作涉及其他区域，当合作涉及区域为其他时必填
            reqBody.fd_contract_name = resApproval.Name; //合同名称
            reqBody.fd_desc = resApproval.Desc__c; //备注说明
            reqBody.fd_design = String.isBlank(resApproval.Design__c)?'':resApproval.Design__c; //涉及的风光储氢等产能设计
            reqBody.fd_industry_order = resApproval.Industry_Order__c==null?'':resApproval.Industry_Order__r.Process_Id__c;//产业项目投资评审单ID
            reqBody.fd_industry_order_text = resApproval.Industry_Order__c==null?'':resApproval.Industry_Order__r.Name;//产业项目投资评审单Name
            reqBody.fd_industry_type = String.isBlank(resApproval.Industry_Type__c)?'':resApproval.Industry_Type__c; //新产业版块类别
            reqBody.fd_introduction = resApproval.Introduction__c; //协议/合同内容简介
            reqBody.fd_is_investment = resApproval.Is_Investment__c==true?'是':'否';//是否涉及产业投资
            reqBody.fd_is_new_industry = resApproval.Is_New_Industry__c==true?'是':'否';//是否涉及新产业板块
            reqBody.fd_other_design = resApproval.Other_Design__c; //其他产业(产能设计)
            reqBody.fd_other_industry = resApproval.Other_Industry__c; //其他产业(新产业)
            reqBody.fd_seal_admin = sealAdmins;//印章管理员
            reqBody.fd_seal_compay_name = sealCompayName; //印章归属公司
            reqBody.fd_seal_name = sealName; //印章类别
            reqBody.fd_seal_number = sealNumber; //印章数量
            reqBody.fd_seal_org = String.isBlank(resApproval.Seal_Org__c)?'':resApproval.Seal_Org__c;//管理单位
            reqBody.fd_seal_safekeep_dept = String.isBlank(resApproval.Seal_Safekeep_Dept__c)?'':resApproval.Seal_Safekeep_Dept__c;//印章保管部门
            reqBody.fd_cooperation_background = resApproval.Cooperation_Background__c; //合作背景
            if (resApproval.Sign_Type__c=='客户') {
                if(resApproval.Sign_Unit_Account__c!=null){
                    reqBody.fd_sign_unit = resApproval.Sign_Unit_Account__r.Name;//签约方单位
                }else{
                    return 'Error: No Account!';
                }
            }else if (resApproval.Sign_Type__c=='资源客户') {
                if(resApproval.Sign_Unit_Res_Acc__c!=null){
                    reqBody.fd_sign_unit = resApproval.Sign_Unit_Res_Acc__r.Name;//签约方单位
                }else{
                    return 'Error: No Resource Account!';
                }
            }else{
                return 'Error: No Sign Type!';
            }
            

            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'ControllerStrategicCooperationContract',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
            if (response.substring(0,5) == 'Error') {
                // return response;
                logInfo.RequestURL__c = ext.Request_URL__c;
                logInfo.ClassName__c = 'ControllerStrategicCooperationContract';
                logInfo.RequestBody__c = JSON.serialize(reqBody);
                logInfo.RespondBody__c = response;
                logInfo.IsSuccess__c = false;
                logInfo.ErrorMessage__c = '';
                insert logInfo;
                Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                return 'Error:'+response+'\n日志编号:'+newLog.Name;
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

                    StrategicCooperationContract__c updateStra = new StrategicCooperationContract__c();
                    updateStra.Id = resApproval.Id;
                    updateStra.Process_Id__c = resBody.data.fdId;
                    updateStra.Approvalstatus__c = '20';
                    updateStra.Contract_Code__c = resBody.data.fdNumber;//流程单号
                    updateStra.Doc_Subject__c = resBody.data.docSubject;//流程主题
                    updateStra.Flow_Start_Date__c = Datetime.now();//流程发起时间
                    returnId = resBody.data.fdId;
                    update updateStra;   //更新返回信息

                    //插入数据到集成中间表
                    Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                    if (updateMiddleTableSign) {
                        middleForm.id = findId;
                        middleForm.Approvalstatus__c = '20';//审批状态
                        update middleForm;
                    }else {
                        middleForm.RecordTypeId = recTypeId;//赋值记录类型
                        middleForm.Object_API__c = 'StrategicCooperationContract__c';//对象API
                        middleForm.Mapping_Object_Id__c = resApproval.Id;//对应对象的Id
                        middleForm.Scheme_Type__c = null;//方案类型
                        middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        insert middleForm;
                    }
                    


                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerStrategicCooperationContract';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerStrategicCooperationContract';
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
            // throw new AuraHandledException(e.getMessage());

            logInfo.RequestURL__c = ext.Request_URL__c;
			logInfo.ClassName__c = 'ControllerStrategicCooperationContract';
			logInfo.RequestBody__c = JSON.serialize(reqBody);
			logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
        }
    }

    public class RequestBody {
        public String fdId{get;set;}
        public String auditNode{get;set;}
        public String docCreator{get;set;}
        public String fd_apply_seal{get;set;}
        public String fd_applyer{get;set;}
        public String fd_chose_area{get;set;}
        public String fd_other_area{get;set;}
        public String fd_contract_name{get;set;}
        public String fd_desc{get;set;}
        public String fd_design{get;set;}
        public String fd_industry_order{get;set;}
        public String fd_industry_order_text{get;set;}
        public String fd_industry_type{get;set;}
        public String fd_introduction{get;set;}
        public String fd_is_investment{get;set;}
        public String fd_is_new_industry{get;set;}
        public String fd_other_design{get;set;}
        public String fd_other_industry{get;set;}
        public List<String> fd_seal_admin{get;set;}//印章管理员,是否申请盖章为“是”时必填	
        public List<String> fd_seal_compay_name{get;set;}//印章归属公司  是否申请盖章为“是”时必填	
        public List<String> fd_seal_name{get;set;}//印章类别  是否申请盖章为“是”时必填
        public List<String> fd_seal_number{get;set;}//盖章数量  是否申请盖章为“是”时必填
        public String fd_seal_org{get;set;}
        public String fd_seal_safekeep_dept{get;set;}
        public String fd_sign_unit{get;set;}
        public String fd_cooperation_background{get;set;}//合作背景
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