@isTest
public with sharing class Test_MarketingCountersign {
    static testMethod void testMarketingCountersign(){
        
        Contractmanagement__c cm=new Contractmanagement__c();
        cm.Contractname__c='合同';
        cm.WBS__c='123';
        cm.Approvalstatus__c='10';
        cm.DifferentCountries__c='国内非关联方';
        cm.Process_Id__c='18435ebc58c62421033a9ac41daa346b';
        insert cm; 

        ContractSignProcesss__c contractProcess = new ContractSignProcesss__c();
        contractProcess.Process_Id__c = 'OA流程id'; //OA流程id
        contractProcess.FlowTheme__c = '流程主题'; //流程主题
        contractProcess.ProjectManagerCode__c = '项目经理工号'; //项目经理工号
        contractProcess.BusinessManagerCode__c = '商务经理工号'; //商务经理工号
        contractProcess.ProjectType__c = '项目类型'; //项目类型
        contractProcess.Province__c = '省份'; //省份
        contractProcess.ProjectArea__c = '项目所属区域'; //项目所属区域
        contractProcess.CustomerDept__c = '客户营销分部'; //客户营销分部
        contractProcess.ContractCapacity__c = Decimal.valueOf('1.0'); //合同容量
        contractProcess.Quantity__c = Decimal.valueOf('1.0'); //合同数量
        contractProcess.Amount__c = Decimal.valueOf('1.0'); //合同金额（含税）
        contractProcess.Price__c = Decimal.valueOf('1.0'); //合同单价（含税）
        contractProcess.TaxRate__c = '%'; //合同税率
        contractProcess.PaymentMethod__c = ''; //付款方式
        contractProcess.PaymentMethodOther__c = ''; //其他付款方式
        contractProcess.CustomerGroup__c = ''; //所属集团
        insert contractProcess;

        Rest_MarketingCountersign.ResponseClass rMR = new Rest_MarketingCountersign.ResponseClass();
        rMR.errorMessage = 'errorMsg';
        rMR.status = 'pass';

        List<Rest_MarketingCountersign.ContractOtherPartiesEntity> contractOtherPartiesList = new List<Rest_MarketingCountersign.ContractOtherPartiesEntity>();
        List<Rest_MarketingCountersign.SalesModelAndQuantityDetailedEntity> salesModelQuaList = new List<Rest_MarketingCountersign.SalesModelAndQuantityDetailedEntity>();
        List<Rest_MarketingCountersign.PaymentProportionDetailedEntity> payProportionList = new List<Rest_MarketingCountersign.PaymentProportionDetailedEntity>();

        Rest_MarketingCountersign.ContractOtherPartiesEntity  contractOther= new Rest_MarketingCountersign.ContractOtherPartiesEntity();
        contractOther.fd_companyfullname = '1';//公司全称
        contractOther.fd_principal_identity = '1';//主体身份
        // contractOther.ContractSignProcesss__c = contractProcess.Id;//OA营销合同会签流程对象ID
        // contractOther.ContractManagement__c = cm.id;//合同商务ID
        contractOtherPartiesList.add(contractOther);

        Rest_MarketingCountersign.SalesModelAndQuantityDetailedEntity salesModelNew = new Rest_MarketingCountersign.SalesModelAndQuantityDetailedEntity();
        salesModelNew.fd_goods_model = '';//机型
        salesModelNew.fd_goods_number = '1';//数量
        salesModelNew.fd_goods_unit = '';//单位
        salesModelNew.fd_goods_remarks = '';//备注
        // salesModelNew.ContractSignProcesss__c = contractProcess.Id;//OA营销合同会签流程对象ID
        // salesModelNew.ContractManagement__c = cm.id;//合同商务ID
        salesModelQuaList.add(salesModelNew);

        Rest_MarketingCountersign.PaymentProportionDetailedEntity payPro = new Rest_MarketingCountersign.PaymentProportionDetailedEntity();
        payPro.fd_fkfs = '';//付款方式
        payPro.fd_payment_no = '';//付款节点
        payPro.fd_other_payment_node = '';//浮动内容
        payPro.fd_payment_proportion = '1.0';//付款比例
        // payPro.ContractSignProcesss__c = contractProcess.Id;//OA营销合同会签流程对象ID
        // payPro.ContractManagement__c = cm.id;//合同商务ID
        payProportionList.add(payPro);

        Employee__c employee = new Employee__c();
        employee.Name='1';
        employee.Job_Number__c='112252';
        insert employee;

        Rest_MarketingCountersign.MarketingCountersignEntity rMMCE = new Rest_MarketingCountersign.MarketingCountersignEntity();
        rMMCE.applicant = '申请者'; //申请者
        rMMCE.processId = contractProcess.Process_Id__c; //流程Id
        rMMCE.contractId = cm.id;//合同Id
        rMMCE.fd_project_manager = '项目经理';//项目经理
        rMMCE.fd_business_manager = '商务经理'; //商务经理
        //  rMMCE.salesModelQuaList = new List<SalesModelAndQuantityDetailedEntity>();//销售机型及数量集合
        // rMMCE.fjxx = new List<SalesModelAndQuantityDetailedEntity>();

        rMMCE.processtopic = '合同各方全称';//合同各方全称
        rMMCE.fd_contract_amount = '200'; //合同金额（含税）
        rMMCE.fd_contract_unit_price = '100' ;//合同单价（含税）
        rMMCE.fd_payment_method = '税率';//税率
        rMMCE.fd_country_in = '国别';//国别
        rMMCE.fd_xm_khfb = '客户分部';//客户分部
        rMMCE.fd_payment_method = '付款方式';//付款方式
        rMMCE.fd_category = '项目类型';//项目类型
        // rMMCE.paymentRemark = '付款比例备注';//付款比例备注
        // rMMCE.fkbl = new List<PaymentProportionDetailedEntity>();//付款比例集合
        // rMMCE.deliveryPlanRemark = '交付计划备注';//交付计划备注
        // rMMCE.qtf = new List<ContractOtherPartiesEntity>();//交付计划集合
        // rMMCE.remark = '备注';//备注
        // rMMCE.penaltyInfo = '罚款信息';//罚款信息
        // rMMCE.warrantyPeriod = '质保期';//质保期
        // rMMCE.relatedParty = '是否关联方';//是否关联方
        rMMCE.qtf=contractOtherPartiesList;
        rMMCE.fjxx=salesModelQuaList;
        rMMCE.fkbl=payProportionList;

        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        request.requestUri = '/services/apexrest/MarketingCountersign';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"applicant":"A05189","processId":"18435ebc58c62421033a9ac41daa346b","contractId":"'+cm.id+'","processtopic":"内务组_梁舒晗_营销合同会签审批单_合同_补充协议测试_ITXTXQ20220902003-1102_2022-11-02_MS-XSHT20221102001","fd_project_manager":"112252","fd_business_manager":"112252","fd_category":"陆上","fd_project_province":"河北省","fd_war_zone":"西北大区","fd_xm_khfb":"客户三部","fd_contract_capacity":"13.00","fd_contract_quantity":"13","fd_contract_amount":"110200202.00","fd_contract_unit_price":"1102.00","fd_tax_rate":"13","fd_payment_method":"其他","fd_payment_method_qt":"其他付款方式","fd_country_in":"","fd_xsgc":"明阳智慧能源集团股份公司","qtf":[],"fjxx":[{"fd_goods_model":"MY6.6-122/134","fd_goods_number":"23","fd_goods_unit":"台","fd_goods_remarks":"11"},{"fd_goods_model":"MySE5.5-123/135","fd_goods_number":"32","fd_goods_unit":"台","fd_goods_remarks":"11"}],"fkbl":[{"fd_fkfs":"固定","fd_payment_node":"预付款","fd_payment_no":"1","fd_other_payment_node":"","fd_payment_proportion":"10.00"},{"fd_fkfs":"固定","fd_payment_node":"投料款","fd_payment_no":"2","fd_other_payment_node":"","fd_payment_proportion":"10.00"},{"fd_fkfs":"固定","fd_payment_node":"到货款","fd_payment_no":"3","fd_other_payment_node":"","fd_payment_proportion":"10.00"},{"fd_fkfs":"固定","fd_payment_node":"预验收款","fd_payment_no":"4","fd_other_payment_node":"","fd_payment_proportion":"10.00"},{"fd_fkfs":"固定","fd_payment_node":"质保金款","fd_payment_no":"5","fd_other_payment_node":"","fd_payment_proportion":"10.00"},{"fd_fkfs":"浮动","fd_payment_node":"","fd_payment_no":"","fd_other_payment_node":"浮动1102-1","fd_payment_proportion":"10.00"},{"fd_fkfs":"浮动","fd_payment_node":"","fd_payment_no":"","fd_other_payment_node":"浮动1102-2","fd_payment_proportion":"40.00"}]}');
        Rest_MarketingCountersign.doPost();
        Test.stopTest();
    }

    
}