/*
 * @Descripttion: 
 * @Author: irving
 * @Date: 2021-10-18 10:08:34
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-11-30 10:44:26
 */
public without sharing class Controller_ImportProjectTask {

    public Controller_ImportProjectTask(ApexPages.StandardController stdController) {

        String PId = ApexPages.currentPage().getParameters().get('PId');
        System.debug('PId----'+PId);
    }

    /**
     * @description: parentId 项目id
     * @param {*}
     * @return {*}
     */
    @AuraEnabled    
    public static Map<Object,Object> ImportProjectTask(String parentId,String TaskType){

        System.debug('拉取项目接口进来了');
        System.debug('parentId项目id为'+parentId);
        System.debug('TaskType任务类型====》'+TaskType);

        Map<Object,Object> map_return = new Map<Object,Object>();

        map_return.put('type','S');

        try {


            List<ProjectTask__c> existTasks = [SELECT ID,NAME,Project__c,TaskType__c FROM ProjectTask__c 
            WHERE Project__c =:parentId];

            System.debug('existTasks现存的项目任务数量为'+existTasks.size());

            //修改有一条就不给拉 irving  2021/11/30
            if (existTasks.size()>=1) {
                map_return.put('type','E');
                map_return.put('messages','该项目下已经拉取过,不允许再拉取');
                return  map_return; 
            }

            Project__c currentPro = [SELECT ID,NAME,Stage__c,Opportunity__c  FROM Project__c WHERE ID = : parentId];

            System.debug('currentPro-----'+currentPro);

            List<ProjectStage__c> stage1List = [SELECT ID, 
                                            NAME 
                                            FROM ProjectStage__c WHERE Project__c=:parentId 
                                            and name =:currentPro.Stage__c];

            System.debug('---------'+stage1List.size());

            //项目阶段
            ProjectStage__c  stage = [SELECT ID, 
                                            NAME 
                                            FROM ProjectStage__c WHERE Project__c=:parentId 
                                            and name =:currentPro.Stage__c] ;

            List<ProjectStage__c>  stageList = [SELECT ID, 
                                                        NAME 
                                                        FROM ProjectStage__c 
                                                        WHERE Project__c=:parentId ] ;

            System.debug('stageList----'+stageList);
            Map<String,String> stageNameAndIdMap = new  Map<String,String>();

            for (ProjectStage__c s : stageList) {
                stageNameAndIdMap.put(s.name, s.id);
            }


            List<ProjectTaskBoard__c> proTaskBoardList = new List<ProjectTaskBoard__c>();

            if (String.isNotBlank(TaskType) || TaskType!=null) {
                 //项目任务配置管理模板
                 proTaskBoardList = [SELECT ID,
                                            CollectionType__c,   //回款分类
                                            ProjectStage__c,    //项目任务阶段 选项列表 name
                                            TaskType__c ,
                                            Department__c,
                                            Description__c,
                                            Status__c,
                                            TaskNumber__c,
                                            TaskOwner__c,
                                            PreTaskName1__c,  //前置任务1 查找类型
                                            PreTaskName2__c, 
                                            PreTaskName3__c,
                                            PreTaskName4__c,
                                            PreTaskName5__c,
                                            PreTaskName6__c,
                                            PreInterval__c,	
                                            OwnerId,
                                            PlannedNumOfDays__c,
                                            Name 
                                            FROM ProjectTaskBoard__c
                                            WHERE TaskType__c = :TaskType 
                                            order by Name asc 
                                            ];   
            }else{
                map_return.put('type','E');
                map_return.put('messages','项目任务类型不能为空');
                return  map_return;   
            }

            if (proTaskBoardList.size()==0 || proTaskBoardList==null) {
                map_return.put('type','E');
                map_return.put('messages','找不到该类型');
                return  map_return;  
            }

            

            List<ProjectTask__c> proTaskList = new List<ProjectTask__c>();

            Map<String,String> boardIDNAMEMMap = new  Map<String,String>();

            Map<String,String> boardNameAndStageNameMap = new Map<String,String>();

            // 模板的每条name - 阶段name
            for (ProjectTaskBoard__c board : proTaskBoardList) {
                if(board.ProjectStage__c!=null){
                    boardNameAndStageNameMap.put(board.name,board.ProjectStage__c) ;
                }
                 
            }

            for (ProjectTaskBoard__c board : proTaskBoardList) {

                boardIDNAMEMMap.put(board.id, board.name);

                ProjectTask__c task = new ProjectTask__c();
                task.Name = board.Name ; 
                task.PlannedNumOfDays__c=board.PlannedNumOfDays__c ;   //计划任务天数
                task.PreInterval__c =   board.PreInterval__c ;  //前置间隔天数
                task.Department__c =    board.Department__c ; 
                //devin 2021-11-24 添加判断条件
                if (String.isNotBlank(board.TaskNumber__c)) {
                    task.Number__c = Integer.valueOf(board.TaskNumber__c) ;   //序号-项目任务编号
                }
                task.Status__c = board.Status__c ;  //任务状态
                task.Description__c = board.Description__c ; //任务描述
                task.Project__c = parentId ; 
                if (board.TaskOwner__c!=null) {
                    task.TaskOwner__c = board.TaskOwner__c;  //任务责任人
                }
                
                if(boardNameAndStageNameMap.get(board.name)!=null){
                    task.ProjectStage__c = stageNameAndIdMap.get(boardNameAndStageNameMap.get(board.name))  ;
                }else{
                    task.ProjectStage__c = stage.id ; 
                }
                task.CollectionType__c = board.CollectionType__c ; 
                task.ProjectName__c = currentPro.Name ;  //项目名
                proTaskList.add(task);
            }
            System.debug('proTaskList=======>>'+proTaskList);
            insert proTaskList ; 


            Map<String,String> IdNameMap = new Map<String,String>();

            Map<String,String> NameIdMap = new Map<String,String>();

            for (ProjectTask__c pro : proTaskList) {      
                IdNameMap.put(pro.id, pro.name);
                NameIdMap.put(pro.name, pro.id);
            }

            Map<String,String> boardNameId1Map = new Map<String,String>();
            Map<String,String> boardNameId2Map = new Map<String,String>();
            Map<String,String> boardNameId3Map = new Map<String,String>();
            Map<String,String> boardNameId4Map = new Map<String,String>();
            Map<String,String> boardNameId5Map = new Map<String,String>();
            Map<String,String> boardNameId6Map = new Map<String,String>();
            
            for (ProjectTaskBoard__c board : proTaskBoardList) {
                
                boardNameId1Map.put(board.name,board.PreTaskName1__c);   //模板的名字，模板的前置id
                boardNameId2Map.put(board.name,board.PreTaskName2__c);
                boardNameId3Map.put(board.name,board.PreTaskName3__c);
                boardNameId4Map.put(board.name,board.PreTaskName4__c);
                boardNameId5Map.put(board.name,board.PreTaskName5__c);
                boardNameId6Map.put(board.name,board.PreTaskName6__c);
            }
            
            List<ProjectTask__c> updateProject = new List<ProjectTask__c>();


            for (ProjectTask__c pro : proTaskList) {
                //---项目任务id--项目name==配置模板Name--配置模板前置id--配置模板前置name==项目任务name--项目任务id给前置1---
                pro.PreTask__c =NameIdMap.get(boardIDNAMEMMap.get(boardNameId1Map.get(IdNameMap.get(pro.id))))  ;
                pro.ExtPreTask2__c =NameIdMap.get(boardIDNAMEMMap.get(boardNameId2Map.get(IdNameMap.get(pro.id)))) ;
                pro.ExtPreTask3__c =NameIdMap.get(boardIDNAMEMMap.get(boardNameId3Map.get(IdNameMap.get(pro.id)))) ;
                pro.ExtPreTask4__c =NameIdMap.get(boardIDNAMEMMap.get(boardNameId4Map.get(IdNameMap.get(pro.id)))) ;
                pro.ExtPreTask5__c = NameIdMap.get(boardIDNAMEMMap.get(boardNameId5Map.get(IdNameMap.get(pro.id)))) ;
                pro.ExtPreTask6__c =NameIdMap.get(boardIDNAMEMMap.get(boardNameId6Map.get(IdNameMap.get(pro.id)))) ;

                updateProject.add(pro);
            }

            update updateProject ; 
            System.debug('更新项目下的项目任务完成');
            map_return.put('messages','拉取项目任务成功!');

            System.debug('开始查找04谈判');

             //要04合同签订与谈判的那一条
             ProjectTask__c pointProjectTask = new ProjectTask__c();

             pointProjectTask = [SELECT ID,
                                        NAME,
                                        PlannedStartDate__c,
                                        Status__c,
                                        ActualStartDate__c,
                                        ActualEndDate__c 
                                        FROM ProjectTask__c WHERE Project__c=:currentPro.id AND NAME LIKE '%合同谈判与签订%'];

            System.debug('04谈判是否存在'+pointProjectTask);

            if (pointProjectTask!=NULL) {
                
                Contractmanagement__c Contract = new Contractmanagement__c();

                if (currentPro.Opportunity__c!=null) {
                     Contract = [SELECT ID,
                                        TaskStatus__c,
                                        ContractNegotiationStartDate__c, //合同谈判开始日期
                                        ContractSigningEndDate__c,   //合同签订完成日期
                                        ObjectName__c
                                        FROM Contractmanagement__c
                                        WHERE ObjectName__c = :currentPro.Opportunity__c];
                }

                if (Contract!=null) {
                    System.debug('Contract.TaskStatus__c'+Contract.TaskStatus__c);
                }

                if (Contract != null && Contract.TaskStatus__c == '未开始') {
                    pointProjectTask.Status__c = '未开始';
                    pointProjectTask.ActualStartDate__c = null ; 
                    pointProjectTask.ActualEndDate__c = null ; 
                    System.debug('合同存在---修改04项目任务状态为未开始');
                }

                //拉取项目任务的时候 如果合同不为空 合同的状态为进行中 04项目任务的计划开始时间不为空
                if (Contract!=null &&Contract.TaskStatus__c == '进行中') {
                    pointProjectTask.Status__c='进行中';

                    if (Contract.ContractNegotiationStartDate__c!=null) {
                        pointProjectTask.ActualStartDate__c =Contract.ContractNegotiationStartDate__c ; 
                    }else{
                        pointProjectTask.ActualStartDate__c =Datetime.now().date() ;
                    }
                    
                    pointProjectTask.ActualEndDate__c = null ; 
                    if (pointProjectTask.PlannedStartDate__c==null) {
                        pointProjectTask.PlannedStartDate__c = Contract.ContractNegotiationStartDate__c;
                    }
                    System.debug('合同存在---修改04项目任务状态为进行中');
                }
                //拉取项目任务的时候 如果合同不为空 合同的状态为已完成 04项目任务的计划开始时间为空时赋值默认时间--当前时间
                if (Contract!=null &&Contract.TaskStatus__c == '已完成') {
                    if ( pointProjectTask.Status__c==null ) {
                         pointProjectTask.Status__c='已完成';
                        if (pointProjectTask.ActualStartDate__c==null) {
                            pointProjectTask.ActualStartDate__c =Contract.ContractNegotiationStartDate__c;
                        }
                        if (pointProjectTask.PlannedStartDate__c==null) {
                            pointProjectTask.PlannedStartDate__c = Contract.ContractNegotiationStartDate__c;
                        }
                    }
                    
                    pointProjectTask.ActualEndDate__c =Contract.ContractSigningEndDate__c; 
                    
                    System.debug('合同存在---修改04项目任务状态为已完成');
                }

                if (pointProjectTask!=NULL) {
                    update pointProjectTask ; 
                    System.debug('更新04合同谈判与签订的项目任务完成');
                }
                

            }

        } catch (Exception e) {
            
           String msg = '返回错误'+e.getMessage();
           map_return.put('type','E');
           map_return.put('messages','提交失败, 请联系系统管理员! 错误信息:'+e.getMessage());
           System.debug('返回错误'+e.getMessage());
           System.debug('返回错误行号'+e.getLineNumber());
        }

        return map_return;

    }

    @AuraEnabled    
    public static Map<Object,Object> selectTaskType(){

    Map<Object,Object> map_return = new Map<Object,Object>();
      
    List<Utils.PickListValue> picklist = Utils.getPickListValue('ProjectTaskBoard__c','TaskType__c');

    map_return.put('picklist',picklist);
    return map_return ; 

    }

    
}