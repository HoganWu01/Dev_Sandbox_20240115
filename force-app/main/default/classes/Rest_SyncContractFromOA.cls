/*
 * @Author: hogan
 * @Date: ###### Mon Jun 19 14:38:48 CST 2023
 * @LastEditors: hogan
 * @LastEditTime: ###### Mon Jun 19 14:38:39 CST 2023
 * @Descripttion: 当OA《合同会签审批流程》审批结束时，以流程ID为关键字，更新{合同商务}的【任务状态】、【合同签订完成日期】
 */
@RestResource(urlMapping='/SyncContractStatus')
global without sharing class Rest_SyncContractFromOA {
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
            if (marCou?.processId != null) {
                List<Contractmanagement__c> findPa = [SELECT Id FROM Contractmanagement__c WHERE Process_Id__c =: marCou.processId];

                if (findPa.size()>0) {

                    Contractmanagement__c upCon = new Contractmanagement__c();
                    upCon.Id = findPa[0].Id;

                    if (marCou.taskStatus!=null&&marCou.taskStatus!='') {
                        upCon.TaskStatus__c = marCou.taskStatus;
                        upCon.Approvalstatus__c = '30';
                    }

                    if (marCou.signingEndDate!=null&&marCou.signingEndDate!='') { 
                        upCon.ContractSigningEndDate__c = Date.valueOf(marCou.signingEndDate);
                    }
                    
                    update upCon;

                    responseClass.status = 'Success';
                }else {
                    responseClass.status = 'Error';
                    errorMessage = '查询不到对应合同商务！';
                }
            }else {
                responseClass.status = 'Error';
                errorMessage = '接口获取合同商务流程ID出错，请检查入参！';
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
		
        logInfo.RequestURL__c = '/SyncContractStatus';
        logInfo.ClassName__c = 'Rest_SyncContractFromOA';
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
    }

    global class ContractEntity {
		global String processId{get;set;} //流程ID
        global String taskStatus {get;set;} //任务状态
        global String signingEndDate {get;set;} //合同签订完成日期
	}

}