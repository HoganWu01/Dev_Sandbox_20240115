/*
 * @Author: IRVING
 * @Date: 2021-09-30 14:45:25
 * @LastEditTime: 2022-03-09 11:10:34
 * @LastEditors: Devin
 * @Description: 项目维护更新  从SAP中拉取项目数据

 */
public without sharing class Controller_SAPProjectMainTain {

    /**
     * @description: 
     * @param {*}
     * @return {*}
     */ 
    @future (callout=true)   
    public static Void SAPProjectMainTain(){

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody reqBody = new RequestBody();  


        External_System_Param__c ext = External_System_Param__c.getValues('sapProject');

        InterfaceParam__c ipc  = [SELECT Id,NAME,SyncDate__c FROM InterfaceParam__c WHERE NAME = 'sapProject' AND SyncDate__c!=null] ; 

        String response = '';
        
        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAPProjectMainTain';

            Datetime interDate =  ipc.SyncDate__c ; 

            reqBody.updateDate = interDate.format('yyyy-MM-dd')  ; 

            response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SAPProjectMainTain',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

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

                    Map<String,String> standardMap = new Map<String,String>();
                    List<String> pspidList = new List<String>();

                    Map<String,String> IdNameMap = new Map<String,String>();
                    Map<String,String> IdCompanyCodeMap = new Map<String,String>();
                    Map<String,String> IdwerkMap = new Map<String,String>();

                    if(resBody.data != null) {

                        for (Data s : resBody.data) {
                            pspidList.add(s.pspid);      //项目wbs集合
                            IdNameMap.put(s.pspid, s.post1);     //项目wbs-项目名字
                            IdCompanyCodeMap.put(s.pspid, s.vbukr);    //项目公司代码
                        }

                        List<Project__c> projectList = [SELECT Id,
                                                                Name,
                                                                WBS__c,
                                                                Projectnumber__c,
                                                                Opportunity__c,
                                                                Ownedcompany__c
                                                            FROM
                                                                Project__c
                                                            WHERE
                                                                WBS__c != NULL
                                                            AND
                                                                WBS__c IN: pspidList];

                        List<Project__c> updateProject = new List<Project__c>();

                        if (projectList.size()>0) {
                            for (Project__c pro :  projectList) {
                                pro.Name = IdNameMap.get(pro.WBS__c);  //项目编号--name
                                updateProject.add(pro);
                            }
                        }

                        if (updateProject.size()>0) {
                            update updateProject ;
                            System.debug('更新项目完成');
                        }
                    }

                    //更新接口参数表时间
                    ipc.SyncDate__c = System.toDay() ;
                    update ipc ;

                    System.debug('更新时间完成');

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
        public String updateDate{get;set;}   //日期(格式yyyy-MM-dd),示例值(2021-08-01)
    }
   
    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String aedat{get;set;}   //最后更改日期   20211009
        public String astna{get;set;}   //申请人姓名
        public String astnr{get;set;}   //申请人编号   00000000
        public String plfaz{get;set;}   //项目计划开始日期   20210914
        public String plsez{get;set;}   //	项目计划完成日期   20210914
        public String post1{get;set;}   //	项目名称描述    CRMTEST001
        public String prctr{get;set;}   //	利润中心   MY1000
        public String pspid{get;set;}   //标准项目   S120210016
        public String vbukr{get;set;}   //公司代码   6000
        public String verna{get;set;}   //负责人姓名   程家晚
        public String vernr{get;set;}   //负责人编号   10000001
        public String werks{get;set;}   //工厂代码
    }
}