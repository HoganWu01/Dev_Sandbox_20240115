/**
 * 项目立项申请controller
 */
public without sharing class ProjectApplication {
      
    @AuraEnabled 
    public static Map<Object,Object> initApproval(String recordId) {
        Opportunity opportunity = [SELECT   Id,
                                            Salesdepartment__c,//所属大区/二级公司  
                                            Chiefgeneralmanager__c,//大区/二级公司总经理 
                                            // Group__c,//项目所属集团
                                            Key_Account_General_Manager__c,//大客户总经理
                                            Customer_Secondary_Company__c,//客户二级公司
                                            Province__c,//省
                                            City__c,//市
                                            capacity__c,//容量
                                            // Objectname__c,//项目名称
                                            Cooperation_Background__c,//合作背景
                                            Stage__c,//所属阶段（待确认）
                                            Tendermethod__c,//招标方式
                                            Approvedbatch__c,//核准批次
                                            Approvaltime__c,//(预计)核准时间
                                            Tendercompany__c,//招标公司
                                            Estimated_Bidding_Time__c,//预计招标时间
                                            Approvedmodel__c,//核准机型
                                            Bidmodel__c,//招标机型
                                            Precommunication__c,//前期交流情况
                                            Avewindspeed__c,//平均风速
                                            Turbulence__c,//湍流
                                            Designinstitute__c,//设计院
                                            Chiefdesigner__c,//设总
                                            Chiefdesignerphone__c,//设总联系电话
                                            Recommendedmodel__c,//可研推荐机型
                                            Recommendedmodelreason__c,//可研推荐机型理由
                                            Designerintentmodel__c,//设计院意向机型
                                            Designerintentmodelreason__c,//设计院意向机型理由
                                            Accountintentmodel__c,//业主意向机型
                                            Accountintentmodelreason__c,//业主意向机型理由
                                            OpportunityApprovalStatus__c//商机创建审批状态    
                                        FROM 
                                            Opportunity
                                        WHERE 
                                            Id =: recordId
                                        ];


         Projectapplication__c projectapplication = [select id ,Oppty__c from Projectapplication__c where Oppty__c =:opportunity.id];

        Matter_Selected_Impeller__c MSI = [select id,
                                                            Name ,//机型
                                                            Powergeneration__c,// 发电量
                                                            Economicrank__c,// 经济性排名
                                                            quotedprice__c // 报价
                                                         from 
                                                            Matter_Selected_Impeller__c 
                                                         where 
                                                            Application__c =: projectapplication.Id];  
                                              
        Competitor__c competitor = [select Id,
                                                Name,//竞争厂家
                                                Competitivemodel__c,//竞争机型
                                                Powergeneration__c,//发电量
                                                Pre_Com_Content__c,//前期交流
                                                Advantage__c //相对优势

                                            from
                                                Competitor__c
                                            where 
                                                Application__c =: projectapplication.Id ];

        Map<Object,Object> map_return = new Map<Object,Object>();
        String approvalRequired = '';//审批必填字段

        //所属大区/二级公司
        if(String.isBlank(opportunity.Salesdepartment__c)) {
            approvalRequired += '所属大区/二级公司,';
        }
        //大区/二级公司总经理 
        if(String.isBlank(opportunity.Chiefgeneralmanager__c)) {
            approvalRequired += '大区/二级公司总经理,';
        }
        //项目所属集团
        // if(String.isBlank(opportunity.Group__c)) {
        //     approvalRequired += '项目所属集团,';
        // }
        //大客户总经理
        if(String.isBlank(opportunity.Key_Account_General_Manager__c)) {
            approvalRequired += '大客户总经理,';
        }
        //客户二级公司
        if(String.isBlank(opportunity.Customer_Secondary_Company__c)) {
            approvalRequired += '客户二级公司,';
        }
        //省
        if(String.isBlank(opportunity.Province__c)) {
            approvalRequired += '省份,';
        }
        //市
        if(String.isBlank(opportunity.City__c)) {
            approvalRequired += '城市,';
        }
        //容量
        if(opportunity.capacity__c == null) {
            approvalRequired += '容量,';
        }
        //项目名称
        // if(String.isBlank(opportunity.Objectname__c)) {
        //     approvalRequired += '项目名称,';
        // }
        //合作背景
        if(String.isBlank(opportunity.Cooperation_Background__c)) {
            approvalRequired += '合作背景,';
        }
        //所属阶段
        if(String.isBlank(opportunity.Stage__c)) {
            approvalRequired += '所属阶段,';
        }
        //招标方式
        if(String.isBlank(opportunity.Tendermethod__c)) {
            approvalRequired += '招标方式,';
        }
        //预计)核准时间
        if(opportunity.Approvaltime__c == null) {
            approvalRequired += '(预计)核准时间,';
        }
        //招标公司
        if(String.isBlank(opportunity.Tendercompany__c)) {
            approvalRequired += '招标公司,';
        }
        //预计招标时间
        if(opportunity.Estimated_Bidding_Time__c == null) {
            approvalRequired += '预计招标时间,';
        }
        //核准机型
        if(String.isBlank(opportunity.Approvedmodel__c)) {
            approvalRequired += '核准机型,';
        }
        //招标机型
        if(String.isBlank(opportunity.Bidmodel__c)) {
            approvalRequired += '招标机型,';
        }
        //前期交流情况
        if(String.isBlank(opportunity.Precommunication__c)) {
            approvalRequired += '前期交流情况,';
        }
        //平均风速
        if(String.isBlank(opportunity.Avewindspeed__c)) {
            approvalRequired += '平均风速,';
        }
        //湍流
        if(String.isBlank(opportunity.Turbulence__c)) {
            approvalRequired += '湍流,';
        }
        //设计院
        if(String.isBlank(opportunity.Designinstitute__c)) {
            approvalRequired += '设计院,';
        }
        //设总
        if(String.isBlank(opportunity.Chiefdesigner__c)) {
            approvalRequired += '设总,';
        }
        //设总联系电话
        if(String.isBlank(opportunity.Chiefdesignerphone__c)) {
            approvalRequired += '设总联系电话,';
        }
        //可研推荐机型
        if(String.isBlank(opportunity.Recommendedmodel__c)) {
            approvalRequired += '可研推荐机型,';
        }
        //可研推荐机型理由
        if(String.isBlank(opportunity.Recommendedmodelreason__c)) {
            approvalRequired += '可研推荐机型理由,';
        }
        //设计院意向机型
        if(String.isBlank(opportunity.Designerintentmodel__c)) {
            approvalRequired += '设计院意向机型,';
        }
        //设计院意向机型理由
        if(String.isBlank(opportunity.Designerintentmodelreason__c)) {
            approvalRequired += '设计院意向机型理由,';
        }
        //业主意向机型
        if(String.isBlank(opportunity.Accountintentmodel__c)) {
            approvalRequired += '业主意向机型,';
        }
        //业主意向机型理由
        if(String.isBlank(opportunity.Accountintentmodelreason__c)) {
            approvalRequired += '业主意向机型理由,';
        }
        
        //子对象Matter_Selected_Impeller__c
        if(String.isBlank(MSI.Name)) {
            approvalRequired += '机型选比叶轮or轮毂高度.机型,';
        }
        if(MSI.Powergeneration__c==null) {
            approvalRequired += '机型选比叶轮or轮毂高度.发电量,';
        }
        if(MSI.Economicrank__c!=null) {
            approvalRequired += '机型选比叶轮or轮毂高度.经济性排名,';
        }
        if(MSI.quotedprice__c != null ) {
            approvalRequired += '机型选比叶轮or轮毂高度.报价,';
        }
         //子对象Competitor__c
         if(String.isBlank(competitor.Name)) {
            approvalRequired += '竞争对手.竞争厂家,';
        }
        if(String.isBlank(competitor.Competitivemodel__c)) {
            approvalRequired += '竞争对手.竞争机型,';
        }
        if(competitor.Powergeneration__c==null) {
            approvalRequired += '竞争对手.发电量,';
        }
        if(String.isBlank(competitor.Pre_Com_Content__c)) {
            approvalRequired += '竞争对手.前期交流,';
        }
        if(String.isBlank(competitor.Advantage__c)) {
            approvalRequired += '竞争对手.相对优势,';
        }


        if (String.isNotBlank(approvalRequired)) {
            approvalRequired = approvalRequired.substring(0, approvalRequired.length() - 1);
        }

        map_return.put('approvalRequired',approvalRequired);
        map_return.put('approvalStatus',opportunity.OpportunityApprovalStatus__c);
        
        return map_return;

    }

}