/*
 * @Author: Hogan
 * @Date: 2022-10-10 09:00:00
 * @LastEditTime: 2022-10-10 09:00:00
 * @LastEditors: Hogan
 * @Description: 从OA中拉取客户/营销分部

 */
public without sharing class Controller_OA_MarketBidDept {

    /**
     * @description: 
     * @param {*}
     * @return {*}
     */ 
    @future (callout=true)   
    public static Void OASync(){

        Interface_Log__c logInfo = new Interface_Log__c();

        External_System_Param__c ext = External_System_Param__c.getValues('oaMarketBidDeptList');

        String response = '';
        
        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_OA_MarketBidDept';

            response = Utils.callOut(null,ext.Request_URL__c,'Controller_OA_MarketBidDept',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

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

                        List<MarketBidDept__c> upsertMarketBidDept = new List<MarketBidDept__c>();

                        for (Data d : resBody.data) {
                            MarketBidDept__c pro = new MarketBidDept__c();
                            pro.CountryType__c = d.fdCountryType;  //国别
                            pro.DeptId__c = d.fdDeptId;  //客户营销分部ID
                            pro.name = d.fdDeptName;  //客户营销分部名称
                            upsertMarketBidDept.add(pro);
                        }

                        if (upsertMarketBidDept.size()>0) {
                            upsert upsertMarketBidDept DeptId__c;
                            System.debug('更新客户/营销分部完成');
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
        public String fdCountryType{get;set;}   //区域公司ID
        public String fdDeptId{get;set;}   //区域公司名称
        public String fdDeptName{get;set;}  //客户营销分部名称
    }
}