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

        //获取基础数据-项目所属区域负责人
        Map<String,String> mapBA = new Map<String,String>();
        String recTypeId1 =Schema.SObjectType.BasicData__c.getRecordTypeInfosByDeveloperName().get('RecordType_BasicData_Sales').getRecordTypeId();
        List<BasicData__c> basicSalesList = [SELECT Id,
                                                    MainChargeEmp__r.Job_Number__c,
                                                    ProjectArea__c
                                                    FROM BasicData__c 
                                                    WHERE RecordTypeId =:recTypeId1  
                                                    ];
        if (basicSalesList.size()!=0) {
            for (BasicData__c ba : basicSalesList) {
                mapBA.put(ba.ProjectArea__c, ba.MainChargeEmp__r.Job_Number__c);
            }
        }

        //获取对应商机字段Label
        Map<String,Opportunity> mapOpp = new Map<String,Opportunity>();
        List<Opportunity> oppList = [select id,toLabel(MarketBidDept__c),toLabel(ProjectArea__c),toLabel(Account.TopGroup__c) 
                                                from Opportunity 
                                                where id in(
                                                    select ObjectName__c
                                                    FROM Contractmanagement__c 
                                                    WHERE (Approvalstatus__c in ('10','11')) AND Contractname__c!=null
                                            )];
        if (oppList.size()!=0) {
            for (Opportunity op : oppList) {
                mapOpp.put(op.Id, op);
            }
        }

        //查找合同商务
            for (Contractmanagement__c conApproval : [SELECT Id,Contractname__c,WBS__c,Objectname2__c,Company__r.AccountNumber,	Company__r.Name,
            toLabel(ObjectName__r.ProjectDeliveryMarket__c), toLabel(ObjectName__r.ProjectCustomerType__c), toLabel(ObjectName__r.ProjectProductType__c),
            ObjectName__c,
            ObjectName__r.MarketBidDept__c,
            ObjectName__r.ProjectArea__c,
            ObjectName__r.Account.TopGroup__c,
            ObjectName__r.Account.Shortname__c
            FROM Contractmanagement__c 
            WHERE (Approvalstatus__c in ('10','11')) AND Contractname__c!=null]) {
                ContractNameEntity contractTemp = new ContractNameEntity();
                contractTemp.contractId = conApproval.Id;
                contractTemp.name = conApproval.Contractname__c;
                contractTemp.wbs = conApproval.WBS__c;
                contractTemp.projectName = conApproval.Objectname2__c;
                contractTemp.customerCode = conApproval.Company__r.AccountNumber;
                contractTemp.customerName = conApproval.Company__r.Name;
                contractTemp.projectDeliveryMarket = conApproval.ObjectName__r.ProjectDeliveryMarket__c;
                contractTemp.projectCustomerType = conApproval.ObjectName__r.ProjectCustomerType__c;
                contractTemp.projectProductType = conApproval.ObjectName__r.ProjectProductType__c;
                contractTemp.marketBidDept = conApproval.ObjectName__r.MarketBidDept__c;
                if (conApproval.ObjectName__r.MarketBidDept__c!=null && mapOpp.keySet().contains(conApproval.ObjectName__c)) {
                    contractTemp.marketBidDeptLabel = mapOpp.get(conApproval.ObjectName__c).MarketBidDept__c;
                }
                contractTemp.projectArea = conApproval.ObjectName__r.ProjectArea__c;
                if (conApproval.ObjectName__r.ProjectArea__c!=null && mapOpp.keySet().contains(conApproval.ObjectName__c)) {
                    contractTemp.projectAreaLabel = mapOpp.get(conApproval.ObjectName__c).ProjectArea__c;
                }
                if (conApproval.ObjectName__r.ProjectArea__c!=null && mapBA.keySet().contains(conApproval.ObjectName__r.ProjectArea__c)) {
                    contractTemp.projectAreaPerson = mapBA.get(conApproval.ObjectName__r.ProjectArea__c);
                }

                contractTemp.topGroup = conApproval.ObjectName__r.Account.TopGroup__c;
                if (conApproval.ObjectName__r.Account.TopGroup__c!=null && mapOpp.keySet().contains(conApproval.ObjectName__c)) {
                    contractTemp.topGroupLabel = mapOpp.get(conApproval.ObjectName__c).Account.TopGroup__c;
                }
                contractTemp.accountShortName = conApproval.ObjectName__r.Account.Shortname__c;

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
        global String projectDeliveryMarket {get;set;}//项目交付市场
        global String projectCustomerType {get;set;}//项目客户类型
        global String projectProductType{get;set;}//项目产品类型
        global String marketBidDept{get;set;}//客户分部
        global String marketBidDeptLabel{get;set;}//客户分部Label
        global String projectArea{get;set;}//项目所属区域
        global String projectAreaLabel{get;set;}//项目所属区域Label
        global String projectAreaPerson{get;set;}//区域负责人
        global String topGroup{get;set;}//客户所属集团
        global String topGroupLabel{get;set;}//客户所属集团Label
        global String accountShortName{get;set;}//客户所属集团为‘其他’的客户简称
    }
}