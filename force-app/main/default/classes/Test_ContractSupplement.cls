@isTest
public with sharing class Test_ContractSupplement {
    @TestSetup
    static void makeData(){

        Interface_Log__c logInfo = new Interface_Log__c();
        logInfo.RequestURL__c = '/GetContractName';
        logInfo.ClassName__c = 'Rest_GetContractName';
        logInfo.RequestBody__c = '';
        insert logInfo;
        
        // Rest_ContractSupplement.ContractSupplementEntity rMMCE = new Rest_ContractSupplement.ContractSupplementEntity();
        // rMMCE.processId = '流程Id'; //流程Id
        // rMMCE.contractSupplementCode = '补充协议编号';//补充协议编号
        // rMMCE.contractNo = '买方合同编号';//买方合同编号
        // rMMCE.contractDate = System.today();//签订时间

        ContractSupplement__c findManage = new ContractSupplement__c();
        findManage.Process_Id__c='11112121311';
        insert findManage;

    }

    static testMethod void testContractSupplement(){

        ContractSupplement__c contract = new ContractSupplement__c();
        insert contract ; 
        Rest_ContractSupplement.ResponseClass rMR = new Rest_ContractSupplement.ResponseClass();
        rMR.errorMessage = 'errorMsg';
        rMR.status = 'pass';
        
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        request.requestUri = '/services/apexrest/ContractSupplement';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"applicant":"测试用户","applicatDate":null,"projectManager":"","businessManager":"","processId":"11112121311","contractId":"'+contract.id+'"}');
        Rest_ContractSupplement.doPost();
        Test.stopTest();
    }

    
}