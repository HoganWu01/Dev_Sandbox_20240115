public without sharing class EmployeeHandler implements Triggers.Handler {

    public void handle() {

        List<String> empIds = new List<String>();

        if (Trigger.isAfter && Trigger.isUpdate) {

            for(Employee__c newEmp : (List<Employee__c>)Trigger.new) {
                Employee__c oldEmp = (Employee__c)Trigger.oldMap.get(newEmp.Id);
                empIds.add(newEmp.id);
            }
        }

        if (empIds.size()>0) {
            Execute(empIds);
        }
    }

    public static void Execute(List<String> empIds){


        //-------------
        List<Employee__c> empList = [SELECT id,
                                            name,
                                            Job_Number__c,
                                            Department__c,
                                            Duty__c,
                                            Department_Number__c,
                                            Status__c,
                                            Mobile_Phone__c
                                            FROM Employee__c WHERE id IN:empIds];

        List<String> JobNumberList  = new List<String>();

        //Map<工号,员工>
        Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();

        for (Employee__c emp : empList) {
            JobNumberList.add(emp.Job_Number__c);

            employeeMap.put(emp.Job_Number__c,emp);
        }

        List<User> userList = [SELECT   id,
                                        name,
                                        Job_Number__c,
                                        Title, //职务
                                        ProfileId,  //简档
                                        Department_Number__c,
                                        MobilePhone,
                                        Department FROM User WHERE Job_Number__c IN:JobNumberList];

        if (userList.size()==0 || userList==null) {
           return ; 
        }

        System.debug('userList---------'+userList);

        //要更新的用户信息集合
        List<User> upUserList = new List<User>();

        for (User user : userList) {

            if (employeeMap.get(user.Job_Number__c) != null) {
                
                User upUser = new User();
                upUser.Id = user.Id;
                upUser.Department = employeeMap.get(user.Job_Number__c)?.Department__c; 
                upUser.Department_Number__c = employeeMap.get(user.Job_Number__c)?.Department_Number__c; 
                upUser.Title = employeeMap.get(user.Job_Number__c)?.Duty__c; 
                upUser.Status__c = employeeMap.get(user.Job_Number__c)?.Status__c; 
                upUser.MobilePhone = employeeMap.get(user.Job_Number__c)?.Mobile_Phone__c;  
    
                upUserList.add(upUser);
            }
        }

        update upUserList ; 
        System.debug('更新用户完成'+upUserList);

         //if (empList[0].Status__c=='离职') {

           // Profile p = [SELECT Id FROM Profile WHERE Name='系统管理员'];


           // System.debug('发送小铃铛通知');
           // Set<String> userIdSet = new Set<String>();
            //User user = [SELECT ID,NAME,Email  FROM USER WHERE name = '吴潮辉 Hogan Wu'];

            //List<User> selectUserList = [SELECT ID,NAME,Email,ProfileId  FROM USER WHERE ProfileId  = :p.id AND IsActive = true];

           // System.debug('系统管理员的用户有'+selectUserList);
            // if (selectUserList!=null &&selectUserList.size()>0) {
            //     for (User user : selectUserList) {
            //         userIdSet.add(user.Id); 
            //     }
                
            // }

            //System.debug('准备发送的用户有'+userIdSet);
            
            // if (userIdSet.size()>0) {
            //     Utils.notifyUsers(userIdSet, empList[0].id, '员工离职通知', '员工'+empList[0].name+'已离职');
            // }
            

            //System.debug('离职状态,发送邮件通知');
            //Set<String> emailSet = new Set<String>();

            //测试发送邮箱
            //Email_Setting__mdt mdt = [select id,email__c from Email_Setting__mdt where DeveloperName = 'irving' ];

            //通知xxx
            //Email_Setting__mdt mdt = [select id,email__c from Email_Setting__mdt where DeveloperName = 'WuChaoHui' ];

            // if (mdt!=null) {
            //     emailSet.add(mdt.email__c);
            // }
            
            // if (emailSet.size()>0) {
            //     sendMail(emailSet,'邮件通知','员工'+empList[0].name+'状态为已离职');  
            // }
            
         //}

    }

        /**
     * @name: 
     * @message: 
     * @param {*}
     * @return {*}
     */    
    // public static void sendMail(Set<String> strs,String subject,String messageBody){
    //     System.debug('strs---------' + strs);
    //     System.debug('subject---------' + subject);
    //     System.debug('messageBody---------' + messageBody);
    //     List<String> toAddStr = new List<String>();
    //     if(strs != null){
    //         for (String str : strs) {
    //             toAddStr.add(str);
    //         }
    //     }
    //     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    //     message.toAddresses = toAddStr;
    //     // message.optOutPolicy = 'FILTER';
    //     message.subject = subject;
    //     message.htmlbody = messageBody;
    //     Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
    //     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    //     System.debug('results---------' + results);
    //     if (results[0].success) {
    //         System.debug('The email was sent successfully.');
    //     } else {
    //         System.debug('The email failed to send: ' + results[0].errors[0].message);
    //     }
    // }
    
}