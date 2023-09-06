/*
 * @Descripttion: 項目发生变更通知信息触发器（项目所有人发生变更、项目名称发生变更）
 * @Author: Hogan
 * @Date: 2023-01-07 11:08:00
 * @LastEditors: Hogan
 * @LastEditTime: 2023-01-07 11:08:00
 */
public without sharing class ProjectNotifyHandler implements Triggers.Handler{

    public void handle() {
        if (Trigger.isAfter && Trigger.isUpdate) {
            System.debug('触发器进来了');
            for(Project__c newPro : (List<Project__c>)Trigger.new) {
                Project__c oldPro = (Project__c)Trigger.oldMap.get(newPro.Id);
                Set<String> userIdSet = new Set<String>();

                //项目所有人变更
                if (newPro.OwnerId != oldPro.OwnerId) {
                    //小铃铛通知
                    userIdSet.add(newPro.OwnerId);//通知项目所有人

                    System.debug('小铃铛通知');
                    if (userIdSet.size()>0) {
                        String content = '您有新的项目分配，项目编号：【'+ newPro.WBS__c +'】，项目名称：【'+ newPro.Name +'】，请及时跟进处理。';
                        Utils.notifyUsers(userIdSet, newPro.id, '项目分配通知',content );
                    }
                }

                //项目名称更新通知
                if(newPro.Name != oldPro.Name){
                    userIdSet.add(newPro.OwnerId);//通知所有人
                    userIdSet.add(newPro.ProjectManager__c);//通知项目经理
                    List<User> userList = [SELECT ID,NAME,UserRoleId  FROM USER WHERE Name in ('娄建宏','甘进力','马晶','郑耿昭','田静') AND IsActive = true] ;
                    if (userList.size()>0) {
                        for (User user : userList) {
                            userIdSet.add(user.Id);//通知相关人员
                        }
                    }

                    List<OpportunityTeamMember> oppTeamList = [SELECT UserId FROM OpportunityTeamMember 
                    WHERE OpportunityId =: newPro.Opportunity__c];
                    if (oppTeamList.size()>0) {
                        for (OpportunityTeamMember oppTeam : oppTeamList) {
                            userIdSet.add(oppTeam.UserId);//通知商机团队成员
                        }
                    }

                    System.debug('小铃铛通知');
                    if (userIdSet.size()>0) {
                        String content = '项目编号为【'+ newPro.WBS__c +'】的项目名称，已经从【'+ oldPro.Name +'】变更为【'+ newPro.Name +'】。';
                        Utils.notifyUsers(userIdSet, newPro.id, '【项目名称】更新通知',content );
                    }
                }
            }
        }
    }
}