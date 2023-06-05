/*
 * @Author: irving
 * @Date: 2021-09-29 15:49:13
 * @LastEditTime: 2022-01-10 15:45:00
 * @LastEditors: Devin
 * @Description: 营销/资源项目方案申请单
 * @FilePath: \MINGYANG\force-app\main\default\classes\Controller_OAMarketingPlanAdd.cls
 */
global without sharing class Controller_OAMarketingPlanAdd {
    /**
     * @description: 营销项目方案申请单
     * @param  {*}
     * @return {*}
     */    
    @AuraEnabled(cacheable=false)
    global static String MarketingPlanAdd(Id recordId){
        Interface_Log__c logInfo = new Interface_Log__c();
        Project_Scheme_Application_Form__c proScheme = [SELECT Id,Process_Id__c,Applicant_Num__c,Models__c,Owner_Title__c,Owner_Department__c,Aftermarketornot__c,Wind_Energy_Design__c,Wind_Energy_Design__r.Job_Number__c
                                                        ,Proprietor_Responsible_Phone__c,Demandtype__c,Schemetype__c,Reason__c,
                                                        City__c,
                                                        Telephone__c,CommunicationTheme__c,CommunicationDate__c
                                                        ,Node_Personnel__c,Node_Personnel__r.Job_Number__c,District__c,Technicalexchange__c,Key_Customer_Deputy_First__c,Key_Customer_Deputy_First__r.Job_Number__c
                                                        ,Density__c,Accountdesigner__c,OnwerContactPositionAndName__c,OwnerUnitEmail__c,OwnerUnitName__c,OwnerUnitPhone__c,RoadSurveyCloseTime__c,EndDate__c
                                                        ,Projectrequirement__c,Requiredcompletiondate__c,Belongbigaccountornot__c,Technicalscheme__c,Prewonornot__c,Group__c,Group__r.Shortname__c,Proprietor_Responsible__c
                                                        ,Approval_Comments__c,Period__c,OwnerLeaderLevel__c,Fancoordinatecode__c,MaterialType__c,RoadSurveyStartTime__c,Rawwinddatacode__c,FormPhone__c,Projectbelong__c,Objectname__c
                                                        ,ProjectPhase__c,Applicatbelong__c,Province__c,ProjectInformationReason__c,Windfarmrangecode__c,RoadSurveyType__c,Projectstatus__c
                                                        ,Oppty__c,Windfarmprojectname__c,BeginDate__c,RoadSurveySite__c,Turbulent__c,Demandstatement__c,Approvalstatus__c
                                                        ,Dataurl__c,Capacity__c,ProjectTheater__c,Dataurlcode__c,Address__c,ExtremeWindSpeed__c,AverageWindSpeed__c,Mappingmapcode__c,Projecttype__c,Feasibilitystudyreportcode__c
                                                         FROM Project_Scheme_Application_Form__c WHERE Id =: recordId];
        RequestBody reqBody = new RequestBody();  
        String returnId = '';
        External_System_Param__c ext = External_System_Param__c.getValues('oaMarketingPlanAdd');
        
        try {

            //测试数据
            reqBody.fdId = String.isBlank(proScheme.Process_Id__c)?'':proScheme.Process_Id__c;//流程Id
            reqBody.auditNode = String.isBlank(proScheme.Approval_Comments__c)?'请审批':proScheme.Approval_Comments__c;
            reqBody.docCreator = proScheme.Applicant_Num__c;
            reqBody.fd_aftermarket_whether = proScheme.Aftermarketornot__c;//是否后市场
            reqBody.fd_apply_dept = proScheme.Owner_Department__c;//申请人部门
            reqBody.fd_apply_post = proScheme.Owner_Title__c;//岗位,示例值(销售经理)
            reqBody.fd_applyer = proScheme.Applicant_Num__c;
            reqBody.fd_area_group = proScheme?.Wind_Energy_Design__c==null?'':proScheme.Wind_Energy_Design__r.Job_Number__c;//风能设计院区域组长
            reqBody.fd_bidding_before_model = String.isBlank(proScheme.Models__c)?'':proScheme.Models__c;//机型（标前提资）需求类型包括项目提资时必填
            reqBody.fd_business_selphone = String.isBlank(proScheme.Proprietor_Responsible_Phone__c)?'':proScheme.Proprietor_Responsible_Phone__c;//业主方负责人联系电话
            reqBody.fd_category_need = proScheme.Demandtype__c;//需求类型
            reqBody.fd_category_plan = String.isBlank(proScheme.Schemetype__c)?'':proScheme.Schemetype__c;//方案类型
            reqBody.fd_change_reason = String.isBlank(proScheme.Reason__c)?'':proScheme.Reason__c;//优化原因需求说明为优化需求时必填	
            reqBody.fd_city = proScheme.City__c;//市
            reqBody.fd_contact_number = String.isBlank(proScheme.Telephone__c)?'':proScheme.Telephone__c;//业主设计院联系电话
            if (proScheme.Technicalexchange__c!=null&&proScheme.Technicalexchange__c=='方案交流') {
                reqBody.fd_contact_theme = String.isBlank(proScheme.CommunicationTheme__c)?'':proScheme.CommunicationTheme__c;//交流主题（方案交流）技术交流类型为方案交流时必填
                reqBody.fd_contact_time = proScheme.CommunicationDate__c==null?'':String.valueOf(proScheme.CommunicationDate__c);//交流时间（方案交流）技术交流类型为方案交流时必填
            }else {
                reqBody.fd_contact_theme = '';
                reqBody.fd_contact_time = '';
            }
            reqBody.fd_copyto = proScheme?.Node_Personnel__c==null?'':proScheme.Node_Personnel__r.Job_Number__c;//抄送节点抄送人员项目所属为其他时不必填，其余条件必填
            reqBody.fd_county = String.isBlank(proScheme.District__c)?'':proScheme.District__c;//县
            if (proScheme.Technicalexchange__c!=null&&proScheme.Technicalexchange__c=='产品推介') {
                reqBody.fd_cptj_contact_theme = String.isBlank(proScheme.CommunicationTheme__c)?'':proScheme.CommunicationTheme__c;//交流主题（产品推介）技术交流类型为产品推介时必填
                reqBody.fd_cptj_contact_time = proScheme.CommunicationDate__c==null?'':String.valueOf(proScheme.CommunicationDate__c);//交流时间（产品推介）技术交流类型为产品推介时必填
            }else {
                reqBody.fd_cptj_contact_theme = '';
                reqBody.fd_cptj_contact_time = '';
            }
            reqBody.fd_dakehu = proScheme?.Key_Customer_Deputy_First__c==null?'':proScheme.Key_Customer_Deputy_First__r.Job_Number__c;//大客户/战区副首代项目是否所属大客户为是时必填、
            reqBody.fd_density = String.isBlank(proScheme.Density__c)?'':proScheme.Density__c;//密度需求类型包括项目提资时必填
            reqBody.fd_design_person = String.isBlank(proScheme.Accountdesigner__c)?'':proScheme.Accountdesigner__c;//业主设计院技术人员
            reqBody.fd_design_unit_contact = String.isBlank(proScheme.OnwerContactPositionAndName__c)?'':proScheme.OnwerContactPositionAndName__c;//业主/设计院系人职务及名称需求类型包括项目提资时必填
            reqBody.fd_design_unit_mail = String.isBlank(proScheme.OwnerUnitEmail__c)?'':proScheme.OwnerUnitEmail__c;//业主/设计院单位邮箱需求类型包括项目提资时必填
            reqBody.fd_design_unit_name = String.isBlank(proScheme.OwnerUnitName__c)?'':proScheme.OwnerUnitName__c;//业主/设计院单位名称需求类型包括项目提资时必填
            reqBody.fd_design_unit_tel = String.isBlank(proScheme.OwnerUnitPhone__c)?'':proScheme.OwnerUnitPhone__c;//业主/设计院单位电话需求类型包括项目提资时必填
            reqBody.fd_ditu_pass = String.isBlank(proScheme.Mappingmapcode__c)?'':proScheme.Mappingmapcode__c;//测绘密码
            reqBody.fd_end_takan = proScheme.RoadSurveyCloseTime__c==null?'':String.valueOf(proScheme.RoadSurveyCloseTime__c);//道路踏勘结束时间需求类型包括设备运输道路踏勘时必填
            reqBody.fd_energy_solution = '低碳解决方案';//智慧能源解决方案项目类型
            reqBody.fd_etime_atomic = proScheme.EndDate__c==null?'':String.valueOf(proScheme.EndDate__c)+' 00:00:00';//选址结束时间方案类型包括"选址"关键字时必填
            reqBody.fd_fangan_need = String.isBlank(proScheme.Projectrequirement__c)?'':proScheme.Projectrequirement__c;//项目需求
            reqBody.fd_finish_time = proScheme.Requiredcompletiondate__c==null?'':String.valueOf(proScheme.Requiredcompletiondate__c)+' 00:00:00';//项目要求完成时间需求类型包括项目技术方案时必填
            reqBody.fd_is_dakehu = String.isBlank(proScheme.Belongbigaccountornot__c)?'否':proScheme.Belongbigaccountornot__c;//项目是否所属大客户需求类型包括项目技术方案时必填,可用值:是,否,示例值(否)
            reqBody.fd_is_finish_tecplan = String.isBlank(proScheme.Technicalscheme__c)?'':proScheme.Technicalscheme__c;//技术方案是否完成方案类型包括"选址"关键字时必填,可用值:是,否
            reqBody.fd_is_zhongbiao = String.isBlank(proScheme.Prewonornot__c)?'':proScheme.Prewonornot__c;//是否预中标,可用值:是,否,示例值(否)	
            reqBody.fd_jituan_attribute = proScheme?.Group__c==null?'':proScheme.Group__r.Shortname__c;//客户所属集团,示例值(华能)
            reqBody.fd_jituan_attribute_text = proScheme?.Group__c==null?'':proScheme.Group__r.Shortname__c;//客户所属集团,示例值(华能)
            reqBody.fd_jituan_other = '';//客户所属集团,示例值(华能)
            reqBody.fd_leader_business = String.isBlank(proScheme.Proprietor_Responsible__c)?'':proScheme.Proprietor_Responsible__c;//业主方负责人
            reqBody.fd_leader_contact = String.isBlank(proScheme.OwnerLeaderLevel__c)?'':proScheme.OwnerLeaderLevel__c;//业主参与交流领导级别
            reqBody.fd_location_pass = String.isBlank(proScheme.Fancoordinatecode__c)?'':proScheme.Fancoordinatecode__c;//机位点密码
            reqBody.fd_material_type = String.isBlank(proScheme.MaterialType__c)?'':proScheme.MaterialType__c;//物料类型,可用值:机型技术参数表,功率曲线,标准塔架参数,标准地基基础载荷,机型证书
            reqBody.fd_measure_time = proScheme.RoadSurveyStartTime__c==null?'':String.valueOf(proScheme.RoadSurveyStartTime__c);//道路路勘开始时间需求类型包括设备运输道路踏勘时必填
            reqBody.fd_need_describle = proScheme.Demandstatement__c;//需求说明,可用值:优化需求,新增需求,示例值(新增需求)
            reqBody.fd_order_project_type = '常规订单';//项目类型（订单/资源）,可用值:常规订单,资源开发,智慧能源解决方案（两个一体化、零碳,低碳）,示例值(常规订单)
            reqBody.fd_pass_wind = String.isBlank(proScheme.Rawwinddatacode__c)?'':proScheme.Rawwinddatacode__c;//原始测风数据密码	
            reqBody.fd_phone = String.isBlank(proScheme.FormPhone__c)?'':proScheme.FormPhone__c;//联系方式,示例值(15208146889)
            reqBody.fd_project_belongs = String.isBlank(proScheme.Projectbelong__c)?'':proScheme.Projectbelong__c;//项目所属,可用值:战区,营销部后市场运营管理部,润阳,其他,示例值(战区)
            reqBody.fd_project_fullname = String.isBlank(proScheme.Objectname__c)?'':proScheme.Objectname__c;//项目全称
            reqBody.fd_project_name = String.isBlank(proScheme.Windfarmprojectname__c)?'':proScheme.Windfarmprojectname__c;//风场项目名（如：锡铁山，若无可不填）
            reqBody.fd_project_phase = String.isBlank(proScheme.ProjectPhase__c)?'':proScheme.ProjectPhase__c;//项目阶段需求类型包括项目提资时必填,可用值:前期项目,投标项目
            reqBody.fd_project_type = String.isBlank(proScheme.Projecttype__c)?'':proScheme.Projecttype__c;//项目类型,可用值:陆上项目,海上项目,示例值(陆上项目)
            reqBody.fd_proposer_belongs = String.isBlank(proScheme.Applicatbelong__c)?'':proScheme.Applicatbelong__c;//申请人所属,可用值:战区,营销部后市场运营管理部,润阳,其他,示例值(战区)
            reqBody.fd_province = String.isBlank(proScheme.Province__c)?'':proScheme.Province__c;//所属省份,示例值(四川)
            reqBody.fd_raise_reason = String.isBlank(proScheme.ProjectInformationReason__c)?'':proScheme.ProjectInformationReason__c;//项目资料申请原因目的需求类型包括项目提资时必填
            reqBody.fd_range_pass = String.isBlank(proScheme.Windfarmrangecode__c)?'':proScheme.Windfarmrangecode__c;//范围密码
            reqBody.fd_report_md = String.isBlank(proScheme.Feasibilitystudyreportcode__c)?'':proScheme.Feasibilitystudyreportcode__c;//可研密码
            //此apex类仅适用于常规订单，资源订单查找（资源项目方案对象）
            reqBody.fd_resource_delp = '自主开发';//资源开发项目类型（订单/资源）为资源开发时必填,可用值:自主开发,合作开发,示例值(自主开发)
            reqBody.fd_road_mearsure = String.isBlank(proScheme.RoadSurveyType__c)?'':proScheme.RoadSurveyType__c;//道路踏勘类型需求类型包括设备运输道路踏勘时必填,可用值:项目前期路堪,投标项目方案路堪,中标后项目路堪,项目交付前路堪,项目交付中路堪
            reqBody.fd_situation_project = String.isBlank(proScheme.Projectstatus__c)?'':proScheme.Projectstatus__c;//项目情况
            reqBody.fd_stage = String.isBlank(proScheme.Period__c)?'':proScheme.Period__c;//期数
            reqBody.fd_stime_atomic = proScheme.BeginDate__c==null?'':String.valueOf(proScheme.BeginDate__c)+' 00:00:00';//选址开始时间方案类型包括"选址"关键字时必填
            reqBody.fd_takan_place = String.isBlank(proScheme.RoadSurveySite__c)?'':proScheme.RoadSurveySite__c;//踏勘地点需求类型包括设备运输道路踏勘时必填
            reqBody.fd_technology_commun = String.isBlank(proScheme.Technicalexchange__c)?'':proScheme.Technicalexchange__c;//技术交流类型需求类型包括项目技术交流时必填,可用值:方案交流,产品推介
            reqBody.fd_turbulence = String.isBlank(proScheme.Turbulent__c)?'':proScheme.Turbulent__c;//	湍流
            reqBody.fd_url_ziliao = String.isBlank(proScheme.Dataurl__c)?'':proScheme.Dataurl__c;//资料网址
            reqBody.fd_volume_project = proScheme.Capacity__c==null?0:proScheme.Capacity__c;//容量(MW)_项目,示例值(150)
            reqBody.fd_war_zone = String.isBlank(proScheme.ProjectTheater__c)?'':proScheme.ProjectTheater__c;//项目所属战区,示例值(云南公司)
            reqBody.fd_website_pass = String.isBlank(proScheme.Dataurlcode__c)?'':proScheme.Dataurlcode__c;//资料密码
            reqBody.fd_weiguan_adress = String.isBlank(proScheme.Address__c)?'':proScheme.Address__c;//选址地点方案类型包括"选址"关键字时必填
            reqBody.fd_wind_speed_max = String.isBlank(proScheme.ExtremeWindSpeed__c)?'':proScheme.ExtremeWindSpeed__c;//极限风速
            reqBody.fd_wind_speed_mean = String.isBlank(proScheme.AverageWindSpeed__c)?'':proScheme.AverageWindSpeed__c;//平均风速


            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OAMarketingPlanAdd',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);


            if(response.substring(0,5) == 'Error'){
                return response ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                if (resBody.code == 200) {
                    String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
                    //先判断是否是驳回状态，用于更新中间表状态
                    Boolean updateMiddleTableSign = false;
                    String findId = '';
                    if (!String.isBlank(proScheme.Process_Id__c)&&(proScheme.Approvalstatus__c=='11'||proScheme.Approvalstatus__c=='10')) {
                        updateMiddleTableSign = true;
                        findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:proScheme.Id AND RecordTypeId =: recTypeId].Id;
                    }
                    Project_Scheme_Application_Form__c updateReq = new Project_Scheme_Application_Form__c();
                    updateReq.Id = proScheme.Id;
                    updateReq.Process_Id__c = resBody.data.fdId;
                    updateReq.ApplicantionNumber__c = resBody.data.docSubject;
                    updateReq.Approvalstatus__c = '20';//提交成功后修改审批状态
                    returnId = resBody.data.fdId;
                    update updateReq;   //更新回流程id

                    //插入数据到集成中间表
                    Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                    if (updateMiddleTableSign) {
                        middleForm.id = findId;
                        middleForm.Approvalstatus__c = '20';//审批状态
                        update middleForm;
                    }else {
                        middleForm.RecordTypeId = recTypeId;//赋值记录类型
                        middleForm.Object_API__c = 'Project_Scheme_Application_Form__c';//对象API
                        middleForm.Mapping_Object_Id__c = proScheme.Id;//对应对象的Id
                        middleForm.Approval_Parent_Id__c = proScheme.Oppty__c;//审批单的父Id
                        String oppId = proScheme.Oppty__c;
                        
                        if (proScheme.RoadSurveyType__c!=null) {
                            middleForm.Scheme_Type__c = proScheme.RoadSurveyType__c;//道路踏勘类型
                        }else {
                            middleForm.Scheme_Type__c = proScheme.Schemetype__c;//方案类型
                            middleForm.Contract_Business_Id__c = [SELECT Id FROM Contractmanagement__c WHERE ObjectName__c =: oppId].Id;//合同商务Id
                        }
                        middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        insert middleForm;
                    }
                    

                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAMarketingPlanAdd';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAMarketingPlanAdd';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
                }
            }
            return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+returnId+'&loginName='+proScheme.Applicant_Num__c+'&identification=CRM';
        } catch (Exception e ) {
            logInfo.RequestURL__c = ext.Request_URL__c;
			logInfo.ClassName__c = 'Controller_OAMarketingPlanAdd';
			logInfo.RequestBody__c = JSON.serialize(reqBody);
			logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
        }

    }

    /**
     * @description: 资源项目方案申请单
     * @param  {*}
     * @return {*}
     */    
    @AuraEnabled(cacheable=false)
    global static String ResourcesPlanAdd(Id recordId){
        Interface_Log__c logInfo = new Interface_Log__c();
        Resource_Project_Scheme_Application__c proScheme = [SELECT Id,Process_Id__c,Applicant_Num__c,Models__c,Owner_Title__c,Owner_Department__c,Aftermarketornot__c,Wind_Energy_Design__c,Wind_Energy_Design__r.Job_Number__c
                                                        ,Proprietor_Responsible_Phone__c,Demandtype__c,Scheme_Type__c,Reason__c,
                                                        City__c,
                                                        Telephone__c,CommunicationTheme__c,CommunicationDate__c
                                                        ,Node_Personnel__c,Node_Personnel__r.Job_Number__c,District__c,TechnicalCommunicationType__c,Key_Customer_Deputy_First__c,Key_Customer_Deputy_First__r.Job_Number__c
                                                        ,Density__c,Technical_Personnel_Design__c,OnwerContactPositionAndName__c,OwnerUnitEmail__c,OwnerUnitName__c,OwnerUnitPhone__c,RoadSurveyCloseTime__c,LocationEndTime__c
                                                        ,ResourceProjectName__c,Resource_Development_Name__c,Project_Requirements__c,Required_Completion_Time__c,Belongbigaccountornot__c,TechnicalSolutions__c,Prewonornot__c,Proprietor_Responsible__c
                                                        ,Approval_Comments__c,OwnerLeaderLevel__c,Location_Coordinates_Upload__c,MaterialType__c,Begin_Date__c,Original_Measurement_Upload__c,FormPhone__c,Project_Owner__c
                                                        ,Period__c,ProjectPhase__c,Applicatbelong__c,Province__c,ProjectInformationReason__c,Wind_Farm_Upload__c,Survey_Type__c,Project_Situation__c,Resource_Development__c
                                                        ,Wind_Farm_Project_Name__c,LocationStartTime__c,Address__c,Turbulent__c,Requirement_Description__c,Approvalstatus__c
                                                        ,Information_Website__c,Capacity__c,ProjectArea__c,Dataurlcode__c,Location__c,ExtremeWindSpeed__c,AverageWindSpeed__c,Mapping_Map_Upload__c,Project_Type__c,Feasibility_Study_Report_Upload__c
                                                         FROM Resource_Project_Scheme_Application__c WHERE Id =: recordId];
        RequestBody reqBody = new RequestBody();  
        String returnId = '';
        External_System_Param__c ext = External_System_Param__c.getValues('oaMarketingPlanAdd');
        
        try {
            reqBody.fdId = String.isBlank(proScheme.Process_Id__c)?'':proScheme.Process_Id__c;//流程Id
            reqBody.auditNode = String.isBlank(proScheme.Approval_Comments__c)?'请审批':proScheme.Approval_Comments__c;
            reqBody.docCreator = proScheme.Applicant_Num__c;
            reqBody.fd_aftermarket_whether = proScheme.Aftermarketornot__c;//是否后市场
            reqBody.fd_apply_dept = proScheme.Owner_Department__c;//申请人部门
            reqBody.fd_apply_post = proScheme.Owner_Title__c;//岗位,示例值(销售经理)
            reqBody.fd_applyer = proScheme.Applicant_Num__c;
            reqBody.fd_area_group = proScheme?.Wind_Energy_Design__c==null?'':proScheme.Wind_Energy_Design__r.Job_Number__c;//风能设计院区域组长
            reqBody.fd_bidding_before_model = String.isBlank(proScheme.Models__c)?'':proScheme.Models__c;//机型（标前提资）需求类型包括项目提资时必填
            reqBody.fd_business_selphone = String.isBlank(proScheme.Proprietor_Responsible_Phone__c)?'':proScheme.Proprietor_Responsible_Phone__c;//业主方负责人联系电话
            reqBody.fd_category_need = proScheme.Demandtype__c;//需求类型
            reqBody.fd_category_plan = String.isBlank(proScheme.Scheme_Type__c)?'':proScheme.Scheme_Type__c;//方案类型
            reqBody.fd_change_reason = String.isBlank(proScheme.Reason__c)?'':proScheme.Reason__c;//优化原因需求说明为优化需求时必填	
            reqBody.fd_city = proScheme.City__c;//市
            reqBody.fd_contact_number = String.isBlank(proScheme.Telephone__c)?'':proScheme.Telephone__c;//业主设计院联系电话
            if (proScheme.TechnicalCommunicationType__c!=null&&proScheme.TechnicalCommunicationType__c=='方案交流') {
                reqBody.fd_contact_theme = String.isBlank(proScheme.CommunicationTheme__c)?'':proScheme.CommunicationTheme__c;//交流主题（方案交流）技术交流类型为方案交流时必填
                reqBody.fd_contact_time = proScheme.CommunicationDate__c==null?'':String.valueOf(proScheme.CommunicationDate__c);//交流时间（方案交流）技术交流类型为方案交流时必填
            }else {
                reqBody.fd_contact_theme = '';
                reqBody.fd_contact_time = '';
            }
            reqBody.fd_copyto = proScheme?.Node_Personnel__c==null?'':proScheme.Node_Personnel__r.Job_Number__c;//抄送节点抄送人员项目所属为其他时不必填，其余条件必填
            reqBody.fd_county = String.isBlank(proScheme.District__c)?'':proScheme.District__c;//县
            if (proScheme.TechnicalCommunicationType__c!=null&&proScheme.TechnicalCommunicationType__c=='产品推介') {
                reqBody.fd_cptj_contact_theme = String.isBlank(proScheme.CommunicationTheme__c)?'':proScheme.CommunicationTheme__c;//交流主题（产品推介）技术交流类型为产品推介时必填
                reqBody.fd_cptj_contact_time = proScheme.CommunicationDate__c==null?'':String.valueOf(proScheme.CommunicationDate__c);//交流时间（产品推介）技术交流类型为产品推介时必填
            }else {
                reqBody.fd_cptj_contact_theme = '';
                reqBody.fd_cptj_contact_time = '';
            }
            reqBody.fd_dakehu = proScheme?.Key_Customer_Deputy_First__c==null?'':proScheme.Key_Customer_Deputy_First__r.Job_Number__c;//大客户/战区副首代项目是否所属大客户为是时必填、
            reqBody.fd_density = String.isBlank(proScheme.Density__c)?'':proScheme.Density__c;//密度需求类型包括项目提资时必填
            reqBody.fd_design_person = String.isBlank(proScheme.Technical_Personnel_Design__c)?'':proScheme.Technical_Personnel_Design__c;//业主设计院技术人员
            reqBody.fd_design_unit_contact = String.isBlank(proScheme.OnwerContactPositionAndName__c)?'':proScheme.OnwerContactPositionAndName__c;//业主/设计院系人职务及名称需求类型包括项目提资时必填
            reqBody.fd_design_unit_mail = String.isBlank(proScheme.OwnerUnitEmail__c)?'':proScheme.OwnerUnitEmail__c;//业主/设计院单位邮箱需求类型包括项目提资时必填
            reqBody.fd_design_unit_name = String.isBlank(proScheme.OwnerUnitName__c)?'':proScheme.OwnerUnitName__c;//业主/设计院单位名称需求类型包括项目提资时必填
            reqBody.fd_design_unit_tel = String.isBlank(proScheme.OwnerUnitPhone__c)?'':proScheme.OwnerUnitPhone__c;//业主/设计院单位电话需求类型包括项目提资时必填
            reqBody.fd_ditu_pass = String.isBlank(proScheme.Mapping_Map_Upload__c)?'':proScheme.Mapping_Map_Upload__c;//测绘密码
            reqBody.fd_end_takan = proScheme.RoadSurveyCloseTime__c==null?'':String.valueOf(proScheme.RoadSurveyCloseTime__c);//道路踏勘结束时间需求类型包括设备运输道路踏勘时必填
            reqBody.fd_energy_solution = '低碳解决方案';//智慧能源解决方案项目类型
            reqBody.fd_etime_atomic = proScheme.LocationEndTime__c==null?'':String.valueOf(proScheme.LocationEndTime__c)+' 00:00:00';//选址结束时间方案类型包括"选址"关键字时必填
            reqBody.fd_fangan_need = String.isBlank(proScheme.Project_Requirements__c)?'':proScheme.Project_Requirements__c;//项目需求
            reqBody.fd_finish_time = proScheme.Required_Completion_Time__c==null?'':String.valueOf(proScheme.Required_Completion_Time__c)+' 00:00:00';//项目要求完成时间需求类型包括项目技术方案时必填
            reqBody.fd_is_dakehu = String.isBlank(proScheme.Belongbigaccountornot__c)?'否':proScheme.Belongbigaccountornot__c;//项目是否所属大客户需求类型包括项目技术方案时必填,可用值:是,否,示例值(否)
            reqBody.fd_is_finish_tecplan = String.isBlank(proScheme.TechnicalSolutions__c)?'':proScheme.TechnicalSolutions__c;//技术方案是否完成方案类型包括"选址"关键字时必填,可用值:是,否
            reqBody.fd_is_zhongbiao = String.isBlank(proScheme.Prewonornot__c)?'':proScheme.Prewonornot__c;//是否预中标,可用值:是,否,示例值(否)	
            reqBody.fd_jituan_attribute = '各级政府部门';//客户所属集团,示例值(华能)
            reqBody.fd_jituan_attribute_text = '各级政府部门';//客户所属集团,示例值(华能)
            reqBody.fd_jituan_other = '';//客户所属集团,示例值(华能)
            reqBody.fd_leader_business = String.isBlank(proScheme.Proprietor_Responsible__c)?'':proScheme.Proprietor_Responsible__c;//业主方负责人
            reqBody.fd_leader_contact = String.isBlank(proScheme.OwnerLeaderLevel__c)?'':proScheme.OwnerLeaderLevel__c;//业主参与交流领导级别
            reqBody.fd_location_pass = String.isBlank(proScheme.Location_Coordinates_Upload__c)?'':proScheme.Location_Coordinates_Upload__c;//机位点密码
            reqBody.fd_material_type = String.isBlank(proScheme.MaterialType__c)?'':proScheme.MaterialType__c;//物料类型,可用值:机型技术参数表,功率曲线,标准塔架参数,标准地基基础载荷,机型证书
            reqBody.fd_measure_time = proScheme.Begin_Date__c==null?'':String.valueOf(proScheme.Begin_Date__c);//道路路勘开始时间需求类型包括设备运输道路踏勘时必填
            reqBody.fd_need_describle = proScheme.Requirement_Description__c;//需求说明,可用值:优化需求,新增需求,示例值(新增需求)
            reqBody.fd_order_project_type = '资源开发';//项目类型（订单/资源）,可用值:常规订单,资源开发,智慧能源解决方案（两个一体化、零碳,低碳）,示例值(常规订单)
            reqBody.fd_pass_wind = String.isBlank(proScheme.Original_Measurement_Upload__c)?'':proScheme.Original_Measurement_Upload__c;//原始测风数据密码	
            reqBody.fd_phone = String.isBlank(proScheme.FormPhone__c)?'':proScheme.FormPhone__c;//联系方式,示例值(15208146889)
            reqBody.fd_project_belongs = String.isBlank(proScheme.Project_Owner__c)?'':proScheme.Project_Owner__c;//项目所属,可用值:战区,营销部后市场运营管理部,润阳,其他,示例值(战区)
            reqBody.fd_project_fullname = proScheme.ResourceProjectName__c;//项目全称
            reqBody.fd_project_name = String.isBlank(proScheme.Wind_Farm_Project_Name__c)?'':proScheme.Wind_Farm_Project_Name__c;//风场项目名（如：锡铁山，若无可不填）待确认
            reqBody.fd_project_phase = String.isBlank(proScheme.ProjectPhase__c)?'':proScheme.ProjectPhase__c;//项目阶段需求类型包括项目提资时必填,可用值:前期项目,投标项目
            reqBody.fd_project_type = String.isBlank(proScheme.Project_Type__c)?'':proScheme.Project_Type__c;//项目类型,可用值:陆上项目,海上项目,示例值(陆上项目)
            reqBody.fd_proposer_belongs = String.isBlank(proScheme.Applicatbelong__c)?'':proScheme.Applicatbelong__c;//申请人所属,可用值:战区,营销部后市场运营管理部,润阳,其他,示例值(战区)
            reqBody.fd_province = String.isBlank(proScheme.Province__c)?'':proScheme.Province__c;//所属省份,示例值(四川)
            reqBody.fd_raise_reason = String.isBlank(proScheme.ProjectInformationReason__c)?'':proScheme.ProjectInformationReason__c;//项目资料申请原因目的需求类型包括项目提资时必填
            reqBody.fd_range_pass = String.isBlank(proScheme.Wind_Farm_Upload__c)?'':proScheme.Wind_Farm_Upload__c;//范围密码
            reqBody.fd_report_md = String.isBlank(proScheme.Feasibility_Study_Report_Upload__c)?'':proScheme.Feasibility_Study_Report_Upload__c;//可研密码
            //此apex类仅适用于常规订单，资源订单查找（资源项目方案对象）
            reqBody.fd_resource_delp = proScheme.Resource_Development__c;//资源开发项目类型（订单/资源）为资源开发时必填,可用值:自主开发,合作开发,示例值(自主开发)
            reqBody.fd_road_mearsure = String.isBlank(proScheme.Survey_Type__c)?'':proScheme.Survey_Type__c;//道路踏勘类型需求类型包括设备运输道路踏勘时必填,可用值:项目前期路堪,投标项目方案路堪,中标后项目路堪,项目交付前路堪,项目交付中路堪
            reqBody.fd_situation_project = String.isBlank(proScheme.Project_Situation__c)?'':proScheme.Project_Situation__c;//项目情况
            reqBody.fd_stage = String.isBlank(proScheme.Period__c)?'':proScheme.Period__c;//期数
            reqBody.fd_stime_atomic = proScheme.LocationStartTime__c==null?'':String.valueOf(proScheme.LocationStartTime__c)+' 00:00:00';//选址开始时间方案类型包括"选址"关键字时必填
            reqBody.fd_takan_place = String.isBlank(proScheme.Address__c)?'':proScheme.Address__c;//踏勘地点需求类型包括设备运输道路踏勘时必填
            reqBody.fd_technology_commun = String.isBlank(proScheme.TechnicalCommunicationType__c)?'':proScheme.TechnicalCommunicationType__c;//技术交流类型需求类型包括项目技术交流时必填,可用值:方案交流,产品推介
            reqBody.fd_turbulence = String.isBlank(proScheme.Turbulent__c)?'':proScheme.Turbulent__c;//	湍流
            reqBody.fd_url_ziliao = String.isBlank(proScheme.Information_Website__c)?'':proScheme.Information_Website__c;//资料网址
            reqBody.fd_volume_project = proScheme.Capacity__c==null?0:proScheme.Capacity__c;//容量(MW)_项目,示例值(150)
            reqBody.fd_war_zone = String.isBlank(proScheme.ProjectArea__c)?'':proScheme.ProjectArea__c;//项目所属战区,示例值(云南公司)
            reqBody.fd_website_pass = String.isBlank(proScheme.Dataurlcode__c)?'':proScheme.Dataurlcode__c;//资料密码
            reqBody.fd_weiguan_adress = String.isBlank(proScheme.Location__c)?'':proScheme.Location__c;//选址地点方案类型包括"选址"关键字时必填
            reqBody.fd_wind_speed_max = String.isBlank(proScheme.ExtremeWindSpeed__c)?'':proScheme.ExtremeWindSpeed__c;//极限风速
            reqBody.fd_wind_speed_mean = String.isBlank(proScheme.AverageWindSpeed__c)?'':proScheme.AverageWindSpeed__c;//平均风速


            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OAMarketingPlanAdd_资源',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);


            if(response.substring(0,5) == 'Error'){
                return response;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                if (resBody.code == 200) {
                    //先判断是否是驳回状态，用于更新中间表状态
                    Boolean updateMiddleTableSign = false;
                    String findId = '';
                    if (!String.isBlank(proScheme.Process_Id__c)&&(proScheme.Approvalstatus__c=='11'||proScheme.Approvalstatus__c=='10')) {
                        updateMiddleTableSign = true;
                        findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:proScheme.Id].Id;
                    }
                    Resource_Project_Scheme_Application__c updateReq = new Resource_Project_Scheme_Application__c();
                    updateReq.Id = proScheme.Id;
                    updateReq.Process_Id__c = resBody.data.fdId;
                    updateReq.ApplicantionNumber__c = resBody.data.docSubject;
                    updateReq.Approvalstatus__c = '20';//提交成功后修改审批状态
                    returnId = resBody.data.fdId;
                    update updateReq;   //更新回流程id

                    //插入数据到集成中间表
                    Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                    if (updateMiddleTableSign) {
                        middleForm.id = findId;
                        middleForm.Approvalstatus__c = '20';//审批状态
                        update middleForm;
                    }else {
                        middleForm.Object_API__c = 'Resource_Project_Scheme_Application__c';//对象API
                        middleForm.Approval_Parent_Id__c = proScheme.Resource_Development_Name__c;//审批单的父Id
                        middleForm.Mapping_Object_Id__c = proScheme.Id;//对应对象的Id
                        middleForm.Require_Type__c = proScheme.Demandtype__c;//需求类型
                        middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        insert middleForm;
                    }

                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAMarketingPlanAdd_资源';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAMarketingPlanAdd_资源';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name; 
                }
            }
            return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+returnId+'&loginName='+proScheme.Applicant_Num__c+'&identification=CRM';
        } catch (Exception e ) {
            logInfo.RequestURL__c = ext.Request_URL__c;
			logInfo.ClassName__c = 'Controller_OAMarketingPlanAdd_资源';
			logInfo.RequestBody__c = JSON.serialize(reqBody);
			logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name; 
        }

    }

    public class RequestBody {
        public String fdId{get;set;}//已驳回携带流程id
        public String auditNode{get;set;} //审批意见,示例值(请审批)
        public String docCreator{get;set;} //创建人,示例值(A07068)
        public String fd_aftermarket_whether{get;set;} //是否后市场,可用值:是,否,示例值(否)
        public String fd_apply_dept{get;set;} //申请人部门(全路径),示例值(明阳智慧能源集团股份公司/市场与客户发展业务/云南公司/销售业务部)
        public String fd_apply_post{get;set;} //岗位,示例值(销售经理)
        public String fd_applyer{get;set;} //姓名,示例值(A07068)
        public String fd_area_group{get;set;} //风能设计院区域组长,示例值(A03176)
        public String fd_bidding_before_model{get;set;} //机型（标前提资）需求类型包括项目提资时必填
        public String fd_business_selphone{get;set;} //联系电话
        public String fd_category_need{get;set;} //需求类型(多值,以;分隔),可用值:项目技术方案,技术交流,设备运输道路踏勘,项目提资项目提资,示例值(项目提资)
        public String fd_category_plan{get;set;} //方案类型需求类型包括项目技术
        public String fd_change_reason{get;set;} //优化原因需求说明为优化需求时必填
        public String fd_city{get;set;} //市,示例值(广元)
        public String fd_contact_number{get;set;} //联系电话
        public String fd_contact_theme{get;set;} //交流主题（方案交流）技术交流类型为方案交流时必填
        public String fd_contact_time{get;set;} //	交流时间（方案交流）技术交流类型为方案交流时必填
        public String fd_copyto{get;set;} //抄送节点抄送人员项目所属为其他时不必填，其余条件必填
        public String fd_county{get;set;} //	县
        public String fd_cptj_contact_theme{get;set;} //	交流主题（产品推介）技术交流类型为产品推介时必填
        public String fd_cptj_contact_time{get;set;} //	交流时间（产品推介）技术交流类型为产品推介时必填
        public String fd_dakehu{get;set;} //大客户/战区副首代项目是否所属大客户为是时必填
        public String fd_density{get;set;} //密度需求类型包括项目提资时必填
        public String fd_design_person{get;set;} //业主设计院技术人员
        public String fd_design_unit_contact{get;set;} //业主/设计院系人职务及名称需求类型包括项目提资时必填
        public String fd_design_unit_mail{get;set;} //	业主/设计院单位邮箱需求类型包括项目提资时必填
        public String fd_design_unit_name{get;set;} //业主/设计院单位名称需求类型包括项目提资时必填
        public String fd_design_unit_tel{get;set;} //业主/设计院单位电话需求类型包括项目提资时必填
        public String fd_ditu_pass{get;set;} //测绘密码
        public String fd_end_takan{get;set;} //道路踏勘结束时间需求类型包括设备运输道路踏勘时必填
        public String fd_energy_solution{get;set;} //智慧能源解决方案项目类型（订单/资源）为智慧能源解决方案（两个一体化、零碳/低碳）时必填,可用值:两个一体化,零碳/低碳解决方案,示例值(低碳解决方案)
        public String fd_etime_atomic{get;set;} //选址结束时间方案类型包括"选址"关键字时必填
        public String fd_fangan_need{get;set;} //项目需求
        public String fd_finish_time{get;set;} //项目要求完成时间需求类型包括项目技术方案时必填
        public String fd_is_dakehu{get;set;} //项目是否所属大客户需求类型包括项目技术方案时必填,可用值:是,否,示例值(否)
        public String fd_is_finish_tecplan{get;set;} //技术方案是否完成方案类型包括"选址"关键字时必填,可用值:是,否
        public String fd_is_zhongbiao{get;set;} //是否预中标,可用值:是,否,示例值(否)
        public String fd_jituan_attribute{get;set;} //客户所属集团,示例值(华能)
        public String fd_jituan_attribute_text{get;set;} //	客户所属集团,示例值(华能)
        public String fd_jituan_other{get;set;} //客户所属集团_其他
        public String fd_leader_business{get;set;} //业主方负责人
        public String fd_leader_contact{get;set;} //	业主参与交流领导级别
        public String fd_location_pass{get;set;} //机位点密码
        public String fd_material_type{get;set;} //物料类型,可用值:机型技术参数表,功率曲线,标准塔架参数,标准地基基础载荷,机型证书
        public String fd_measure_time{get;set;} //道路路勘开始时间需求类型包括设备运输道路踏勘时必填
        public String fd_need_describle{get;set;} //需求说明,可用值:优化需求,新增需求,示例值(新增需求)
        public String fd_order_project_type{get;set;} //项目类型（订单/资源）,可用值:常规订单,资源开发,智慧能源解决方案（两个一体化、零碳,低碳）,示例值(常规订单)
        public String fd_pass_wind{get;set;} //	密码
        public String fd_phone{get;set;} //联系方式,示例值(15208146889)	
        public String fd_project_belongs{get;set;} //项目所属,可用值:战区,营销部后市场运营管理部,润阳,其他,示例值(战区)
        public String fd_project_fullname{get;set;} //项目全称
        public String fd_project_name{get;set;} //风场项目名（如：锡铁山，若无可不填）
        public String fd_project_phase{get;set;} //项目阶段需求类型包括项目提资时必填,可用值:前期项目,投标项目
        public String fd_project_type{get;set;} //项目类型,可用值:陆上项目,海上项目,示例值(陆上项目)
        public String fd_proposer_belongs{get;set;} //申请人所属,可用值:战区,营销部后市场运营管理部,润阳,其他,示例值(战区)
        public String fd_province{get;set;} //所属省份,示例值(四川)
        public String fd_raise_reason{get;set;} //	项目资料申请原因目的需求类型包括项目提资时必填
        public String fd_range_pass{get;set;} //范围密码
        public String fd_report_md{get;set;} //	可研密码
        public String fd_resource_delp{get;set;} //资源开发项目类型（订单/资源）为资源开发时必填,可用值:自主开发,合作开发,示例值(自主开发)
        public String fd_road_mearsure{get;set;} //道路踏勘类型需求类型包括设备运输道路踏勘时必填,可用值:项目前期路堪,投标项目方案路堪,中标后项目路堪,项目交付前路堪,项目交付中路堪
        public String fd_situation_project{get;set;} //项目情况
        public String fd_stage{get;set;} //期数
        public String fd_stime_atomic{get;set;} //选址开始时间方案类型包括"选址"关键字时必填
        public String fd_takan_place{get;set;} //踏勘地点需求类型包括设备运输道路踏勘时必填
        public String fd_technology_commun{get;set;} //技术交流类型需求类型包括项目技术交流时必填,可用值:方案交流,产品推介
        public String fd_turbulence{get;set;} //湍流
        public String fd_url_ziliao{get;set;} //资料网址
        public Double fd_volume_project{get;set;} //容量(MW)_项目,示例值(150)
        public String fd_war_zone{get;set;} //项目所属战区,示例值(云南公司)	
        public String fd_website_pass{get;set;} //资料密码
        public String fd_weiguan_adress{get;set;} //选址地点方案类型包括"选址"关键字时必填
        public String fd_wind_speed_max{get;set;} //极限风速
        public String fd_wind_speed_mean{get;set;} //平均风速
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public Data data{get;set;} 
    }

    public class Data {
        public String docSubject{get;set;}  
        public String fdId{get;set;}  
        public String fdNumber{get;set;}   
        public String rtMsg{get;set;} 
        public String rtStatus{get;set;} 
    } 
}