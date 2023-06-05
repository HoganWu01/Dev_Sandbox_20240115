global class UpdateTaskData implements Database.Batchable<sObject>{
    global final String query;
    global UpdateTaskData(String q) {
        this.query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<ProjectTask__c> updateTask = new List<ProjectTask__c>();
        Integer size = scope.size();
        Date today = Date.today();
        for(Integer i = 0; i < size; ++i){
            ProjectTask__c projectTask = (ProjectTask__c)scope[i];
            projectTask.Today__c = today;
            updateTask.add(projectTask);
        }
        update updateTask;
    }

    global void finish(Database.BatchableContext BC){

    }
}