@isTest
public with sharing class Test_UpdateTaskDate {
    static testMethod void testUpdateTaskDate(){

        System.Test.startTest();
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;

        // Profile pro = [SELECT ID,NAME FROM Profile WHERE NAME = '项目交付管理员'];
        //String roleId = [select id,name from userrole where id = '00E2v000000bkNIEAY'].id ; 
        // User user = new User();
        // user.Username = 'john@acmeee.com';
        // user.LastName = 'www';
        // user.Email = 'john@acme.com.sanbox4';
        // user.Alias = 'www';
        // user.TimeZoneSidKey = 'Asia/Shanghai';
        // user.LocaleSidKey = 'zh_CN';
        // user.EmailEncodingKey = 'GB2312';
        // user.ProfileId = pro.id;
        // user.LanguageLocaleKey = 'zh_CN';
        // user.UserRoleId = '00E2v000000bkNIEAY';
        // insert user;

        User user = [SELECT ID,NAME,Email  FROM USER WHERE name = '郑耿昭'];

        //---------
        project__c proj = new project__c();
        proj.name = 'proj';
        //proj.OwnerId  = user.id ;
        proj.ProjectManager__c = user.id; 
        insert proj;

        ProjectStage__c stage1 = new ProjectStage__c(Name='合同商务',Project__c=proj.id, Number__c='1');
        insert stage1;

       ProjectTask__c task = new ProjectTask__c(name='004合同谈判与签订');
        task.TaskType__c = '普通类';
        task.Status__c = '未开始';
        task.PlannedStartDate__c = Datetime.now().date() ; 
        task.ActualStartDate__c = Datetime.now().date();
        task.Project__c = proj.id;
        task.ProjectStage__c = stage1.id ; 
        task.PlannedNumOfDays__c = 2;
        
        insert task;

        ProjectTask__c task5 = new ProjectTask__c(name='005组织道路分界点勘核');
        task5.TaskType__c = '普通类';
        task5.Status__c = '未开始';
        //task5.PlannedStartDate__c = Datetime.now().date() ; 
        //task5.ActualStartDate__c = Datetime.now().date();
        task5.Project__c = proj.id;
        task5.ProjectStage__c = stage1.id ; 
        task5.PlannedNumOfDays__c = 2;
       
        insert task5;

        ProjectTask__c task6 = new ProjectTask__c(name='006中标利润测算');
        task6.TaskType__c = '普通类';
        task6.Status__c = '未开始';
        task6.PlannedStartDate__c = Datetime.now().date() ; 
        task6.ActualStartDate__c = Datetime.now().date();
        task6.Project__c = proj.id;
        task6.PlannedNumOfDays__c = 2;
        task6.ProjectStage__c = stage1.id ; 
        insert task6;

        ProjectTask__c task7 = new ProjectTask__c(name='007传递技术资料需求');
        task7.TaskType__c = '普通类';
        task7.Status__c = '未开始';
        task7.PlannedStartDate__c = Datetime.now().date() ; 
        task7.ActualStartDate__c = Datetime.now().date();
        task7.Project__c = proj.id;
        task7.PlannedNumOfDays__c = 2;
        task7.ProjectStage__c = stage1.id ; 
        insert task7;

        ProjectTask__c task8 = new ProjectTask__c(name='008微观选址及风资源确认');
        task8.TaskType__c = '普通类';
        task8.Status__c = '未开始';
        task8.PlannedStartDate__c = Datetime.now().date() ; 
        task8.ActualStartDate__c = Datetime.now().date();
        task8.Project__c = proj.id;
        task8.PlannedNumOfDays__c = 2;
        task8.ProjectStage__c = stage1.id ; 
        insert task8;

        ProjectTask__c task9 = new ProjectTask__c(name='009输出地基载荷报告');
        task9.TaskType__c = '普通类';
        task9.Status__c = '未开始';
        task9.PlannedStartDate__c = Datetime.now().date() ; 
        task9.ActualStartDate__c = Datetime.now().date();
        task9.Project__c = proj.id;
        task9.PlannedNumOfDays__c = 2;
        task9.ProjectStage__c = stage1.id ; 
        insert task9;

        ProjectTask__c task10 = new ProjectTask__c(name='010输出塔筒招标图纸');
        task10.TaskType__c = '普通类';
        task10.Status__c = '未开始';
        task10.PlannedStartDate__c = Datetime.now().date() ; 
        task10.ActualStartDate__c = Datetime.now().date();
        task10.Project__c = proj.id;
        task10.ExtPreTask2__c = task.id;
        task10.ExtPreTask3__c = task.id;
        task10.PreTask__c = task.id;
        task10.PreTask__c = task.id;
        task10.PreTask__c = task.id;
        task10.PreTask__c = task.id;
        task10.PlannedNumOfDays__c = 2;
        task10.ProjectStage__c = stage1.id ; 
        insert task10;

        Date d = Datetime.now().addDays(1).date();

        Controller_UpdateTaskDate.UpdateTaskDate(task.id, proj.id, d);
        System.Test.stopTest();
    }
}