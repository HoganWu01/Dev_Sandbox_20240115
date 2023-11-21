/*
 * @Author: hogan
 * @Date: ###### Wed Jun 21 11:28:39 CST 2023
 * @LastEditors: hogan
 * @LastEditTime: ###### Wed Jun 21 11:28:41 CST 2023
 * @Descripttion: 商机数据查询接口
 */
@RestResource(urlMapping='/RptContract')
global without sharing class Rest_RptContract {
    @HttpPost
    global static void doPost() {
		RestRequest rReq = RestContext.request;
		RestResponse res = RestContext.response;
        Interface_Log__c logInfo = new Interface_Log__c();
		String errorMessage = '';
		ResponseClass responseClass = new ResponseClass();
        List<ConEntity> conListTemp = new List<ConEntity>();
        // System.debug('请求参数'+rReq.requestBody.toString());
		try
        {
            logInfo.RequestBody__c = rReq.requestBody.toString();
            // System.debug('logInfo.RequestBody__c===>'+logInfo.RequestBody__c);
            List<Contractmanagement__c> conList = [SELECT Id, ObjectName__c, CreatedDate, LastModifiedDate, ContractSigningEndDate__c, ObjectName__r.Account.Name, 
            ObjectName__r.Account.Shortname__c, ObjectName__r.StageName, toLabel(ObjectName__r.ProjectProductType__c), ObjectName__r.Province__c, 
            toLabel(ObjectName__r.ProjectArea__c), ObjectName__r.WinCapacity__c, toLabel(ObjectName__r.MarketBidDept__c), Objectname2__c, TaskStatus__c, 
            WBS__c, SectionCapacity__c, ContractCapacity__c, ObjectName__r.ProjectDeliveryMarket__c, ObjectName__r.ProjectCustomerType__c, ObjectName__r.Close__c, Company__r.Name
            FROM Contractmanagement__c WHERE ObjectName__c != ''];

            if (conList.size()>0) {
                for (Contractmanagement__c con: conList) {
                    ConEntity oEnt = new ConEntity();
                    oEnt.contractId = con.Id;
                    oEnt.opportunityId = con.ObjectName__c;
                    oEnt.projectNumber = con.WBS__c==null?'':con.WBS__c;
                    oEnt.projectName = con.Objectname2__c;
                    oEnt.accountName = con.ObjectName__r.Account.Name==null?'':con.ObjectName__r.Account.Name;
                    oEnt.accountShortName = con.ObjectName__r.Account.Shortname__c==null?'':con.ObjectName__r.Account.Shortname__c;
                    oEnt.stageName = con.ObjectName__r.StageName==null?'':con.ObjectName__r.StageName;
                    oEnt.projectType = con.ObjectName__r.ProjectProductType__c==null?'':con.ObjectName__r.ProjectProductType__c;
                    oEnt.province = con.ObjectName__r.Province__c==null?'':con.ObjectName__r.Province__c;
                    oEnt.salesDepartment = con.ObjectName__r.ProjectArea__c==null?'':con.ObjectName__r.ProjectArea__c;
                    oEnt.marketBidDept = con.ObjectName__r.MarketBidDept__c==null?'':con.ObjectName__r.MarketBidDept__c;
                    oEnt.contractSignStatus = con.TaskStatus__c==null?'':con.TaskStatus__c;
                    oEnt.contractSigningEndDate = con.ContractSigningEndDate__c;
                    oEnt.contractCapacity = con.SectionCapacity__c==null?con.ObjectName__r.WinCapacity__c:con.SectionCapacity__c;
                    oEnt.createdDate = con.CreatedDate;
                    oEnt.modifiedDate = con.LastModifiedDate;
                    oEnt.projectDeliveryMarket = con.ObjectName__r.ProjectDeliveryMarket__c;
                    oEnt.projectCustomerType = con.ObjectName__r.ProjectCustomerType__c;
                    oEnt.oppCloseStatus = String.valueOf(con.ObjectName__r.Close__c);
                    oEnt.contractAccountName = con.Company__r.Name;
                    conListTemp.add(oEnt);
                }

                responseClass.status = 'Success';
                responseClass.data = conListTemp;
            }else {
                responseClass.status = 'Error';
                errorMessage = '无商机数据！';
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
		
        logInfo.RequestURL__c = '/RptContract';
        logInfo.ClassName__c = 'Rest_RptContract';
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
        global List<ConEntity> data {get;set;}
    }

    global class ConEntity {
        global String contractId{get;set;} //合同商务ID
        global String opportunityId{get;set;} //商机ID
        global String projectNumber{get;set;} //项目编号
        global String projectName{get;set;} //项目名称
        global String projectDeliveryMarket{get;set;} //项目交付市场
        global String projectCustomerType{get;set;} //项目客户类型
        global String accountName{get;set;} //客户全称
        global String accountShortName{get;set;} //客户简称
        global String stageName{get;set;} //阶段
        global String oppCloseStatus{get;set;} //商机已关闭
        global String projectType{get;set;} //项目类型
        global String province{get;set;} //省份
        global String salesDepartment{get;set;} //所属大区/二级公司
        global String marketBidDept{get;set;} //客户分部
        global String contractAccountName{get;set;} //合同签订主体
        global String contractSignStatus{get;set;} //合同签订状态
        global Date contractSigningEndDate{get;set;} //合同签订完成日期
        global Decimal contractCapacity{get;set;} //合同容量
        global Datetime createdDate{get;set;} //创建时间
        global Datetime modifiedDate{get;set;} //上次修改时间
	}

}