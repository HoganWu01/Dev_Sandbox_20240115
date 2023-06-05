/*
 * @Descripttion: 项目触发器
 * @Author: Devin
 * @Date: 2021-10-26 18:35:08
 * @LastEditors: Devin
 * @LastEditTime: 2021-12-29 17:06:01
 */
public without sharing class Project2Handler implements Triggers.Handler {
    public void handle() {

        // if(Trigger.isBefore && Trigger.isInsert) {
        //     for(Project__c project : (List<Project__c>)Trigger.new) {
        //         //一个商机只能有一条项目立项记录
        //         if (project.Opportunity__c != null) {
        //             Integer records = [SELECT count() FROM Project__c WHERE Opportunity__c =: project.Opportunity__c];
        //             if (records > 0) {
        //                 project.addError('【商机】只能生成一条【项目】!');
        //             }
        //         }
        //     }
        // }

        //插入之后变更所有人为PMO，默认为销售经理/合同专员
        if (Trigger.isAfter && Trigger.isInsert) {
            Set<Id> projectOwnerSet = new Set<Id>();
            for(Project__c project : (List<Project__c>)Trigger.new) {
                projectOwnerSet.add(project.Id);
            }

            if (projectOwnerSet.size() > 0) {
                updateProjectOwner(projectOwnerSet);
            }
        }

        //插入之后共享项目
        if (Trigger.isAfter && Trigger.isInsert) {
            
            //当前用户
            String currentUserId = UserInfo.getUserId();

            //项目共享给业务机会的所有人
            Set<Id> projectIdSet = new Set<Id>();

            //项目共享给项目的创建
            Set<Id> shareProjectCreatedSet = new Set<Id>();

            for(Project__c project : (List<Project__c>)Trigger.new) {

                if (project.Opportunity__c != null) {
                    projectIdSet.add(project.Id);
                }

                //当前用户和分配的项目经理不是同一个人
                if (currentUserId != project.ProjectManager__c) {
                    shareProjectCreatedSet.add(project.Id);
                }
            }
            if (projectIdSet.size() > 0) {
                shareToOpportunityOwner(projectIdSet);
            }

            if (shareProjectCreatedSet.size() > 0) {
                shareToProjectCreated(shareProjectCreatedSet);
            }
        }
    }

    
    /**
     * @Descripttion: 新建【项目】记录 共享给 【商机】的所有人
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public void shareToOpportunityOwner(Set<Id> projectIdSet) {

        List<Project__c> projectList = new List<Project__c>();

        projectList = [SELECT Id,OwnerId,Opportunity__r.OwnerId FROM Project__c WHERE Id IN: projectIdSet];

        List<Project__share> insertList = new List<Project__share>();

        for(Project__c app : projectList) {

            User user = [select id,IsActive from user where id =: app.Opportunity__r.OwnerId];
            if (user.IsActive == true) {
                if (app.OwnerId != app.Opportunity__r.OwnerId) {
                    Project__share share = new Project__share();
                    share.ParentId = app.Id;
                    share.UserOrGroupId = app.Opportunity__r.OwnerId;//分配给商机所有人
                    share.AccessLevel = 'Read';
                    insertList.add(share);
                }
            }
        }

        System.debug('insertList--------'+insertList);

        Database.insert(insertList,true);
    }

    /**
     * @Descripttion: 当创建项目时，项目经理不是当前登录人时，共享项目给创建项目的人
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public void shareToProjectCreated(Set<Id> shareProjectCreatedSet) {

        //当前用户
        String currentUserId = UserInfo.getUserId();

        List<Project__c> projectList = new List<Project__c>();

        projectList = [SELECT Id,OwnerId FROM Project__c WHERE Id IN: shareProjectCreatedSet];

        List<Project__share> insertList = new List<Project__share>();

        for(Project__c app : projectList) {

            if (app.OwnerId != currentUserId) {
                Project__share share = new Project__share();
                share.ParentId = app.Id;
                share.UserOrGroupId = currentUserId;//分配给项目创建人
                share.AccessLevel = 'edit';
                insertList.add(share);
            }
        }

        System.debug('insertList---'+insertList);

        Database.insert(insertList,true);
    }

    public void updateProjectOwner(Set<Id> projectOwnerSet){
        List<Project__c> projectList = [SELECT Id,Type__c,OwnerId FROM Project__c WHERE Id IN: projectOwnerSet];

        for(Project__c pro : projectList) {
            User u = new User();
            if(pro.Type__c == '陆上项目'){
                u = [select id from User where name = '郑耿昭'] ; 
                pro.OwnerId = u.Id;
            } else if (pro.Type__c == '海上项目'){
                u = [select id from User where name = '甘进力'] ;
                pro.OwnerId = u.Id; 
            }else {
                break;
            }
            update pro;
        }
    }
}