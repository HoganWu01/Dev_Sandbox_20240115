/*
 * @Author: Hogan
 * @Date: 2022-10-09 09:00:00
 * @LastEditTime: 2022-10-09 09:00:00
 * @LastEditors: Hogan
 * @Description: 从OA中拉取项目所属区域

 */
public without sharing class Controller_OA_ProjectArea {

    /**
     * @description: 
     * @param {*}
     * @return {*}
     */ 
    @future (callout=true)   
    public static Void OASync(){
        Interface_Log__c logInfo = new Interface_Log__c();
        External_System_Param__c ext = External_System_Param__c.getValues('oaMarketGroupList');
        String response = '';
        try {
            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_OA_ProjectArea';

            response = Utils.callOut(null,ext.Request_URL__c,'Controller_OA_ProjectArea',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
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
                    if(resBody.data != null) {
                        List<ProjectArea__c> insertProArea = new List<ProjectArea__c>();
                        for (Data d : resBody.data) {
                            ProjectArea__c pro = new ProjectArea__c();
                            pro.fdid__c = d.fdId;  //记录ID
                            pro.name = d.fdGroupName;  //项目所属区域名称
                            pro.AreaId__c = d.fdGroupId;  //区域公司ID
                            pro.AreaPerson__c = d.fdLeaderName;  //区域负责人
                            pro.AreaPersonId__c = d.fdLeaderId;  //区域负责人ID
                            insertProArea.add(pro);
                        }

                        if (insertProArea.size()>0) {
                            upsert insertProArea fdid__c;
                            System.debug('更新项目所属区域完成');
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
    }
   
    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String fdId{get;set;}   //记录ID
        public String fdGroupId{get;set;}   //区域公司ID
        public String fdGroupName{get;set;}   //区域公司名称
        public String fdLeaderId{get;set;}  //负责人ID
        public String fdLeaderName{get;set;}  //负责人名称
    }
}