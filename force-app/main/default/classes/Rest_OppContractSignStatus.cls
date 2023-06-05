/*
 * @Author: hogan
 * @Date: 2023-04-21 09:00:00
 * @LastEditors: hogan
 * @LastEditTime: 2023-04-21 09:00:00
 * @Descripttion: 商机合同签订状态接口，供OA计划平台使用
 */
@RestResource(urlMapping='/OppContractSignStatus')
global without sharing class Rest_OppContractSignStatus {
    @HttpPost
    global static void doPost() {
		RestRequest rReq = RestContext.request;
		RestResponse res = RestContext.response;
        Interface_Log__c logInfo = new Interface_Log__c();
		String errorMessage = '';
		ResponseClass responseClass = new ResponseClass();
        // System.debug('请求参数'+rReq.requestBody.toString());
		try
        {
            ContractEntity marCou=(ContractEntity)System.JSON.deserialize(rReq.requestBody.toString(), ContractEntity.class);
            logInfo.RequestBody__c = rReq.requestBody.toString();
            // System.debug('logInfo.RequestBody__c===>'+logInfo.RequestBody__c);
            if (marCou?.projectNumber != null) {
                Contractmanagement__c findManage = new Contractmanagement__c();
                findManage = [SELECT Id, 
                WBS__c, //项目编号
                ObjectName__r.Account.Name,//商机-客户全称
                ObjectName__r.Account.Shortname__c, //商机-客户简称
                toLabel(ObjectName__r.MarketBidDept__c), //商机-客户分部
                TaskStatus__c //任务状态
                FROM Contractmanagement__c WHERE WBS__c =: marCou.projectNumber and ObjectName__r.Close__c = false limit 1];

                if (findManage!=null) {
                    ContractEntity con = new ContractEntity();
                    con.projectNumber = findManage.WBS__c;
                    con.accountName = findManage.ObjectName__r.Account.Name;
                    con.accountShortName = findManage.ObjectName__r.Account.Shortname__c;
                    con.marketBidDept = findManage.ObjectName__r.MarketBidDept__c;
                    con.taskStatus = findManage.TaskStatus__c;

                    responseClass.status = 'Success';
                    responseClass.data = con;
                }else {
                    responseClass.status = 'Error';
                    errorMessage = '查询不到对应项目编号的合同！';
                }
            }else {
                responseClass.status = 'Error';
                errorMessage = '接口获取项目编号出错，请检查入参！';
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
		
        logInfo.RequestURL__c = '/OppContractSignStatus';
        logInfo.ClassName__c = 'Rest_OppContractSignStatus';
        logInfo.RespondBody__c = System.JSON.serialize(responseClass);
        logInfo.ErrorMessage__c = errorMessage;
        logInfo.RequestCall__c = 'CallIn';
        if (responseClass.status == 'Success') {
            logInfo.IsSuccess__c = true;
        }else {
            logInfo.IsSuccess__c = false;
        }
        insert logInfo;
    }

    global Class ResponseClass{
        global String status {get;set;}
    	global String errorMessage {get;set;}
        global ContractEntity data {get;set;}
    }

    global class ContractEntity {
		global String projectNumber{get;set;} //项目编号
        global String accountName {get;set;} //商机-客户全称
        global String accountShortName {get;set;} //商机-客户简称
        global String marketBidDept {get;set;} //商机-客户分部
        global String taskStatus  {get;set;} //任务状态
	}

}