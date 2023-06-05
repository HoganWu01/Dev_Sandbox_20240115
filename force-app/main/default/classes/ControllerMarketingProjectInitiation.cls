/*
 * @Author: Conner
 * @Date: 2021-09-15 13:47:44
 * @LastEditors: Devin
 * @LastEditTime: 2022-02-21 16:02:50
 * @Descripttion: 
 */
global without sharing class ControllerMarketingProjectInitiation {
    
    /**
     * @description: 营销项目立项申请
     * @param  {*}
     * @return {*}
     */    
    @AuraEnabled(cacheable=false)
    global static String toCreateApproveMarketing(Id recordId){
        Interface_Log__c logInfo = new Interface_Log__c();
        Projectapplication__c proInit = [SELECT Id,Process_Id__c,Chiefdesignerphone__c,Precommunication__c,Applicant_Num__c,City__c,Approvaltime__c,Province__c,Manager_Secondary_Company__r.Job_Number__c,Projectmaturityanalysis__c,Approvedmodel__c,Avewindspeed__c,Background__c,Projectadvantage__c,Designinstitute__c,Chiefdesigner__c
                                        ,Bidmodel__c,County__c,Designerintentmodelreason__c,Designerintentmodel__c,Accountintentmodel__c,Support2__c,Plan__c,projectleader__r.Job_Number__c,Approvedbatch__c,General_Manager__r.Job_Number__c,General_Manager__c,projectleader__c
                                        ,Internalrateofreturnoncapital__c,Group__r.Shortname__c,Situation3__c,Accountintentmodelreason__c,Stage__c,Name2__c,Name3__c,Name1__c,Pretime__c,Name__c,ProjectName__c
                                        ,Totalinvestmentinternalrateofreturn__c,Turbulence__c,Recommendedmodelreason__c,Evalutionrulekey__c,Secondarycompany__r.Name,Secondarycompany__c,Periods__c,Evalutionrulekeyinstruction__c
                                        ,Oppty__c,Approval_Comments__c,Recommendedmodel__c,Communication__c,EPC_Bidding_Method__c,Salesdepartment__c,Projectproblemandkey__c,Situation1__c,Tendercompany__c,Tendercompany__r.Name,Tendermethod__c
                                        ,Situation2__c,Support3__c,Support1__c,Approvalstatus__c
                                        ,(SELECT Id,Powergeneration__c,Name,quotedprice__c,Economicrank__c FROM Application__r)
                                        ,(SELECT Id,Powergeneration__c,Is_Pre_Communicate__c,Advantage__c,Competitivemodel__c,Name,Pre_Com_Content__c FROM Application2__r)
                                         FROM Projectapplication__c WHERE Id =: recordId];

        Opportunity opp = [SELECT Province__c,City__c,County__c,Wind_Farm_Project_Name__c,Periods__c,capacity__c,Account.Shortname__c 
        from Opportunity where Id =:proInit.Oppty__c];

        if (proInit.Application__r.size()==0||proInit.Application2__r.size()==0) {
            return 'ApplicationIsNull';
        }
        RequestBody reqBody = new RequestBody();
        String returnId = '';
        External_System_Param__c ext = External_System_Param__c.getValues('oaMarketingProjectAdd');
        List<String> commitPrice = new List<String>(); //报价（机型选比叶轮or轮毂高度）
        List<String> totalHappen = new List<String>(); //发电量（机型选比叶轮or轮毂高度）
        List<String> rankName = new List<String>(); //经济型排名（机型选比叶轮or轮毂高度）
        List<String> robotType = new List<String>(); //机型（机型选比叶轮or轮毂高度）
        List<String> producePower = new List<String>(); //发电量内容（竞争对手）
        List<String> compareAdvantage = new List<String>(); //相对优势（竞争对手）
        List<String> equipmentComp = new List<String>(); //竞争机器内容(竞争对手)
        List<String> factoryCompetion = new List<String>(); //竞争厂家内容(竞争对手)
        List<String> formContact = new List<String>(); //前期交流内容(竞争对手)
        List<String> isFormContact = new List<String>(); //是否前期交流(竞争对手)
        for (Matter_Selected_Impeller__c mat : proInit.Application__r) {
            if (mat.quotedprice__c!=null) {
                commitPrice.add(String.valueOf(mat.quotedprice__c));
            }else {
                commitPrice.add('0');
            }
            if (mat.Economicrank__c!=null) {
                rankName.add(String.valueOf(mat.Economicrank__c));
            }else {
                rankName.add('无');
            }
            if (mat.Name!=null) {
                robotType.add(mat.Name);
            }else {
                robotType.add('无');
            }
            if (mat.Powergeneration__c!=null) {
                totalHappen.add(String.valueOf(mat.Powergeneration__c));
            }else {
                totalHappen.add('无');
            }
        }
        for (Competitor__c com : proInit.Application2__r) {
            if (com.Advantage__c!=null) {
                compareAdvantage.add(com.Advantage__c);
            }else {
                compareAdvantage.add('无');
            }
            if (com.Competitivemodel__c!=null) {
                equipmentComp.add(com.Competitivemodel__c);
            }else {
                equipmentComp.add('无');
            }
            if (com.Name!=null) {
                factoryCompetion.add(com.Name);
            }else {
                factoryCompetion.add('无');
            }
            if (com.Pre_Com_Content__c!=null) {
                formContact.add(com.Pre_Com_Content__c);
            }else {
                formContact.add('');
            }
            if (com.Is_Pre_Communicate__c!=null) {
                isFormContact.add(com.Is_Pre_Communicate__c);
            }else {
                isFormContact.add('无');
            }
            if (com.Powergeneration__c!=null) {
                producePower.add(String.valueOf(com.Powergeneration__c));
            }else {
                producePower.add('未获取');
            }
        }
        try {
            reqBody.fdId = String.isBlank(proInit.Process_Id__c)?'':proInit.Process_Id__c;//流程Id
            reqBody.auditNode = String.isBlank(proInit.Approval_Comments__c)?'请审批':proInit.Approval_Comments__c;
            reqBody.docCreator = proInit.Applicant_Num__c; //创建人
            reqBody.fd_350257d5ed5758 = proInit.Background__c; //合作背景
            reqBody.fd_350257d80f7be0 = proInit.Projectadvantage__c; //项目相对优势
            reqBody.fd_acacde_design = proInit.Designinstitute__c; //设计院
            reqBody.fd_all_design = proInit.Chiefdesigner__c; //设总
            reqBody.fd_applyer = proInit.Applicant_Num__c; //姓名(申请人)
            reqBody.fd_avg_vector = proInit.Avewindspeed__c; //平均风速
            reqBody.fd_calcuate_type = proInit.Approvedmodel__c; //核准机型
            reqBody.fd_chengshudu = proInit.Projectmaturityanalysis__c; //项目成熟度分析
            //devin 2021-11-11 从原本的查询用户 改为 查询 员工 Chiefgeneralmanager__r 取消
            reqBody.fd_chief_delegate = proInit.Manager_Secondary_Company__r.Job_Number__c; //大区/二级公司总经理
            reqBody.fd_choose_province = opp.Province__c; //省
            reqBody.fd_choose_time = proInit?.Approvaltime__c==null?'':proInit.Approvaltime__c.format(); //(预计)核准时间
            reqBody.fd_city_choose = opp.City__c; //市
            reqBody.fd_commit_price = commitPrice; //报价(机型选比叶轮or轮毂高度)
            reqBody.fd_communication_condition = proInit.Precommunication__c; //前期交流情况
            reqBody.fd_compare_advantage = compareAdvantage; //相对优势内容
            reqBody.fd_competion_type = proInit.Bidmodel__c==null?'':proInit.Bidmodel__c; //招标机型
            reqBody.fd_contact_phone = proInit.Chiefdesignerphone__c; //设总联系电话
            reqBody.fd_county_choose = opp.County__c==null?'':opp.County__c; //县
            reqBody.fd_design_resaon = proInit.Designerintentmodelreason__c==null?'':proInit.Designerintentmodelreason__c; //设计院意向机型理由2
            reqBody.fd_design_type = proInit.Designerintentmodel__c==null?'':proInit.Designerintentmodel__c; //设计院意向机型
            reqBody.fd_engine_type = proInit.Accountintentmodel__c==null?'':proInit.Accountintentmodel__c; //业主意向机型
            reqBody.fd_equipment_comp = equipmentComp; //竞争机器内容
            reqBody.fd_erji_gongsi = proInit.Support2__c; //二级公司
            reqBody.fd_factory_competion = factoryCompetion; //竞争厂家内容
            reqBody.fd_fangdan_details = proInit.Plan__c==null?'':proInit.Plan__c; //行动计划（商务、技术、其他）
            reqBody.fd_form_contact = formContact; //前期交流内容
            reqBody.fd_group_leader = proInit?.projectleader__c==null?'':proInit?.projectleader__r.Job_Number__c; //项目组长提名
            reqBody.fd_hezhun_num = proInit.Approvedbatch__c==null?'':proInit.Approvedbatch__c; //核准批次
            reqBody.fd_inner_percent = proInit.Totalinvestmentinternalrateofreturn__c==null?0:Double.valueOf(proInit.Totalinvestmentinternalrateofreturn__c); //总投资内部收益率(%)
            reqBody.fd_is_form_contact = isFormContact; //是否前期交流
            reqBody.fd_jituan_attribute = opp.Account.Shortname__c; //项目所属集团
            reqBody.fd_jituan_attribute_text = opp.Account.Shortname__c; //项目所属集团text
            reqBody.fd_jituan_gongsi = proInit.Situation3__c==null?'':proInit.Situation3__c; //集团公司
            reqBody.fd_jituan_other = ''; //项目所属集团其他
            reqBody.fd_main_reason = proInit.Accountintentmodelreason__c==null?'':proInit.Accountintentmodelreason__c; //业主意向机型理由
            //devin 2021-11-11 改为查找 员工
            reqBody.fd_manager = proInit?.General_Manager__c==null?'':proInit?.General_Manager__r.Job_Number__c; //大客户总经理
            reqBody.fd_period_attr = proInit.Stage__c; //所属阶段
            reqBody.fd_person_post_erji = proInit.Name2__c==null?'':proInit.Name2__c; //姓名/职位（二级公司）
            reqBody.fd_person_post_jituan = proInit.Name3__c==null?'':proInit.Name3__c; //姓名/职位（集团公司）
            reqBody.fd_person_post_xm = proInit.Name1__c==null?'':proInit.Name1__c; //姓名/职位（项目公司）
            reqBody.fd_prepare_time = proInit.Pretime__c==null?'':proInit.Pretime__c.format(); //预计招标时间
            reqBody.fd_produce_power = producePower; //发电量内容
            reqBody.fd_proj_name = opp.Wind_Farm_Project_Name__c==null?'':opp.Wind_Farm_Project_Name__c; //风场项目名
            reqBody.fd_project_name = proInit.ProjectName__c==null?'':proInit.ProjectName__c; //项目名称
            reqBody.fd_quick_flow = proInit.Turbulence__c==null?'':proInit.Turbulence__c; //湍流
            reqBody.fd_rank_name = rankName; //经济性排名
            reqBody.fd_reason = proInit.Recommendedmodelreason__c==null?'':proInit.Recommendedmodelreason__c; //可研推荐机型理由1
            if (proInit.Evalutionrulekey__c=='机型选比重要性') {
                reqBody.fd_robot_choose = '机型选比重要性'; //评标规则重点_robot(机型选比重要性按钮)
                reqBody.fd_text_robot = proInit.Evalutionrulekeyinstruction__c==null?'':proInit.Evalutionrulekeyinstruction__c;//评标规则重点_text_robot(机型选比重要性文本)
            }else {
                reqBody.fd_robot_choose = '';
                reqBody.fd_text_robot = '';
            }
            reqBody.fd_robot_type = robotType; //机型
            reqBody.fd_salary_percent = proInit.Internalrateofreturnoncapital__c==null?0:Double.valueOf(proInit.Internalrateofreturnoncapital__c); //资本金内部收益率(%)
            reqBody.fd_second_company = proInit?.Secondarycompany__c==null?'':proInit.Secondarycompany__r.Name; //客户二级公司
            reqBody.fd_stage = String.isBlank(opp.Periods__c)?'':opp.Periods__c; //期数
            if (proInit.Evalutionrulekey__c=='可研重要性'){
                reqBody.fd_study_important = '可研重要性'; //评标规则重点(可研重要性按钮)
                reqBody.fd_study_text = proInit.Evalutionrulekeyinstruction__c==null?'':proInit.Evalutionrulekeyinstruction__c;//评标规则重点_text（可研重要性文本）
            }else {
                reqBody.fd_study_important='';
                reqBody.fd_study_text = '';
            }
            reqBody.fd_study_ype = proInit.Recommendedmodel__c==null?'':proInit.Recommendedmodel__c;//可研推荐机型
            reqBody.fd_text_communication = proInit.Communication__c==null?'':proInit.Communication__c;//交流内容及效果
            reqBody.fd_text_fangan = proInit.EPC_Bidding_Method__c==null?'':proInit.EPC_Bidding_Method__c;//EPC方招标招标方式
            reqBody.fd_total_happen = totalHappen;//发电量(/h)
            reqBody.fd_total_in = String.valueOf(opp.capacity__c);//容量
            reqBody.fd_war_zone = proInit.Salesdepartment__c==null?'':proInit.Salesdepartment__c;//所属大区/二级公司
            reqBody.fd_wenti_guanjian = proInit.Projectproblemandkey__c==null?'':proInit.Projectproblemandkey__c;//项目问题点及关键点
            reqBody.fd_xiangmu_gongsi = proInit.Situation1__c==null?'':proInit.Situation1__c;//项目公司
            reqBody.fd_zhao_company = proInit?.Tendercompany__c==null?'':proInit.Tendercompany__r.Name;//招标公司
            reqBody.fd_zhaobiao_way = proInit.Tendermethod__c==null?'':proInit.Tendermethod__c;//招标方式
            reqBody.fd_zhichi_erji = proInit.Situation2__c==null?'':proInit.Situation2__c;//支持情况（二级公司）二级公司
            reqBody.fd_zhichi_jituan = proInit.Support3__c==null?'':proInit.Support3__c;//支持情况（集团公司）集团公司
            reqBody.fd_zhichi_xm = proInit.Support1__c==null?'':proInit.Support1__c;//支持情况（项目公司）项目公司
            //devin 2021-11-11 改为查找员工
            // reqBody.n23 = proInit?.General_Manager__c==null?'':proInit?.General_Manager__r.Job_Number__c;//大客户总监
            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'ControllerMarketingProjectInitiation',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
            if (response.substring(0,5) == 'Error') {
                return response;
            }else {
                
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                if (resBody.code == 200) {
                    String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();

                    //先判断是否是驳回状态，用于更新中间表状态
                    // Boolean updateMiddleTableSign = false;
                    // String findId = '';
                    // if (!String.isBlank(proInit.Process_Id__c)&&(proInit.Approvalstatus__c=='11'||proInit.Approvalstatus__c=='10')) {
                    //     updateMiddleTableSign = true;
                    //     findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:proInit.Id AND RecordTypeId =: recTypeId].Id;
                    // }


                    Projectapplication__c updateReq = new Projectapplication__c();
                    updateReq.Id = proInit.Id;
                    updateReq.Process_Id__c = resBody.data.fdId;
                    updateReq.ApplicantionNumber__c = resBody.data.docSubject;
                    returnId = resBody.data.fdId;
                    updateReq.Approvalstatus__c = '20';
                    update updateReq;   //更新回流程id
                    Opportunity oppUpdate = new Opportunity();
                    oppUpdate.Id = proInit.Oppty__c;//业务机会Id
                    oppUpdate.StageName = '项目立项';
                    oppUpdate.Is_Manual_Modification__c = false;//devin add 2022-02-21 
                    update oppUpdate;

                    //插入或更新数据到集成中间表
                    Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                    // if (updateMiddleTableSign) {
                    //     middleForm.id = findId;
                    //     middleForm.Approvalstatus__c = '20';//审批状态
                    //     update middleForm;
                    // }else {
                        middleForm.RecordTypeId = recTypeId;//赋值记录类型
                        middleForm.Object_API__c = 'Projectapplication__c';//对象API
                        middleForm.Mapping_Object_Id__c = proInit.Id;//对应对象的Id
                        middleForm.Scheme_Type__c = null;//方案类型
                        middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        upsert middleForm Process_Id__c;
                    // }
                    
                    
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerMarketingProjectInitiation';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerMarketingProjectInitiation';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
                }
            }
            return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+returnId+'&loginName='+proInit.Applicant_Num__c+'&identification=CRM';
        } catch (Exception e) {
            logInfo.RequestURL__c = ext.Request_URL__c;
			logInfo.ClassName__c = 'ControllerMarketingProjectInitiation';
			logInfo.RequestBody__c = JSON.serialize(reqBody);
			logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
        }
        
    }
    public class RequestBody {
        public String fdId{get;set;}//已驳回携带流程id
        public String auditNode{get;set;} //审批意见
        public String docCreator{get;set;} //创建人
        public String fd_350257d5ed5758{get;set;} //合作背景
        public String fd_350257d80f7be0{get;set;} //项目相对优势
        public String fd_acacde_design{get;set;} //设计院
        public String fd_all_design{get;set;} //设总
        public String fd_applyer{get;set;} //姓名
        public String fd_avg_vector{get;set;} //平均风速
        public String fd_calcuate_type{get;set;} //核准机型
        public String fd_chengshudu{get;set;} //项目成熟度分析
        public String fd_chief_delegate{get;set;} //大区/二级公司总经理
        public String fd_choose_province{get;set;} //省
        public String fd_choose_time{get;set;}//(预计)核准时间
        public String fd_city_choose{get;set;}//市
        public List<String> fd_commit_price{get;set;}//报价
        public String fd_communication_condition{get;set;} //前期交流情况
        public List<String> fd_compare_advantage{get;set;} //相对优势内容
        public String fd_competion_type{get;set;} //招标机型
        public String fd_contact_phone{get;set;} //设总联系电话
        public String fd_county_choose{get;set;} //县
        public String fd_design_resaon{get;set;} //设计院意向机型理由2
        public String fd_design_type{get;set;} //设计院意向机型
        public String fd_engine_type{get;set;} //业主意向机型
        public List<String> fd_equipment_comp{get;set;}//竞争机器内容(竞争机型)
        public String fd_erji_gongsi{get;set;}//	二级公司
        public List<String> fd_factory_competion{get;set;}//竞争厂家内容
        public String fd_fangdan_details{get;set;}//行动计划（商务、技术、其他）
        public List<String> fd_form_contact{get;set;}//前期交流内容（竞争对手）
        public String fd_group_leader{get;set;}//项目组长提名
        public String fd_hezhun_num{get;set;}//核准批次
        public Double fd_inner_percent{get;set;}//总投资内部收益率(%)
        public List<String> fd_is_form_contact{get;set;}//是否前期交流
        public String fd_jituan_attribute{get;set;}//项目所属集团
        public String fd_jituan_attribute_text{get;set;}//项目所属集团
        public String fd_jituan_gongsi{get;set;}//集团公司
        public String fd_jituan_other{get;set;}//项目所属集团_其他
        public String fd_main_reason{get;set;}//理由:(业主意向机型)
        public String fd_manager{get;set;}//	大客户总经理
        public String fd_period_attr{get;set;}//所属阶段
        public String fd_person_post_erji{get;set;}//姓名/职位（二级公司）
        public String fd_person_post_jituan{get;set;}//姓名/职位（集团公司）
        public String fd_person_post_xm{get;set;}//姓名/职位（项目公司）
        public String fd_prepare_time{get;set;}//预计招标时间
        public List<String> fd_produce_power{get;set;}//发电量内容
        public String fd_proj_name{get;set;}//风场项目名
        public String fd_project_name{get;set;}//项目名称
        public String fd_quick_flow{get;set;}//湍流
        public List<String> fd_rank_name{get;set;}//经济性排名
        public String fd_reason{get;set;}//可研推荐机型理由1
        public String fd_robot_choose{get;set;}//评标规则重点_robot(机型选比重要性按钮)
        public List<String> fd_robot_type{get;set;}//机型
        public Double fd_salary_percent{get;set;}//资本金内部收益率(%)
        public String fd_second_company{get;set;}//客户二级公司
        public String fd_stage{get;set;}//期数
        public String fd_study_important{get;set;}//评标规则重点(可研重要性按钮)
        public String fd_study_text{get;set;}//评标规则重点_text（可研重要性文本）
        public String fd_study_ype{get;set;}//可研推荐机型
        public String fd_text_communication{get;set;}//交流内容及效果
        public String fd_text_fangan{get;set;}//EPC方招标招标方式
        public String fd_text_robot{get;set;}//评标规则重点_text_robot(机型选比重要性文本)
        public List<String> fd_total_happen{get;set;}//发电量(/h)
        public String fd_total_in{get;set;}//容量
        public String fd_war_zone{get;set;}//所属大区/二级公司
        public String fd_wenti_guanjian{get;set;}//项目问题点及关键点
        public String fd_xiangmu_gongsi{get;set;}//项目公司
        public String fd_zhao_company{get;set;}//招标公司
        public String fd_zhaobiao_way{get;set;}//招标方式
        public String fd_zhichi_erji{get;set;}//支持情况（二级公司）二级公司
        public String fd_zhichi_jituan{get;set;}//	支持情况（集团公司）集团公司
        public String fd_zhichi_xm{get;set;}//支持情况（项目公司）项目公司
        public String n23{get;set;}//大客户总监
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public Data data{get;set;} 
    }
    public class Data {
        public String rtStatus{get;set;}
        public String rtMsg{get;set;}
        public String fdId{get;set;}
        public String docSubject{get;set;}
        public String fdNumber{get;set;}
    } 
}