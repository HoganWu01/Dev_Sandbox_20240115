/*
 * @Author: your name
 * @Date: 2021-10-18 17:27:16
 * @LastEditTime: 2021-12-30 16:16:48
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \MINGYANG\force-app\main\default\classes\Controller_SAPGetCustomerNum.cls
 */
public without sharing class Controller_SAPGetCustomerNum {
   

    @AuraEnabled
    public static Map<Object,Object> getCustomerNum(String accGroup){


        Map<Object,Object> map_return = new Map<Object,Object>();

        map_return.put('type','S');
        map_return.put('messages','返回成功');

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody req = new RequestBody();  

        External_System_Param__c ext = External_System_Param__c.getValues('sapgetCustomerNum');

        try {

            System.debug('查询客户最新编码接口进来了');

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAPGetCustomerNum';

            req.account = accGroup ;    //账户分配组

            System.debug('JSON.serialize(req)---'+JSON.serialize(req));

            String response = Utils.callOut(JSON.serialize(req),ext.Request_URL__c,'Controller_SAPGetCustomerNum',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

            System.debug('调用成功，response响应结果--->>>>>'+response);

            logInfo.RequestBody__c = JSON.serialize(req);

            if (response.substring(0,5) == 'Error') {
                logInfo.RespondBody__c = response;
                insert logInfo;
                map_return.put('type','E');
                map_return.put('messages','接口响应失败');
                return map_return;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                logInfo.RespondBody__c = response;

                if (resBody.code == 200) {
                    logInfo.IsSuccess__c = true; 
                    map_return.put('messages','返回成功');

                    map_return.put('accNum',resBody.data);
                    System.debug('成功调用===》返回最新编号为'+resBody.data);

                }else {
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                }

                insert logInfo ;
            }

            
        } catch (Exception e) {
            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug(msg);
            map_return.put('type','E');
            map_return.put('messages','提交失败, 请联系系统管理员! 错误信息:'+e.getMessage());
        }

        return map_return; 

    }

    


    @AuraEnabled 
    public static Map<Object,Object> getAccGroupList(){

        Map<Object,Object> map_return = new Map<Object,Object>();

        List<Utils.PickListValue> picklist = Utils.getPickListValue('Account','CustomerAccountGroup__c');

        map_return.put('picklist',picklist);
        return map_return ; 
        
    }


    public class RequestBody {
        public String account;   //客户帐户组,示例值(ZD99)	
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public String data{get;set;} 
    }

    
}