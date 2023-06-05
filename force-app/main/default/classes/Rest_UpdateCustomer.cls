/*
 * @Author: zxg
 * @Date: 2022-11-08 09:34:59
 * @LastEditors: zxg
 * @LastEditTime: 2022-11-08 09:34:59
 * @Descripttion: SAP推送客户更新信息
 */
@RestResource(urlMapping='/UpdateCustomer')
global without sharing class Rest_UpdateCustomer {
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
            CustomerEntity customer=(CustomerEntity)System.JSON.deserialize(rReq.requestBody.toString(), CustomerEntity.class);
            logInfo.RequestBody__c = rReq.requestBody.toString();
            // System.debug('logInfo.RequestBody__c===>'+logInfo.RequestBody__c);
            if (customer?.kunnr!=null) {
                List<Account> accountList = [SELECT Id,Officialcode__c FROM Account WHERE Officialcode__c =: customer.taxnum];

                if (accountList.size()>0) {
                    Account account = accountList.get(0);
                    account.AccountNumber = customer.kunnr; //客户编号
                    account.CustomerAccountGroup__c = customer.ktokd; //客户科目组
                    account.Name = customer.name1; //客户全称
                    account.Shortname__c = customer.sortl; //客户简称
                    account.Street__c = customer.stras; //街道
                    account.Postalcode__c = customer.pstlz; //邮政编码
                    account.Country__c = customer.land1; //国家
                    account.City__c = customer.ort01; //城市
                    account.Area__c = customer.land1+ '_' + customer.regio; //地区
                    account.Phone__c = customer.telf1; //联系方式
                    account.Fax = customer.telfx; //传真
                    account.Phone = customer.telf2; //电话
                    account.Mailbox__c = customer.smtp_addr; //邮箱
                    account.Officialcode__c = customer.taxnum; //统一社会信息代码
                    account.SalesrOrganization__c = customer.vkorg; //销售组织
                    account.DistributionChannels__c = customer.vtweg; //分销渠道
                    account.ProductGroup__c = customer.spart; //产品组
                    account.PaymentTerms__c = customer.zterm; //付款条件
                    account.PriceGroup__c = customer.konda; //价格组
                    account.PricingProcess__c = customer.kalks; //定价过程
                    account.ShippingConditions__c = customer.vsbed; //装运条件
                    account.AccountAllocationGroup__c = customer.ktgrd; //账户分配组
                    account.TaxType__c = customer.takld; //客户税分类

                    List<Company__c> company = [SELECT Id FROM Company__c WHERE CompanySelfCode__c =: customer.bukrs];
                    if(company.size()>0){
                        account.CompanyCode__c = company.get(0).Id; //公司代码
                    }
                    account.ReconciliationSubjects__c = customer.akont; //统驭科目
                    // account.PaymentTerms__c = customer.zterm1; //付款条件
                    
                    update account;
                    
                    responseClass.status = 'Success';
                }else {
                    responseClass.status = 'Error';
                    errorMessage = 'CRM不存在该用户';
                }
            }else {
                responseClass.status = 'Error';
                errorMessage = '客户编号不能为空';
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
        
        logInfo.RequestURL__c = '/updateCustomer';
        logInfo.ClassName__c = 'Rest_UpdateCustomer';
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
        if (isAttReq) {
            Attachment insertAttReq = new Attachment();
            insertAttReq.ParentId = logInfo.Id;
            insertAttReq.Body = Blob.valueOf(rReq.requestBody.toString());
            insertAttReq.Name = 'RequestBody.txt';
            insertAttReq.ContentType = 'text/plain';
            insert insertAttReq;
        }
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
    }

    global class CustomerEntity {
		public String kunnr{get;set;} //客户编号	
		public String ktokd{get;set;} //客户账户组	
        public String land1{get;set;} //国家代码
        public String name1{get;set;} //公司地址名（公司全称）
        public String sortl{get;set;} //排序字段（简称、检索项）
        public String ort01{get;set;} //城市
        public String pstlz{get;set;} //邮政编码
        public String regio{get;set;} //地区（州、省）
        public String smtp_addr{get;set;} //电子邮件地址
        public String spras{get;set;} //语言代码
        public String stras{get;set;} //街道（详细地址）
        public String taxnum{get;set;} //业务合作伙伴税号
        public String taxtype{get;set;} //税号类别
        public String telf1{get;set;} //电话号码: 拨区号 + 号码
        public String telf2{get;set;} //第一个移动电话号码：区号 + 电话号码
        public String telfx{get;set;} //传真号
        //销售视图
        public String zterm{get;set;}//付款条件代码
        public String kalks{get;set;}//用于定价过程确定的客户分类
        public String konda{get;set;} //价格组
        public String ktgrd{get;set;} //客户组的账户分配
        public String spart{get;set;} //产品组
        public String takld{get;set;} //客户税分类
        public String vkorg{get;set;} //销售机构
        public String vsbed{get;set;} //装运条件
        public String vtweg{get;set;} //分销渠道
        public String waers{get;set;} //货币码
        //公司视图
        public String akont{get;set;}//总帐中的统驭科目
        public String bukrs{get;set;}//公司代码
        public String zterm1{get;set;} //付款条件代码
	}
    
}