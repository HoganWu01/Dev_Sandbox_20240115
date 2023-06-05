/*
 * @Author: Conner
 * @Date: 2021-09-07 09:34:59
 * @LastEditors: Conner
 * @LastEditTime: 2021-11-15 17:48:50
 * @Descripttion: 营销合同会签审批单接口
 */
@RestResource(urlMapping='/MarketingCountersign')
global without sharing class Rest_MarketingCountersign {
    @HttpPost
    global static void doPost() {
		RestRequest rReq = RestContext.request;
		RestResponse res = RestContext.response;
        Interface_Log__c logInfo = new Interface_Log__c();
		String errorMessage = '';
		ResponseClass responseClass = new ResponseClass();
        // System.debug('请求参数'+rReq.requestBody.toString());
        // List<ContractSignedApproval__c> contractSignedApprovalList = new List<ContractSignedApproval__c>();
        
		try
        {
            MarketingCountersignEntity marCou=(MarketingCountersignEntity)System.JSON.deserialize(rReq.requestBody.toString(), MarketingCountersignEntity.class);
            logInfo.RequestBody__c = rReq.requestBody.toString();
            // System.debug('logInfo.RequestBody__c===>'+logInfo.RequestBody__c);
            //如果OA因为草稿状态使用了两次一样的合同名称，则以先提交的为准
            if (marCou?.contractId!=null && marCou?.processId != null) {
                Id conId = marCou.contractId;//合同商务id
                String processId = marCou.processId;//OA流程id

                // if (contractManagement.Process_Id__c==null) {
                    ContractSignProcesss__c contractProcess = new ContractSignProcesss__c();

                    contractProcess.Process_Id__c = processId; //OA流程id
                    contractProcess.FlowTheme__c = marCou.processtopic; //流程主题
                    Employee__c employee = [SELECT Id,Name FROM Employee__c WHERE Job_Number__c =: marCou.fd_project_manager];
                    Employee__c employee2 = [SELECT Id,Name FROM Employee__c WHERE Job_Number__c =: marCou.fd_business_manager];
                    contractProcess.ProjectManagerName__c = employee?.Name; //项目经理名称
                    contractProcess.ProjectManagerCode__c = marCou.fd_project_manager; //项目经理工号
                    contractProcess.BusinessManagerName__c = employee2?.Name; //商务经理名称
                    contractProcess.BusinessManagerCode__c = marCou.fd_business_manager; //商务经理工号
                    contractProcess.ProjectType__c = marCou.fd_category; //项目类型
                    contractProcess.Province__c = marCou.fd_project_province; //省份

                    // List<ProjectArea__c> projectArea = [SELECT fdid__c FROM ProjectArea__c WHERE Name =: marCou.fd_war_zone];
                    // contractProcess.ProjectArea__c = projectArea.get(0)?.fdid__c; //项目所属区域
                    contractProcess.ProjectArea__c = marCou.fd_war_zone; //项目所属区域

                    // MarketBidDept__c marketBidDept = [SELECT DeptId__c FROM MarketBidDept__c WHERE Name =: marCou.fd_xm_khfb];
                    // contractProcess.CustomerMarketingDivision__c = marketBidDept?.DeptId__c; //客户营销分部
                    contractProcess.CustomerDept__c = marCou.fd_xm_khfb; //客户营销分部
                    contractProcess.ContractCapacity__c = Decimal.valueOf(marCou.fd_contract_capacity); //合同容量
                    contractProcess.Quantity__c = Decimal.valueOf(marCou.fd_contract_quantity); //合同数量
                    contractProcess.Amount__c = Decimal.valueOf(marCou.fd_contract_amount); //合同金额（含税）
                    contractProcess.Price__c = Decimal.valueOf(marCou.fd_contract_unit_price); //合同单价（含税）
                    contractProcess.TaxRate__c = marCou.fd_tax_rate==''?'':marCou.fd_tax_rate+'%'; //合同税率
                    contractProcess.PaymentMethod__c = marCou.fd_payment_method; //付款方式
                    contractProcess.PaymentMethodOther__c = marCou.fd_payment_method_qt; //其他付款方式
                    // contractProcess.DifferentCountries__c = marCou.fd_country_in; //客户类型
                    contractProcess.CustomerGroup__c = marCou.fd_xsgc; //所属集团
                    
                    //更新OA会签合同
                    List<ContractSignProcesss__c> contractProcessList = new List<ContractSignProcesss__c>([SELECT Id FROM ContractSignProcesss__c WHERE Process_Id__c =: processId ]);
		            delete contractProcessList;
                    insert contractProcess;

                    Contractmanagement__c contractManagement = [SELECT Id,Process_Id__c FROM Contractmanagement__c WHERE Id =: conId];
                    contractManagement.OAProcessTheme__c=contractProcess.Id;
                    contractManagement.Process_Id__c = processId; //OA流程id
                    contractManagement.Applicant__c = marCou.applicant; //申请人
                    contractManagement.StartDate__c = Date.today(); //合同会签审批开始日期
                    contractManagement.Approvalstatus__c = '20';
                    //更新合同商务
                    update contractManagement;
                    
                List<ContractOtherParties__c> contractOtherPartiesList = new List<ContractOtherParties__c>();
                List<SalesModelContract__c> salesModelQuaList = new List<SalesModelContract__c>();
                List<Payment_Proportion_Contract__c> payProportionList = new List<Payment_Proportion_Contract__c>();

                    if (marCou?.qtf != null) {
                        for (ContractOtherPartiesEntity other : marCou?.qtf) {
                            ContractOtherParties__c contractOther = new ContractOtherParties__c();
                            contractOther.CompanyName__c = other.fd_companyfullname;//公司全称
                            contractOther.SubjectIdentity__c = other?.fd_principal_identity;//主体身份
                            contractOther.ContractSignProcesss__c = contractProcess.Id;//OA营销合同会签流程对象ID
                            contractOther.ContractManagement__c = conId;//合同商务ID
                            contractOtherPartiesList.add(contractOther);
                        }
                    }
                    if (marCou?.fjxx !=null) {
                        for (SalesModelAndQuantityDetailedEntity salesModel : marCou.fjxx) {
                            SalesModelContract__c salesModelNew = new SalesModelContract__c();
                            salesModelNew.Name = salesModel.fd_goods_model;//机型
                            salesModelNew.Quantity__c = Integer.valueOf(salesModel.fd_goods_number);//数量
                            salesModelNew.Unit__c = salesModel.fd_goods_unit;//单位
                            salesModelNew.Remark__c = salesModel.fd_goods_remarks;//备注
                            salesModelNew.ContractSignProcesss__c = contractProcess.Id;//OA营销合同会签流程对象ID
                            salesModelNew.ContractManagement__c = conId;//合同商务ID
                            salesModelQuaList.add(salesModelNew);
                        }
                    }
                    if (marCou?.fkbl!=null) {
                        for (PaymentProportionDetailedEntity pay : marCou.fkbl) {
                            Payment_Proportion_Contract__c payPro = new Payment_Proportion_Contract__c();
                            payPro.PaymentType__c = pay.fd_fkfs;//付款方式
                            payPro.Paymentnode__c = pay.fd_payment_no;//付款节点
                            payPro.FloatContent__c = pay.fd_other_payment_node;//浮动内容
                            payPro.Paymentratio__c = Decimal.valueOf(pay.fd_payment_proportion);//付款比例
                            payPro.ContractSignProcesss__c = contractProcess.Id;//OA营销合同会签流程对象ID
                            payPro.ContractManagement__c = conId;//合同商务ID
                            payProportionList.add(payPro);
                        }
                    }

                    String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();
                    //插入数据到集成中间表
                    Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                    middleForm.RecordTypeId = recTypeId;//赋值记录类型
                    middleForm.Object_API__c = 'Contractmanagement__c';//对象API
                    middleForm.Mapping_Object_Id__c = marCou.contractId;//对应对象的Id
                    middleForm.Scheme_Type__c = null;//方案类型
                    middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                    middleForm.Process_Id__c = marCou.processId;//流程Id
                    middleForm.Approvalstatus__c = '20';//审批状态
                    insert middleForm;

                    insert salesModelQuaList;
                    insert payProportionList;
                    insert contractOtherPartiesList;
                    responseClass.status = 'Success';
                // }else {
                //     responseClass.status = 'Error';
                //     errorMessage = '该合同名称已被使用';
                // }
            }else {
                responseClass.status = 'Error';
                errorMessage = '合同Id&流程Id不能为空';
            }
		}catch(Exception e){

            // System.debug('错误行号：'+e.getLineNumber());
            // System.debug('错误信息：'+e.getMessage());
			responseClass.status = 'Error';
			errorMessage = e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
		}

		responseClass.errorMessage = errorMessage;
        res.addHeader('Content-Type', 'application/json; charset=utf-8');
    	res.responseBody = Blob.valueOf(System.JSON.serialize(responseClass));
		
        Boolean isAtt = false;
        Boolean isAttReq = false;
        
        logInfo.RequestURL__c = '/MarketingCountersign';
        logInfo.ClassName__c = 'Rest_MarketingCountersign';
        // System.debug('logInfo--------------'+logInfo);
        // System.debug('RequestBody__c--------------'+logInfo.RequestBody__c);
        if (logInfo.RequestBody__c.length()>130000) {
            logInfo.RequestBody__c = '见附件';
            isAttReq = true;
        }
        if (System.JSON.serialize(responseClass).length()>130000) {
            logInfo.RespondBody__c = '见附件';
            isAtt = true;
        }else {
            logInfo.RespondBody__c = System.JSON.serialize(responseClass);
        }
        logInfo.ErrorMessage__c = errorMessage;
        logInfo.RequestCall__c = 'CallIn';
        if (responseClass.status == 'Success') {
            logInfo.IsSuccess__c = true;
        }else {
            logInfo.IsSuccess__c = false;
        }
        insert logInfo;
        if (isAttReq) {
            Attachment insertAttReq = new Attachment();
            insertAttReq.ParentId = logInfo.Id;
            insertAttReq.Body = Blob.valueOf(rReq.requestBody.toString());
            insertAttReq.Name = 'RequestBody.txt';
            insertAttReq.ContentType = 'text/plain';
            insert insertAttReq;
        }
        if (isAtt) {
            Attachment insertAtt = new Attachment();
            insertAtt.ParentId = logInfo.Id;
            insertAtt.Body = Blob.valueOf(System.JSON.serialize(responseClass));
            insertAtt.Name = 'ResponseBody.txt';
            insertAtt.ContentType = 'text/plain';
            insert insertAtt;
        }
    }

    global Class ResponseClass{
    	global String status {get;set;}
    	global String errorMessage {get;set;}
    }

    global class MarketingCountersignEntity {
		global String applicant{get;set;} //申请者
		global String processId{get;set;} //流程Id
		global String contractId{get;set;} //合同Id
		global String processtopic{get;set;} //合同主题
		// global Date applicatDate{get;set;} //申请日期
		global String fd_project_manager{get;set;} //项目经理
		global String fd_business_manager{get;set;} //商务经理
		global String fd_category{get;set;} //项目类型
		global String fd_project_province{get;set;} //省份
		global String fd_war_zone{get;set;} //项目区域
		global String fd_xm_khfb{get;set;} //客户/营销分部
		// global String fullName{get;set;} //合同各方全称
		global String fd_contract_capacity{get;set;} //合同容量
        global String fd_contract_quantity{get;set;} //合同台数
		global String fd_contract_amount{get;set;} //合同金额（含税）
		global String fd_contract_unit_price{get;set;} //合同单价（含税）
		global String fd_tax_rate{get;set;} //税率
		global String fd_payment_method{get;set;} //付款方式
		global String fd_payment_method_qt{get;set;} //其他付款方式
		global String fd_country_in{get;set;} //客户类型
		global String fd_xsgc{get;set;} //所属集团
        
        global List<ContractOtherPartiesEntity> qtf{get;set;} //其他方集合
		global List<SalesModelAndQuantityDetailedEntity> fjxx{get;set;} //销售机型及数量集合
		global List<PaymentProportionDetailedEntity> fkbl{get;set;} //付款比例集合
	}

    global class ContractOtherPartiesEntity {
		global String fd_companyfullname{get;set;} //公司全称
		global String fd_principal_identity{get;set;} //主体身份
	}

    global class SalesModelAndQuantityDetailedEntity {
		global String fd_goods_model{get;set;} //机型
		global String fd_goods_number{get;set;} //数量
		global String fd_goods_unit{get;set;} //单位
		global String fd_goods_remarks{get;set;} //备注
	}

    global class PaymentProportionDetailedEntity {
		global String fd_fkfs{get;set;} //固定/浮动
		global String fd_payment_no{get;set;} //付款节点
		global String fd_other_payment_node{get;set;} //浮动内容
		global String fd_payment_proportion{get;set;} //付款比例
	}

}