public without sharing class ProjectAppLeaderHandler implements Triggers.Handler {

    public void handle() {

        // List<String> projectAppIds = new List<String>();

        // if (Trigger.isAfter && Trigger.isInsert) {
        //     System.debug('新增项目立项触发器进来了');
        //     for(Projectapplication__c projectApp : (List<Projectapplication__c>)Trigger.new) {
        //         if(projectApp.projectleader__c!=null){
        //             projectAppIds.add(projectApp.id);
        //         }
               
        //     }
        // }

        // if (Trigger.isAfter && Trigger.isUpdate) {

        //     System.debug('更新项目立项触发器进来了');
        //     for(Projectapplication__c newProjectApp : (List<Projectapplication__c>)Trigger.new) {
        //         Projectapplication__c oldProjectApp = (Projectapplication__c)Trigger.oldMap.get(newProjectApp.Id);
                
               
        //          if(newProjectApp.projectleader__c!=oldProjectApp.projectleader__c &&newProjectApp.projectleader__c!=null){
        //             projectAppIds.add(newProjectApp.id);
        //         }

        //     }
        // }

        // if (Trigger.isBefore && Trigger.isDelete) {
        //     System.debug('删除项目立项触发器进来了');
        //     for(Projectapplication__c projectApp : (List<Projectapplication__c>)Trigger.old) {
                
        //             projectAppIds.add(projectApp.id);
                
               
        //     }
        // }

        // if(projectAppIds.size()>0){
        //     excute(projectAppIds);
        // }

    }

    // public void excute(List<String> projectAppIds) {

    //     List<Projectapplication__c> proAppList = new List<Projectapplication__c>();

    //     proAppList = [SELECT ID,
    //                         NAME,
    //                         projectleader__c,  //项目组长提名
    //                         Oppty__c    //查找（商机）
    //                         FROM Projectapplication__c WHERE ID IN :projectAppIds];

    //     System.debug('proAppList==='+proAppList);

    //     if (proAppList==null || proAppList.size()==0) {
    //         return ; 
    //     }

    //     List<String> oppIds = new List<String>();

    //     for (Projectapplication__c proApp : proAppList) {
    //         oppIds.add(proApp.Oppty__c);
    //     }

    //     List<Opportunity> oppList = new List<Opportunity>();

    //     oppList = [SELECT ID,NAME,Appiontleader__c FROM Opportunity WHERE ID IN :oppIds];

    //     System.debug('oppList==='+oppList);

    //     if (oppList==null || oppList.size()==0) {
    //         return ; 
    //     }

    //     oppList[0].Appiontleader__c = proAppList[0].projectleader__c ; 

    //     if (Trigger.isBefore && Trigger.isDelete) {
    //         oppList[0].Appiontleader__c = null ; 
    //         System.debug('oppList[0].Appiontleader__c'+oppList[0].Appiontleader__c);
    //     }

    //     if (oppList[0].id!=null) {
    //         update oppList ; 
    //     }
        
    // }

}