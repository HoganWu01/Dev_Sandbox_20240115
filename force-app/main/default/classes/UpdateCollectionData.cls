global class UpdateCollectionData implements Database.Batchable<sObject>{
    global final String query;
    global UpdateCollectionData(String q) {
        this.query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<ProjectCollection__c> updateCollection = new List<ProjectCollection__c>();
        Integer size = scope.size();
        Date today = Date.today();
        for(Integer i = 0; i < size; ++i){
            ProjectCollection__c projectCollection = (ProjectCollection__c)scope[i];
            projectCollection.Today__c = today;
            updateCollection.add(projectCollection);
        }
        update updateCollection;
    }

    global void finish(Database.BatchableContext BC){

    }
}