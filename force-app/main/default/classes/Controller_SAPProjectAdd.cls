/*
 * @Author: IRVING
 * @Date: 2021-09-26 10:41:00
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-01-19 11:35:09
 * @Descripttion: 项目创建
 */
global without sharing class Controller_SAPProjectAdd {
    
    //@AuraEnabled
    @future (callout=true)
    global static Void SAPProjectAdd(String recordId,String oldProjectName){

        System.debug('旧的项目名为'+oldProjectName);

        Interface_Log__c logInfo = new Interface_Log__c();


        Project__c pro = new Project__c();

        pro = [SELECT   Id,Name,
                            OwnerId,
                            WBS__c,	Projectnumber__c,
                            InitialNumOfMachine__c,
                            ProjectCategory__c,    //项目类别
                            Type__c,       //项目类型
                            SyncSapMsg__c,
                            StandardProject__c,
                            ProgramYear__c ,
                            Opportunity__c
                            FROM Project__c Where Id = : recordId] ; 

        String recTypeId =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('ProjectType_RecordType').getRecordTypeId();

        Integrated_Middle_Table__c table = [SELECT Id,
                                                    ProjectType__c,
                                                    RoleName__c
                                                    FROM Integrated_Middle_Table__c 
                                                    WHERE RecordTypeId =:recTypeId  
                                                    AND ProjectType__c = :pro.Type__c];

         UserRole  userrole = [select id,name FROM UserRole WHERE Name = :table.RoleName__c];

         List<User> userList = new List<User>();

         userList = [SELECT ID,NAME,Email,UserRoleId  FROM USER WHERE UserRoleId =:userrole.id] ;

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE id =:table.ProjectPrincipal__c];

        //User user = [SELECT ID,NAME,Email  FROM USER WHERE name ='郑梗昭'];

        RequestBody reqBody = new RequestBody();  

        External_System_Param__c ext = External_System_Param__c.getValues('sapProjectAdd');

        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAPProjectAdd';

            if(pro==null){
                logInfo.IsSuccess__c = false;
                logInfo.ErrorMessage__c = '找不到项目'; 
                insert logInfo ; 
                return ; 
            }

            String oppId = '';
            if (pro.Opportunity__c!=NULL) {
                oppId = pro.Opportunity__c ; 
            }

            Contractmanagement__c contract = new Contractmanagement__c();

            if (String.isNotBlank(oppId)) {

                contract = [SELECT ID,
                                Name,
                                TaskStatus__c,
                                ObjectName__c,
                                Contractname__c,
                                WBS__c 
                                FROM Contractmanagement__c WHERE ObjectName__c =:oppId];
            }

            if (contract!=null &&contract.Contractname__c!=null &&contract.TaskStatus__c=='已完成') {
                reqBody.post1 = contract.Contractname__c ;   //合同名
            }else{
                reqBody.post1 = pro.Name ;     //项目名
            }

            reqBody.pnum = Integer.valueof(pro.InitialNumOfMachine__c )  ; 
            reqBody.prart = pro.ProjectCategory__c ; 
            reqBody.pspid = pro.StandardProject__c ; //标准项目
            
            if (pro.ProgramYear__c==null) {
                reqBody.pyear = Datetime.now().year();
            }else{
                reqBody.pyear = Integer.valueof(pro.ProgramYear__c)  ; 
            }
            

            System.debug('JSON.serialize(reqBody)---'+JSON.serialize(reqBody));

            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SAPProjectAdd',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        

            System.debug('调用成功，response响应结果--->>>>>'+response);

            logInfo.RequestBody__c = JSON.serialize(reqBody);

            if(response.substring(0,5) == 'Error'){
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                logInfo.RespondBody__c = response;
                if (resBody.code == 200) {
                    System.debug('resBody.data---'+resBody.data);  //返回data

                    if (resBody.data==null || resBody.data.size()==0) {
                        logInfo.IsSuccess__c = false;
                        logInfo.ErrorMessage__c = '返回数据为空';
                        System.debug('resBody.data===》》'+resBody.data);
                        pro.SyncSapMsg__c = resBody.message;
                        update pro ; 
                        System.debug('pro.SyncSapMsg__c========>>>>'+pro.SyncSapMsg__c);
                        insert logInfo ; 
                        return ; 
                    }

                    System.debug('resBody.message========>>>>'+resBody.message);
                    logInfo.IsSuccess__c = true; 

                    Data rd = resBody.data[0];

                    pro.Projectnumber__c = rd.pspid  ;   //项目编号
                    pro.WBS__c = rd.pspid ; 
                    pro.Name =  rd.post1 ; 
                    pro.SyncSapMsg__c = resBody.message;

                    if (pro.ProgramYear__c==null) {
                        pro.ProgramYear__c = Datetime.now().year();
                    }
                    update pro ; 
                    System.debug('更新项目完成');
                    System.debug('pro.SyncSapMsg__c========>>>>'+pro.SyncSapMsg__c);


                    //2021-12-7  更新合同商务的 wbs号     
                    if (contract!=null) {
                        contract.WBS__c = rd.pspid ; 
                        update contract ; 
                    }

                    Set<String> userIdSet = new Set<String>();
                    if (userList.size()>0) {
                        for (User user : userList) {
                            userIdSet.add(user.id);
                        }
                        
                    }
                   

                    String content = '你的项目已经成功同步到SAP,项目名由【'+oldProjectName+'】更新为【'+reqBody.post1+'】';
                    System.debug('内容content==========》》》'+content);
                    //String content = '你的项目已经成功同步到SAP,项目名更新为'+reqBody.post1;

                    System.debug('小铃铛通知');
                    if (userIdSet.size()>0) {
                        Utils.notifyUsers(userIdSet, pro.id, '同步SAP项目成功',content );
                    }
                    

                    System.debug('邮箱通知');
                    Set<String> emailSet = new Set<String>();

                    //测试邮箱
                    //String testEmail  = 'irving.ou@celnet.com.cn' ; 
                    //emailSet.add(testEmail);

                    if (userList.size()>0) {
                        for (User user : userList) {
                            emailSet.add(user.email); 
                        }
                    }
                    
                    String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+pro.id ; 

                    if (emailSet.size()>0) {
                     sendMail(emailSet,'同步SAP项目成功','你的项目已经成功同步到SAP,项目名已更改,项目名更新为【'+reqBody.post1+'】,详情请点击'+'\r\n'+Recordlink);
                    }
                   
                    System.debug('发送邮件完成');

                }else{
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                    
                    pro.SyncSapMsg__c = resBody.message;
                    update pro ; 
                }
                insert logInfo ; 


            }

        }catch(Exception e){
            System.debug(e.getMessage());
            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug('error---msg'+msg);
        }


    }

    /**
     * @name: 
     * @message: 
     * @param {*}
     * @return {*}
     */    
    public static void sendMail(Set<String> strs,String subject,String messageBody){
        System.debug('strs---------' + strs);
        System.debug('subject---------' + subject);
        System.debug('messageBody---------' + messageBody);
        List<String> toAddStr = new List<String>();
        if(strs != null){
            for (String str : strs) {
                toAddStr.add(str);
            }
        }
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = toAddStr;
        // message.optOutPolicy = 'FILTER';
        message.subject = subject;
        message.htmlbody = messageBody;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        System.debug('results---------' + results);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }

    public class RequestBody {
        public Integer pfrom{get;set;} //起始号
        public String plfaz{get;set;} //项目计划开始日期
        public String plsez{get;set;} //项目计划完成日期
        public Integer pnum{get;set;} //风机台数,示例值(1)
        public String post1{get;set;} //项目名称描述,示例值(S1-20210020)
        public String prart{get;set;} //项目类型,示例值(S1)
        public String pspid{get;set;} //标准项目,示例值(L1-20120000)	
        public Integer pyear{get;set;} //项目年度,示例值(2021)

    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String message{get;set;}  //提示信息
        public String obj{get;set;}     //出错阶段
        public String post1{get;set;}   //项目描述
        public String pspid{get;set;} //项目定义
        public String type{get;set;}  //消息类型(S 成功,E 错误,W 警告 I信息 A 中断)
    } 
}