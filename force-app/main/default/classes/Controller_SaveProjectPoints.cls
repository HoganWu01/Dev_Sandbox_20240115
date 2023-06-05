/*
 * @Author: IRVING
 * @Date: 
 * @LastEditors: Devin
 * @LastEditTime: 2022-03-11 17:59:31
 * @Descripttion: 
 */
public without sharing class Controller_SaveProjectPoints {

    @future (callout=true)
    @AuraEnabled
    public static Void SaveProjectPoints(String recordId){

        System.debug('资源节点');

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody reqBody = new RequestBody();  

        External_System_Param__c ext = External_System_Param__c.getValues('oaSaveProjectPoints');

        String response = '';

        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SaveProjectPoints';


            Resource_Development__c resource = [SELECT 
                                                    ID,
                                                    Name,
                                                    ResourceNumber__c,   //编号
                                                    SyncOASuccess__c,
                                                    Stage__c
                                                    FROM Resource_Development__c WHERE ID =:recordId ];


            reqBody.fdCompanyId = '6000';
            reqBody.fdParentNumber = 'points003';
            reqBody.fdType = '05';

            reqBody.fdProjectFullname = resource.name ; 
            reqBody.fdProjectCode = resource.ResourceNumber__c ; 

            Integer num = Integer.valueOf(resource.Stage__c);

            Map<String,String> map_return = new Map<String,String>();
            Map<Integer,String> map_return_Integer = new Map<Integer,String>();


            List<Utils.PickListValue> picklist = Utils.getPickListValue('Resource_Development__c','Stage__c');

            for (Utils.PickListValue pick : picklist) {
                map_return.put(pick.FieldValue, pick.FieldLabel);
                map_return_Integer.put(Integer.valueOf(pick.FieldValue),pick.FieldValue);

            }

            List<Dlist> dlistlist = new List<Dlist>();

            for (Integer i = 0; i < num; i++) {
                Dlist cutlList = new Dlist();

                if (resource.Stage__c=='007') {
                    cutlList.fdDisable = false ; 
                }else{
                    cutlList.fdDisable = true ; 
                }

                cutlList.fdPointCode =  map_return_Integer.get(i+1); 
                cutlList.fdPointName = '资源'+map_return.get(map_return_Integer.get(i+1));
                cutlList.fdProjectId = String.valueOf(resource.id+map_return_Integer.get(i+1));
                dlistlist.add(cutlList);
            }

            reqBody.dlist = dlistlist ; 

            System.debug('JSON.serialize(reqBody)---'+JSON.serialize(reqBody));

            response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SaveProjectPoints',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        

            System.debug('调用成功，response响应结果--->>>>>'+response);

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

                    resource.SyncOASuccess__c = true ; 
                    update resource ; 
                  
                }else{
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
    
        public List<Dlist> dlist;
        public String fdCompanyId;
        public String fdParentNumber;
        public String fdProjectCode;
        public String fdProjectFullname;
        public String fdType;
      
    }


    public class Dlist {
        public Boolean fdDisable;
        public String fdPointCode;
        public String fdPointName;
        public String fdProjectId;
    }


    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public Data data{get;set;} 
    }

    public class Data {}
}