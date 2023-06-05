/**
 * Created by zhangwei08330 on 2019/9/14.
 */

trigger ProjectTrigger on Project__c (after insert) {
    
    Trigger__mdt mc = Trigger__mdt.getInstance('ProjectTrigger');
    if (mc == null || mc.IsActive__c) {
        System.debug('项目创建触发器~~~~~~~~');
        for(Project__c project : Trigger.new){
            if (Trigger.isAfter){
                Id project_id = project.Id;
                String project_name = project.Name;
                Decimal initial_num_of_machine = project.InitialNumOfMachine__c;
                String project_type = project.Type__c;
                String region = project.RegionNew__c;
    
               
    
                // create project stages
                List<ProjectStage__c> projectStagesList = new List<ProjectStage__c>();
                projectStagesList.add(new ProjectStage__c(Name='合同商务', Project__c=project_id, Number__c='1'));
                projectStagesList.add(new ProjectStage__c(Name='生产准备', Project__c=project_id, Number__c='2'));
                projectStagesList.add(new ProjectStage__c(Name='制造及交付', Project__c=project_id, Number__c='3'));
                projectStagesList.add(new ProjectStage__c(Name='吊装及预验收', Project__c=project_id, Number__c='4'));
    
                insert  projectStagesList;
    
                // 整机吊装前置任务的偏移
                Decimal diff = 0.0;
                Decimal interval = 0.0;
    
                Map<String, Id> stageIds = new Map<String, Id>();
                List<ProjectStage__c> projectStageList = [SELECT Id, Name FROM ProjectStage__c WHERE Project__c = :project_id];
                Integer size = projectStageList.size();
                for(Integer i=0 ; i < size; ++i ){
                    stageIds.put(projectStageList[i].Name, projectStageList[i].Id);
                }
                // for(ProjectStage__c projectStage: [SELECT Id, Name FROM ProjectStage__c WHERE Project__c = :project_id]){
                    // stageIds.put(projectStage.Name, projectStage.Id);
                // }
    
                // get static resource (json file)
                StaticResource staticResource = null;
                if(project_type.equals('陆上')){
                    staticResource = [SELECT Name, SystemModstamp,Body
                    FROM StaticResource
                    WHERE Name = 'LandTaskList'
                    LIMIT 1];
    
                    diff = 2.0;
                }
                else{
                    staticResource = [SELECT Name, SystemModstamp,Body
                    FROM StaticResource
                    WHERE Name = 'SeaTaskList'
                    LIMIT 1];
    
                    diff = 3.0;
                    interval = 1.0;
                }
    
                if (staticResource != null){
                    String json_body = staticResource.Body.toString();
    
                    Decimal pre_first_machine = 0.0; //记录前置任务第一台风机的编号
                    Decimal pre_first_yepian = 0.0;  //记录前置任务第一台叶片的编号
                    Decimal pre_first_tatong = 0.0;  //记录前置任务第一台塔筒的编号
                    Decimal pre_first_whole = 0.0;   //记录前置任务第一个整机任务的编号
                    Decimal first = 0.0;
                    Decimal index = 1.0;
    
                    Decimal last_machine = 0.0; //记录最后一台试运行的风机序号
    
                    //记录风机任务前的最后一个普通任务, 在这个任务之前的普通任务的序号保持不变, 之后的任务随着机器的增加会发生改变
                    Decimal before_machine = -1.0;
                    Boolean flag = true; 
    
                    Integer step = 0; //记录执行到第几个风机任务，用于计算风机类任务之后的普通任务的前置的前序
    
                    List<ProjectTask__c> projectTasks = new List<ProjectTask__c>();
                    // decode json string
                    Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(json_body);
                    List<Object> items = (List<Object>)root.get('items');
                    for(Object item : items){
                        Boolean milestone = false;
    
                        Map<String, Object> key_value = (Map<String,Object>)item;
    
                        String task_name = (String)key_value.get('task_name');
                        String task_type = (String)key_value.get('task_type');
                        String department = (String)key_value.get('department');
    
                        // System.debug(project_type.equals('陆上'));
                        // System.debug(department.equals('战区') + ' ' + department);
                        if(project_type.equals('陆上') && department.equals('战区')){
                            department = region;
                            // System.debug(department);
                        }
    
                        if (task_type.equals('风机交付类')){
    
                            if (flag){
                                before_machine = index - 1;
                                flag = false;
                            }
                            
                            Decimal pre_task_num = 0.0;
    
                            // first用于记录风机类任务的前置任务的第一台机器的任务序号, 后面的按此递增
                            if(task_name.contains('叶片')){
                                if(task_name.equals('叶片发运')){
                                    // -1 则表示从表中获取前置任务
                                    first = -1.0;
                                }
                                else {
                                    // 记录当前风机的第一台机器的序号
                                    first = pre_first_yepian;
                                }
                                // 记录当前风机的第一台机器的叶片的序号
                                pre_first_yepian = index;
    
                                // System.debug(task_name + ' pre_first_yepian: ' + pre_first_yepian);
                            }
                            else if(task_name.contains('主机')){
                                if(task_name.equals('主机齐套')){
                                    // -1 则表示从表中获取前置任务
                                    first = -1.0;
                                }
                                else{
                                    // 记录上一个风机类任务的第一台机器的序号
                                    first = pre_first_machine;
                                }
                                // 记录当前风机的第一台机器的序号
                                pre_first_machine = index;
    
                                // System.debug(task_name + ' pre_first_machine: ' + pre_first_machine);
                            }
                            else if(task_name.contains('塔筒')){
                                if(task_name.equals('塔筒齐套')){
                                    // -1 则表示从表中获取前置任务
                                    first = -1.0;
                                }
                                else{
                                    // 记录上一个风机类任务的第一台机器的序号
                                    first = pre_first_tatong;
                                }
                                // 记录当前风机任务的第一台机器的序号
                                pre_first_tatong = index;
    
                                // System.debug(task_name + ' pre_first_machine: ' + pre_first_machine);
                            }
                            else if(task_name.contains('整机')) {
                                if(task_name.equals('整机吊装')){
                                    // 整机吊装任务需要特殊计算
                                    first = index - diff * initial_num_of_machine  - interval;
                                }
                                else{
                                    // 记录上一个风机类任务的第一台机器的序号
                                    first = pre_first_whole;
                                }
                                // 记录当前风机任务的第一台机器的序号
                                pre_first_whole = index;
                            }
    
                            for (Integer i = 1; i < initial_num_of_machine + 1; i++){
                                String name = '第' + (Integer)i + '台' + task_name;
    
                                milestone = false;
    
                                // 如果不是主机齐套和叶片发运, 都是前一个风机类项目, 依次递增
                                if(first > 0.0){
                                    // first 是 前置任务的第一台机器, 如果直接递增1, 会往后挪一个序号, 因此需要减1
                                    pre_task_num = first + i - 1;
                                }
                                // 如果是主机齐套或叶片发运, 统一取文件中的前置任务, 所有机器都相同
                                else{
                                    pre_task_num = (Decimal)key_value.get('pre_task_num');
                                }
    
                                if (i == 1 && (Boolean)key_value.get('milestone')){
                                    milestone = true;
                                }
    
                                // System.debug('风机类 ' + task_name + ' number: ' + index);
                                // System.debug('风机类 ' + task_name + ' pre_task_num: ' + pre_task_num);
                                projectTasks.add(new ProjectTask__c(Name=name,
                                        Number__c=index,
                                        Status__c = '未开始',
                                        TaskType__c=(String)key_value.get('task_type'),
                                        ProjectStage__c=stageIds.get((String)key_value.get('stage')),
                                        SubType__c=(String)key_value.get('subtype'),
                                        Description__c=(String)key_value.get('task_desc'),
                                        PlannedNumOfDays__c=(Decimal)key_value.get('planned_num_of_days'),
                                        Department__c=department,
                                        Output__c=(String)key_value.get('output'),
                                        PreTaskNumber__c=pre_task_num,
                                        Project__c=project_id,
                                        Today__c=Date.today(),
                                        ProjectName__c=project_name,
                                        Milestone__c = milestone,
                                        PreInterval__c = (Decimal)key_value.get('interval')));
    
                                index += 1;
                            }
    
                            if(task_name.equals('整机试运行')){
                                last_machine = index - 1;
                            }
    
                            step += 1;
                        }
                        else{
                            Decimal pre_task_num = (Decimal)key_value.get('pre_task_num');
    
                            // System.debug(before_machine + ' ' + pre_task_num + ' ' + task_name);
                            // 在风机类任务之后的普通任务
                            if (before_machine > 0.0 && pre_task_num > before_machine){
                                // System.debug('-------- step: ' + step + ' ' + task_name);
                                // System.debug('-------- initial_num_of_machine: ' + initial_num_of_machine);
                                // System.debug('-------- 1 pre_task_num: ' + pre_task_num);
                                //json文件里的前置是以一台计算, 如果只有1台则保持不变, 1台以上则每个步骤增加n-1
                                pre_task_num = pre_task_num + step * (initial_num_of_machine - 1);
                                // System.debug('-------- 2 pre_task_num: ' + pre_task_num);
                            }
    
                            if(task_name.equals('预验收证书签署')){
                                pre_task_num = last_machine;
                            }
    
                            // System.debug('普通类 ' + task_name + ' number: ' + index);
                            // System.debug('普通类 ' + task_name + ' pre_task_num: ' + pre_task_num);
                            projectTasks.add(new ProjectTask__c(Name=task_name,
                                    Number__c=index,
                                    Status__c = '未开始',
                                    TaskType__c=(String)key_value.get('task_type'),
                                    ProjectStage__c=stageIds.get((String)key_value.get('stage')),
                                    SubType__c=(String)key_value.get('subtype'),
                                    Description__c=(String)key_value.get('task_desc'),
                                    PlannedNumOfDays__c=(Decimal)key_value.get('planned_num_of_days'),
                                    Department__c=department,
                                    Output__c=(String)key_value.get('output'),
                                    PreTaskNumber__c=pre_task_num,
                                    Project__c=project_id,
                                    Today__c=Date.today(),
                                    ProjectName__c=project_name,
                                    Milestone__c = (Boolean)key_value.get('milestone'),
                                    PreInterval__c = (Decimal)key_value.get('interval')));
    
                            index += 1;
                        }
                    }
    
                    insert projectTasks;
    
                    // update PreTask__c
                    Map<Decimal, Id> pretaskid_map = new Map<Decimal, Id>();
                    // List<ProjectTask__c> projectTaskList = [SELECT Id, Number__c, PreTaskNumber__c,ProjectName__c FROM ProjectTask__c WHERE Project__c = :project_id AND Number__c > 0 ORDER BY Number__c];
                    Map<Id, ProjectTask__c> pt_map = new Map<Id, ProjectTask__c>([SELECT Id, Number__c, PreTaskNumber__c,ProjectName__c FROM ProjectTask__c WHERE Project__c = :project_id AND Number__c > 0 ORDER BY Number__c]);
                    // size = projectTaskList.size();
                    // for(Integer i=0 ; i < size; ++i ){
                    for(ProjectTask__c pt: pt_map.values()){
                        pretaskid_map.put(pt.Number__c, pt.Id);
                    }
    
                    // for (ProjectTask__c projectTask : [SELECT Id, Number__c, PreTaskNumber__c,ProjectName__c FROM ProjectTask__c WHERE Project__c = :project_id ORDER BY Number__c]){
                    //     pretaskid_map.put(projectTask.Number__c, projectTask.Id);
                    // }
    
                    List<ProjectTask__c> updateProjectTasks = new List<ProjectTask__c>();
                    // for (ProjectTask__c projectTask : [SELECT Id, Number__c, PreTaskNumber__c,ProjectName__c FROM ProjectTask__c WHERE Project__c = :project_id ORDER BY Number__c]){
                    for(ProjectTask__c pt: pt_map.values()){
                        if (pt.PreTaskNumber__c > 0.000001) {
                            pt.PreTask__c = pretaskid_map.get(pt.PreTaskNumber__c);
                            updateProjectTasks.add(pt);
                        }
                    }
    
                    update updateProjectTasks;
                }
            }
        }
    }

}