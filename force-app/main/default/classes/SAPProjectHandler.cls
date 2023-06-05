/*
 * @Author: irving
 * @Date: 2021-11-02 18:09:47
 * @LastEditTime: 2022-02-15 22:08:13
 * @LastEditors: Please set LastEditors
 * @Description: 项目创建 条件满足 同步sap
 */
public without sharing class SAPProjectHandler implements Triggers.Handler {

    public void handle() {

        List<String> proList = new List<String>();

        String oldProjectName = '';

        String oldOppId = '';

        List<String> SyncAccToProjectByContractId = new List<String>();

        List<String> shareProToOppOwnerList  =new List<String>();

        List<String> wbsSyncContract  =new List<String>();

        if (Trigger.isAfter && Trigger.isInsert) {
            for(Project__c pro : (List<Project__c>)Trigger.new) {
                if(pro.WBS__c!=null){
                    wbsSyncContract.add(pro.id);
                }
            }
        }


        if (Trigger.isAfter && Trigger.isUpdate) {
            for(Project__c newPro : (List<Project__c>)Trigger.new) {
                Project__c oldPro = (Project__c)Trigger.oldMap.get(newPro.Id);
                if (newPro.WBS__c!=oldPro.WBS__c) {
                    wbsSyncContract.add(newPro.id);
                }
            }
        }

        if (wbsSyncContract.size()>0) {
            wbsSyncContractMethod(wbsSyncContract);
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            for(Project__c pro : (List<Project__c>)Trigger.new) {
                if (
                pro.InitialNumOfMachine__c!=null &&
                pro.ProjectCategory__c!=null &&
                pro.StandardProject__c!=null &&
                pro.ProgramYear__c!=null &&
                pro.WBS__c==null &&pro.Projectnumber__c==null) {
                    oldProjectName = pro.name;
                    proList.add(pro.id);
                }

                //新建项目看有没有合同商务，合同商务有没有签订主体公司,有就直接拉取同步到项目客户 2021-12-14 irving
                SyncAccToProjectByContractId.add(pro.id);

               

            }
        }


        if (Trigger.isAfter && Trigger.isUpdate) {
            for(Project__c newPro : (List<Project__c>)Trigger.new) {
                Project__c oldPro = (Project__c)Trigger.oldMap.get(newPro.Id);
                if (
                newPro.InitialNumOfMachine__c!=null &&
                newPro.ProjectCategory__c!=null &&
                newPro.StandardProject__c!=null &&
                newPro.ProgramYear__c!=null &&
                newPro.WBS__c==null &&newPro.Projectnumber__c==null ) {
                    oldProjectName = oldPro.Name ; 
                    proList.add(newPro.id);
                }

                //2.1旧业务机会没有值时，给业务机会赋值，共享项目给业务机会的所有人只读权限
                //2.2旧业务机会有值时，删除原来业务机会Owner对项目的只读权限，给新的业务机会Owner只读权限
                // if (newPro.Opportunity__c!=oldPro.Opportunity__c) {
                //     shareProToOppOwnerList.add(newPro.id);

                //     if (oldPro.Opportunity__c!=null) {
                //         oldOppId = oldPro.Opportunity__c ; 
                //     }
                    
                // }
            }
        }

        //共享权限
        //if (shareProToOppOwnerList.size()>0) {
           // shareProToOppOwner(shareProToOppOwnerList,oldOppId);
            //shareProToOppOwner(shareProToOppOwnerList);
        //}

        if(proList.size() > 0){
            excute(proList,oldProjectName);
        }

        if (SyncAccToProjectByContractId.size()>0) {
            SyncAccToProject(SyncAccToProjectByContractId);
        }

    }

    //共享权限    没做修改处理  在别处已实现
    //public void shareProToOppOwner(List<String> shareProToOppOwnerList) {

        // List<Project__c> proList = [select id,name,Opportunity__c from Project__c where id in :shareProToOppOwnerList];

        // List<Project__share> insertList = new List<Project__share>();

        // List<String> nowOppIdList = new List<String>();

        // for (Project__c p : proList) {
        //     nowOppIdList.add(p.Opportunity__c);
        // }

        // List<Opportunity> oppList = [select id,name,OwnerId from Opportunity where id in :nowOppIdList];

        // List<String> oppOwnerId = new List<String>();
        

        // for (Opportunity opp : oppList) {
        //     oppOwnerId.add(opp.OwnerId);
        // }

        // List<User> uList  =new List<User>();

        // if (oppOwnerId.size()>0) {
        //      uList = [select id,name,IsActive from User where id in :oppOwnerId and IsActive=true];
        // }

        //if (uList.size()>0) {
            //for (User u : uList) {
                //for (Project__c p : proList) {
                    // Project__share share = new Project__share();
                    // share.ParentId = String.valueOf(proList[0].Id) ;
                    // share.UserOrGroupId = uList[0].id;  //分配给现商机所有人 
                    // share.AccessLevel = 'Read';
                    // insertList.add(share);
               // }
            //}
        //}

        //if (insertList.size()>0) {
          // List<Database.SaveResult> t =  Database.insert(insertList,true);
        //}
        //insert insertList ; 
        

        //Opportunity oldOpp  = new Opportunity();
        //如果旧的商机不为空，删除商机所有人的只读权限
        // if (String.isNotBlank(oldOppId)) {
        //     oldOpp = [select id,name,OwnerId from Opportunity where id = :oldOppId];
        // }

       // List<Project__share> deleteList = new List<Project__share>();

        // if (oldOpp!=null &&oldOpp.OwnerId!=null) {
        //     for (Project__c p : proList) {
        //         Project__share share = new Project__share();
        //         share = [select id,ParentId,UserOrGroupId,AccessLevel from Project__share where ParentId=:p.id and UserOrGroupId = :oldOpp.OwnerId and AccessLevel = 'Read'];
        //         if (share!=null) {
        //             deleteList.add(share);
        //         }
                
        //     }
        // }

        // if (deleteList.size()>0) {
        //    List<Database.SaveResult> tt =  Database.delete(insertList,true);
        // }

    //}

    //wbsSyncContract 项目ID  同步wbs到合同wbs
    public void wbsSyncContractMethod(List<String> wbsSyncContract) {

        List<Project__c> projectList = [SELECT ID,                                 
                                                Wbs__c,
                                                Opportunity__c  //商机id
                                                FROM Project__c WHERE ID IN:wbsSyncContract];

        List<String> oppId = new List<String>();

        Map<String,String> oppWbsMap = new Map<String,String>();

         for (Project__c p : projectList) {
            oppId.add(p.Opportunity__c);
            oppWbsMap.put(p.Opportunity__c, p.WBS__c);
        }

        List<Contractmanagement__c> contractList = new List<Contractmanagement__c>();

        if (oppId.size()>0) {
            contractList = [SELECT ID,WBS__c,ObjectName__c FROM Contractmanagement__c WHERE ObjectName__c IN:oppId];
        }

        if (contractList.size()>0) {
            for (Contractmanagement__c c : contractList) {
                c.WBS__c = oppWbsMap.get(c.ObjectName__c);
            }
        }

        update contractList ; 

    }

    public void SyncAccToProject(List<String> SyncAccToProjectByContractId) {


        List<Project__c> projectList = [SELECT ID,
                                                Account__c,
                                                ProjectManager__c,
                                                Type__c,
                                                Opportunity__c  //商机id
                                                FROM Project__c WHERE ID IN:SyncAccToProjectByContractId];


        if (projectList.size()==0) {
            return ; 
        }

        List<String> opplist = new List<String>();

        for (Project__c project : projectList) {
            opplist.add(project.Opportunity__c);
        }

        if (opplist.size()==0 || opplist==null) {
            return ; 
        }


        List<Contractmanagement__c> contractList = [SELECT ID,
                                                            Name,
                                                            Company__c,
                                                            ObjectName__c
                                                            FROM Contractmanagement__c WHERE ObjectName__c IN:opplist];

        System.debug('contractList合同===》》》'+contractList);

        if (contractList.size()==0 || contractList==null) {
            System.debug('项目没有合同商务');
            return ; 
        }

        if (contractList.size()>0) {
            if (contractList[0].Company__c==null) {

                return  ;
            }
        }

        if (contractList.size()>0 && projectList.size()>0 &&contractList[0].Company__c!=null) {
            projectList[0].Account__c = contractList[0].Company__c ;
            update projectList ; 
            System.debug('更新项目客户完成');
        }


        //给郑部长和项目经理发送小铃铛和邮件通知

        //自定义元素据  郑部长 邮箱
        //Email_Setting__mdt mdt = [select id,email__c,DeveloperName from Email_Setting__mdt where DeveloperName = 'zhenggengzhao'] ;

        String recTypeId =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('ProjectType_RecordType').getRecordTypeId();


        Integrated_Middle_Table__c table = new Integrated_Middle_Table__c();

        if (projectList.size()>0) {
            table = [SELECT Id,
                            ProjectType__c,
                            RoleName__c
                            FROM Integrated_Middle_Table__c 
                            WHERE RecordTypeId =:recTypeId  
                            AND ProjectType__c = :projectList[0].Type__c];
        }

        UserRole userrole = [SELECT Id,NAME  FROM UserRole WHERE NAME =: table.RoleName__c];

        List<User> userList = new List<User>();
        //User user = new User();

        if (table!=null && userrole!=null) {
            userList = [SELECT ID,NAME,Email,UserRoleId  FROM USER WHERE UserRoleId =:userrole.Id];
        }

        //测试邮箱
        //Email_Setting__mdt mdt = [select id,email__c,DeveloperName from Email_Setting__mdt where DeveloperName = 'irving'] ;

        //项目经理  小铃铛+邮件通知
        User manage = new User();
        if (projectList.size()>0 &&projectList[0].ProjectManager__c!=null) {
            manage = [select id,email from User where id  = :projectList[0].ProjectManager__c];
        }

        System.debug('小铃铛通知');
        Set<String> userIdSet = new Set<String>();
        // if (user!=null) {
        //     userIdSet.add(user.id);
        // }


        Set<String> emailSet = new Set<String>();

        if (userList.size()>0) {
            for (User user : userList) {
                userIdSet.add(user.id);
                if (user.Email!=null) {
                    emailSet.add(user.Email);
                }
            }
            
        }
        

        if (projectList.size()>0) {
            if (projectList[0].ProjectManager__c!=null) {
                userIdSet.add(projectList[0].ProjectManager__c);
            }
        }

        //String oldAccName = '';
        String newAccName = '';

        // if (oldContractList[0].Company__c!=NULL && conList[0].Company__c!=NULL) {
        //     oldAccName =  selectNameById(oldContractList[0].Company__c);
        //     newAccName = selectNameById(conList[0].Company__c);
        // }

        if (contractList[0].Company__c!=NULL) {
           
            newAccName = selectNameById(contractList[0].Company__c);
        }

        String content = '合同商务的合同签订主体公司发生改变并同步项目中的客户,客户名更新为'+newAccName;

        // if (String.isBlank(oldAccName)) {
        //     content = '合同商务的合同签订主体公司发生改变并同步项目中的客户,项目客户名为'+newAccName ;
        // }

        if (String.isBlank(newAccName)) {
            content = '合同商务的合同签订主体公司发生改变并同步项目中的客户,项目客户名为空' ;
        }

        //发给郑部长和项目中的项目经理  项目客户改变
        if (projectList.size()>0 &&userIdSet.size()>0) {
            Utils.notifyUsers(userIdSet, projectList[0].id, '项目客户改动', content);
        }

        System.debug('邮件通知');
        

        //测试邮箱
        // String testEmail  = 'irving.ou@celnet.com.cn' ; 
        // emailSet.add(testEmail);

       

        if (manage!=null &&manage.Email!=null) {
            emailSet.add(manage.Email);
        }
        if (projectList.size()>0 &&emailSet.size()>0) {
            String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+projectList[0].id ;
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

    public void excute(List<String> proList,String oldProjectName) {

        

        System.debug('合同条件满足，项目创建触发同步SAP');
        System.debug('旧的项目名为'+oldProjectName);

        List<Project__c> projectList = [SELECT ID,
                                                Name,
                                                WBS__c,
                                                Projectnumber__c,
                                                InitialNumOfMachine__c,
                                                ProjectCategory__c,
                                                Type__c,
                                                StandardProject__c,
                                                ProgramYear__c,
                                                Opportunity__c  //商机id
                                                FROM Project__c WHERE ID IN:proList];



        List<String> opplist = new List<String>();

        for (Project__c project : projectList) {
            opplist.add(project.Opportunity__c);
        }

        if (opplist.size()==0 || opplist==null) {
            return ; 
        }



        List<Contractmanagement__c> contractList = [SELECT ID,
                                                            Name,
                                                            TaskStatus__c,
                                                            ObjectName__c,
                                                            Contractname__c
                                                            FROM Contractmanagement__c WHERE ObjectName__c IN:opplist];



        if (contractList.size()==0 || contractList==null) {
            return ; 
        }

        

        if (contractList[0].TaskStatus__c!='已完成' &&contractList[0].Contractname__c==null) {
            return ; 
        }

        if (contractList[0].TaskStatus__c=='已完成' &&contractList[0].Contractname__c!=null) {
           
            //Controller_SAPProjectAdd.SAPProjectAdd(projectList[0].id,oldProjectName);
            //System.debug('调用SAP接口响应完成');

           
           
        }
    }
}