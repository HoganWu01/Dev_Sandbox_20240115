/*
 * @Author: Conner
 * @Date: 2021-09-06 10:34:20
 * @LastEditors: Conner
 * @LastEditTime: 2021-11-17 18:53:47
 * @Descripttion: 获取合同名称接口
 */
@RestResource(urlMapping='/GetContractName')
global without sharing class Rest_GetContractName {
    @HttpGet
    global static void doGet() {
		RestRequest rReq = RestContext.request;
		RestResponse res = RestContext.response;
		String errorMessage = '';
		ResponseClass responseClass = new ResponseClass();
        List<ContractNameEntity> contractNameListTemp = new List<ContractNameEntity>();
		try
        {
        //查找合同商务
            for (Contractmanagement__c conApproval : [SELECT Id,Contractname__c,WBS__c,Objectname2__c,Company__r.AccountNumber,	Company__r.Name,DifferentCountries__c FROM Contractmanagement__c WHERE (Approvalstatus__c in ('10','11')) AND Contractname__c!=null]) {
                ContractNameEntity contractTemp = new ContractNameEntity();
                contractTemp.contractId = conApproval.Id;
                contractTemp.name = conApproval.Contractname__c;
                contractTemp.wbs = conApproval.WBS__c==null?'':conApproval.WBS__c;
                contractTemp.projectName = conApproval.Objectname2__c==null?'':conApproval.Objectname2__c;
                contractTemp.customerCode = conApproval.Company__r.AccountNumber==null?'':conApproval.Company__r.AccountNumber;
                contractTemp.customerName = conApproval.Company__r.Name==null?'':conApproval.Company__r.Name;
                contractTemp.customerType = conApproval.DifferentCountries__c==null?'':conApproval.DifferentCountries__c;
                contractNameListTemp.add(contractTemp);
            }
            responseClass.status = 'Success';
            responseClass.data = contractNameListTemp;
                  
		}catch(Exception e){
			responseClass.status = 'Error';
			errorMessage = e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
		}

		responseClass.errorMessage = errorMessage;
        res.addHeader('Content-Type', 'application/json; charset=utf-8');
    	res.responseBody = Blob.valueOf(System.JSON.serialize(responseClass));
		
        Boolean isAtt = false;
        if(Test.isRunningTest()){
            isAtt =true;
        }
        Interface_Log__c logInfo = new Interface_Log__c();
        logInfo.RequestURL__c = '/GetContractName';
        logInfo.ClassName__c = 'Rest_GetContractName';
        logInfo.RequestBody__c = '';
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
        global List<ContractNameEntity> data {get;set;}
    }

    global Class ContractNameEntity{
    	global String contractId {get;set;}//合同id
        global String name {get;set;}//合同名称
        global String wbs {get;set;}//项目编号
        global String projectName {get;set;}//项目名称
        global String customerCode {get;set;}//客户编号
        global String customerName {get;set;}//客户名称
        global String customerType {get;set;}//客户类型
    }
}