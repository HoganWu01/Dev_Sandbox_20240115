/*
 * @Author: Conner
 * @Date: 2021-10-19 09:25:35
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-01-25 19:29:44
 * @Descripttion: 营销项目立项触发器
 */
trigger ProjectapplicationTrigger on Projectapplication__c(before insert, before update, before delete, after insert, after update, after delete ) {
    List<Trigger__mdt> mc = [select id,DeveloperName,IsActive__c from Trigger__mdt where DeveloperName = 'ProjectapplicationTrigger'] ;

    // Trigger__mdt mc = Trigger__mdt.getInstance('ProjectapplicationTrigger');
    if (mc.size() == 0 || mc[0].IsActive__c) {
        new Triggers()
        .bind(Triggers.Evt.afterupdate, new ProjectapplicationTriggerHandler.SendNotifyToOwner())
        .bind(Triggers.Evt.afterInsert, new ProjectapplicationTriggerHandler.AssignToOpportunity())
        .bind(Triggers.Evt.beforeInsert, new ProjectapplicationTriggerHandler.cheakRecords())
        .bind(Triggers.Evt.afterInsert, new ProjectapplicationTriggerHandler.SyncOppCompetitorToPA())
        .bind(Triggers.Evt.beforeupdate, new ProjectapplicationTriggerHandler.cheakStatusRecords())
        .bind(Triggers.Evt.afterInsert, new ProjectapplicationTriggerHandler.contractOppTeamMember())
        .bind(Triggers.Evt.afterupdate, new ProjectapplicationTriggerHandler.contractOppTeamMember())
        .execute();

        ProjectapplicationTriggerHandler proAppHandler = new ProjectapplicationTriggerHandler();
        if (Trigger.isBefore) {
            if (Trigger.isUpdate) {
                //每次更新立项，都重新配置大区总经理和大客户总经理
                List<Projectapplication__c> appUpdateList = new List<Projectapplication__c>();
                for (Projectapplication__c app : (List<Projectapplication__c>)Trigger.new) {
                    appUpdateList.add(app);
                    // if (app.Salesdepartment__c!=null && app?.Manager_Secondary_Company__c==null) {
                    //     appUpdateList.add(app);
                    // }
                    // if (app.MarketBidDept__c!=null && app?.General_Manager__c==null) {
                    //     appUpdateList.add(app);
                    // }
                }
                if (appUpdateList.size()>0) {
                    proAppHandler.autoSetValueTrigger(appUpdateList);
                }
            }
        }
        if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                List<Projectapplication__c> schemeUpdateList = new List<Projectapplication__c>();
                List<Projectapplication__c> schemeUpdate11List = new List<Projectapplication__c>();
                for (Projectapplication__c scheme : (List<Projectapplication__c>)Trigger.new) {
                    Projectapplication__c old = (Projectapplication__c) Trigger.oldMap.get(scheme.Id);
                    //审批状态修改并且审批状态为审批中
                    if (scheme.Approvalstatus__c!=old.Approvalstatus__c&& (scheme.Approvalstatus__c=='20' || scheme.Approvalstatus__c=='30')) {
                        schemeUpdateList.add(scheme);
                    }
                    //审批状态修改并且审批状态为已驳回
                    if (scheme.Approvalstatus__c!=old.Approvalstatus__c&& (scheme.Approvalstatus__c=='11'||scheme.Approvalstatus__c=='10')) {
                        schemeUpdate11List.add(scheme);
                    }
                }
                if (schemeUpdateList.size()>0) {
                    proAppHandler.autoLockTrigger(schemeUpdateList);
                }
                if (schemeUpdate11List.size()>0) {
                    proAppHandler.autoUnLockTrigger(schemeUpdate11List);
                }
            }
        }
    }
}