/*
 * @Author: IRVING
 * @Date: 2021-09-30 09:13:59
 * @LastEditTime: 2021-12-28 10:32:17
 * @LastEditors: Conner
 * @Description: 获取员工基本信息
 */
global without sharing class Controller_OAUser {
    @future(callout=true)
    global static Void OAUser(){
        InterfaceParam__c param = new InterfaceParam__c();
        param = [SELECT Id,Name,SyncDate__c,Approval_Record_Datetime__c FROM InterfaceParam__c WHERE Name = 'OAUser'];
        Interface_Log__c logInfo = new Interface_Log__c();
        RequestBody reqBody = new RequestBody();  
        Boolean isAtt = false;
        External_System_Param__c ext = External_System_Param__c.getValues('oaUser');
        try {
            String nowTime = String.valueOf(Datetime.now());
            if (param != null && param.Approval_Record_Datetime__c != null) {
                reqBody.updateDate = String.valueOf(param.Approval_Record_Datetime__c); 
            }else {
                reqBody.updateDate = String.valueOf(nowTime); 
            }
            
            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OAUser',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

            if(response.substring(0,5) != 'Error'){
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                if (resBody.code == 200) {
                    Set<String> userJobNumInfo = new Set<String>();//存员工工号
                    Map<String,Data> dataMap = new Map<String,Data>(); //key : 工号,value : 员工数据
                    List<Employee__c> existEmpUpdateList = new List<Employee__c>(); //存在的员工，更新
                    List<Employee__c> unExistEmpInsertList = new List<Employee__c>(); //不存在的员工，插入
                    if (resBody?.data!=null) {
                        for (Data da : resBody.data) {
                            if (String.isNotBlank(da.oldUserId)) {
                                userJobNumInfo.add(da.oldUserId);
                                dataMap.put(da.oldUserId, da);
                            }
                        }
                        //查找已存在的员工
                        List<Employee__c> emp = new List<Employee__c>([SELECT Id,Job_Number__c FROM Employee__c WHERE Job_Number__c IN: userJobNumInfo]);
                        for (Employee__c existEmp : emp) {
                            Employee__c upEmp = new Employee__c();
                            upEmp.Id = existEmp.Id;
                            upEmp.Name = dataMap.get(existEmp.Job_Number__c).hrUserName;
                            upEmp.Duty__c = dataMap.get(existEmp.Job_Number__c).hrGwgrade;
                            upEmp.Department__c = dataMap.get(existEmp.Job_Number__c).hrDeptName;
                            upEmp.Department_Number__c = dataMap.get(existEmp.Job_Number__c).hrUserDept;
                            upEmp.Status__c = dataMap.get(existEmp.Job_Number__c).hrUserStatus;
                            upEmp.Gender__c = dataMap.get(existEmp.Job_Number__c).hrUserSex;
                            upEmp.Mobile_Phone__c = dataMap.get(existEmp.Job_Number__c).hrMobileNo;
                            existEmpUpdateList.add(upEmp);
                            dataMap.remove(existEmp.Job_Number__c);
                        }
                        if (!dataMap.isEmpty()) {
                            for (Data da : dataMap.values()) {
                                Employee__c inEmp = new Employee__c();
                                inEmp.Job_Number__c = da.oldUserId;
                                inEmp.Name = da.hrUserName;
                                inEmp.Duty__c = da.hrGwgrade;
                                inEmp.Department__c = da.hrDeptName;
                                inEmp.Department_Number__c = da.hrUserDept;
                                inEmp.Status__c = da.hrUserStatus;
                                inEmp.Gender__c = da.hrUserSex;
                                inEmp.Mobile_Phone__c = da.hrMobileNo;
                                unExistEmpInsertList.add(inEmp);
                            }
                        }
                        update existEmpUpdateList;
                        insert unExistEmpInsertList;
                    }
                    //更新获取员工基本信息的时间
                    InterfaceParam__c newParam = new InterfaceParam__c();
                    newParam.Id = param.Id;
                    newParam.Approval_Record_Datetime__c = Datetime.valueOf(nowTime);
                    update newParam;

                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAUser';
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
                    logInfo.ClassName__c = 'Controller_OAUser';
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

        }catch(Exception e){
            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_OAUser';
            logInfo.RequestBody__c = JSON.serialize(reqBody);
            logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
        }
 
    }

    public class RequestBody {
        public String updateDate{get;set;}   //时间,示例值(2021-08-01 00:00:00)
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String hrDeptName{get;set;}  //员工部门名称
        public String hrGwgrade{get;set;}     //职级
        public String hrTimestamp{get;set;}   //HR操作变更时间
        public String hrUserDept{get;set;} //员工部门编码
        public String hrUserName{get;set;}  //用户名
        public String hrUserSex{get;set;}   //姓别
        public String hrUserStatus{get;set;} //员工状态
        public String oldUserId{get;set;}  //员工工号
        public String hrMobileNo{get;set;}  //手机号
    } 
}