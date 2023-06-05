public with sharing class LwcProjectController {
    public LwcProjectController() {

    }

    /**
     * 获取项目相关任务。
     */
    @AuraEnabled(cacheable=true)
    public static List<ProjectTask__c> getRelatedTasks(String projectId) {
        return [SELECT Id, Name, PreTask2__c, PreInterval__c, PlannedStartDate__c, PlannedNumOfDays__c, PlannedEndDate__c, Number__c 
                FROM ProjectTask__c 
                WHERE Project__c = :projectId 
                ORDER BY Number__c];
    }

    /**
     * 更新项目相关任务。
     */
    @AuraEnabled
    public static void updateRelatedTasks(List<ProjectTask__c> tasks){
        update tasks;
    }
}