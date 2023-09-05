/*
 * @Author: hogan
 * @Date: ###### Sat Jun 10 14:58:20 CST 2023
 * @LastEditors: hogan
 * @LastEditTime: ###### Sat Jun 10 14:58:22 CST 2023
 * @Descripttion: 项目立项OA审批通过，回传 项目主将、项目支撑统筹领导、流程类型 到项目立项申请单，回传 项目主将、项目支撑统筹领导 到商机
 */
@RestResource(urlMapping='/ProjectApplication')
global without sharing class Rest_ProjectApplication {
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
            ProjAppEntity marCou=(ProjAppEntity)System.JSON.deserialize(rReq.requestBody.toString(), ProjAppEntity.class);
            logInfo.RequestBody__c = rReq.requestBody.toString();
            // System.debug('logInfo.RequestBody__c===>'+logInfo.RequestBody__c);
            if (marCou?.processId != null) {
                List<Projectapplication__c> findPa = [SELECT Id,Oppty__c FROM Projectapplication__c WHERE Process_Id__c =: marCou.processId];

                if (findPa.size()>0) {

                    Projectapplication__c upPro = new Projectapplication__c();
                    upPro.Id = findPa[0].Id;

                    Opportunity upOpp = new Opportunity();
                    upOpp.Id = findPa[0].Oppty__c;

                    if (marCou.groupLeader!=null) {
                        List<Employee__c> groupEmp = [SELECT Id FROM Employee__c WHERE Job_Number__c =: marCou.groupLeader];
                        if (groupEmp.size()>0) {
                            upPro.GroupLeader__c = groupEmp[0].Id;
                            upOpp.GroupLeader__c = groupEmp[0].Id;
                        }
                    }

                    if (marCou.groupLeader!=null) {
                        List<Employee__c> leaderEmp = [SELECT Id FROM Employee__c WHERE Job_Number__c =: marCou.projectLeader];
                        if (leaderEmp.size()>0) {
                            upPro.ProjectLeader__c = leaderEmp[0].Id;
                            upOpp.ProjectLeader__c = leaderEmp[0].Id;
                        }
                    }
                    if (marCou.processType!=null) {
                        upPro.ProcessType__c = marCou.processType;
                    }
                    
                    update upPro;
                    update upOpp;

                    responseClass.status = 'Success';
                }else {
                    responseClass.status = 'Error';
                    errorMessage = '查询不到对应项目立项单流程！';
                }
            }else {
                responseClass.status = 'Error';
                errorMessage = '接口获取项目立项流程ID出错，请检查入参！';
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
		
        logInfo.RequestURL__c = '/ProjectApplication';
        logInfo.ClassName__c = 'Rest_ProjectApplication';
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

    global class ProjAppEntity {
		global String processId{get;set;} //流程ID
        global String groupLeader {get;set;} //项目主将
        global String projectLeader {get;set;} //项目支撑统筹领导
        global String processType {get;set;} //流程类型
	}

}