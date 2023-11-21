/*
 * @Author: hogan
 * @Date: ###### Wed Sep 13 17:56:15 CST 2023
 * @LastEditors: hogan
 * @LastEditTime: ###### Wed Sep 13 17:56:21 CST 2023
 * @Descripttion: 基础数据查询接口
 */
@RestResource(urlMapping='/BasicDataList')
global without sharing class Rest_BasicData {
    @HttpPost
    global static void doPost() {
		RestRequest rReq = RestContext.request;
		RestResponse res = RestContext.response;
        Interface_Log__c logInfo = new Interface_Log__c();
		String errorMessage = '';
		ResponseClass responseClass = new ResponseClass();
        List<BasicDataEntity> basicListTemp = new List<BasicDataEntity>();
        // System.debug('请求参数'+rReq.requestBody.toString());
		try
        {
            logInfo.RequestBody__c = rReq.requestBody.toString();
            // System.debug('logInfo.RequestBody__c===>'+logInfo.RequestBody__c);
            List<BasicData__c> baList = [SELECT 
                Id, 
                Name, 
                IsActivity__c,
                RecordType.DeveloperName, 
                LastModifiedDate, 
                BasicNo__c, 
                ProjectDeliveryMarket__c, 
                toLabel(ProjectDeliveryMarket__c) ProjectDeliveryMarketLabel,
                ProjectArea__c, 
                toLabel(ProjectArea__c) ProjectAreaLabel,
                MainChargeEmp__r.Job_Number__c,
                MinorChargeEmp__r.Job_Number__c, 
                PreManagerEmp__r.Job_Number__c, 
                WindLeaderEmp__r.Job_Number__c, 
                RecordTypeDesc__c, 
                MarketBidDept__c, 
                toLabel(MarketBidDept__c) MarketBidDeptLabel,
                ProjectCustomerType__c,
                toLabel(ProjectCustomerType__c) ProjectCustomerTypeLable
                FROM BasicData__c];

            if (baList.size()>0) {
                for (BasicData__c ba: baList) {
                    BasicDataEntity bEnt = new BasicDataEntity();
                    bEnt.sId = ba.Id;
                    bEnt.name = ba.Name;
                    bEnt.isActivity = ba.IsActivity__c;
                    bEnt.recordTypeName = ba.RecordType.DeveloperName;
                    bEnt.lastModifiedDate = ba.LastModifiedDate;
                    bEnt.basicNo = ba.BasicNo__c;
                    bEnt.projectDeliveryMarket = ba.ProjectDeliveryMarket__c;
                    bEnt.projectDeliveryMarketLabel = (String)ba.get('ProjectDeliveryMarketLabel');
                    bEnt.projectArea = ba.ProjectArea__c;
                    bEnt.projectAreaLabel = (String)ba.get('ProjectAreaLabel');
                    bEnt.mainChargeEmp = ba.MainChargeEmp__r.Job_Number__c;
                    bEnt.minorChargeEmp = ba.MinorChargeEmp__r.Job_Number__c;
                    bEnt.preManagerEmp = ba.PreManagerEmp__r.Job_Number__c;
                    bEnt.windLeaderEmp = ba.WindLeaderEmp__r.Job_Number__c;
                    bEnt.recordTypeDesc = ba.RecordTypeDesc__c;
                    bEnt.marketBidDept = ba.MarketBidDept__c;
                    bEnt.marketBidDeptLabel = (String)ba.get('MarketBidDeptLabel');
                    bEnt.projectCustomerType = ba.ProjectCustomerType__c;
                    bEnt.projectCustomerTypeLable = (String)ba.get('ProjectCustomerTypeLable');
                    basicListTemp.add(bEnt);
                }

                responseClass.status = 'Success';
                responseClass.data = basicListTemp;
            }else {
                responseClass.status = 'Error';
                errorMessage = '无数据！';
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
		
        logInfo.RequestURL__c = '/BasicDataList';
        logInfo.ClassName__c = 'Rest_BasicData';
        // logInfo.RespondBody__c = System.JSON.serialize(responseClass);
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
        global List<BasicDataEntity> data {get;set;}
    }

    global class BasicDataEntity {
        global String sId{get;set;} //
        global String name{get;set;} //
        global Boolean isActivity{get;set;} //
        global String recordTypeName{get;set;} //
        global Datetime lastModifiedDate{get;set;} //
        global String basicNo{get;set;} //
        global String projectDeliveryMarket{get;set;} //
        global String projectDeliveryMarketLabel{get;set;} //
        global String projectArea{get;set;} //
        global String projectAreaLabel{get;set;} //
        global String mainChargeEmp{get;set;} //
        global String minorChargeEmp{get;set;} //
        global String preManagerEmp{get;set;} //
        global String windLeaderEmp{get;set;} //
        global String recordTypeDesc{get;set;} //
        global String marketBidDept{get;set;} //
        global String marketBidDeptLabel{get;set;} //
        global String projectCustomerType{get;set;} //
        global String projectCustomerTypeLable{get;set;} //
	}

}