/*
 * @Author: zxg
 * @Date: 2022-10-10 09:00:00
 * @LastEditors: zxg
 * @LastEditTime: 2022-10-10 09:00:00
 * @Descripttion: 营销合同补充协议接口
 */
@RestResource(urlMapping='/ContractSupplement')
global without sharing class Rest_ContractSupplement {
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
            ContractSupplementEntity marCou=(ContractSupplementEntity)System.JSON.deserialize(rReq.requestBody.toString(), ContractSupplementEntity.class);
            logInfo.RequestBody__c = rReq.requestBody.toString();
            // System.debug('logInfo.RequestBody__c===>'+logInfo.RequestBody__c);
            //如果OA因为草稿状态使用了两次一样的合同名称，则以先提交的为准
            if (marCou?.processId != null) {
                ContractSupplement__c findManage = new ContractSupplement__c();
                findManage = [SELECT Id FROM ContractSupplement__c WHERE Process_Id__c =: marCou.processId];
                if (findManage.Id!=null) {
                    ContractSupplement__c conApproval = new ContractSupplement__c();
                    conApproval.Id = findManage.Id;
                    conApproval.contractSupplementCode__c = marCou.contractSupplementCode; //补充协议编号
                    conApproval.BuyerContractCode__c = marCou.contractNo; //买方合同编号
                    conApproval.SignDate__c = marCou.contractDate; //签订时间
                    update conApproval;

                    responseClass.status = 'Success';
                }else {
                    responseClass.status = 'Error';
                    errorMessage = '该合同不存在';
                }
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
        
        logInfo.RequestURL__c = '/ContractSupplement';
        logInfo.ClassName__c = 'Rest_ContractSupplement';
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
        // if (isAttReq) {
        //     Attachment insertAttReq = new Attachment();
        //     insertAttReq.ParentId = logInfo.Id;
        //     insertAttReq.Body = Blob.valueOf(rReq.requestBody.toString());
        //     insertAttReq.Name = 'RequestBody.txt';
        //     insertAttReq.ContentType = 'text/plain';
        //     insert insertAttReq;
        // }
        // if (isAtt) {
        //     Attachment insertAtt = new Attachment();
        //     insertAtt.ParentId = logInfo.Id;
        //     insertAtt.Body = Blob.valueOf(System.JSON.serialize(responseClass));
        //     insertAtt.Name = 'ResponseBody.txt';
        //     insertAtt.ContentType = 'text/plain';
        //     insert insertAtt;
        // }
    }

    global Class ResponseClass{
    	global String status {get;set;}
    	global String errorMessage {get;set;}
    }

    global class ContractSupplementEntity {
		global String processId{get;set;} //流程Id
		global String contractSupplementCode{get;set;} //补充协议编号
		global String contractNo{get;set;} //买方合同编号
		global Date contractDate{get;set;} //签订时间
	}

}