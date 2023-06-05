/*
 * @Author: Conner
 * @Date: 2021-09-28 17:52:44
 * @LastEditTime: 2022-01-10 15:45:38
 * @LastEditors: Devin
 * @Description: 资源立项申请单
 * @FilePath: \MINGYANG\force-app\main\default\classes\Controller_OAResourceApprovalAdd.cls
 */
global without sharing class Controller_OAResourceApprovalAdd {
    @AuraEnabled(cacheable=false)
    global static String ResourceApprovalAdd(Id recordId){

        Interface_Log__c logInfo = new Interface_Log__c();
        RequestBody reqBody = new RequestBody();
        String returnId = '';

        External_System_Param__c ext = External_System_Param__c.getValues('oaResourceApprovalAdd');

        ResourceProjectApplication__c rpc = new ResourceProjectApplication__c();

        rpc = [SELECT Id,
                        Process_Id__c,
                        ResourceName__c,
                        Applicant_Num__c,
                        Approvalstatus__c,
                        Owner_Department__c,
                        Approval_Comments__c,
                        CreatedById,
                        DebtAssetRatioMax__c,
                        OwnerId,
                        ProjectBackground__c,
                        ProfitAnalysis__c,
                        BEPAnnualOutput__c,
                        BEPProductionCapacityUtilization__c,
                        CapitalFinancialNPV__c,
                        CapitalFinanceIRR__c,
                        City__c,
                        ConstructionImplementationPlan__c,
                        TotalCost__c,
                        ResponseMeasures__c,
                        ApplyerDepartment__c,
                        ExpectedEconomicSignificance__c,
                        Electrovalency__c,
                        ConstructionPeriodInterest__c,
                        InvestmentPerKW__c,
                        ResponsiblePerson__c,
                        CapitalPP__c,
                        TotalInternetPower__c,
                        PowerTotalProfits__c,
                        ProjectName__c,
                        ProjectIntroduce__c,
                        ProjectType__c,
                        Capacity__c,
                        Province__c,
                        ProjectInvestmentNPVAfterTax__c,
                        ProjectInvestmentNPVBeforeTax__c,
                        OwnInvestmentIRR__c,
                        AllIRR__c,
                        RiskAssessment__c,
                        ROE__c,
                        ROI__c,
                        PowerTotalSalesRevenue__c,
                        SalesTax__c,
                        FullInvestmentPaybackPeriod__c,
                        OwnInvestmentPaybackPeriod__c,
                        ExpectedStrategicSignificance__c,
                        InvestmentInterestRate__c,
                        TechnicalAndEconomicIndicators__c,
                        TotalInvestment__c,
                        VATRefund__c,
                        Political_Commissar_Charge__c,
                        Political_Commissar_Charge__r.Job_Number__c,
                        ProjectArea__c,
                        Liquidity__c,
                        Responsible_People__c,
                        Responsible_People__r.Job_Number__c,
                        (SELECT Id,ProjectDivision__c,Department__c,Position__c,Name_Project_Member__c,Name_Project_Member__r.Job_Number__c FROM ResourceProjectApplicationName__r)
                         from ResourceProjectApplication__c WHERE Id =: recordId];

        try {

            List<String> divisionLaborsList = new List<String>();//项目分工
            List<String> personDeptsList = new List<String>();//所属部门
            List<String> personNamesList = new List<String>();//姓名
            List<String> personPostsList = new List<String>();//职务

            for (ResourceMember__c resMem : rpc.ResourceProjectApplicationName__r) {
                if (resMem.ProjectDivision__c!=null) {
                    divisionLaborsList.add(resMem.ProjectDivision__c);
                }else {
                    divisionLaborsList.add('无');
                }
                if (resMem.Department__c!=null) {
                    personDeptsList.add(resMem.Department__c);
                }else {
                    personDeptsList.add('无');
                }
                if (resMem?.Name_Project_Member__c!=null) {
                    personNamesList.add(resMem.Name_Project_Member__r.Job_Number__c);
                }else {
                    personNamesList.add('无');
                }
                if (resMem?.Position__c!=null) {
                    personPostsList.add(resMem.Position__c);
                }else {
                    personPostsList.add('无');
                }
            }
            reqBody.fdId = String.isBlank(rpc.Process_Id__c)?'':rpc.Process_Id__c;//流程Id
            reqBody.auditNode = String.isBlank(rpc.Approval_Comments__c)?'请审批':rpc.Approval_Comments__c;//审批意见
            reqBody.docCreator = rpc.Applicant_Num__c;//创建人
            reqBody.fd_Asset_liability_max = rpc.DebtAssetRatioMax__c==null?0:rpc.DebtAssetRatioMax__c; //资产负债率（最大值）
            reqBody.fd_apply_dept = rpc.Owner_Department__c;//所有人部门
            reqBody.fd_applyer = rpc.Applicant_Num__c;//创建人
            reqBody.fd_background = rpc.ProjectBackground__c;//项目背景
            reqBody.fd_break_even_analysis = rpc.ProfitAnalysis__c==null?'':rpc.ProfitAnalysis__c;//损益分析
            reqBody.fd_breakeven_point_ao = rpc.BEPAnnualOutput__c==null?0:rpc.BEPAnnualOutput__c;//盈亏平衡点（年产量）
            reqBody.fd_breakeven_point_cu = rpc.BEPProductionCapacityUtilization__c==null?0:rpc.BEPProductionCapacityUtilization__c;//盈亏平衡点（生产能力利用率）
            reqBody.fd_capital_pv = rpc.CapitalFinancialNPV__c==null?0:rpc.CapitalFinancialNPV__c;//资本金财务净现值
            reqBody.fd_capital_return_rate = rpc.CapitalFinanceIRR__c==null?0:rpc.CapitalFinanceIRR__c;//资本金财务内部收益率
            reqBody.fd_city = rpc.City__c;//市,示例值(中山)
            reqBody.fd_construction_plan = rpc.ConstructionImplementationPlan__c;//建设实施方案,示例值(建设实施方案)	
            reqBody.fd_cost_total = rpc.TotalCost__c;//	总成本费用,示例值(19890)
            reqBody.fd_countermeasures = rpc.ResponseMeasures__c;//	应对措施,示例值(应对措施)
            reqBody.fd_dept_show = rpc.ApplyerDepartment__c;//申请人部门显示
            reqBody.fd_division_labor = divisionLaborsList;   //项目分工
            reqBody.fd_economic_expected = rpc.ExpectedEconomicSignificance__c==null?'':rpc.ExpectedEconomicSignificance__c;//项目的预期经济意义
            reqBody.fd_electricity_price = rpc.Electrovalency__c;//电价（不含税）,示例值(0.38)
            reqBody.fd_interest = rpc.ConstructionPeriodInterest__c;//建设期利息,示例值(19890)
            reqBody.fd_investment_kilowatt = rpc.InvestmentPerKW__c;//单位千瓦投资,示例值(20000)
            reqBody.fd_leader = rpc?.Responsible_People__c==null?'':rpc?.Responsible_People__r.Job_Number__c;//责任人,示例值(A02323)
            reqBody.fd_payback_period = rpc.CapitalPP__c==null?0:rpc.CapitalPP__c;//资本金投资回收期
            reqBody.fd_person_dept = personDeptsList;     //所属部门
            reqBody.fd_person_name = personNamesList;     //姓名
            reqBody.fd_person_post = personPostsList;    //职务
            reqBody.fd_power_total = rpc.TotalInternetPower__c;//上网电量总计,示例值(280979)
            reqBody.fd_profit_total = rpc.PowerTotalProfits__c;//发电利润总额,示例值(19890)
            reqBody.fd_project_fullname = rpc.ProjectName__c;//	项目名称,示例值(中山xx光伏项目)
            reqBody.fd_project_introduce = rpc.ProjectIntroduce__c;//项目介绍,示例值(项目介绍)
            reqBody.fd_project_type = rpc.ProjectType__c;//项目类型,可用值:风电项目,光伏项目,风光复合型项目,两个一体化,示例值(光伏项目)
            reqBody.fd_project_volume = rpc.Capacity__c;//容量
            reqBody.fd_province =rpc.Province__c;//省,示例值(广东)
            reqBody.fd_pv_after = rpc.ProjectInvestmentNPVAfterTax__c==null?0:rpc.ProjectInvestmentNPVAfterTax__c;//项目投资财务净现值（所得税后）	
            reqBody.fd_pv_before = rpc.ProjectInvestmentNPVBeforeTax__c==null?0:rpc.ProjectInvestmentNPVBeforeTax__c;//项目投资财务净现值（所得税前）
            reqBody.fd_return_self_rate = rpc.OwnInvestmentIRR__c;//自有资金内部收益率,示例值(13)
            reqBody.fd_return_total_rate = rpc.AllIRR__c;//全部投资内部收益率,示例值(9)
            reqBody.fd_risk = rpc.RiskAssessment__c;//风险评估,示例值(风险评估)
            reqBody.fd_roe = rpc.ROE__c==null?0:rpc.ROE__c;//项目资本金净利润率（ROE）
            reqBody.fd_roi = rpc.ROI__c==null?0:rpc.ROI__c;//总投资收益率(ROI)
            reqBody.fd_sales_total = rpc.PowerTotalSalesRevenue__c;//发电销售收入总额（不含增值税）,示例值(10786)
            reqBody.fd_sales_total_tax = rpc.SalesTax__c;//销售税金附加总额
            reqBody.fd_static_payback_all = rpc.FullInvestmentPaybackPeriod__c==null?0:rpc.FullInvestmentPaybackPeriod__c;//全投资静态投资回收期,示例值(15)
            reqBody.fd_static_payback_self = rpc.OwnInvestmentPaybackPeriod__c==null?0:rpc.OwnInvestmentPaybackPeriod__c;//自有资金静态投资回收期,示例值(16)
            reqBody.fd_strategic_expected = rpc.ExpectedStrategicSignificance__c;//项目的预期战略意义,示例值(项目的预期战略意义)
            reqBody.fd_tax_rate = rpc.InvestmentInterestRate__c==null?0:rpc.InvestmentInterestRate__c;//投资利税率
            reqBody.fd_technical_economic = rpc.TechnicalAndEconomicIndicators__c==null?'':rpc.TechnicalAndEconomicIndicators__c;//技术经济指标
            reqBody.fd_total_investment = rpc.TotalInvestment__c==null?0:rpc.TotalInvestment__c;//总投资,示例值(500000)
            reqBody.fd_vat_refund = rpc.VATRefund__c==null?0:rpc.VATRefund__c;//增值税返还
            reqBody.fd_vice_admin = rpc.Political_Commissar_Charge__c==null?'':rpc.Political_Commissar_Charge__r.Job_Number__c;//分管政委,示例值(A02323)
            reqBody.fd_war_zone = rpc.ProjectArea__c;//项目所属战区或部门,示例值(能源技术公司)
            reqBody.fd_working_capital = rpc.Liquidity__c==null?0:rpc.Liquidity__c;//流动资金

            logInfo.RequestBody__c = JSON.serialize(reqBody);

            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OAResourceApprovalAdd',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

            if(response.substring(0,5)=='Error'){
                return response;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                if (resBody.code == 200) {
                    String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
                    //先判断是否是驳回状态，用于更新中间表状态
                    Boolean updateMiddleTableSign = false;
                    String findId = '';
                    if (!String.isBlank(rpc.Process_Id__c)&&(rpc.Approvalstatus__c=='11'||rpc.Approvalstatus__c=='10')) {//add by hogan 草稿重复提交或驳回状态，更新集成中间表
                        updateMiddleTableSign = true;
                        findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:rpc.Id AND RecordTypeId =: recTypeId].Id;
                    }
                    
                    ResourceProjectApplication__c updateReq = new ResourceProjectApplication__c();
                    updateReq.Id = rpc.Id;
                    updateReq.Process_Id__c = resBody.data.fdId;
                    String docName = resBody.data.docSubject;
                    String num = docName.substring(docName.lastIndexOf('_') - 10);
                    updateReq.ApplicantionNumber__c = num;//
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
                        middleForm.Object_API__c = 'ResourceProjectApplication__c';//对象API
                        middleForm.Approval_Parent_Id__c = rpc.ResourceName__c;//审批单的父Id
                        middleForm.Mapping_Object_Id__c = rpc.Id;//对应对象的Id
                        middleForm.Scheme_Type__c = null;//方案类型
                        middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        insert middleForm;
                    }
                    
                    

                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAResourceApprovalAdd';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'Controller_OAResourceApprovalAdd';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name; 
                }
            }
            return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+returnId+'&loginName='+rpc.Applicant_Num__c+'&identification=CRM';
        } catch (Exception e) {
            
            logInfo.RequestURL__c = ext.Request_URL__c;
			logInfo.ClassName__c = 'Controller_OAResourceApprovalAdd';
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
        public Double fd_Asset_liability_max{get;set;} //资产负债率（最大值）
        public String fd_apply_dept{get;set;} //申请人部门,示例值(1000106)
        public String fd_applyer{get;set;} //姓名,示例值(A07068)
        public String fd_background{get;set;} //项目背景,示例值(项目背景)
        public String fd_break_even_analysis{get;set;} //损益分析
        public Double fd_breakeven_point_ao{get;set;} //盈亏平衡点（年产量）
        public Double fd_breakeven_point_cu{get;set;} //盈亏平衡点（生产能力利用率）
        public Double fd_capital_pv{get;set;} //资本金财务净现值
        public Double fd_capital_return_rate{get;set;} //资本金财务内部收益率
        public String fd_city{get;set;} //市,示例值(中山)
        public String fd_construction_plan{get;set;} //建设实施方案,示例值(建设实施方案)
        public Double fd_cost_total{get;set;} //总成本费用,示例值(19890)
        public String fd_countermeasures{get;set;} //应对措施,示例值(应对措施)
        public String fd_dept_show{get;set;} //申请人部门显示,示例值(应用运维室)
        public List<String> fd_division_labor{get;set;} //项目分工      false
        public String fd_economic_expected{get;set;} //项目的预期经济意义
        public Double fd_electricity_price{get;set;} //电价（不含税）,示例值(0.38)	
        public Double fd_interest{get;set;} //建设期利息,示例值(19890)
        public Double fd_investment_kilowatt{get;set;} //单位千瓦投资,示例值(20000)
        public String fd_leader{get;set;} //责任人,示例值(A02323)
        public Double fd_payback_period{get;set;} //资本金投资回收期
        public List<String> fd_person_dept{get;set;} //所属部门     false
        public List<String> fd_person_name{get;set;} //	姓名        false
        public List<String> fd_person_post{get;set;} //职务         false
        public Double fd_power_total{get;set;} //上网电量总计,示例值(280979)
        public Double fd_profit_total{get;set;} //发电利润总额,示例值(19890)
        public String fd_project_fullname{get;set;} //项目名称,示例值(中山xx光伏项目)
        public String fd_project_introduce{get;set;} //项目介绍,示例值(项目介绍)
        public String fd_project_type{get;set;} //项目类型,可用值:风电项目,光伏项目,风光复合型项目,两个一体化,示例值(光伏项目)
        public Double fd_project_volume{get;set;} //容量,示例值(1000)
        public String fd_province{get;set;} //省,示例值(广东)
        public Double fd_pv_after{get;set;} //项目投资财务净现值（所得税后）
        public Double fd_pv_before{get;set;} //项目投资财务净现值（所得税前）
        public Double fd_return_self_rate{get;set;} //自有资金内部收益率,示例值(13)	
        public Double fd_return_total_rate{get;set;} //全部投资内部收益率,示例值(9)
        public String fd_risk{get;set;} //风险评估,示例值(风险评估)
        public Double fd_roe{get;set;} //	项目资本金净利润率（ROE）
        public Double fd_roi{get;set;} //总投资收益率(ROI)
        public Double fd_sales_total{get;set;} //发电销售收入总额（不含增值税）,示例值(10786)
        public Double fd_sales_total_tax{get;set;} //销售税金附加总额,示例值(19890)
        public Double fd_static_payback_all{get;set;} //全投资静态投资回收期,示例值(15)
        public Double fd_static_payback_self{get;set;} //自有资金静态投资回收期,示例值(16)
        public String fd_strategic_expected{get;set;} //项目的预期战略意义,示例值(项目的预期战略意义)
        public Double fd_tax_rate{get;set;} //投资利税率
        public String fd_technical_economic{get;set;} //技术经济指标
        public Double fd_total_investment{get;set;} //总投资,示例值(500000)

        public Double fd_vat_refund{get;set;} //	增值税返还
        public String fd_vice_admin{get;set;} //分管政委,示例值(A02323)
        public String fd_war_zone{get;set;} //项目所属战区或部门,示例值(能源技术公司)
        public Double fd_working_capital{get;set;} //流动资金
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