/*
 * @Author: irving
 * @Date: 2021-09-28 11:12:13
 * @LastEditTime: 2021-12-24 14:27:14
 * @LastEditors: Conner
 * @Description: 印章盖章申请单
 */

global without sharing class Controller_SealApplicationAdd {
    @AuraEnabled(cacheable=false)
    global static String SealApplicationAdd(Id recordId){
        Seal_Approval__c sealApp = [SELECT SealKeep__c,Seal_Document_Type__c,Seal_Org__c,Id,Approvalstatus__c,Approval_Comments__c,Process_Id__c,Stamp_Description__c,Applicant_Num__c,Owner_Department__c,Owner_Phone__c,Direct_Leaders__c,Direct_Leaders__r.Job_Number__c,
                                    (SELECT Id,Document_Category__c,Seal_Type__c,Seal_Company__c,Document_Name__c,Seal_Numble__c FROM Seal_Approval__r)
                                     FROM Seal_Approval__c WHERE Id =: recordId];
        Interface_Log__c logInfo = new Interface_Log__c();
        String returnId = '';
        if (sealApp.Process_Id__c!=null) {
            // List<String> fileCategory = new List<String>(); //文档类别
            // List<String> qualityFilename = new List<String>(); //资质文件名称
            List<String> sealCompayName = new List<String>(); //印章归属公司
            List<String> sealName = new List<String>(); //印章类别
            List<String> sealNumber = new List<String>(); //印章数量
            List<String> sealAdmins = new List<String>(); //印章保管员

            for (Seal_Related_Information__c sealRelInfo : sealApp.Seal_Approval__r) {
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
                    System.debug('company===>>>'+company);
                    Integer tempPosition = company.indexOf('+MY+');
                    System.debug('tempPosition===>>>'+tempPosition);
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

            RequestBody reqBody = new RequestBody();
            External_System_Param__c ext = External_System_Param__c.getValues('oaSealApplicationAdd');

            try {

                reqBody.fdId = String.isBlank(sealApp.Process_Id__c)?'':sealApp.Process_Id__c;//流程Id
                reqBody.auditNode = String.isBlank(sealApp.Approval_Comments__c)?'请审批':sealApp.Approval_Comments__c;
                reqBody.docCreator = sealApp.Applicant_Num__c;
                reqBody.fd_apply_dept = sealApp.Owner_Department__c; //申请部门
                reqBody.fd_apply_mobile = sealApp.Owner_Phone__c; //电话
                reqBody.fd_applyer = sealApp.Applicant_Num__c;
                // reqBody.fd_file_category = fileCategory; //文档类别
                // reqBody.fd_quality_filaname = qualityFilename;//资质文件名称
                reqBody.fd_remark = sealApp.Stamp_Description__c;//盖章说明
                reqBody.fd_seal_admin = sealAdmins;//印章保管员
                reqBody.fd_seal_compay_name = sealCompayName;//印章归属公司
                reqBody.fd_seal_name = sealName;//印章类别
                reqBody.fd_seal_number = sealNumber;//盖章数量
                reqBody.fd_seal_safekeep_dept = sealApp.SealKeep__c;//印章保管部门
                reqBody.n18 = sealApp?.Direct_Leaders__c==null?'':sealApp?.Direct_Leaders__r.Job_Number__c;//直属领导审批
                reqBody.fd_seal_org = String.isBlank(sealApp.Seal_Org__c)?'':sealApp.Seal_Org__c;//管理单位 conner
                reqBody.fd_file_type = String.isBlank(sealApp.Seal_Document_Type__c)?'':sealApp.Seal_Document_Type__c;//盖章文件类别 conner


                String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SealApplicationAdd',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

                if(response.substring(0,5)=='Error'){
                    return response;
                }else{
                    ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                    if (resBody.code == 200) {
                        String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();

                        //先判断是否是驳回状态，用于更新中间表状态
                        Boolean updateMiddleTableSign = false;
                        String findId = '';
                        if (!String.isBlank(sealApp.Process_Id__c)&&(sealApp.Approvalstatus__c=='11'||sealApp.Approvalstatus__c=='10')) {
                            updateMiddleTableSign = true;
                            findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:sealApp.Id AND RecordTypeId =: recTypeId].Id;
                        }
                        Seal_Approval__c updateReq = new Seal_Approval__c();
                        updateReq.Id = sealApp.Id;
                        updateReq.Approvalstatus__c = '20';//提交成功后修改审批状态
                        updateReq.ApplicantionNumber__c = resBody.data.docSubject;
                        update updateReq;   //更新回流程id

                        //插入数据到集成中间表
                        Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                        if (updateMiddleTableSign) {
                            middleForm.id = findId;
                            middleForm.Approvalstatus__c = '20';//审批状态
                            update middleForm;
                        }else {
                            middleForm.RecordTypeId = recTypeId;//赋值记录类型
                            middleForm.Object_API__c = 'Seal_Approval__c';//对象API
                            middleForm.Mapping_Object_Id__c = sealApp.Id;//对应对象的Id
                            middleForm.Scheme_Type__c = null;//方案类型
                            middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                            middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                            middleForm.Approvalstatus__c = '20';//审批状态
                            insert middleForm;
                        }
                        

                        logInfo.RequestURL__c = ext.Request_URL__c;
                        logInfo.ClassName__c = 'Controller_SealApplicationAdd';
                        logInfo.RequestBody__c = JSON.serialize(reqBody);
                        logInfo.RespondBody__c = response;
                        logInfo.IsSuccess__c = true;
                        logInfo.ErrorMessage__c = '';
                        insert logInfo;    
                    }else{
                        logInfo.RequestURL__c = ext.Request_URL__c;
                        logInfo.ClassName__c = 'Controller_SealApplicationAdd';
                        logInfo.RequestBody__c = JSON.serialize(reqBody);
                        logInfo.RespondBody__c = response;
                        logInfo.IsSuccess__c = false;
                        logInfo.ErrorMessage__c = '';
                        insert logInfo;
                        Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                        return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
                    }
                    
                    // insert logInfo;
                }
                return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+sealApp.Process_Id__c+'&loginName='+sealApp.Applicant_Num__c+'&identification=CRM';
            } catch (Exception e) {
                System.debug('错误信息：'+e.getMessage());
                System.debug('错误行：'+e.getLineNumber());
                logInfo.RequestURL__c = ext.Request_URL__c;
                logInfo.ClassName__c = 'Controller_SealApplicationAdd';
                logInfo.RequestBody__c = JSON.serialize(reqBody);
                logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
                insert logInfo;
                Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
            }
        }else {
            return 'NullProcessId';
        }
    }


    public class RequestBody {
        public String fdId{get;set;}//已驳回携带流程id
        public String auditNode{get;set;} //审批意见,示例值(请审批)
        public String docCreator{get;set;} //创建人,示例值(A07068)
        public String fd_apply_dept{get;set;} //申请部门,示例值(1000106)
        public String fd_apply_mobile{get;set;} //	联系电话,示例值(13456578897)	
        public String fd_applyer{get;set;} //	姓名,示例值(A07068)
        // public List<String> fd_file_category{get;set;} //文档类别(1:纸质流程,2:电子流程,3:资质文件),示例值([ "2" ])
        // public List<String> fd_quality_filaname{get;set;} //资质文件名称
        public String fd_remark{get;set;} //	盖章说明,示例值(测试)
        public List<String> fd_seal_admin{get;set;} //	印章保管员,示例值([ "A02323" ])	
        public List<String> fd_seal_compay_name{get;set;} //印章归属公司
        public List<String> fd_seal_name{get;set;} //	印章类别
        public List<String> fd_seal_number{get;set;} //盖章数量,示例值([ "3" ])
        public String fd_seal_safekeep_dept{get;set;} //印章保管部门,示例值(集团总裁办)
        public String n18{get;set;} //流程参数，需传输节点人员：N18.直属领导审批,示例值(A02323)
        public String fd_seal_org{get;set;}//管理单位,可用值:集团总裁办,基地,子公司,海上风电子公司,示例值(集团总裁办)
        public String fd_file_type{get;set;}//合同协议类（未关联合同审批流程）|合同协议类（已关联合同审批流程）|企业工商业务类|对外说明、承诺文件类|财务、行政、人事类|其他业务类
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public Data data{get;set;} 
    }

    public class Data {
        public String docSubject{get;set;}  
        public String fdId{get;set;}  
        public String fdNumber{get;set;}   
        public String rtMsg{get;set;} 
        public String rtStatus{get;set;} 
    } 
}