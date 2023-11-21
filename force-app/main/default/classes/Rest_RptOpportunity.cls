/*
 * @Author: hogan
 * @Date: ###### Wed Jun 21 08:52:36 CST 2023
 * @LastEditors: hogan
 * @LastEditTime: ###### Wed Jun 21 08:52:31 CST 2023
 * @Descripttion: 商机数据查询接口
 */
@RestResource(urlMapping='/RptOpportunity')
global without sharing class Rest_RptOpportunity {
    @HttpPost
    global static void doPost() {
		RestRequest rReq = RestContext.request;
		RestResponse res = RestContext.response;
        Interface_Log__c logInfo = new Interface_Log__c();
		String errorMessage = '';
		ResponseClass responseClass = new ResponseClass();
        List<OppEntity> oppListTemp = new List<OppEntity>();
        // System.debug('请求参数'+rReq.requestBody.toString());
		try
        {
            logInfo.RequestBody__c = rReq.requestBody.toString();
            // System.debug('logInfo.RequestBody__c===>'+logInfo.RequestBody__c);
            List<Opportunity> oppList = [SELECT Id, OpportunityApprovalStatus__c, Account.Name, CreatedDate, LastModifiedDate, Account.Shortname__c, 
            Name, StageName, CalibrationDate__c, toLabel(ProjectProductType__c), Province__c, toLabel(ProjectArea__c), capacity__c, CalibResults__c, 
            toLabel(MarketBidDept__c), ProjectNumber__c, WinCapacity__c, Approval__c, Estimated_Bidding_Time__c, Winningopponent__c, Close__c, CloseType__c, Owner.Name
                FROM Opportunity];

            if (oppList.size()>0) {
                for (Opportunity opp: oppList) {
                    OppEntity oEnt = new OppEntity();
                    oEnt.opportunityId = opp.Id;
                    oEnt.projectNumber = opp.ProjectNumber__c==null?'':opp.ProjectNumber__c;
                    oEnt.oppName = opp.Name;
                    oEnt.accountName = opp.Account.Name==null?'':opp.Account.Name;
                    oEnt.accountShortName = opp.Account.Shortname__c==null?'':opp.Account.Shortname__c;
                    oEnt.stageName = opp.StageName==null?'':opp.StageName;
                    oEnt.projectType = opp.ProjectProductType__c==null?'':opp.ProjectProductType__c;
                    oEnt.province = opp.Province__c==null?'':opp.Province__c;
                    oEnt.salesDepartment = opp.ProjectArea__c==null?'':opp.ProjectArea__c;
                    oEnt.marketBidDept = opp.MarketBidDept__c==null?'':opp.MarketBidDept__c;
                    oEnt.capacity = opp.capacity__c;
                    oEnt.calibResults = opp.CalibResults__c==null?'':opp.CalibResults__c;
                    oEnt.calibrationDate = opp.CalibrationDate__c;
                    oEnt.winCapacity = opp.WinCapacity__c;
                    oEnt.createdDate = opp.CreatedDate;
                    oEnt.modifiedDate = opp.LastModifiedDate;
                    oEnt.opportunityApprovalStatus = opp.OpportunityApprovalStatus__c;
                    oEnt.approval = opp.Approval__c ;
                    oEnt.estimatedBiddingTime = opp.Estimated_Bidding_Time__c ;
                    oEnt.winningOpponent = opp.Winningopponent__c ;
                    oEnt.close = String.valueOf(opp.Close__c) ;
                    oEnt.closeType = opp.CloseType__c ;
                    oEnt.ownerName = opp.Owner.Name ;
                    oppListTemp.add(oEnt);
                }

                responseClass.status = 'Success';
                responseClass.data = oppListTemp;
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
		
        logInfo.RequestURL__c = '/RptOpportunity';
        logInfo.ClassName__c = 'Rest_RptOpportunity';
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
        global List<OppEntity> data {get;set;}
    }

    global class OppEntity {
        global String opportunityId{get;set;} //商机ID
        global String opportunityApprovalStatus{get;set;}//商机审批状态
        global String projectNumber{get;set;} //项目编号
        global String oppName{get;set;} //商机名称
        global String accountName{get;set;} //客户全称
        global String accountShortName{get;set;} //客户简称
        global String stageName{get;set;} //阶段
        global String projectType{get;set;} //项目类型
        global String province{get;set;} //省份
        global String approval{get;set;} //项目是否核准
        global Date estimatedBiddingTime{get;set;}//（预计）招标时间
        global String salesDepartment{get;set;} //所属大区/二级公司
        global String marketBidDept{get;set;} //客户分部
        global Decimal capacity{get;set;} //总容量
        global String calibResults{get;set;} //	定标结果
        global Date calibrationDate{get;set;} //定标时间
        global Decimal winCapacity{get;set;} //中标容量
        global String winningOpponent{get;set;} //赢标对手
        global String close{get;set;} //商机已关闭
        global String closeType{get;set;} //关闭类型
        global String ownerName{get;set;} //商机所有人
        global Datetime createdDate{get;set;} //创建时间
        global Datetime modifiedDate{get;set;} //上次修改时间
	}

}