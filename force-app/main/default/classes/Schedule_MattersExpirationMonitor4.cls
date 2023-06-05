/*
 * @Author: your name
 * @Date: 2023-04-25 09:00:00
 * @LastEditTime: 2023-04-25 09:00:00
 * @LastEditors: Hogan
 * @Description: 督办事项逾期监控 周期性提醒-每周一8:30
 * @FilePath: \MINGYANG\force-app\main\default\classes\Schedule_MattersExpirationMonitor4.cls
 */
global class Schedule_MattersExpirationMonitor4 implements Schedulable {

    global void execute(SchedulableContext SC) {
        
        //督办事项临期通知

         //计划时间超过今天2天以上
         List<SupervisoryMatters__c> mattersDueList_Current = [SELECT Id,Name,ChargePerson__c,ChargePerson__r.Email,OwnerId,Owner.Email FROM SupervisoryMatters__c  
        WHERE MattersStatus__c = '1' and (ActualCompletionDate__c = null or ApprovalStatus__c = '1') and PlanCompletionDate__c > TODAY and PlanCompletionDate__c > NEXT_N_DAYS:2];
        //  NEXT_N_DAYS:n  超过今天第n天

        if (mattersDueList_Current.size() > 0) {
            List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
            for (SupervisoryMatters__c matters : mattersDueList_Current) {
                List<MattersCollaboration__c> mattersCollList = [SELECT Id, Collaborators__c, Collaborators__r.Email FROM MattersCollaboration__c WHERE SupervisoryMatters__c =: matters.Id];
    
                Set<String> userIdSet = new Set<String>();
                Set<String> emailSet = new Set<String>();
                if (mattersCollList.size()>0) {
                    for (MattersCollaboration__c maColl : mattersCollList) {
                        userIdSet.add(maColl.Collaborators__c);
                        if (maColl.Collaborators__r.Email!=null) {
                            emailSet.add(maColl.Collaborators__r.Email);
                        } 
                    }
                }
                if (matters.ChargePerson__c!=null) {
                    userIdSet.add(matters.ChargePerson__c);
                    if (matters.ChargePerson__r.Email!=null) {
                        emailSet.add(matters.ChargePerson__r.Email);
                    }
                }
                // userIdSet.add(matters.OwnerId);
                // if (matters.Owner.Email!=null) {
                //     emailSet.add(matters.Owner.Email);
                // }

                String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+matters.Id ; 
                String content = '您有以下待处理的督办事项，请及时跟进。点击以查看督办事项：【' +matters.Name+ '】';
                System.debug('督办事项周期提醒内容》》》'+content);

                if (userIdSet.size()>0) {
                    //发送小铃铛通知
                    Utils.notifyUsers(userIdSet, matters.Id, '督办事项提醒',content);
                }

                if (emailSet.size()>0) {
                    //发送邮件通知
                    System.debug('emailSet>>>>>>'+emailSet);
                    // Utils.sendMail(emailSet,'督办事项临期提醒',content);

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    String subject = '督办事项提醒';
                    String body = 'test plain text body...';
                    Id oweaId = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName like '%系统邮件%'][0].Id;
                
                    List<String> toAddStr = new List<String>();
                    if(emailSet != null){
                        for (String str : emailSet) {
                            toAddStr.add(str);
                        }
                    }

                    mail.setToAddresses(toAddStr); 
                    mail.setSubject(subject); 
                    mail.setPlainTextBody(body); 
                    mail.setHtmlBody(content+Recordlink);
                    mail.setOrgWideEmailAddressId(oweaId);
                    mail.setUseSignature(false); 
                    // mail.setReplyTo('test@gmail.com'); 
                
                    listEmails.add(mail);
                }
            }
            if (listEmails.size()>0) {
                Messaging.sendEmail(listEmails);
            }
        }
    }
}