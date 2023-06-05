/**
 * Created by zhangwei08330 on 2020/01/18.
 */

trigger UpdateTaskDate on ProjectTask__c (before update, after update) {

    // Trigger__mdt mc = Trigger__mdt.getInstance('UpdateTaskDate');
    // if (mc == null || mc.IsActive__c) {
    //     if( Trigger.new.size() == 1){
    //         ProjectTask__c new_pt = Trigger.new[0];
    //         ProjectTask__c old_pt = Trigger.oldMap.get(new_pt.Id);
    
    //         System.debug('new_pt新的项目任务序号'+new_pt.Number__c);
    //         System.debug('old_pt旧的项目任务序号'+old_pt.Number__c);
    
    
    //         if(new_pt.Number__c!=old_pt.Number__c){
    //             return ; 
    //         }
    
    //         // if(new_pt.Is_Sort__c==true){
    //         //     return ; 
    //         // }
    
    
    //         if (old_pt.PlannedStartDate__c == null) {
    //             return;
    //         }
    
    //         if(new_pt.TaskType__c.equals('风机交付类')){  
    //             Integer interval = old_pt.PlannedStartDate__c.daysBetween(new_pt.PlannedStartDate__c); // 计划开始日期变动天数
    //             Integer preinterval = (Integer)(new_pt.PreInterval__c - old_pt.PreInterval__c);         // 前置任务天数变化数
    //             Integer planned_days = (Integer)(new_pt.PlannedNumOfDays__c - old_pt.PlannedNumOfDays__c); // 任务计划天数变动天数
    
    //             // 更新记录时，需要区分before、after，否则会死循环
    //             // 修改自己
    //             if (Trigger.isBefore){
    //                 if (interval != 0){
    //                     // 前置任务
    //                     List<ProjectTask__c> pre_pt = [SELECT PlannedStartDate__c, PlannedEndDate__c, PlannedNumOfDays__c,Name,Id FROM ProjectTask__c WHERE Id = :new_pt.PreTask__c];
    
    //                     if (!(new_pt.SubType__c.contains('主机齐套') 
    //                         || new_pt.SubType__c.contains('塔筒齐套') 
    //                         || new_pt.SubType__c.contains('5 叶片生产入库')
    //                         || new_pt.SubType__c.contains('4 叶片发运及到货'))
    //                         ){
    //                         // 修改当前项目任务的间隔天数和计划开始日期
    //                         // new_pt.PreInterval__c = new_pt.PreInterval__c + interval;
    //                         new_pt.PreInterval__c = pre_pt[0].PlannedEndDate__c.daysBetween(new_pt.PlannedStartDate__c);
    //                         // new_pt.PlannedStartDate__c = pre_pt[0].PlannedStartDate__c.addDays((Integer)new_pt.PreInterval__c + (Integer)pre_pt[0].PlannedNumOfDays__c);
    //                     }
    //                     else {
    //                         // 主机、塔筒、叶片的第一个任务，不需要更新间隔天数
    //                     }
                        
    //                     // before 不需要手动调用DML语句
    //                     // update new_pt;
    //                 }
    //                 else if(preinterval != 0){
    //                     if (!(new_pt.SubType__c.contains('主机齐套') 
    //                         || new_pt.SubType__c.contains('塔筒齐套') 
    //                         || new_pt.SubType__c.contains('5 叶片生产入库')
    //                         || new_pt.SubType__c.contains('4 叶片发运及到货'))
    //                         ){
    //                         // 前置任务
    //                         List<ProjectTask__c> pre_pt = [SELECT PlannedStartDate__c, PlannedNumOfDays__c,Name,Id FROM ProjectTask__c WHERE Id = :new_pt.PreTask__c];
    //                         new_pt.PlannedStartDate__c = pre_pt[0].PlannedStartDate__c.addDays((Integer)new_pt.PreInterval__c + (Integer)pre_pt[0].PlannedNumOfDays__c);
    //                         // update new_pt;
    //                     }
    //                     else{
    //                         // 主机、塔筒、叶片的第一个任务，只需要根据调整的间隔天数，直接修改计划开始日期即可
    //                         new_pt.PlannedStartDate__c = new_pt.PlannedStartDate__c.addDays(preinterval);
    //                     }
    //                 }
    //             }
    //             // 修改后续项目任务
    //             else if (Trigger.isAfter) {
    //                 if (interval !=0  || preinterval != 0 || planned_days != 0)
    //                 {
    //                     List<ProjectTask__c> pt_follow = [SELECT Id, PlannedStartDate__c, PreInterval__c FROM ProjectTask__c WHERE PreTask__c = :new_pt.Id];
    //                     if(pt_follow.size() == 0){
    //                         return;
    //                     }
    
    //                     if (pt_follow[0].PlannedStartDate__c != null){
    //                         // 后续任务只需要根据当前任务的计划开始日期和计划任务天数（实际就是计划结束日期），以及后续任务的间隔日期来设置计划开始日期
    //                         try{
    //                             pt_follow[0].PlannedStartDate__c = new_pt.PlannedStartDate__c.addDays((Integer)pt_follow[0].PreInterval__c + (Integer)new_pt.PlannedNumOfDays__c);
    //                             update pt_follow[0];
    //                         } catch(DmlException e){
    //                             System.debug('An unexpected error has occurred:' + e.getMessage());
    //                             System.debug('update project task:'+new_pt.Id + ', follow project task:'+pt_follow[0].Id);
    //                         }
    //                     }
    //                     // while循环中，update会导致嵌套触发Trigger. 如果是一个循环里面改其他任务，其他任务也会触发trigger，导致无限死循环。
    //                     // 每次修改一条任务, 修改后出触发后一条任务的触发, 这样可以保证不死循环
    //                 }  
    //             }
    //         }
    //     }
    // }

}