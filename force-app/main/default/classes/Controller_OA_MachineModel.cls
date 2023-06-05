/*
 * @Author: zxg
 * @Date: 2022-10-14 09:00:00
 * @LastEditTime: 2022-10-14 09:00:00
 * @LastEditors: zxg
 * @Description: 从OA中拉取主机型
 */

public without sharing class Controller_OA_MachineModel {

    /**
     * @description: 
     * @param {*}
     * @return {*}
     */ 
    @future (callout=true)   
    public static Void OASync(){
        Interface_Log__c logInfo = new Interface_Log__c();
        External_System_Param__c ext = External_System_Param__c.getValues('oaMarketBidMachineList');
        String response = '';
        try {
            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_OA_MachineModel';

            response = Utils.callOut(null,ext.Request_URL__c,'Controller_OA_MachineModel',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
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
                        List<MachineModel__c> insertMachineModel = new List<MachineModel__c>();
                        for (String model : resBody.data) {
                            MachineModel__c machine = new MachineModel__c();
                            machine.name = model;  //主机型
                            insertMachineModel.add(machine);
                        }

                        if (insertMachineModel.size()>0) {
                            List<MachineModel__c> MachineModelList = new List<MachineModel__c>([SELECT Id FROM MachineModel__c]);
		                    delete MachineModelList;
                            insert insertMachineModel;
                            System.debug('更新主机型完成');
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
        public List<String> data{get;set;} 
    }

    public class Data {
    }
}