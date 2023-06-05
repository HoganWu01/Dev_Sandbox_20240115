public with sharing class ProjectCreateStageHandler implements Triggers.Handler {

    public void handle() {

        
        //更新之后
        if (Trigger.isAfter && Trigger.isInsert) {
            
            List<String> projectIds = new List<String>();

            System.debug('项目创建触发器进来了');
            for(Project__c project : (List<Project__c>)Trigger.new) {
                projectIds.add(project.Id);
            }

            if (projectIds.size()>0) {
                Execute(projectIds);
            }
        }

    }

    public static void Execute(List<String> projectIds){

        List<ProjectStage__c> stageList = [SELECT ID,NAME FROM ProjectStage__c WHERE Project__c IN :projectIds];

        List<ProjectStage__c> stages = new List<ProjectStage__c>();
        if (stageList.size()==0) {
            stages.add(new ProjectStage__c(Name='合同商务', Project__c=projectIds[0], Number__c='1'));
            stages.add(new ProjectStage__c(Name='生产准备', Project__c=projectIds[0], Number__c='2'));
            stages.add(new ProjectStage__c(Name='制造及交付', Project__c=projectIds[0], Number__c='3'));
            stages.add(new ProjectStage__c(Name='吊装及预验收', Project__c=projectIds[0], Number__c='4'));
        }
        insert stages ; 
        System.debug('id为'+projectIds[0]+'的项目阶段已新建');
    }

}