@isTest
public with sharing class Test_MarketingContract {

    @TestSetup
    static void makeData(){

        Interface_Log__c logInfo = new Interface_Log__c();
        logInfo.RequestURL__c = '/GetContractName';
        logInfo.ClassName__c = 'Rest_GetContractName';
        logInfo.RequestBody__c = '';
        insert logInfo;
    }
    
    static testMethod void testCreateMarketingContract(){
        Interface_Log__c logInfo = new Interface_Log__c();
        logInfo.RequestURL__c = '/MarketingContract';
        logInfo.ClassName__c = 'MarketingContract';
        logInfo.RequestBody__c = '';
        insert logInfo;

        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaMarketingContractAdd';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaMarketingContractAdd';
        ext.Request_Source__c = '1';
        ext.Request_Method__c = 'oaTestAdd';
        ext.Request_Key__c = '2907f6af61e44988a8de4a01f2248e10';
        ext.Initialization_Vector__c = 'bWluZ3lhbmd6aGlu';
        insert ext ; 

        OpenPlatformApi__c open = new OpenPlatformApi__c();
        open.Name = 'GetToken';
        open.Client_Id__c = 'aHI6XXcIxmO5CVfXkPE80sPA';
        open.Client_Secret__c = 'vSaQLaO7Bhp5jK0CGgkoJO4NpO41b4ZZ';
        open.Grant_Type__c = 'client_credentials';
        open.IP__c = 'http://61.142.78.5:8011';
        open.URL__c = 'http://61.142.78.5:8011/admin/oauth/token';
        insert open;
        
        Account acc = new Account();
        acc.BeenGroup__c =true ; 
        acc.Name = 'acc';
        acc.AccountNumber = 'acc';
        acc.name = 'acc';
        acc.name = 'acc';
        insert acc ; 

        Employee__c ee = new Employee__c();
        ee.Name='黎智聪';
        ee.Status__c = '在职';
        insert ee;

        ContractSupplement__c cc = new ContractSupplement__c();
        cc.SealApplication__c = '是';
        cc.Seal_Org__c = '基地';
        cc.Seal_Safekeep_Dept__c = '青海基地';
        cc.Country__c = '国内非关联方';
        cc.ProtocolType__c = '主体变更;机型或配置变更;其他';
        cc.Salesdepartment__c = '新疆公司';
        cc.Other_Protocol_Types__c = '2';
        cc.Process_Id__c = '3';
        cc.Approval_Comments__c = '4';
        cc.WBS__c = '5';
        cc.Project_Manager__c = ee.id;
        cc.ProjectType__c = '陆上';
        // cc.ProjectArea__c = '9';
        cc.Approvalstatus__c = '10';
        cc.AgreementIntroduction__c = '11';
        cc.AccountName__c = acc.id;
        cc.Business_Manager__c = ee.id;
        cc.ContractCapacity__c = 1.0;
        // cc.TaxRate__c = '17%';
        // cc.Amount__c = 1.0;
        cc.ContractQuantity__c = 1.0;
        // cc.Price__c = 1.0;
        // cc.PaymentMethod__c = '其他';
        // cc.PaymentMethodOther__c='19';

        MarketBidDept__c marketBidDept = new MarketBidDept__c();
        marketBidDept.Name='客户三部';
        marketBidDept.DeptId__c='162092f16e404d92eb794264e8797013';
        insert marketBidDept;
        cc.CustomerMarketingDivision__c = marketBidDept.DeptId__c; //客户营销分部id

        ProjectArea__c projectArea = new ProjectArea__c(); 
        projectArea.Name='西北大区';
        projectArea.fdid__c='183bfa1a47eff4b47f600a34a7486c2c';
        projectArea.AreaId__c='175687b6a2fad210cba0146485eaf5c2';
        projectArea.AreaPerson__c='王博';
        projectArea.AreaPersonId__c='151eb7ea8e38e715f426c6f47a6aa6a0';
        insert projectArea;

        cc.ProjectArea__c=projectArea.fdid__c;
        insert cc ; 

        Seal_Related_Information__c sc = new Seal_Related_Information__c();
        sc.Document_Category__c = '1';
        sc.Document_Name__c = '111';
        sc.Seal_Company__c = '	明阳智慧能源集团股份公司+MY+A04313';
        sc.Seal_Type__c = '公章';
        sc.Seal_Numble__c = '11';
        sc.Marketing_Contract__c = cc.id ; 
        insert sc ; 

        SupplementOtherParties__c so= new SupplementOtherParties__c();
        so.CompanyName__c='1';
        so.SubjectIdentity__c='1';
        so.ContractSupplement__c=cc.id;
        insert so;

        SalesModelAndQuantity__c sm= new SalesModelAndQuantity__c();
        sm.MachineCfg__c=1.0;
        sm.MachineZj__c=1;
        sm.MachineHeight__c=1.0;
        sm.Remark__c='1';
        sm.Quantity__c=1;
        sm.ContractSupplement__c=cc.id;
        insert sm;
       
        recordType imtRecordType = [SELECT Id,DeveloperName ,Sobjecttype FROM recordType WHERE sobjecttype = 'Integrated_Middle_Table__c' AND DeveloperName = 'Integrated_Record_Type'];
        
        Integrated_Middle_Table__c ic = new Integrated_Middle_Table__c();
        ic.Mapping_Object_Id__c = cc.id;
        ic.RecordTypeId = imtRecordType.id;
        insert ic;

        List<String> sealCompayName = new List<String>(); //印章归属公司
        List<String> sealName = new List<String>(); //印章类别
        List<String> sealNumber = new List<String>(); //印章数量
        List<String> sealAdmins = new List<String>(); //印章保管员

        List<String> fd_bg_machine_cfg = new List<String>();//变更后风机信息明细表.单机容量（MW）,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_count = new List<String>();//变更后风机信息明细表.数量,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_height = new List<String>();//变更后风机信息明细表.塔筒高度（米）,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_name = new List<String>();//变更后风机信息明细表.机型,格式：'主机型'+'单机容量'+'-'+'叶轮直径'+'/'+'塔筒高度'，协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_remark = new List<String>();//变更后风机信息明细表.备注,协议类型为“机型或配置变更”时选填
        List<String> fd_bg_machine_type = new List<String>();//变更后风机信息明细表.主机型显示值,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_unit = new List<String>();//变更后风机信息明细表.单位,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_zj = new List<String>();//变更后风机信息明细表.叶轮直径（米）,协议类型为“机型或配置变更”时必填

        List<String> fd_bg_fkfs = new List<String>();//变更付款比例明细表.固定/浮动,协议类型为“支付条款变更”时必填,可填固定、浮动
        List<String> fd_bg_pay_fnode = new List<String>();//变更付款比例明细表.付款节点_浮动,协议类型为“支付条款变更”且选择浮动时必填
        List<String> fd_bg_pay_gnode = new List<String>();
        List<String> fd_bg_pay_hd_gnode = new List<String>();
        List<String> fd_bg_pay_proportion = new List<String>();//变更付款比例明细表.付款比例
        List<String> fd_company_name = new List<String>();//其他方明细表.公司全称
        List<String> fd_subject_identity = new List<String>();//其他方明细表.主体身份

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new ProprietorRequireReview_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        ControllerMarketingContract.toCreateMarketingContract(cc.id);
        System.Test.stopTest();

    }

    class ProprietorRequireReview_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": 200,"message": "流程启动成功！","data":{"rtStatus":"Y","rtMsg":"流程审批成功！","fdId":"1843662ee53d420b4f6770145c493f69","docSubject":"销售业务部_彭智宣_营销合同补充协议审批单_魔龙风河北棒棒藤椅蠕动泵三期22MW项目_2022-11-02_MS-HTBCXY-20221102003","fdNumber":"MS-HTBCXY-20221102003"}}');
			return response;
		}
	}
}