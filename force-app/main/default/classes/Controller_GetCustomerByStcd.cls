/*
 * @Author: irving
 * @Date: 2021-10-18 17:28:10
 * @LastEditTime: 2021-12-01 10:52:38
 * @LastEditors: Please set LastEditors
 * @Description: 查询税号对应的客户
 */
public without sharing class Controller_GetCustomerByStcd {

    public static Void getCustomerByStcd(String taxNum){

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody reqBody = new RequestBody();  

        External_System_Param__c ext = External_System_Param__c.getValues('sapgetCustomerByStcd');

        try {

            System.debug('根据税号查询对应的客户接口进来了');

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_GetCustomerByStcd';

            reqBody.stcd = taxNum ;    //税号

            System.debug('JSON.serialize(reqBody)---'+JSON.serialize(reqBody));

            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_GetCustomerByStcd',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

            System.debug('调用成功，response响应结果--->>>>>'+response);

            logInfo.RequestBody__c = JSON.serialize(reqBody);

            if (response.substring(0,5) == 'Error') {
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                logInfo.RespondBody__c = response;

                if (resBody.code == 200) {
                    System.debug('resBody.data---'+resBody.data);  //返回的data
                    logInfo.IsSuccess__c = true; 

                    for (Data d : resBody.data) {
                        
                    }

                }else {
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                }

                insert logInfo ;
            }

            
        } catch (Exception e) {
            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug(msg);
        }

    }


    public class RequestBody {
        public String stcd;   //税号,示例值(已冻结)
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        // public String ernam{get;set;}   //	创建人工号
        // public String ktokd{get;set;}   //客户账户组
        // public String kunnr{get;set;}   //客户编号
        // public String name1{get;set;}   //客户名称
        // public String stcd5{get;set;}   //税号
        // public String uname{get;set;}   //创建人姓名
    }
}