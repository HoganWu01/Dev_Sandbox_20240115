/*
 * @Author: irving
 * @Date: 2021-10-16 16:57:21
 * @LastEditTime: 2021-10-29 16:48:05
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 */
public without sharing class Controller_UpdateTaskDate {

    public Controller_UpdateTaskDate(ApexPages.StandardController stdController) {

        String PId = ApexPages.currentPage().getParameters().get('PId');
        System.debug('PId----'+PId);
    }

    /**
     * @description: parentId 项目id  payDate 手动输入的时间
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled 
    public static Map<Object,Object> UpdateTaskDate(String pointTaskId,String parentId,Date payDate){

        System.debug('更新项目时间接口进来了');
        System.debug('指定的项目任务id为===》》》'+pointTaskId);
        System.debug('parentId项目id为===》》》'+parentId);
        System.debug('payDate时间为===》》》'+payDate);

        Map<Object,Object> map_return = new Map<Object,Object>();

        map_return.put('type','S');

        try {

            //根据序号排序
            List<ProjectTask__c> taskList = [SELECT ID,
                                                    NAME,
                                                    PreTask__c,         //前置任务
                                                    ExtPreTask2__c ,
                                                    ExtPreTask3__c,
                                                    ExtPreTask4__c,
                                                    ExtPreTask5__c ,
                                                    ExtPreTask6__c , 
                                                    PreInterval__c,         //前置间隔天数
                                                    PlannedNumOfDays__c , //计划任务天数
                                                    PlannedStartDate__c,   //交付计划开始日期
                                                    PlannedEndDate__c,   //交付计划结束日期  公式字段：交付计划开始日期+计划任务天数
                                                    ActualStartDate__c,   //实际开始日期
                                                    ActualEndDate__c     //实际结束日期
                                                    FROM ProjectTask__c 
                                                    WHERE 
                                                    Project__c= :parentId
                                                    order by Number__c asc];

            System.debug('taskList===>'+taskList);
            

            Map<String,ProjectTask__c> idTaskMap = new Map<String,ProjectTask__c>();

            for (ProjectTask__c task : taskList) {
                idTaskMap.put(task.id, task);
            }

            List<ProjectTask__c> updateProjectTask = new List<ProjectTask__c>();

            Date tempDate =null; 

            Map<String,Date> nowTaskIdAndEndDateMap = new Map<String,Date>();

            Date tempEndDate = null ; 

           for (Integer i = 0; i < taskList.size(); i++) {
               System.debug('taskList'+i+taskList[i].Id+taskList[i].name);
               System.debug('pointTaskId===>'+pointTaskId);
               if(pointTaskId.equals(taskList[i].Id)){    //指定的任务找到对应的任务
                System.debug('i为==============>>>'+i);
                taskList[i].PlannedStartDate__c = payDate ; 

                //结束日期 = 交付开始日期+计划任务天数+前置间隔天数
                tempEndDate =taskList[i].PlannedStartDate__c.addDays(Integer.valueOf(taskList[i].PlannedNumOfDays__c+taskList[i].PreInterval__c));
                updateProjectTask.add(taskList[i]);

                nowTaskIdAndEndDateMap.put(taskList[i].id, tempEndDate);
               }

               //判断当前项目任务的所有前置任务的结束时间，取最大值  存在6个前置任务
               Date maxEndDate  =  GetPreTaskMaxEndDate(taskList[i].id,idTaskMap,nowTaskIdAndEndDateMap);

               if (maxEndDate==null) {
                   continue ; 
               }

               //下一条项目任务 找多个前置任务的最大时间  加上当前任务的前置间隔天数
               taskList[i].PlannedStartDate__c =  maxEndDate.addDays(Integer.valueOf(taskList[i].PreInterval__c));

               //开始日期+任务计划天数
               tempEndDate = taskList[i].PlannedStartDate__c.addDays(Integer.valueOf(taskList[i].PlannedNumOfDays__c)) ;  

               nowTaskIdAndEndDateMap.put(taskList[i].id,tempEndDate);

               updateProjectTask.add(taskList[i]);
           }

             update updateProjectTask ;
             System.debug('更新项目任务时间完成');
             System.debug('updateProjectTask===>'+updateProjectTask);

             map_return.put('messages','更新项目时间成功!');
            
        } catch (Exception e) {
           String msg = '返回错误'+e.getMessage()+e.getLineNumber();
           map_return.put('messages','提交失败, 请联系系统管理员! 错误信息:'+e.getMessage()+'错误行数'+e.getLineNumber());
        }

        return map_return;
    }

    public static Date GetPreTaskMaxEndDate (String taskId,Map<String,ProjectTask__c> taskidAndTaskMap,Map<String,Date> nowTaskIdAndEndDateMap){

        ProjectTask__c  nowTask = taskidAndTaskMap.get(taskId);

        Date tempMaxDate = null ; 
        Date taskenddate1 = null; 
        Date taskenddate2= null ; 
        Date taskenddate3= null ; 
        Date taskenddate4= null ; 
        Date taskenddate5= null ; 
        Date taskenddate6= null ; 

        if (nowTask.PreTask__c!=null) {
             taskenddate1 =  nowTaskIdAndEndDateMap.get(nowTask.PreTask__c);
        }

        if (nowTask.ExtPreTask2__c!=null) {
             taskenddate2 =  nowTaskIdAndEndDateMap.get(nowTask.ExtPreTask2__c);
        }

        if (nowTask.ExtPreTask3__c!=null) {
             taskenddate3 =  nowTaskIdAndEndDateMap.get(nowTask.ExtPreTask3__c);
        }

        if (nowTask.ExtPreTask4__c!=null) {
             taskenddate4 =  nowTaskIdAndEndDateMap.get(nowTask.ExtPreTask4__c);
        }
        
        if (nowTask.ExtPreTask5__c!=null) {
             taskenddate5 =  nowTaskIdAndEndDateMap.get(nowTask.ExtPreTask5__c);
        }

        if (nowTask.ExtPreTask6__c!=null) {
             taskenddate6 =  nowTaskIdAndEndDateMap.get(nowTask.ExtPreTask6__c);
        }
        

        tempMaxDate = taskenddate1 ; 

        if (taskenddate2!=null &&tempMaxDate!=null) {
            if (taskenddate2>tempMaxDate) {
                tempMaxDate = taskenddate2 ; 
            }
        }
        
        if (taskenddate3!=null &&tempMaxDate!=null) {
            if (taskenddate3>tempMaxDate) {
                tempMaxDate = taskenddate3 ; 
            }
        }
       
        if (taskenddate4!=null &&tempMaxDate!=null) {
            if (taskenddate4>tempMaxDate) {
                tempMaxDate = taskenddate4 ; 
            }
        }
        
        if (taskenddate5!=null &&tempMaxDate!=null) {
            if (taskenddate5>tempMaxDate) {
                tempMaxDate = taskenddate5 ; 
            }
        }
       
        if (taskenddate6!=null &&tempMaxDate!=null) {
            if (taskenddate6>tempMaxDate) {
                tempMaxDate = taskenddate6 ; 
            }
        }
        return tempMaxDate ; 
        
    }

    
}