/*
 * @Author: irving
 * @Date: 2021-10-20 15:15:53
 * @LastEditTime: 2021-12-22 17:33:43
 * @LastEditors: Please set LastEditors
 * @Description: 项目任务为合同谈判与签订的  状态时间同步指定项目下的合同商务的状态与时间
 */
public without sharing class PointTaskStatusHandler implements Triggers.Handler{
    
    public void handle() {

        List<String> taskIds = new List<String>();

        if (Trigger.isAfter && Trigger.isInsert) {
            System.debug('新增项目任务触发器进来了');
            for(ProjectTask__c task : (List<ProjectTask__c>)Trigger.new) {

                if (task.name.contains('合同谈判与签订') ) {
                        taskIds.add(task.id);
                }   
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {

            System.debug('更新触发器进来了==========>>>>>>>');
            for(ProjectTask__c newTask : (List<ProjectTask__c>)Trigger.new) {
                ProjectTask__c oldTask = (ProjectTask__c)Trigger.oldMap.get(newTask.Id);
                
                System.debug('newTask.Status__c'+newTask.Status__c);
                System.debug('oldTask.Status__c'+oldTask.Status__c);
                 //
                 if(newTask.name.contains('合同谈判与签订')&& newTask.Status__c!=oldTask.Status__c &&newTask.Status__c=='进行中' &&oldTask.Status__c!='进行中'){
                    System.debug('修改为进行中');
                    taskIds.add(newTask.Id);
                }

                if(newTask.name.contains('合同谈判与签订')&&newTask.Status__c!=oldTask.Status__c &&newTask.Status__c=='已完成' &&oldTask.Status__c!='已完成'){
                    System.debug('修改为已经完成');
                    taskIds.add(newTask.Id);
                }

                if(newTask.name.contains('合同谈判与签订')&&newTask.Status__c!=oldTask.Status__c &&newTask.Status__c=='未开始' &&oldTask.Status__c!='未开始'){
                    System.debug('修改为未开始');
                    taskIds.add(newTask.Id);
                }

            }
        }

        if(taskIds.size()>0){
            excute(taskIds);
        }

    }

    public void excute(List<String> taskIds) {

        ProjectTask__c projectTask = [SELECT ID,
                                            NAME,
                                            PlannedStartDate__c,
                                            Project__c,     //项目id
                                            Status__c,
                                            ActualStartDate__c,
                                            ActualEndDate__c
                                            FROM ProjectTask__c WHERE 
                                            ID = :taskIds[0]
                                            AND NAME LIKE '%合同谈判与签订%'];

        System.debug('projectTask指定的项目任务===》》》'+projectTask);


        Project__c project = [SELECT ID,
                                    NAME,
                                    Opportunity__c 
                                    FROM Project__c 
                                    WHERE ID = :projectTask.Project__c];

        System.debug('project指定的项目===》》》'+project);

        List<Contractmanagement__c> ContractList = new List<Contractmanagement__c>();

        if (project.Opportunity__c!=null) {
            ContractList = [SELECT ID,
                                TaskStatus__c,
                                ContractNegotiationStartDate__c, //合同谈判开始日期
                                ContractSigningEndDate__c,   //合同签订完成日期
                                ObjectName__c
                                FROM Contractmanagement__c
                                WHERE ObjectName__c = :project.Opportunity__c];

        if (ContractList.size()>0) {
            System.debug('Contract指定的合同===》》》'+ContractList[0]);
            System.debug('Contract指定的合同状态===》》》'+ContractList[0].TaskStatus__c);  //未开始
        }
        
        
        }

        //项目任务状态为未开始
        if (projectTask.Status__c=='未开始') {
            projectTask.ActualStartDate__c = null ; 
            projectTask.ActualEndDate__c = null ; 
            System.debug('再次修改项目任务状态时间进来了');

             //更新合同商务
             if (ContractList.size()>0) {
                if(ContractList[0]!=null){
                    ContractList[0].TaskStatus__c = '未开始';
                    ContractList[0].ContractNegotiationStartDate__c = null ; 
                    ContractList[0].ContractSigningEndDate__c = null ; 
                    System.debug('更新合同商务');
                 }
             }
             
          
        }

        if (projectTask.Status__c=='进行中') {
            projectTask.ActualStartDate__c = Datetime.now().date();
            projectTask.ActualEndDate__c = null ; 

             //更新合同商务
             if (ContractList.size()>0) {
                if(ContractList[0]!=null){
                    ContractList[0].TaskStatus__c = '进行中';
                    ContractList[0].ContractNegotiationStartDate__c = Datetime.now().date();
                    ContractList[0].ContractSigningEndDate__c = null ; 
                 } 
             }
             
         
        }

        if (projectTask.Status__c=='已完成') {
            if(projectTask.ActualStartDate__c==null){
                projectTask.ActualStartDate__c = Datetime.now().date();
            }
            projectTask.ActualEndDate__c =Datetime.now().date(); 

            //更新合同商务
            if (ContractList.size()>0) {
                if(ContractList[0]!=null){
                    ContractList[0].TaskStatus__c = '已完成';
                    if (ContractList[0].ContractNegotiationStartDate__c==null) {
                        ContractList[0].ContractNegotiationStartDate__c = Datetime.now().date();
                    }
                    
                    ContractList[0].ContractSigningEndDate__c = Datetime.now().date();
                }
            }
           
           
        }
        
        if(projectTask.id!=null){
            System.debug('==========>>>');
            upsert projectTask;
            System.debug('更新项目任务最终完成');
        }
       
        if (ContractList.size()>0) {
            if (ContractList[0].id!=null) {
                update ContractList;
            }
        }
        
    }
}