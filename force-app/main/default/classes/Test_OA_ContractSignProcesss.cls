@isTest
public with sharing class Test_OA_ContractSignProcesss {
    @TestSetup
    static void makeData(){
        External_System_Param__c ext = new External_System_Param__c();
        ext.name = 'oaCounterSignProcesssList';
        ext.Request_URL__c = 'http://61.142.78.7:8001/api/oaCounterSignProcesssList';
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

    }    

    static testMethod void testOA_ContractSignProcesss(){
        String startDate=String.valueOf(Datetime.now().addDays(-3));
        String endDate=String.valueOf(Datetime.now());
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Res_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OA_ContractSignProcesss.OASync(startDate,endDate);
        System.Test.stopTest();
    }

    static testMethod void testError(){
        System.Test.startTest();
        System.test.setMock(HttpCalloutMock.class,new Error_Mock());
        RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		RestContext.response = response;
		RestContext.request = request;
        Controller_OA_ContractSignProcesss.OASync('','');
        System.Test.stopTest();
    }

    static testMethod void testSchedule_OA_SyncContractSignProcesss(){

        System.Test.startTest();
        System.schedule('每天早上7点调用','0 0 7 * * ?',new Schedule_OA_SyncContractSignProcesss());
        System.Test.stopTest();
    }

    class Res_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code":200,"message":null,"data":[{"fdId":"1840deb45198e64af8802c74e098328e","docSubject":"开发室_袁誉柱_营销合同会签审批单_11_2022-10-25_MS-XSHT20221025003","fdOldProjectManager":"谌程","fdOldProjectManagerNo":"A06784","fdOldBusinessManager":"代维锋","fdOldBusinessManagerNo":"A00688","fdOldProjectCode":"S1-20210127","fdOldProjectName":"中电建内蒙古呼和浩特阿拉巴UAT1221800MW项目","fdOldProjectType":"陆上","fdOldProvince":"内蒙古自治区","fdOldZone":"中部大区","fdOldCustomerDept":"不涉及大客户","fdOldSell":"明阳智慧能源集团股份公司","fdOldCustomerCode":"0000990369","fdOldCustomerName":"福建华清新能源有限公司","fdOldCustomerGroup":"中节能","fdYhCapacity":"111.0","fdYhNum":"11.0","fdOldHtTotal":"1111.99","fdOldHtRate":"17%","fdOldPrice":"33.44","fdOldPayMode":"商业承兑","fdYlTotalProportion":"100","signProcesssOtherList":[],"signProcesssGoodsList":[{"fdParentId":"1840deb45198e64af8802c74e098328e","fdGoodsModel":"MySE5.2-166_111","fdGoodsNumber":"11","fdGoodsUnit":"台","fdGoodsRemarks":"22"},{"fdParentId":"1840deb45198e64af8802c74e098328e","fdGoodsModel":"MySE4.2-145_111","fdGoodsNumber":"11","fdGoodsUnit":"台","fdGoodsRemarks":"22"}],"signProcesssPayList":[{"fdParentId":"1840deb45198e64af8802c74e098328e","fdFkfs":"浮动","fdPaymentNode":"","fdPaymentNodeNo":"","fdOtherPaymentNode":"测试浮动","fdPaymentProportion":""},{"fdParentId":"1840deb45198e64af8802c74e098328e","fdFkfs":"固定","fdPaymentNode":"投料款","fdPaymentNodeNo":"2","fdOtherPaymentNode":"","fdPaymentProportion":""},{"fdParentId":"1840deb45198e64af8802c74e098328e","fdFkfs":"固定","fdPaymentNode":"到货款","fdPaymentNodeNo":"3","fdOtherPaymentNode":"","fdPaymentProportion":""},{"fdParentId":"1840deb45198e64af8802c74e098328e","fdFkfs":"浮动","fdPaymentNode":"","fdPaymentNodeNo":"","fdOtherPaymentNode":"123","fdPaymentProportion":""},{"fdParentId":"1840deb45198e64af8802c74e098328e","fdFkfs":"固定","fdPaymentNode":"预验收款","fdPaymentNodeNo":"4","fdOtherPaymentNode":"","fdPaymentProportion":""},{"fdParentId":"1840deb45198e64af8802c74e098328e","fdFkfs":"固定","fdPaymentNode":"质保金款","fdPaymentNodeNo":"5","fdOtherPaymentNode":"","fdPaymentProportion":""}]}]}');
			return response;
		}

	}

    class Error_Mock implements HttpCalloutMock{

		public HttpResponse respond(HttpRequest param1) {
			HttpResponse response=new HttpResponse();
			response.setStatusCode(200);
			response.setStatus('OK');
			response.setBody('{"code": "2001","message": null,"data": []}');
			return response;
		}

	}
}