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
                                        ,Bidmodel__c,County__c,Designerintentmodelreason__c,Designerintentmodel__c,Accountintentmodel__c,Plan__c,Approvedbatch__c,General_Manager__r.Job_Number__c,General_Manager__c
                                        ,Internalrateofreturnoncapital__c,Group__r.Shortname__c,Accountintentmodelreason__c,Stage__c,Name2__c,Name3__c,Name1__c,Pretime__c,Name__c,ProjectName__c
                                        ,Totalinvestmentinternalrateofreturn__c,Turbulence__c,Recommendedmodelreason__c,Evalutionrulekey__c,Secondarycompany__r.Name,Secondarycompany__c,Periods__c,Evalutionrulekeyinstruction__c
                                        ,Oppty__c,Approval_Comments__c,Recommendedmodel__c,Communication__c,EPC_Bidding_Method__c,Salesdepartment__c,Projectproblemandkey__c,Tendercompany__c,Tendercompany__r.Name,Tendermethod__c
                                        ,Approvalstatus__c,MW__c
                                        ,(SELECT Id,Powergeneration__c,Name,quotedprice__c,Economicrank__c FROM Application__r)
                                        ,(SELECT Id,Powergeneration__c,Is_Pre_Communicate__c,Advantage__c,Competitivemodel__c,Name,Pre_Com_Content__c FROM Application2__r)
                                        //###### Thu Jun 8 17:20:32 CST 2023
                                        ,XiangmuGongsi__c,ErjiGongsi__c,JituanGongsi__c,ProcessType__c,TargetCapacity__c
                                        ,DesigningInstitute__c,GovernmentSide__c,ProjectType__c,Pre_Sales_Project_Manager__c,Pre_Sales_Project_Manager__r.Job_Number__c
                                        ,(SELECT Name,PersonPostXm__c,ZhichiXm__c,PersonTelXm__c,PersonSuqiuXm__c,PersonOtherXm__c FROM XmProjectApplication__r)
                                        ,(SELECT Name,PersonPostErji__c,ZhichiErji__c,PersonTelErji__c,PersonSuqiuErji__c,PersonOtherErji__c FROM ErjiProjectApplication__r)
                                        ,(SELECT Name,PersonPostJt__c,ZhichiJt__c,PersonTelJt__c,PersonSuqiuJt__c,PersonOtherJt__c FROM JituanProjectApplication__r)
                                        ,(SELECT Name,PersonPostDes__c,ZhichiDes__c,PersonTelDes__c,PersonSuqiuDes__c,PersonOtherDes__c FROM DesignProjectApplication__r)
                                        ,(SELECT Name,PersonPostGov__c,ZhichiGov__c,PersonTelGov__c,PersonSuqiuGov__c,PersonOtherGov__c FROM GovernmentProjectApplication__r)
                                        ,MarketBidDept__c,GroupLeader__c,GroupLeader__r.Job_Number__c,ProjectMember__c,ModelSelect__c,RoadSurvey__c,LogisticsTran__c,MicroSelection__c
                                        ,PowerSelection__c,OtherSelection__c,TechnicalProblem__c,PlanSecurity__c,PlanStrategy__c
                                        ,KeyContent__c,PathWay__c,ProblemCustomer__c,ProblemBase__c,ProblemProgram__c,ProblemOther__c
                                        ,(SELECT Name,ZhichiCust__c,PersonSuqiuCust__c,PersonOtherCust__c FROM CustomerProjectApplication__r)
                                        ,(SELECT Name,CustomerAdvantages__c,CustomerWeaknesses__c,TechAdvantages__c,TechWeaknesses__c,CostAdvantages__c,CostWeaknesses__c,OtherAdvantages__c,OtherWeaknesses__c,CompetitorRemark__c FROM CompetitorProjectApplication__r)
                                        ,(SELECT Name,ComplementaryReason__c,ComplementaryEffect__c,ComplementaryStrategies__c,ComplementaryOther__c FROM ComplementaryProjectApplication__r)
                                        ,(SELECT Name,SupplierReason__c,SupplierEffect__c,SupplierStrategies__c,SupplierOther__c FROM SupplierProjectApplication__r)
                                         FROM Projectapplication__c WHERE Id =: recordId];

        Projectapplication__c proInit2 = [SELECT Id,toLabel(MarketBidDept__c) FROM Projectapplication__c WHERE Id =: recordId];


        if (proInit.Stage__c == null || proInit.Tendermethod__c == null) {
            return 'RequiredIsNull';
        }

        Opportunity opp = [SELECT Province__c,City__c,County__c,Wind_Farm_Project_Name__c,Periods__c,capacity__c,Account.Shortname__c 
        from Opportunity where Id =:proInit.Oppty__c];

        if (proInit.Application__r.size()==0||proInit.Application2__r.size()==0) {
            return 'ApplicationIsNull';
        }

        if (proInit.XiangmuGongsi__c == '已获悉' && proInit.XmProjectApplication__r.size()==0) {
            return 'XmProjectApplicationIsNull';
        }

        if (proInit.ErjiGongsi__c == '已获悉' && proInit.ErjiProjectApplication__r.size()==0) {
            return 'ErjiProjectApplicationIsNull';
        }

        if (proInit.JituanGongsi__c == '已获悉' && proInit.JituanProjectApplication__r.size()==0) {
            return 'JituanProjectApplicationIsNull';
        }

        if (proInit.DesigningInstitute__c == '已获悉' && proInit.DesignProjectApplication__r.size()==0) {
            return 'DesignProjectApplicationIsNull';
        }

        if (proInit.GovernmentSide__c == '已获悉' && proInit.GovernmentProjectApplication__r.size()==0) {
            return 'GovernmentProjectApplicationIsNull';
        }

        //容量大于200MW，参与者分析不为空
        if ( proInit.MW__c != null && Integer.valueOf(proInit.MW__c) >= 200 && 
            (proInit.CustomerProjectApplication__r.size()==0 
            || proInit.CompetitorProjectApplication__r.size()==0 
            || proInit.ComplementaryProjectApplication__r.size()==0 
            || proInit.SupplierProjectApplication__r.size()==0)
            ) {
            return 'ParticipantAnalysisIsNull';
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

        List<String> nameXm = new List<String>(); //姓名(项目公司)
        List<String> personPostXm = new List<String>(); //职位(项目公司)
        List<String> zhichiXm = new List<String>(); //支持情况(项目公司)
        List<String> personTelXm = new List<String>(); //联系方式(项目公司)
        List<String> personSuqiuXm = new List<String>(); //诉求情况(项目公司)
        List<String> personOtherXm = new List<String>(); //其他(项目公司)
        
        for (XmDetails__c detail : proInit.XmProjectApplication__r) {
            nameXm.add(detail.Name);
            personPostXm.add(detail.PersonPostXm__c==null?'':detail.PersonPostXm__c);
            zhichiXm.add(detail.ZhichiXm__c==null?'':detail.ZhichiXm__c);
            personTelXm.add(detail.PersonTelXm__c==null?'':String.valueOf(detail.PersonTelXm__c));
            personSuqiuXm.add(detail.PersonSuqiuXm__c==null?'':detail.PersonSuqiuXm__c);
            personOtherXm.add(detail.PersonOtherXm__c==null?'':detail.PersonOtherXm__c);
        }
        
        List<String> nameErji = new List<String>(); //姓名(二级公司)
        List<String> personPostErji = new List<String>(); //职位(二级公司)
        List<String> zhichiErji = new List<String>(); //支持情况(二级公司)
        List<String> personTelErji = new List<String>(); //联系方式(二级公司)
        List<String> personSuqiuErji = new List<String>(); //诉求情况(二级公司)
        List<String> personOtherErji = new List<String>(); //其他(二级公司)

        for (ErjiDetails__c detail : proInit.ErjiProjectApplication__r) {
            nameErji.add(detail.Name);
            personPostErji.add(detail.PersonPostErji__c==null?'':detail.PersonPostErji__c);
            zhichiErji.add(detail.ZhichiErji__c==null?'':detail.ZhichiErji__c);
            personTelErji.add(detail.PersonTelErji__c==null?'':String.valueOf(detail.PersonTelErji__c));
            personSuqiuErji.add(detail.PersonSuqiuErji__c==null?'':detail.PersonSuqiuErji__c);
            personOtherErji.add(detail.PersonOtherErji__c==null?'':detail.PersonOtherErji__c);
        }

        List<String> nameJt = new List<String>(); //姓名(集团公司)
        List<String> personPostJt = new List<String>(); //职位(集团公司)
        List<String> zhichiJt = new List<String>(); //支持情况(集团公司)
        List<String> personTelJt = new List<String>(); //联系方式(集团公司)
        List<String> personSuqiuJt = new List<String>(); //诉求情况(集团公司)
        List<String> personOtherJt = new List<String>(); //其他(集团公司)

        for (JituanDetails__c detail : proInit.JituanProjectApplication__r) {
            nameJt.add(detail.Name);
            personPostJt.add(detail.PersonPostJt__c==null?'':detail.PersonPostJt__c);
            zhichiJt.add(detail.ZhichiJt__c==null?'':detail.ZhichiJt__c);
            personTelJt.add(detail.PersonTelJt__c==null?'':String.valueOf(detail.PersonTelJt__c));
            personSuqiuJt.add(detail.PersonSuqiuJt__c==null?'':detail.PersonSuqiuJt__c);
            personOtherJt.add(detail.PersonOtherJt__c==null?'':detail.PersonOtherJt__c);
        }

        List<String> nameDes = new List<String>(); //姓名(设计院)
        List<String> personPostDes = new List<String>(); //职位(设计院)
        List<String> zhichiDes = new List<String>(); //支持情况(设计院)
        List<String> personTelDes = new List<String>(); //联系方式(设计院)
        List<String> personSuqiuDes = new List<String>(); //诉求情况(设计院)
        List<String> personOtherDes = new List<String>(); //其他(设计院)

        for (DesigningDetails__c detail : proInit.DesignProjectApplication__r) {
            nameDes.add(detail.Name);
            personPostDes.add(detail.PersonPostDes__c==null?'':detail.PersonPostDes__c);
            zhichiDes.add(detail.ZhichiDes__c==null?'':detail.ZhichiDes__c);
            personTelDes.add(detail.PersonTelDes__c==null?'':String.valueOf(detail.PersonTelDes__c));
            personSuqiuDes.add(detail.PersonSuqiuDes__c==null?'':detail.PersonSuqiuDes__c);
            personOtherDes.add(detail.PersonOtherDes__c==null?'':detail.PersonOtherDes__c);
        }

        List<String> nameGov = new List<String>(); //姓名(政府侧)
        List<String> personPostGov = new List<String>(); //职位(政府侧)
        List<String> zhichiGov = new List<String>(); //支持情况(政府侧)
        List<String> personTelGov = new List<String>(); //联系方式(政府侧)
        List<String> personSuqiuGov = new List<String>(); //诉求情况(政府侧)
        List<String> personOtherGov = new List<String>(); //其他(政府侧)
        
        for (GovernmentDetails__c detail : proInit.GovernmentProjectApplication__r) {
            nameGov.add(detail.Name);
            personPostGov.add(detail.PersonPostGov__c==null?'':detail.PersonPostGov__c);
            zhichiGov.add(detail.ZhichiGov__c==null?'':detail.ZhichiGov__c);
            personTelGov.add(detail.PersonTelGov__c==null?'':String.valueOf(detail.PersonTelGov__c));
            personSuqiuGov.add(detail.PersonSuqiuGov__c==null?'':detail.PersonSuqiuGov__c);
            personOtherGov.add(detail.PersonOtherGov__c==null?'':detail.PersonOtherGov__c);
        }

        //顾客分析
        List<String> c1List = new List<String>();
        List<String> c2List = new List<String>();
        List<String> c3List = new List<String>();
        List<String> c4List = new List<String>();
        
        for (CustomerAnalysis__c detail : proInit.CustomerProjectApplication__r) {
            c1List.add(detail.Name);
            c2List.add(detail.ZhichiCust__c==null?'':detail.ZhichiCust__c);
            c3List.add(detail.PersonSuqiuCust__c==null?'':detail.PersonSuqiuCust__c);
            c4List.add(detail.PersonOtherCust__c==null?'':detail.PersonOtherCust__c);
        }

        //竞争者分析
        List<String> co1List = new List<String>();
        List<String> co2List = new List<String>();
        List<String> co3List = new List<String>();
        List<String> co4List = new List<String>();
        List<String> co5List = new List<String>();
        List<String> co6List = new List<String>();
        List<String> co7List = new List<String>();
        List<String> co8List = new List<String>();
        List<String> co9List = new List<String>();
        List<String> co10List = new List<String>();
        
        for (CompetitorAnalysis__c detail : proInit.CompetitorProjectApplication__r) {
            co1List.add(detail.Name);
            co2List.add(detail.CustomerAdvantages__c==null?'':detail.CustomerAdvantages__c);
            co3List.add(detail.CustomerWeaknesses__c==null?'':detail.CustomerWeaknesses__c);
            co4List.add(detail.TechAdvantages__c==null?'':detail.TechAdvantages__c);
            co5List.add(detail.TechWeaknesses__c==null?'':detail.TechWeaknesses__c);
            co6List.add(detail.CostAdvantages__c==null?'':detail.CostAdvantages__c);
            co7List.add(detail.CostWeaknesses__c==null?'':detail.CostWeaknesses__c);
            co8List.add(detail.OtherAdvantages__c==null?'':detail.OtherAdvantages__c);
            co9List.add(detail.OtherWeaknesses__c==null?'':detail.OtherWeaknesses__c);
            co10List.add(detail.CompetitorRemark__c==null?'':detail.CompetitorRemark__c);
        }

        //互补者分析
        List<String> cl1List = new List<String>();
        List<String> cl2List = new List<String>();
        List<String> cl3List = new List<String>();
        List<String> cl4List = new List<String>();
        List<String> cl5List = new List<String>();
        
        for (ComplementaryAnalysis__c detail : proInit.ComplementaryProjectApplication__r) {
            cl1List.add(detail.Name);
            cl2List.add(detail.ComplementaryReason__c==null?'':detail.ComplementaryReason__c);
            cl3List.add(detail.ComplementaryEffect__c==null?'':detail.ComplementaryEffect__c);
            cl4List.add(detail.ComplementaryStrategies__c==null?'':detail.ComplementaryStrategies__c);
            cl5List.add(detail.ComplementaryOther__c==null?'':detail.ComplementaryOther__c);
        }

        //供应商分析
        List<String> s1List = new List<String>();
        List<String> s2List = new List<String>();
        List<String> s3List = new List<String>();
        List<String> s4List = new List<String>();
        List<String> s5List = new List<String>();

        for (SupplierAnalysis__c detail : proInit.SupplierProjectApplication__r) {
            s1List.add(detail.Name);
            s2List.add(detail.SupplierReason__c==null?'':detail.SupplierReason__c);
            s3List.add(detail.SupplierEffect__c==null?'':detail.SupplierEffect__c);
            s4List.add(detail.SupplierStrategies__c==null?'':detail.SupplierStrategies__c);
            s5List.add(detail.SupplierOther__c==null?'':detail.SupplierOther__c);
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
            reqBody.fd_erji_gongsi = proInit.ErjiGongsi__c==null?'':proInit.ErjiGongsi__c; //二级公司
            reqBody.fd_factory_competion = factoryCompetion; //竞争厂家内容
            reqBody.fd_form_contact = formContact; //前期交流内容
            reqBody.fd_group_leader = proInit?.GroupLeader__c==null?'':proInit?.GroupLeader__r.Job_Number__c; //项目主将
            reqBody.fd_hezhun_num = proInit.Approvedbatch__c==null?'':proInit.Approvedbatch__c; //核准批次
            reqBody.fd_inner_percent = proInit.Totalinvestmentinternalrateofreturn__c==null?0:Double.valueOf(proInit.Totalinvestmentinternalrateofreturn__c); //总投资内部收益率(%)
            reqBody.fd_is_form_contact = isFormContact; //是否前期交流
            reqBody.fd_jituan_attribute = opp.Account.Shortname__c; //项目所属集团
            reqBody.fd_jituan_attribute_text = opp.Account.Shortname__c; //项目所属集团text
            reqBody.fd_jituan_gongsi = proInit.JituanGongsi__c==null?'':proInit.JituanGongsi__c; //集团公司
            reqBody.fd_jituan_other = ''; //项目所属集团其他
            reqBody.fd_main_reason = proInit.Accountintentmodelreason__c==null?'':proInit.Accountintentmodelreason__c; //业主意向机型理由
            //devin 2021-11-11 改为查找 员工
            reqBody.fd_manager = proInit?.General_Manager__c==null?'':proInit?.General_Manager__r.Job_Number__c; //大客户总经理
            reqBody.fd_period_attr = proInit.Stage__c; //所属阶段
            reqBody.fd_person_post_jituan = proInit.Name3__c==null?'':proInit.Name3__c; //姓名/职位（集团公司）
            
            reqBody.fd_prepare_time = proInit.Pretime__c==null?'':proInit.Pretime__c.format(); //预计挂网时间
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
            reqBody.fd_xiangmu_gongsi = proInit.XiangmuGongsi__c==null?'':proInit.XiangmuGongsi__c;//项目公司
            reqBody.fd_zhao_company = proInit?.Tendercompany__c==null?'':proInit.Tendercompany__r.Name;//招标公司
            reqBody.fd_zhaobiao_way = proInit.Tendermethod__c==null?'':proInit.Tendermethod__c;//招标方式
            // reqBody.fd_zhichi_jituan = proInit.Support3__c==null?'':proInit.Support3__c;//支持情况（集团公司）集团公司

            //###### Fri Jun 9 15:34:29 CST 2023
            reqBody.fd_sub_division = proInit.MarketBidDept__c==null?'':proInit.MarketBidDept__c;//项目所属客户分部
            reqBody.fd_sub_division_text = proInit2.MarketBidDept__c==null?'':proInit2.MarketBidDept__c;//项目所属客户分部
            reqBody.fd_project_member = proInit?.ProjectMember__c==null?'':proInit.ProjectMember__c; //项目组成员
            reqBody.fd_project_type = proInit?.ProjectType__c==null?'':proInit.ProjectType__c;//项目类型

            reqBody.fd_model_select = proInit?.ModelSelect__c==null?'':proInit.ModelSelect__c;//机型比选
            reqBody.fd_road_survey = proInit?.RoadSurvey__c==null?'':proInit.RoadSurvey__c;//路勘及路改
            reqBody.fd_logistics_tran = proInit?.LogisticsTran__c==null?'':proInit.LogisticsTran__c;//物流运输
            reqBody.fd_micro_selection = proInit?.MicroSelection__c==null?'':proInit.MicroSelection__c;//微观选址
            reqBody.fd_power_selection = proInit?.PowerSelection__c==null?'':proInit.PowerSelection__c;//发电量比选
            reqBody.fd_other_selection = proInit?.OtherSelection__c==null?'':proInit.OtherSelection__c;//其他
            reqBody.fd_technical_problem = proInit?.TechnicalProblem__c==null?'':proInit.TechnicalProblem__c;//存在的技术问题
            reqBody.fd_designing_institute = proInit?.DesigningInstitute__c==null?'':proInit.DesigningInstitute__c;//设计院（已获悉、未获悉）
            reqBody.fd_government_side = proInit?.GovernmentSide__c==null?'':proInit.GovernmentSide__c;//政府侧
            reqBody.fd_pre_pm = proInit.Pre_Sales_Project_Manager__c==null?'':proInit.Pre_Sales_Project_Manager__r.Job_Number__c;//售前项目经理
            reqBody.fd_process_type = proInit.ProcessType__c==null?'':proInit.ProcessType__c;//流程类型
            reqBody.fd_target_capacity = String.valueOf(proInit.TargetCapacity__c);//目标获取容量

            reqBody.fd_person_name_xm = nameXm;//项目公司明细-姓名
            reqBody.fd_person_post_xm = personPostXm;//项目公司明细-职位
            reqBody.fd_zhichi_xm = zhichiXm;//项目公司明细-支持情况
            reqBody.fd_person_tel_xm = personTelXm;//项目公司明细-联系方式（保密）
            reqBody.fd_person_suqiu_xm = personSuqiuXm;//项目公司明细-诉求
            reqBody.fd_person_other_xm = personOtherXm;//项目公司明细其他

            reqBody.fd_person_name_erji = nameErji;//二级公司明细-姓名
            reqBody.fd_person_post_erji = personPostErji;//二级公司明细-职位
            reqBody.fd_zhichi_erji = zhichiErji;//二级公司明细-支持情况
            reqBody.fd_person_tel_erji = personTelErji;//二级公司明细-联系方式（保密）
            reqBody.fd_person_suqiu_erji = personSuqiuErji;//二级公司明细-诉求
            reqBody.fd_person_other_erji = personOtherErji;//二级公司明细其他

            reqBody.fd_person_name_jt = nameJt;//集团公司明细-姓名
            reqBody.fd_person_post_jt = personPostJt;//集团公司明细-职位
            reqBody.fd_zhichi_jt = zhichiJt;//集团公司明细-支持情况
            reqBody.fd_person_tel_jt = personTelJt;//集团公司明细-联系方式（保密）
            reqBody.fd_person_suqiu_jt = personSuqiuJt;//集团公司明细-诉求
            reqBody.fd_person_other_jt = personOtherJt;//集团公司明细其他
            
            reqBody.fd_person_name_des = nameDes;//设计院明细-姓名
            reqBody.fd_person_post_des = personPostDes;//设计院明细-职位
            reqBody.fd_zhichi_des = zhichiDes;//设计院明细-支持情况
            reqBody.fd_person_tel_des = personTelDes;//设计院明细-联系方式（保密）
            reqBody.fd_person_suqiu_des = personSuqiuDes;//设计院明细-诉求
            reqBody.fd_person_other_des = personOtherDes;//设计院明细其他

            reqBody.fd_person_name_gov = nameGov;//政府侧明细-姓名
            reqBody.fd_person_post_gov = personPostGov;//政府侧明细-职位
            reqBody.fd_zhichi_gov = zhichiGov;//政府侧明细-支持情况
            reqBody.fd_person_tel_gov = personTelGov;//政府侧明细-联系方式（保密）
            reqBody.fd_person_suqiu_gov = personSuqiuGov;//政府侧明细-诉求
            reqBody.fd_person_other_gov = personOtherGov;//政府侧明细其他

            reqBody.fd_plan_security = proInit.PlanSecurity__c;//保密性
            reqBody.fd_plan_strategy = proInit.PlanStrategy__c;//项目策略
            reqBody.fd_fangdan_details = proInit.Plan__c==null?'':proInit.Plan__c; //行动计划

            reqBody.fd_person_name_cust = c1List;//顾客分析
            reqBody.fd_zhichi_cust = c2List;//顾客分析-支持情况
            reqBody.fd_person_other_cust = c3List;//顾客分析-其他
            reqBody.fd_person_suqiu_cust = c4List;//顾客分析-顾客诉求

            reqBody.fd_competitor_item = co1List;//竞争者分析-竞争者
            reqBody.fd_cost_advantages = co2List;//竞争者分析-价格及度电成本优势
            reqBody.fd_cost_weaknesses = co3List;//竞争者分析-价格及度电成本劣势
            reqBody.fd_customer_advantages = co4List;//竞争者分析-客户关系优势
            reqBody.fd_customer_weaknesses = co5List;//竞争者分析-客户关系劣势
            reqBody.fd_other_advantages = co6List;//竞争者分析-其他优势
            reqBody.fd_tech_advantages = co7List;//竞争者分析-技术方案优势
            reqBody.fd_tech_weaknesses = co8List;//竞争者分析-技术方案劣势
            reqBody.fd_competitor_remark = co9List;//竞争者分析-备注
            reqBody.fd_other_weaknesses = co10List;//竞争者分析-其他劣势

            reqBody.fd_complementary_effect = cl1List;//互补者分析-互补者能产生的影响
            reqBody.fd_complementary_item = cl2List;//互补者分析-互补者
            reqBody.fd_complementary_reason = cl3List;//互补者分析-成为互补者的原因
            reqBody.fd_complementary_strategies = cl4List;//互补者分析-转变为竞争者的可能性及应对策略
            reqBody.fd_complementary_other = cl5List;//互补者分析-其他

            reqBody.fd_supplier_other = s1List;//供应商分析-其他
            reqBody.fd_supplier_effect = s2List;//供应商分析-互补者能产生的影响
            reqBody.fd_supplier_item = s3List;//供应商分析-供应商
            reqBody.fd_supplier_reason = s4List;//供应商分析-成为互补者的原因
            reqBody.fd_supplier_strategies = s5List;//供应商分析-转变为竞争者的可能性及应对策略

            reqBody.fd_key_content = proInit.KeyContent__c;//需要植入的关键内容
            reqBody.fd_path_way = proInit.PathWay__c;//根据关键决策链，提出以上关键内容的植入路径
            reqBody.fd_problem_base = proInit.ProblemBase__c;//竞标面临的问题和挑战-基础支持上（例如运维、交付的现状）
            reqBody.fd_problem_customer = proInit.ProblemCustomer__c;//竞标面临的问题和挑战-客户关系上
            reqBody.fd_problem_other = proInit.ProblemOther__c;//竞标面临的问题和挑战-其他
            reqBody.fd_problem_program = proInit.ProblemProgram__c;//竞标面临的问题和挑战-方案成本上

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
        public List<String> fd_form_contact{get;set;}//前期交流内容（竞争对手）
        public String fd_group_leader{get;set;}//项目主将
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
        public String fd_person_post_jituan{get;set;}//姓名/职位（集团公司）
        public String fd_prepare_time{get;set;}//预计挂网时间
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
        public String fd_zhichi_jituan{get;set;}//	支持情况（集团公司）集团公司
        public String n23{get;set;}//大客户总监
        //###### Fri Jun 9 15:33:44 CST 2023
        public String fd_sub_division{get;set;}//项目所属客户分部
        public String fd_sub_division_text{get;set;}//项目所属客户分部描述
        public String fd_process_type{get;set;}//流程类型
        public String fd_project_member{get;set;}//项目组成员
        public String fd_project_type{get;set;}//项目类型
        public String fd_model_select{get;set;}//机型比选 
        public String fd_road_survey{get;set;}//路勘及路改
        public String fd_logistics_tran{get;set;}//物流运输
        public String fd_micro_selection{get;set;}//微观选址
        public String fd_power_selection{get;set;}//发电量比选
        public String fd_other_selection{get;set;}//其他
        public String fd_technical_problem{get;set;}//存在的技术问题
        public String fd_designing_institute{get;set;}//设计院（已获悉、未获悉）
        public String fd_government_side{get;set;}//政府侧
        public String fd_pre_pm{get;set;}//售前项目经理
        public String fd_target_capacity{get;set;}//目标获取容量

        public List<String> fd_person_name_xm{get;set;}//项目公司明细-姓名
        public List<String> fd_person_other_xm{get;set;}//项目公司明细其他
        public List<String> fd_person_post_xm{get;set;}//项目公司明细-职位
        public List<String> fd_person_suqiu_xm{get;set;}//项目公司明细-诉求
        public List<String> fd_person_tel_xm{get;set;}//项目公司明细-联系方式（保密）
        public List<String> fd_zhichi_xm{get;set;}//项目公司明细-支持情况

        public List<String> fd_person_name_erji{get;set;}//二级公司明细-姓名
        public List<String> fd_zhichi_erji{get;set;}//支持情况（二级公司）二级公司
        public List<String> fd_person_other_erji{get;set;}//二级公司明细-其他
        public List<String> fd_person_post_erji{get;set;}//姓名/职位（二级公司）
        public List<String> fd_person_suqiu_erji{get;set;}//二级公司明细-诉求
        public List<String> fd_person_tel_erji{get;set;}//二级公司明细-联系方式（保密）

        public List<String> fd_person_name_jt{get;set;}//集团公司明细-姓名
        public List<String> fd_zhichi_jt{get;set;}//集团公司明细-支持情况
        public List<String> fd_person_other_jt{get;set;}//集团公司明细-其他
        public List<String> fd_person_post_jt{get;set;}//集团公司明细-职位
        public List<String> fd_person_suqiu_jt{get;set;}//集团公司明细-诉求
        public List<String> fd_person_tel_jt{get;set;}//集团公司明细-联系方式（保密）

        public List<String> fd_person_name_des{get;set;}//设计院明细-姓名
        public List<String> fd_zhichi_des{get;set;}//设计院明细-支持情况
        public List<String> fd_person_other_des{get;set;}//设计院明细-其他
        public List<String> fd_person_post_des{get;set;}//设计院明细-职位
        public List<String> fd_person_suqiu_des{get;set;}//设计院明细-诉求
        public List<String> fd_person_tel_des{get;set;}//设计院明细-联系方式（保密）

        public List<String> fd_person_name_gov{get;set;}//政府侧明细-姓名
        public List<String> fd_zhichi_gov{get;set;}//政府侧明细-支持情况
        public List<String> fd_person_other_gov{get;set;}//政府侧明细-其他
        public List<String> fd_person_post_gov{get;set;}//政府侧明细-职位
        public List<String> fd_person_suqiu_gov{get;set;}//政府侧明细-诉求
        public List<String> fd_person_tel_gov{get;set;}//政府侧明细-联系方式（保密）

        public String fd_plan_security{get;set;}//保密性
        public String fd_plan_strategy{get;set;}//项目策略
        public String fd_fangdan_details{get;set;}//行动计划（商务、技术、其他）

        public List<String> fd_person_name_cust{get;set;}//顾客分析
        public List<String> fd_zhichi_cust{get;set;}//顾客分析-支持情况
        public List<String> fd_person_other_cust{get;set;}//顾客分析-其他
        public List<String> fd_person_suqiu_cust{get;set;}//顾客分析-顾客诉求

        public List<String> fd_competitor_item{get;set;}//竞争者分析-竞争者
        public List<String> fd_cost_advantages{get;set;}//竞争者分析-价格及度电成本优势
        public List<String> fd_cost_weaknesses{get;set;}//竞争者分析-价格及度电成本劣势
        public List<String> fd_customer_advantages{get;set;}//竞争者分析-客户关系优势
        public List<String> fd_customer_weaknesses{get;set;}//竞争者分析-客户关系劣势
        public List<String> fd_other_advantages{get;set;}//竞争者分析-其他优势
        public List<String> fd_tech_advantages{get;set;}//竞争者分析-技术方案优势
        public List<String> fd_tech_weaknesses{get;set;}//竞争者分析-技术方案劣势
        public List<String> fd_competitor_remark{get;set;}//竞争者分析-备注
        public List<String> fd_other_weaknesses{get;set;}//竞争者分析-其他劣势

        public List<String> fd_complementary_effect{get;set;}//互补者分析-互补者能产生的影响
        public List<String> fd_complementary_item{get;set;}//互补者分析-互补者
        public List<String> fd_complementary_reason{get;set;}//互补者分析-成为互补者的原因
        public List<String> fd_complementary_strategies{get;set;}//互补者分析-转变为竞争者的可能性及应对策略
        public List<String> fd_complementary_other{get;set;}//互补者分析-其他

        public List<String> fd_supplier_other{get;set;}//供应商分析-其他
        public List<String> fd_supplier_effect{get;set;}//供应商分析-互补者能产生的影响
        public List<String> fd_supplier_item{get;set;}//供应商分析-供应商
        public List<String> fd_supplier_reason{get;set;}//供应商分析-成为互补者的原因
        public List<String> fd_supplier_strategies{get;set;}//供应商分析-转变为竞争者的可能性及应对策略
        
        public String fd_key_content{get;set;}//需要植入的关键内容
        public String fd_path_way{get;set;}//根据关键决策链，提出以上关键内容的植入路径
        public String fd_problem_base{get;set;}//竞标面临的问题和挑战-基础支持上（例如运维、交付的现状）
        public String fd_problem_customer{get;set;}//竞标面临的问题和挑战-客户关系上
        public String fd_problem_other{get;set;}//竞标面临的问题和挑战-其他
        public String fd_problem_program{get;set;}//竞标面临的问题和挑战-方案成本上
        
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