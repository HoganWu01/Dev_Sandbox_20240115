/*
 * @Author: Hogan
 * @Date: 2022-04-14 15:00:00
 * @LastEditTime: 2022-04-14 15:00:00
 * @LastEditors: Hogan
 * @Description: 从OA中拉取产业项目投资

 */
public without sharing class Controller_OA_ProjectInvestment {

    /**
     * @description: 
     * @param {*}
     * @return {*}
     */ 
    @future (callout=true)   
    public static Void OASync(){

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody reqBody = new RequestBody();  

        External_System_Param__c ext = External_System_Param__c.getValues('oaProjectInvestmentList');

        String response = '';
        
        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_OA_ProjectInvestment';

            reqBody.userId = ''; 

            response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OA_ProjectInvestment',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

            logInfo.RequestBody__c = JSON.serialize(reqBody);

            if(response.substring(0,5) == 'Error'){
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                System.debug('responseBody'+resBody);
                logInfo.RespondBody__c = response;
                if (resBody.code == 200) {
                    System.debug('resBody.data---'+resBody.data);  //返回的data
                    logInfo.IsSuccess__c = true; 

                    List<String> pspidList = new List<String>();

                    if(resBody.data != null) {

                        List<ProjectInvestment__c> upsertProject = new List<ProjectInvestment__c>();

                        for (Data d : resBody.data) {
                            ProjectInvestment__c pro = new ProjectInvestment__c();
                            pro.name = d.docSubject;  //流程描述
                            pro.Process_Id__c = d.fdId;  //流程ID
                            pro.UserId__c = d.userId;  //OA申请人工号
                            upsertProject.add(pro);
                        }

                        if (upsertProject.size()>0) {
                            upsert upsertProject Process_Id__c;
                            System.debug('更新产业投资项目完成');
                        }
                    }
                } else {
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                }
                insert logInfo ; 
            }

        }catch(Exception e){

            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug('error---msg'+msg);
            logInfo.IsSuccess__c = false;
            logInfo.RespondBody__c = response;
            logInfo.ErrorMessage__c = '行号:'+e.getLineNumber() + '\n Apex类：'+e.getStackTraceString() + '\n 错误信息:\n' + e.getMessage(); 
            insert logInfo;
        }
    }

    public class RequestBody {
        public String userId{get;set;}   //员工工号
    }
   
    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String fdId{get;set;}   //流程ID
        public String docSubject{get;set;}   //流程名称
        public String userId{get;set;}  //员工工号
    }
}