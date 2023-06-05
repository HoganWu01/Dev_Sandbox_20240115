/*
 * @Author: Hogan
 * @Date: 2022-10-10 09:00:00
 * @LastEditTime: 2022-11-12 08:00:00
 * @LastEditors: zxg
 * @Description: 从OA中拉取营销合同会签流程

 */
public without sharing class Controller_OA_ContractSignProcesss {

    /**
     * @description: 
     * @param {*}
     * @return {*}
     */ 
    @future (callout=true)   
    public static Void OASync(String startDate,String endDate){

        Interface_Log__c logInfo = new Interface_Log__c();

        External_System_Param__c ext = External_System_Param__c.getValues('oaCounterSignProcesssList');
        RequestBody reqBody = new RequestBody();  
        String response = '';
        
        try {
            if (startDate == null || startDate.equals('')) {
                startDate = String.valueOf(Datetime.now().addDays(-3));
            }

            if (endDate == null || endDate.equals('')) {
                endDate = String.valueOf(Datetime.now());
            }

            reqBody.startDate = startDate;
            reqBody.endDate = endDate;

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_OA_ContractSignProcesss';

            response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_OA_ContractSignProcesss',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);

            if(response.substring(0,5) == 'Error'){
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                System.debug('responseBody'+resBody);
                logInfo.RespondBody__c = response;
                if (resBody.code == 200) {
                    System.debug('resBody.data---'+resBody.data);  //返回的data
                    logInfo.IsSuccess__c = true; 
                    if(resBody.data != null) {
                        List<ContractOtherParties__c> contractOtherPartiesList = new List<ContractOtherParties__c>();
                        List<SalesModelContract__c> salesModelQuaList = new List<SalesModelContract__c>();
                        List<Payment_Proportion_Contract__c> payProportionList = new List<Payment_Proportion_Contract__c>();
                        List<ContractSignProcesss__c> contractSignProcesssList = new List<ContractSignProcesss__c>();

                        for (Data marCou : resBody.data) {
                            ContractSignProcesss__c conApproval = new ContractSignProcesss__c();
                            
                            conApproval.Process_Id__c = marCou.fdId;  //流程ID
                            conApproval.FlowTheme__c = marCou.docSubject;  //流程主题
                            conApproval.BusinessManagerName__c = marCou.fdOldBusinessManager; 
                            conApproval.BusinessManagerCode__c = marCou.fdOldBusinessManagerNo; 
                            conApproval.CustomerCode__c = marCou.fdOldCustomerCode; 
                            conApproval.CustomerDept__c = marCou.fdOldCustomerDept; 
                            conApproval.CustomerGroup__c = marCou.fdOldCustomerGroup;
                            conApproval.CustomerName__c = marCou.fdOldCustomerName;
                            conApproval.TaxRate__c = marCou.fdOldHtRate;
                            conApproval.Amount__c = Decimal.valueOf(marCou.fdOldHtTotal==''?'0':marCou.fdOldHtTotal);
                            conApproval.PaymentMethod__c = marCou.fdOldPayMode;
                            conApproval.PaymentMethodOther__c = marCou.fdOldPayModeOther;
                            conApproval.Price__c = Decimal.valueOf(marCou.fdOldPrice==''?'0':marCou.fdOldPrice);
                            conApproval.ProjectCode__c = marCou.fdOldProjectCode;
                            conApproval.ProjectManagerName__c = marCou.fdOldProjectManager;
                            conApproval.ProjectManagerCode__c = marCou.fdOldProjectManagerNo;
                            conApproval.ProjectName__c = marCou.fdOldProjectName;
                            conApproval.ProjectType__c = marCou.fdOldProjectType;
                            conApproval.Province__c = marCou.fdOldProvince;
                            conApproval.Sell__c = marCou.fdOldSell;
                            conApproval.ProjectArea__c = marCou.fdOldZone;
                            conApproval.ContractCapacity__c = Decimal.valueOf(marCou.fdYhCapacity==''?'0':marCou.fdYhCapacity);
                            conApproval.Quantity__c = Decimal.valueOf(marCou.fdYhNum==''?'0':marCou.fdYhNum);
                            conApproval.PaymentProportionTotal__c = marCou.fdYlTotalProportion;
        
                            upsert conApproval Process_Id__c;
                            // contractSignProcesssList.add(conApproval);

                            if (marCou?.signProcesssOtherList != null) {
                                for (ContractOtherPartiesEntity other : marCou?.signProcesssOtherList) {
                                    ContractOtherParties__c contractOther = new ContractOtherParties__c();
                                    contractOther.CompanyName__c = other.fdCompanyFullName;//公司全称
                                    contractOther.SubjectIdentity__c = other.fdPrincipalIdentity;//主体身份
                                    contractOther.ContractSignProcesss__c = conApproval.Id;//OA营销合同会签流程对象ID
                                    contractOtherPartiesList.add(contractOther);
                                }
                            }
                            if (marCou?.signProcesssGoodsList !=null) {
                                for (SalesModelAndQuantityDetailedEntity salesModel : marCou.signProcesssGoodsList) {
                                    SalesModelContract__c salesModelNew = new SalesModelContract__c();
                                    salesModelNew.Name = salesModel.fdGoodsModel;//机型
                                    salesModelNew.Quantity__c = Integer.valueOf(salesModel.fdGoodsNumber);//数量
                                    salesModelNew.Unit__c = salesModel.fdGoodsUnit;//单位
                                    salesModelNew.Remark__c = salesModel.fdGoodsRemarks==null?'':salesModel.fdGoodsRemarks;//备注
                                    salesModelNew.ContractSignProcesss__c = conApproval.Id;//OA营销合同会签流程对象ID
                                    salesModelQuaList.add(salesModelNew);
                                }
                            }
                            if (marCou?.signProcesssPayList!=null) {
                                for (PaymentProportionDetailedEntity pay : marCou.signProcesssPayList) {
                                    Payment_Proportion_Contract__c payPro = new Payment_Proportion_Contract__c();
                                    payPro.PaymentType__c = pay.fdFkfs;//付款方式
                                    payPro.Paymentnode__c = pay.fdPaymentNodeNo;//付款节点编码
                                    payPro.FloatContent__c = pay.fdOtherPaymentNode;//浮动内容
                                    payPro.Paymentratio__c = Decimal.valueOf(pay.fdPaymentProportion==''?'0':pay.fdPaymentProportion);//付款比例
                                    payPro.ContractSignProcesss__c = conApproval.Id;//OA营销合同会签流程对象ID
                                    payProportionList.add(payPro);
                                }
                            }
                        }

                        // upsert contractSignProcesssList Process_Id__c;

                        insert contractOtherPartiesList;
                        insert salesModelQuaList;
                        insert payProportionList;
                    }
                } else {
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = resBody.message; 
                }
                insert logInfo ; 
            }

        }catch(Exception e){

            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            System.debug('error---msg'+msg);
            logInfo.IsSuccess__c = false;
            logInfo.RespondBody__c = response;
            logInfo.ErrorMessage__c = '行号:'+e.getLineNumber() + '\n Apex类：'+e.getStackTraceString() + '\n 错误信息:\n' + e.getMessage(); 
            insert logInfo;
        }
    }

    public class RequestBody {
        public String startDate{get;set;}   //流程审批通过开始时间,示例值(2021-08-01 00:00:00)
        public String endDate{get;set;}   //流程审批通过结束时间,示例值(2021-08-01 00:00:00)
    }
   
    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String fdId{get;set;}   //流程ID
        public String docSubject{get;set;}   //流程主题
        public String fdOldBusinessManager{get;set;}   //商务经理名称
        public String fdOldBusinessManagerNo{get;set;}   //商务经理工号
        public String fdOldCustomerCode{get;set;}   //客户编码
        public String fdOldCustomerDept{get;set;}   //客户营销分部
        public String fdOldCustomerGroup{get;set;}   //客户所属集团
        public String fdOldCustomerName{get;set;}   //客户名称
        public String fdOldHtRate{get;set;}   //税率
        public String fdOldHtTotal{get;set;}   //合同总金额
        public String fdOldPayMode{get;set;}   //付款方式
        public String fdOldPayModeOther{get;set;}   //其他付款方式
        public String fdOldPrice{get;set;}   //单价
        public String fdOldProjectCode{get;set;}   //项目编码
        public String fdOldProjectManager{get;set;}   //项目经理名称
        public String fdOldProjectManagerNo{get;set;}   //项目经理工号
        public String fdOldProjectName{get;set;}   //项目名称
        public String fdOldProjectType{get;set;}   //项目类型
        public String fdOldProvince{get;set;}   //项目所属省份
        public String fdOldSell{get;set;}   //卖方
        public String fdOldZone{get;set;}   //项目所属区域
        public String fdYhCapacity{get;set;}   //合同容量
        public String fdYhNum{get;set;}   //合同台数
        public String fdYlTotalProportion{get;set;}   //付款比例合计
        public List<ContractOtherPartiesEntity> signProcesssOtherList{get;set;} //其他方集合
		public List<PaymentProportionDetailedEntity> signProcesssPayList{get;set;} //付款比例集合
		public List<SalesModelAndQuantityDetailedEntity> signProcesssGoodsList{get;set;} //销售机型及数量集合
    }

    public class ContractOtherPartiesEntity {
        public String fdParentId{get;set;} //流程ID
		public String fdCompanyFullName{get;set;} //公司全称
		public String fdPrincipalIdentity{get;set;} //主体身份
	}

    public class SalesModelAndQuantityDetailedEntity {
        public String fdParentId{get;set;} //流程ID
		public String fdGoodsModel{get;set;} //机型
		public String fdGoodsNumber{get;set;} //数量
		public String fdGoodsUnit{get;set;} //单位
		public String fdGoodsRemarks{get;set;} //备注
	}

    public class PaymentProportionDetailedEntity {
		public String fdParentId{get;set;} //流程ID
		public String fdFkfs{get;set;} //固定/浮动
		public String fdPaymentNode{get;set;} //固定付款节点名称
		public String fdPaymentNodeNo{get;set;} //固定付款节点编码
		public String fdOtherPaymentNode{get;set;} //浮动内容
		public String fdPaymentProportion{get;set;} //付款比例
	}

}