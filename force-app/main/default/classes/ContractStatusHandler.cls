/*
 * @Author: irving
 * @Date: 2021-10-14 14:58:38
 * @LastEditTime: 2022-01-19 11:37:24
 * @LastEditors: Please set LastEditors
 * @Description: 更新合同状态 改变时间  --如果存在该项目任务  同步  合同谈判与签订  的 状态和时间
 */
public without sharing class ContractStatusHandler implements Triggers.Handler{
    public void handle() {

        List<String> contractIds = new List<String>();

        //List<String> SyncAccToOppByContractId = new List<String>();

        //新旧合同id
        Map<String,String> SyncAccToOppByContractMap = new Map<String,String>();

        if (Trigger.isAfter && Trigger.isInsert) {
            System.debug('新增触发器进来了');
            for(Contractmanagement__c Contract : (List<Contractmanagement__c>)Trigger.new) {

               
               if(Contract.TaskStatus__c!=null || Contract.TaskStatus__c=='进行中' || Contract.TaskStatus__c=='已完成' ){
                    contractIds.add(Contract.Id);
                }

                //---合同商务下的合同签订主体公司不为空，同步到商机字段：合同签订主体公司  2021-12-08 IRVING
                // if (Contract.Company__c!=null) {
                //     SyncAccToOppByContractId.add(Contract.Id);
                // }
               
            }
        }

        // if (Trigger.isBefore && Trigger.isUpdate) {
        //     for(Contractmanagement__c contract : (List<Contractmanagement__c>)Trigger.new) {
        //       judgeTrade(contract);
        //     }
        // }

        if (Trigger.isAfter && Trigger.isUpdate) {

            System.debug('更新触发器进来了');
            for(Contractmanagement__c newContract : (List<Contractmanagement__c>)Trigger.new) {
                Contractmanagement__c oldContract = (Contractmanagement__c)Trigger.oldMap.get(newContract.Id);
                
                System.debug('newContract.TaskStatus__c'+newContract.TaskStatus__c);
                System.debug('oldContract.TaskStatus__c'+oldContract.TaskStatus__c);
                 //
                 if(newContract.TaskStatus__c!=oldContract.TaskStatus__c &&newContract.TaskStatus__c=='进行中' &&oldContract.TaskStatus__c!='进行中'){
                    System.debug('修改为进行中');
                    contractIds.add(newContract.Id);
                }

                if(newContract.TaskStatus__c!=oldContract.TaskStatus__c &&newContract.TaskStatus__c=='已完成' &&oldContract.TaskStatus__c!='已完成'){
                    System.debug('修改为已经完成');
                    contractIds.add(newContract.Id);
                }

                if(newContract.TaskStatus__c!=oldContract.TaskStatus__c &&newContract.TaskStatus__c=='未开始'){
                    System.debug('修改为未开始');
                    contractIds.add(newContract.Id);
                }


                //---合同商务下的合同签订主体公司不为空，同步到商机字段：合同签订主体公司 && 项目客户 2021-12-08 IRVING
                if (newContract.Company__c!=null &&newContract.Company__c!=oldContract.Company__c) {
                    System.debug('进入准备修改商机主体签订公司');
                    //SyncAccToOppByContractId.add(newContract.Id);
                    SyncAccToOppByContractMap.put(newContract.id, oldContract.id);
                }

            }
        }

        if(contractIds.size()>0){
            excute(contractIds);
        }

        if(SyncAccToOppByContractMap.size()>0){
            SyncAccToOpp(SyncAccToOppByContractMap);
        }
    }


    public void excute(List<String> contractIds) {

        List<Contractmanagement__c> ContractList = [SELECT ID,
                                                            ObjectName__c,   //查找（商机）
                                                            TaskStatus__c,
                                                            ContractNegotiationStartDate__c, //合同谈判开始日期
                                                            //ContractNegotiationEndDate__c //合同谈判完成日期
                                                            ContractSigningEndDate__c   //合同签订完成日期
                                                            FROM Contractmanagement__c
                                                            WHERE ID IN :contractIds];

        List<String>  oppIdList = new List<String>();

        for (Contractmanagement__c contract : ContractList) {
            oppIdList.add(contract.ObjectName__c);
        }

        List<Project__c> projectList = [SELECT ID,NAME FROM Project__c WHERE Opportunity__c IN : oppIdList];

        List<String>  projectIdList = new List<String>();

        for (Project__c pro : projectList) {
            projectIdList.add(pro.Id);
        }

        List<ProjectTask__c> taskList = [SELECT ID,
                                                NAME,
                                                Status__c,     //任务状态
                                                PlannedStartDate__c,
                                                ActualStartDate__c,    //实际开始日期
                                                ActualEndDate__c        //实际结束日期
                                                FROM ProjectTask__c WHERE Project__c IN:projectIdList
                                                AND NAME LIKE '%合同谈判与签订%'];

        System.debug('taskList对应的项目任务'+taskList);

        ProjectTask__c pointTask = new ProjectTask__c();

        for (ProjectTask__c task : taskList) {
            if (task.name.contains('合同谈判与签订')) {
                System.debug('task的id'+task.id);
                System.debug('task'+task);  
                pointTask = task ; 
            }
        }

        System.debug('pointTask指定的项目任务'+pointTask);

        //-----
        List<Contractmanagement__c> updateContract  = new List<Contractmanagement__c>();
        //

        for (Contractmanagement__c con : ContractList) {
            if (con.TaskStatus__c=='进行中') {
                //更新合同商务的时间
                con.ContractNegotiationStartDate__c = Datetime.now().date();
                con.ContractSigningEndDate__c = null;
                updateContract.add(con);

                //更新项目任务的状态、时间 
                if (pointTask!=null) {
                    pointTask.Status__c = '进行中';
                    if ( pointTask.PlannedStartDate__c==null) {
                        pointTask.PlannedStartDate__c = Datetime.now().date();
                    }
                    pointTask.ActualStartDate__c = Datetime.now().date();
                    pointTask.ActualEndDate__c = null;
                }
            }

            if (con.TaskStatus__c=='已完成') {
                //更新合同商务的时间
                if (con.ContractNegotiationStartDate__c==null) {
                    con.ContractNegotiationStartDate__c = Datetime.now().date();
                }
                con.ContractSigningEndDate__c = Datetime.now().date();
                updateContract.add(con);

                 //更新项目任务的状态、时间
                 if (pointTask!=null) {
                    if ( pointTask.PlannedStartDate__c==null) {
                        pointTask.PlannedStartDate__c = Datetime.now().date();
                    }
                    pointTask.Status__c = '已完成';
                    pointTask.ActualEndDate__c = Datetime.now().date();
                    if(pointTask.ActualStartDate__c==null){
                        pointTask.ActualStartDate__c = Datetime.now().date();
                    }
                }
            }

            if (con.TaskStatus__c=='未开始') {
                //更新合同商务的时间
                con.ContractSigningEndDate__c = null;
                con.ContractNegotiationStartDate__c = null;
                updateContract.add(con);

                 //更新项目任务的状态、时间
                 if (pointTask!=null) {
                    pointTask.Status__c = '未开始';
                    pointTask.ActualStartDate__c =null;
                    pointTask.ActualEndDate__c = null;
                }
            }
        }

        //更新合同商务
        update updateContract ; 

        //更新项目任务
        System.debug('pointTask.id'+pointTask);
        if (pointTask.id!=null) {
            update pointTask ; 
            System.debug('更新项目任务完成');
        }
        //update pointTask ; 
        
    }

    /**
     * author: irving
     * 同步合同商务的主体签订公司到商机的主体签订公司
     */
    public void SyncAccToOpp(Map<String,String> SyncAccToOppByContractMap) {

        List<Contractmanagement__c> conList = [select id,
                                                    Company__c,
                                                    ObjectName__c 
                                                    from Contractmanagement__c where id in:SyncAccToOppByContractMap.keySet()];

        // List<Contractmanagement__c> oldContractList = [select id,
        //                                                        Company__c
        //                                                        //ObjectName__c 
        //                                             from Contractmanagement__c where id in:SyncAccToOppByContractMap.values()];


        // System.debug('旧合同的主体签订公司为===》》'+oldContractList[0].Company__c);

        List<String> oppId  = new List<String>();

        if (conList.size()>0) {
            for (Contractmanagement__c c : conList) {
                oppId.add(c.ObjectName__c);
            }  
        }
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<Project__c> proList = new List<Project__c>();

        if (oppId.size()>0) {
            oppList = [select id,ContractSignedCompany__c from Opportunity where id in: oppId] ;
            proList = [select id,Opportunity__c,Account__c,ProjectManager__c,Type__c from Project__c where Opportunity__c in:oppId ];
        }

        if (oppList.size()>0 &&conList.size()>0) {
            oppList[0].ContractSignedCompany__c = conList[0].Company__c ; 
            
            update oppList ; 
        } 

        //修改项目的客户
        System.debug('proList===>>>'+proList);
        System.debug('conList===>>>'+conList);
        if (proList.size()>0 &&conList.size()>0) {
            proList[0].Account__c = conList[0].Company__c ; 
            update proList ; 
            System.debug('修改项目完成');
        }

        
        //给郑部长和项目经理发送小铃铛和邮件通知

        //自定义元素据  郑部长 邮箱
        Email_Setting__mdt mdt = [select id,email__c,DeveloperName from Email_Setting__mdt where DeveloperName = 'zhenggengzhao'] ;

        String recTypeId =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('ProjectType_RecordType').getRecordTypeId();


        Integrated_Middle_Table__c table = new Integrated_Middle_Table__c();

        if (proList.size()>0) {
            table = [SELECT Id,
                            ProjectType__c,
                            RoleName__c
                            FROM Integrated_Middle_Table__c 
                            WHERE RecordTypeId =:recTypeId  
                            AND ProjectType__c = :proList[0].Type__c];
        }

        UserRole userrole = new UserRole();
        if (table.RoleName__c!=null) {
            userrole = [SELECT Id,NAME  FROM UserRole WHERE NAME =: table.RoleName__c];
        }
         
        
        //User user = new User();
        List<User> userList = new List<User>();

        if (table!=null && userrole!=null ) { 
          userList = [SELECT ID,NAME,Email,UserRoleId  FROM USER WHERE UserRoleId =:userrole.Id];
        }

        //User zheng = [select id,email from User where name = '郑耿昭'] ; 

        //测试邮箱
        //Email_Setting__mdt mdt = [select id,email__c,DeveloperName from Email_Setting__mdt where DeveloperName = 'irving'] ;

        //项目经理  小铃铛+邮件通知
        User manage = new User();
        if (proList.size()>0 &&proList[0].ProjectManager__c!=null) {
            manage = [select id,email from User where id  = :proList[0].ProjectManager__c];
        }

        System.debug('小铃铛通知');
        Set<String> userIdSet = new Set<String>();


        Set<String> emailSet = new Set<String>();

        if (userList.size()>0) {
            for (User user : userList) {
                userIdSet.add(user.id);
                if (user.Email!=null) {
                    emailSet.add(user.Email);
                }
            }
            
        }
        
        if (proList.size()>0) {
            if (proList[0].ProjectManager__c!=null) {
                userIdSet.add(proList[0].ProjectManager__c);
            }
        }

        //String oldAccName = '';
        String newAccName = '';

        // if (oldContractList[0].Company__c!=NULL && conList[0].Company__c!=NULL) {
        //     oldAccName =  selectNameById(oldContractList[0].Company__c);
        //     newAccName = selectNameById(conList[0].Company__c);
        // }

        if (conList[0].Company__c!=NULL) {
           
            newAccName = selectNameById(conList[0].Company__c);
        }

        String content = '合同商务的合同签订主体公司发生改变并同步项目中的客户,客户名更新为【'+newAccName+'】';

        // if (String.isBlank(oldAccName)) {
        //     content = '合同商务的合同签订主体公司发生改变并同步项目中的客户,项目客户名为'+newAccName ;
        // }

        if (String.isBlank(newAccName)) {
            content = '合同商务的合同签订主体公司发生改变并同步项目中的客户,项目客户名为空' ;
        }

        //发给郑部长和项目中的项目经理  项目客户改变
        if (proList.size()>0 &&userIdSet.size()>0) {
            Utils.notifyUsers(userIdSet, proList[0].id, '项目客户改动', content);
        }

        System.debug('邮件通知');
        

        //测试邮箱
        // String testEmail  = 'irving.ou@celnet.com.cn' ; 
        // emailSet.add(testEmail);

        if (mdt.email__c!=null) {
            emailSet.add(mdt.email__c);
        }

       

        if (manage!=null &&manage.Email!=null) {
            emailSet.add(manage.Email);
        }
        if (proList.size()>0 &&emailSet.size()>0) {
            String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+proList[0].id ;
            sendMail(emailSet,'项目客户发生改变','项目客户发生改变,详情请点击'+'\r\n'+Recordlink);
        }
         

        

    }

    public static String selectNameById(String accId){
        Account acc = [select id,name from Account where id = :accId];
        return acc.name ; 
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


}