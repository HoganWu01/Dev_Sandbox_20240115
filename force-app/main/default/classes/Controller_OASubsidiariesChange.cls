/*
 * @Author: irving
 * @Date: 2021-11-12 10:51:44
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-12-11 14:15:42
 * @Descripttion: 子公司投资与注册
 */
global without sharing class Controller_OASubsidiariesChange {
   
    @AuraEnabled(cacheable=false)
    global static String OASubsidiariesChange(Id recordId){
        Interface_Log__c logInfo = new Interface_Log__c();
        //
        CompanyRegisterApplication__c companyRegister = [SELECT ID,
                                                                NAME,
                                                                Approval_Comments__c,
                                                                Process_Id__c,
                                                                Approvalstatus__c,
                                                                Applicant_Num__c,
                                                                SigningAgreement__c,   //涉及协议签订
                                                                ProjectName__c ,   //项目名称
                                                                CapitalAddress__c, //注册地址
                                                                //aaa      //公司注册项目说明
                                                                CapitalOfficeLocation__c ,  //办公地点
                                                                ChangeManagementCompanyName__c, // 变更管理-公司名称
                                                                LogoutCompanyName__c ,   //清算注销-公司名称
                                                                EquityWriteoffsNotes__c,  //项目说明（股权注销情况说明）
                                                                //aaa       //清算注销-项目名称                                                           
                                                                RegisterCapital__c,  //注册资金
                                                                //aaa  //公司注册-公司名称
                                                                //aaa    //是否涉及资源开发业务
                                                                CorrespondingOANumber__c , //对应营销项目立项申请单号
                                                                EquityTransferCompanyName__c  ,  //公司名称（股权转让公司名称）
                                                                Field1__c ,     //项目说明（股权变动情况说明）
                                                                ApprovalReason__c,//申请事项
                                                                EquityRatio__c,//股权比例
                                                                EquityCounterparty__c,//股权对价 
                                                                ChangeManagementInstrusction__c,//详细说明（子公司变更管理）
                                                                SubsidiaryChangeManagementCategory__c,//子公司变更管理
                                                               ChangeSubsidiaryCapitalReason__c,//增减子公司资本背景及原因
                                                                InvestmentProjectApplicationType__c,//子公司投资立项类别
                                                                SoleProprietorshipOrJointVenture__c,//是否涉及独资或合资设立子公司
                                                               SubsidiaryInvestmentsApplicationCause__c,   //子公司投资事前申请具体内容
                                                               CompanyRegistrationDescription__c  ,   //项目说明（公司注册）
                                                               FinanceDirector__c , //财务负责人  
                                                               ManagerDirector__c , //     总经理
                                                               JuridicalPerson__c ,   //法定代表人
                                                               Supervisor__c ,  //监事
                                                               CapitalChangeDescription__c , //增减子公司资本具体说明
                                                               CompanyName_Registered__c ,   //公司名称（公司注册）
                                                               ProjectName_Capital__c , //项目名称（独资）   公司注册-项目名称   
                                                               EquityAcquisitionDescription__c     //收购-项目说明--项目说明（经营投资需求下股权收购情况说明）                                                                                                                                                                                                          
                                                               FROM CompanyRegisterApplication__c WHERE Id =:recordId];
        //
        RequestBody reqBody = new RequestBody();
        String returnId = '';
        External_System_Param__c ext = External_System_Param__c.getValues('oaSubsidiariesChange');
        //String InvestmentProjectArray = '';  //子公司投资立项数组   分号;拼接


        try {
            reqBody.auditNode = String.isBlank(companyRegister.Approval_Comments__c)?'请审批':companyRegister.Approval_Comments__c;
           reqBody.docCreator = companyRegister.Applicant_Num__c; //创建人
            reqBody.fdId = String.isBlank(companyRegister.Process_Id__c)?'':companyRegister.Process_Id__c;     //	表单ID（重新提交表单必填）
            reqBody.fd_agreement_signing = companyRegister.SigningAgreement__c;  //	是否涉及协议签订,可用值:是,否,示例值(是)
            reqBody.fd_applications_types = String.isBlank(companyRegister.ApprovalReason__c)?1:Integer.valueOf(companyRegister.ApprovalReason__c);   //申请事项
            reqBody.fd_applyer = companyRegister.Applicant_Num__c;    //姓名,示例值(A07068)

            reqBody.fd_aquisition_content = companyRegister.EquityAcquisitionDescription__c;   //收购-项目说明(子公司投资立项包含2时必填)---

            reqBody.fd_aquisition_project_name = companyRegister.ProjectName__c;  //收购-项目名称(子公司投资立项包含2时必填)
            reqBody.fd_aquisition_proportion = String.valueOf(companyRegister.EquityRatio__c);   //	股权比例(子公司投资立项包含2时必填)
            reqBody.fd_aquisition_stock = companyRegister.EquityCounterparty__c;   //	股权对价(子公司投资立项包含2时必填)
            reqBody.fd_capital_address = companyRegister.CapitalAddress__c;  //	注册地址(是否涉及资源开发业务为是时必填)ccc

            System.debug('companyRegister.CompanyRegistrationDescription__c===>'+companyRegister.CompanyRegistrationDescription__c);
            String CompanyRegistrationDescription = '';
            if (companyRegister.CompanyRegistrationDescription__c!=null) {
                
                if (companyRegister.CompanyRegistrationDescription__c.contains('<p>') &&companyRegister.CompanyRegistrationDescription__c.contains('</p>')) {
                    CompanyRegistrationDescription = companyRegister.CompanyRegistrationDescription__c.remove('<p>').remove('</p>');
                   reqBody.fd_capital_content = CompanyRegistrationDescription;  //	公司注册项目说明(是否涉及资源开发业务为是时必填)---
               }else{
                   reqBody.fd_capital_content = companyRegister.CompanyRegistrationDescription__c;  //	公司注册项目说明(是否涉及资源开发业务为是时必填)---
               }
            }
            
            //System.debug('companyRegister.FinanceDirector__c==>>'+companyRegister.FinanceDirector__c);

            // if (companyRegister.FinanceDirector__c!=null) {
            //     reqBody.fd_capital_finance_charge = selectEmpNameById(companyRegister.FinanceDirector__c); //财务负责人(是否涉及资源开发业务为是时必填) 
            // }
            reqBody.fd_capital_finance_charge = companyRegister.FinanceDirector__c ;
            // if (companyRegister.ManagerDirector__c!=null) {
            //     reqBody.fd_capital_manager = selectEmpNameById(companyRegister.ManagerDirector__c);   //	总经理(是否涉及资源开发业务为是时必填)
            // }
            reqBody.fd_capital_manager = companyRegister.ManagerDirector__c;
            
            reqBody.fd_capital_office_location = companyRegister.CapitalOfficeLocation__c;   //办公地点(是否涉及资源开发业务为是时必填)ccc
            // if (companyRegister.JuridicalPerson__c!=null) {
            //     reqBody.fd_capital_rpresentative = selectEmpNameById(companyRegister.JuridicalPerson__c) ;   //	法定代表人(是否涉及资源开发业务为是时必填)
            // }
            reqBody.fd_capital_rpresentative = companyRegister.JuridicalPerson__c;
           
            // if (companyRegister.Supervisor__c!=null) {
            //     reqBody.fd_capital_supervisor = selectEmpNameById (companyRegister.Supervisor__c);   //	监事(是否涉及资源开发业务为是时必填)
            // }

            reqBody.fd_capital_supervisor = companyRegister.Supervisor__c; 
            
            reqBody.fd_change_compeny_name = companyRegister.ChangeManagementCompanyName__c;  //变更管理-公司名称(申请事项为2时必填)

            System.debug('companyRegister.ChangeManagementInstrusction__c===>'+companyRegister.ChangeManagementInstrusction__c);
            String ChangeManagementInstrusction = '';
            if (companyRegister.ChangeManagementInstrusction__c!=null) {
                if (companyRegister.ChangeManagementInstrusction__c.contains('<p>') && companyRegister.ChangeManagementInstrusction__c.contains('</p>')) {
                    ChangeManagementInstrusction = companyRegister.ChangeManagementInstrusction__c.remove('<p>').remove('</p>');
                    reqBody.fd_change_content =ChangeManagementInstrusction ;
                }else{
                    reqBody.fd_change_content = companyRegister.ChangeManagementInstrusction__c;  //详细说明(申请事项为2时必填)
                }
            }
            
            
            reqBody.fd_change_management = companyRegister.SubsidiaryChangeManagementCategory__c;  //	子公司变更管理（申请事项为2时必填）(1:公司章程修订、经营范围、经营地址变更,2:法人或董监高变更,3:其它变更),可用值:1,2,3
            reqBody.fd_clear_compeny_name = companyRegister.LogoutCompanyName__c;   //清算注销-公司名称(子公司投资立项包含5时必填)

            System.debug('companyRegister.EquityWriteoffsNotes__c===>'+companyRegister.EquityWriteoffsNotes__c);
            String EquityWriteoffsNotes = '';
            if (companyRegister.EquityWriteoffsNotes__c!=null) {
                if (companyRegister.EquityWriteoffsNotes__c.contains('<p>') && companyRegister.EquityWriteoffsNotes__c.contains('</p>')) {
                    EquityWriteoffsNotes = companyRegister.EquityWriteoffsNotes__c.remove('<p>').remove('</p>');
                    reqBody.fd_clear_project_content = EquityWriteoffsNotes;  //	清算注销-项目说明(子公司投资立项包含5时必填)---
                }else{
                    reqBody.fd_clear_project_content = companyRegister.EquityWriteoffsNotes__c;  //	清算注销-项目说明(子公司投资立项包含5时必填)---
                }
            }
            
            

            reqBody.fd_clear_project_name = companyRegister.ProjectName__c;  //清算注销-项目名称(子公司投资立项包含5时必填)

            System.debug('companyRegister.CapitalChangeDescription__c===>'+companyRegister.CapitalChangeDescription__c);
            String CapitalChangeDescription = '';
            if (companyRegister.CapitalChangeDescription__c!=null) {
                if (companyRegister.CapitalChangeDescription__c.contains('<p>') && companyRegister.CapitalChangeDescription__c.contains('</p>')) {
                    CapitalChangeDescription = companyRegister.CapitalChangeDescription__c.remove('<p>').remove('</p>');
                    reqBody.fd_fluctuate_explain = CapitalChangeDescription;   //	增减子公司资本具体说明(子公司投资立项包含3时必填)---
                }else{
                    reqBody.fd_fluctuate_explain = companyRegister.CapitalChangeDescription__c;
                }
            }
           
           
            System.debug('companyRegister.ChangeSubsidiaryCapitalReason__c===>'+companyRegister.ChangeSubsidiaryCapitalReason__c);
            String ChangeSubsidiaryCapitalReason = '';
            if (companyRegister.ChangeSubsidiaryCapitalReason__c!=null) {
                if (companyRegister.ChangeSubsidiaryCapitalReason__c.contains('<p>') && companyRegister.ChangeSubsidiaryCapitalReason__c.contains('</p>')) {
                    ChangeSubsidiaryCapitalReason = companyRegister.ChangeSubsidiaryCapitalReason__c.remove('<p>').remove('</p>');
                    reqBody.fd_fluctuate_reason =ChangeSubsidiaryCapitalReason;   //增减子公司资本背景及原因(子公司投资立项包含3时必填)	
                }else{
                    reqBody.fd_fluctuate_reason = companyRegister.ChangeSubsidiaryCapitalReason__c;
                }
            }
            
            
            
            reqBody.fd_investment_project = companyRegister.InvestmentProjectApplicationType__c;   //	子公司投资立项（申请事项为1时必填，多值以分号相隔）(1:投资立项申请,2:收购目标公司的部分或全部股权,3:增减子公司资本, 4:子公司股权转让,5:子公司清算注销),可用值:1,2,3,4,5,示例值(1;2)
            reqBody.fd_joint_venture = companyRegister.SoleProprietorshipOrJointVenture__c;  //独资或合资设立子公司（子公司投资立项包含1时必填）,可用值:是,否,示例值(否)
            reqBody.fd_project_charge = companyRegister.Applicant_Num__c;  //	项目负责人,示例值(A02323)
            reqBody.fd_project_reache = companyRegister.Applicant_Num__c;  //项目联系人,示例值(A02323)
            reqBody.fd_register_capital = companyRegister.RegisterCapital__c;   //	注册资金(是否涉及资源开发业务为是时必填)
            reqBody.fd_register_compeny_name = companyRegister.CompanyName_Registered__c;  //公司注册-公司名称(是否涉及资源开发业务为是时必填)---
            reqBody.fd_register_project_name = companyRegister.ProjectName__c;  //	公司注册-项目名称(是否涉及资源开发业务为是时必填)
            reqBody.fd_resource_development = '是';  //	是否涉及资源开发业务（申请事项为1时必填）,可用值:是,否,示例值(是)---

            if (String.isNotBlank(companyRegister.CorrespondingOANumber__c) &&companyRegister.CorrespondingOANumber__c!=null) {
                reqBody.fd_sole_number = companyRegister.CorrespondingOANumber__c;  //	对应营销项目立项申请单号(子公司投资立项包含1时必填)
            }else{
                reqBody.fd_sole_number = '无';
            }
            
            System.debug('companyRegister.SubsidiaryInvestmentsApplicationCause__c===>'+companyRegister.SubsidiaryInvestmentsApplicationCause__c);
            String SubsidiaryInvestmentsApplicationCause = '';
            if (companyRegister.SubsidiaryInvestmentsApplicationCause__c!=null) {
                if (companyRegister.SubsidiaryInvestmentsApplicationCause__c.contains('<p>') &&companyRegister.SubsidiaryInvestmentsApplicationCause__c.contains('</p>')) {
                    SubsidiaryInvestmentsApplicationCause = companyRegister.SubsidiaryInvestmentsApplicationCause__c.remove('<p>').remove('</p>');
                    reqBody.fd_sole_project_content = SubsidiaryInvestmentsApplicationCause;  //子公司投资事前申请具体内容(子公司投资立项包含1时必填)
                }else{
                    reqBody.fd_sole_project_content = companyRegister.SubsidiaryInvestmentsApplicationCause__c;
                }
            }
           

            
            reqBody.fd_sole_project_name = companyRegister.ProjectName__c;  //独资-项目名称(子公司投资立项包含1时必填)
            reqBody.fd_transfer_compeny_name = companyRegister.EquityTransferCompanyName__c;  //股权转让-公司名称(子公司投资立项包含4时必填)

            System.debug('companyRegister.Field1__c===>'+companyRegister.Field1__c);
            String Field1 = '';
            if (companyRegister.Field1__c!=null) {
                if (companyRegister.Field1__c.contains('<p>') &&companyRegister.Field1__c.contains('</p>')) {
                    Field1 = companyRegister.Field1__c.remove('<p>').remove('</p>');
                    reqBody.fd_transfer_project_content = Field1;  //	股权转让-项目说明(子公司投资立项包含4时必填)---
                }else{
                    reqBody.fd_transfer_project_content = companyRegister.Field1__c;  //	股权转让-项目说明(子公司投资立项包含4时必填)---
                }
            }
           

            
            reqBody.fd_transfer_project_name = companyRegister.ProjectName__c;  //股权转让-项目名称(子公司投资立项包含4时必填)
          
            
            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OASubsidiariesChange',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
            if (response.substring(0,5) == 'Error') {
                return response;
            }else {
                
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                if (resBody.code == 200) {
                    String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();

                    //先判断是否是驳回状态，用于更新中间表状态
                   Boolean updateMiddleTableSign = false;
                    String findId = '';
                    if (!String.isBlank(companyRegister.Process_Id__c)&&(companyRegister.Approvalstatus__c=='11'||companyRegister.Approvalstatus__c=='10')) {
                        updateMiddleTableSign = true;
                        findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:companyRegister.Id AND RecordTypeId =: recTypeId].Id;
                    }

                    CompanyRegisterApplication__c updateReq = new CompanyRegisterApplication__c();
                    updateReq.Id = companyRegister.Id;
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
                        middleForm.Object_API__c = 'CompanyRegisterApplication__c';  //对象API
                        middleForm.Mapping_Object_Id__c = companyRegister.id;  //对应对象的Id
                        middleForm.Scheme_Type__c = null; //方案类型
                        middleForm.Final_Approval_Date__c = null; //最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        insert middleForm;
                    }
                    
                    
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OASubsidiariesChange';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OASubsidiariesChange';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name; 
                }
            }
            System.debug('子公司接口调用完成');
            return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+returnId+'&loginName='+companyRegister.Applicant_Num__c+'&identification=CRM';
           
        } catch (Exception e) {
            logInfo.RequestURL__c = ext.Request_URL__c;
			logInfo.ClassName__c = 'Controller_OASubsidiariesChange';
			logInfo.RequestBody__c = JSON.serialize(reqBody);
			logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
        }
        
    }


    // public static String selectEmpNameById(String empId){

    //     Employee__c emp = [select id,name from Employee__c where id = :empId] ; 

    //     System.debug('emp=='+emp);

    //     return emp.name;
    // }

    public class RequestBody {
        public String auditNode;  //	审批意见,示例值(请审批)
        public String docCreator; //创建人,示例值(A07068)
        public String fdId;  //表单ID（重新提交表单必填）
        public String fd_agreement_signing; //是否涉及协议签订,可用值:是,否,示例值(是)
        public Integer fd_applications_types;  //申请事项(1:子公司投资立项事前申请,2:1子公司变更管理),可用值:1,2,示例值(1)
        public String fd_applyer; //姓名,示例值(A07068)
        public String fd_aquisition_content;  //收购-项目说明(子公司投资立项包含2时必填)
        public String fd_aquisition_project_name; //收购-项目名称(子公司投资立项包含2时必填)
        public String fd_aquisition_proportion;  //股权比例(子公司投资立项包含2时必填)
        public String fd_aquisition_stock;  //	股权对价(子公司投资立项包含2时必填)
        public String fd_capital_address; //注册地址(是否涉及资源开发业务为是时必填)
        public String fd_capital_content;  //公司注册项目说明(是否涉及资源开发业务为是时必填)
        public String fd_capital_finance_charge;  //财务负责人(是否涉及资源开发业务为是时必填)
        public String fd_capital_manager; //总经理(是否涉及资源开发业务为是时必填)
        public String fd_capital_office_location; //办公地点(是否涉及资源开发业务为是时必填)
        public String fd_capital_rpresentative;  //法定代表人(是否涉及资源开发业务为是时必填)
        public String fd_capital_supervisor;  //	监事(是否涉及资源开发业务为是时必填)
        public String fd_change_compeny_name;  //变更管理-公司名称(申请事项为2时必填)
        public String fd_change_content;  //	详细说明(申请事项为2时必填)	
        public String fd_change_management;  //子公司变更管理（申请事项为2时必填）(1:公司章程修订、经营范围、经营地址变更,2:法人或董监高变更,3:其它变更),可用值:1,2,3
        public String fd_clear_compeny_name; //	清算注销-公司名称(子公司投资立项包含5时必填)
        public String fd_clear_project_content;  //	清算注销-项目说明(子公司投资立项包含5时必填)
        public String fd_clear_project_name;  //	清算注销-项目名称(子公司投资立项包含5时必填)
        public String fd_fluctuate_explain;  //增减子公司资本具体说明(子公司投资立项包含3时必填)
        public String fd_fluctuate_reason;  //	增减子公司资本背景及原因(子公司投资立项包含3时必填)
        public String fd_investment_project;  //	子公司投资立项（申请事项为1时必填，多值以分号相隔）(1:投资立项申请,2:收购目标公司的部分或全部股权,3:增减子公司资本, 4:子公司股权转让,5:子公司清算注销),可用值:1,2,3,4,5,示例值(1;2)
        public String fd_joint_venture;   //	独资或合资设立子公司（子公司投资立项包含1时必填）,可用值:是,否,示例值(否)
        public String fd_project_charge;  //项目负责人,示例值(A02323)
        public String fd_project_reache;  //项目联系人,示例值(A02323)
        public String fd_register_capital;  //	注册资金(是否涉及资源开发业务为是时必填)
        public String fd_register_compeny_name;  //公司注册-公司名称(是否涉及资源开发业务为是时必填)
        public String fd_register_project_name; //公司注册-项目名称(是否涉及资源开发业务为是时必填)
        public String fd_resource_development; //是否涉及资源开发业务（申请事项为1时必填）,可用值:是,否,示例值(是)
        public String fd_sole_number;  //	对应营销项目立项申请单号(子公司投资立项包含1时必填)
        public String fd_sole_project_content;  //	子公司投资事前申请具体内容(子公司投资立项包含1时必填)
        public String fd_sole_project_name;  //独资-项目名称(子公司投资立项包含1时必填)
        public String fd_transfer_compeny_name;  //股权转让-公司名称(子公司投资立项包含4时必填)
        public String fd_transfer_project_content;  //股权转让-项目说明(子公司投资立项包含4时必填)
        public String fd_transfer_project_name;  //股权转让-项目名称(子公司投资立项包含4时必填)
    }

    public class ResponseBody {
        public Integer code{get;set;}  //	返回编码
        public String message{get;set;}  // 	返回信息
        public Data data{get;set;}   //	请求成功返回明细
    }
    public class Data {
        public DataCls Data{get;set;}
        //public dataCls data{get;set;}
        public String docSubject{get;set;}
        public String fdId{get;set;}
        public String fdNumber{get;set;}
        public String rtMsg{get;set;}
        public String rtStatus{get;set;}
    }

    public class DataCls {  
    }
    
    // public class dataCls {  
    // }
}