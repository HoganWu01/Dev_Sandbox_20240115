/*
 * @Author: IRVING
 * @Date: 
 * @LastEditTime: 2022-01-13 17:44:05
 * @LastEditors: Please set LastEditors
 * @Description: 找到资源中同步oa字段为false的定时调oa接口
 */
global without sharing class Batch_SyncResourceOA implements Database.batchable<SObject>,Database.AllowsCallouts {
     /**
     * @description: 
     * @param {*}
     * @return {*}
     */    
   

    global Database.QueryLocator start(Database.BatchableContext bc) {
      
        return Database.getQueryLocator([SELECT Id,SyncOASuccess__c FROM Resource_Development__c WHERE SyncOASuccess__c = false AND ResourceNumber__c != NULL]);
    }

    global void execute(Database.BatchableContext BC, List<Resource_Development__c> resources) {

       

       if (resources.size()>0) {

        for (Resource_Development__c resource : resources) {
            System.enqueueJob(new QueableUpdate(resource.id));
           
        }
        
       }

    }

    global void finish(Database.BatchableContext BC) {

    }



    public class QueableUpdate implements Queueable {
        public String rId;
        public QueableUpdate(String rId){
            this.rId = rId;
        }
        public void execute(QueueableContext context){
            Controller_SaveProjectPoints.SaveProjectPoints(rId);

        }
    } 


    
}