@isTest
public with sharing class Test_GetContractName {
    @TestSetup
    static void makeData(){

        Interface_Log__c logInfo = new Interface_Log__c();
        logInfo.RequestURL__c = '/GetContractName';
        logInfo.ClassName__c = 'Rest_GetContractName';
        logInfo.RequestBody__c = '';
        insert logInfo;

        Contractmanagement__c cm=new Contractmanagement__c();
        cm.Contractname__c='合同';
        cm.WBS__c='123';
        cm.Approvalstatus__c='10';
        cm.DifferentCountries__c='国内非关联方';
        insert cm;
    }

    static testMethod void test_doGet(){

        //Account acc = [SELECT ID,NAME FROM Account WHERE NAME = 'aaa'];

        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new GetContractName_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Rest_GetContractName.doGet();
        System.Test.stopTest();

    }


    class GetContractName_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"status": 200,"errorMessage": "查询成功!","data":[{"wbs":"S1-2022-2-15","projectName":"中电建北京1测试1347MW项目","name":"SAP项目新建测试1","customerType":"1","customerName":"2","customerCode":"3","contractId":"a0qp0000008Zj8DAAS"},{"wbs":"","projectName":"广东中电建广东中山二期200MW项目","name":"早上好","customerType":"","customerName":"","customerCode":"","contractId":"a0qp0000008ZcHIAA0"}]}');
			return response;
		}

	}

    static testMethod void testError(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new GetContractName_Mock_Error());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Rest_GetContractName.doGet();
        List<Rest_GetContractName.ContractNameEntity> contractNameListTemp = new List<Rest_GetContractName.ContractNameEntity>();
		
        //查找合同商务
            for (Contractmanagement__c conApproval : [SELECT Id,Contractname__c,WBS__c,Objectname2__c,Company__r.AccountNumber,	Company__r.Name,DifferentCountries__c FROM Contractmanagement__c WHERE (Approvalstatus__c in ('10','11')) AND Contractname__c!=null]) {
                Rest_GetContractName.ContractNameEntity contractTemp = new Rest_GetContractName.ContractNameEntity();
                contractTemp.contractId = conApproval.Id;
                contractTemp.name = conApproval.Contractname__c;
                contractTemp.wbs = conApproval.WBS__c==null?'':conApproval.WBS__c;
                contractTemp.projectName = conApproval.Objectname2__c==null?'':conApproval.Objectname2__c;
                contractTemp.customerCode = conApproval.Company__r.AccountNumber==null?'':conApproval.Company__r.AccountNumber;
                contractTemp.customerName = conApproval.Company__r.Name==null?'':conApproval.Company__r.Name;
                contractTemp.customerType = conApproval.DifferentCountries__c==null?'':conApproval.DifferentCountries__c;
                contractNameListTemp.add(contractTemp);
            }
        System.Test.stopTest();

    }

    class GetContractName_Mock_Error implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(401);
			response.setStatus('OK');
			response.setBody('{"code": 5003,"message": "异常!"}');
			return response;
		}

	}
}