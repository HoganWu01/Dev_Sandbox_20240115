/**
 * Created by zhangwei on 2019/9/11.
 */

global class ProjectSchedule implements Schedulable{
    global void execute(SchedulableContext sc){
        String qry_str = '';
        Set<Project__c> projects = new Set<Project__c>([SELECT Id FROM Project__c WHERE IsClosed__c = False ]);
        Integer count = 0;
        Integer length = projects.size();
        for(Project__c project : projects){
            qry_str += ('\'' + project.Id + '\'');
            if( ++count == length){
                break;
            }
            qry_str +=  ',';
        }

        String queryCollection = 'SELECT Id, Today__c FROM ProjectCollection__c WHERE Project__c IN (' + qry_str + ')';
        Database.executeBatch(new UpdateCollectionData(queryCollection), 200);

        String queryTask = 'SELECT Id,Today__c FROM ProjectTask__c WHERE Project__c IN (' + qry_str + ')';
        Database.executeBatch(new UpdateTaskData(queryTask), 200);
    }
}