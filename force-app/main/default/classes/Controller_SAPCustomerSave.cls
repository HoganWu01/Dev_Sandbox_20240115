/*
 * @Author: irving
 * @Date: 2021-09-26 10:20:00
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-12-14 15:50:13
 * @Descripttion: 客户主数据维护
 */
global without sharing class Controller_SAPCustomerSave {
   
    /**
     * @description: recordId 客户ID
     * @param {*}
     * @return {*}
     */
    @future (callout=true)
    global static Void SAPCustomerSave(String recordId){

        System.debug('客户同步SAP接口进来了');
        Interface_Log__c logInfo = new Interface_Log__c();
        RequestBody reqBody = new RequestBody();

        Account acc = new Account();
        acc = [SELECT Id,
                      Name,
                      //SysSAP__c,
                      Accounttype__c,
                      //Company__c,
                      AccountSyncSAPMsg__c,
                      CompanyCode__c,
                      ReconciliationSubjects__c,
                      PricingProcess__c,
                      PriceGroup__c,
                      AccountAllocationGroup__c,
                      //AccGroup__c,    
                      CustomerAccountGroup__c,    //客户科目组
                      AccountNumber,
                      Country__c,
                      Area__c,
                      Officialcode__c,
                      Shortname__c,
                      ProductGroup__c,
                      Street__c,
                      Fax,
                      TaxType__c,
                      Phone,
                      SalesrOrganization__c,
                      ShippingConditions__c,
                      DistributionChannels__c,
                      PaymentTerms__c ,
                      City__c, Postalcode__c,Mailbox__c,Phone__c
                      from Account where Id = :recordId] ;    
        String companyId = acc.CompanyCode__c ; 
        External_System_Param__c ext = External_System_Param__c.getValues('sapCustomerSave');
        
        String sapCustomResponse ='';
        try {
            if(acc==null){
                logInfo.IsSuccess__c = false;
                logInfo.ErrorMessage__c ='客户为空';
                insert logInfo ; 
               return ; 
            }

            if(String.isBlank(companyId)){
                logInfo.IsSuccess__c = false;
                logInfo.ErrorMessage__c = '客户下找不到公司关联，公司为空';
                insert logInfo ; 
                return ; 
            }

            Company__c company  = [SELECT ID,Name,CompanySelfCode__c FROM Company__c WHERE ID = :companyId] ; 

            if(company==null){
                logInfo.IsSuccess__c = false;
                logInfo.ErrorMessage__c = '错误信息:公司为空';
                insert logInfo ; 
                return ; 
            }

            Map<String,String> codeAndIdMap = new Map<String,String>();
            codeAndIdMap.put(company.CompanySelfCode__c, company.Id);
            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAPCustomerSave';

            //调用sap接口判断三证合一是否已经存在===================
            Interface_Log__c checkTaxNumlogInfo = new Interface_Log__c();
            System.debug('开始税号查重===》》》');
            External_System_Param__c extsp = External_System_Param__c.getValues('sapCustomer');
            SAPCustomRequestBody sapRequest = new SAPCustomRequestBody();
            sapRequest.stcd = acc.Officialcode__c ; 
            
            sapCustomResponse = Utils.callOut2(JSON.serialize(sapRequest),extsp.Request_URL__c,'Controller_SAPCustomerSave',extsp.Request_Source__c,extsp.Request_Method__c,extsp.Request_Key__c,extsp.Initialization_Vector__c);
            System.debug('sap税号查重接口调用成功，sapCustomResponse响应结果--->>>>>'+sapCustomResponse);

            if (sapCustomResponse.substring(0,5) == 'Error') {
                logInfo.ErrorMessage__c =sapCustomResponse; 
                logInfo.IsSuccess__c = false;
                logInfo.RequestURL__c = extsp.Request_URL__c;
                logInfo.RequestBody__c = JSON.serialize(sapRequest);
                logInfo.RespondBody__c = sapCustomResponse ; 
                insert logInfo ; 
                return ; 
            }else{
                SAPResponseBody sapResBody = (SAPResponseBody)System.JSON.deserialize(sapCustomResponse, SAPResponseBody.class);
                System.debug('sapResBody.code==='+sapResBody.code);
                System.debug('sapResBody.data==='+sapResBody.data);
                //用户的三证合一和响应的第一个数据返回的税号一致 说明sap存在该三证 直接拉取数据回CRM
                if (sapResBody.code==200 && sapResBody.data!=null &&sapResBody.data.size()>0) {
                    System.debug('条件符合');
                    if (sapResBody.data[0].stcd5.equals(acc.Officialcode__c)) {
                        System.debug('税号相同条件符合');
                        acc.AccountNumber = sapResBody.data[0].kunnr ;      //客户编号
                        acc.Name = sapResBody.data[0].name1Kna1 ;
                        acc.Country__c = sapResBody.data[0].land1 ;
                        acc.Street__c = sapResBody.data[0].street ;

                        if (sapResBody.data[0].land1=='CN' && String.isNotBlank(sapResBody.data[0].regio)) {
                        acc.Area__c ='CN_'+sapResBody.data[0].regio ;
                        }else if (sapResBody.data[0].land1=='JP' && String.isNotBlank(sapResBody.data[0].regio)) {
                        acc.Area__c ='JP_'+sapResBody.data[0].regio ;
                        }else if(String.isNotBlank(sapResBody.data[0].land1) && String.isNotBlank(sapResBody.data[0].regio)){
                        acc.Area__c =sapResBody.data[0].land1+'_'+sapResBody.data[0].regio ;
                        }
                        
                        acc.Shortname__c = sapResBody.data[0].sortl ;
                        // acc.Officialcode__c = sapResBody.data[0].stcd5 ;
                        acc.AccountSyncSAPMsg__c = 'sap已经存在该客户，直接从sap拉取客户数据同步回CRM';
                        update acc ; 
                         System.debug('更新客户基本数据信息完成');
                        acc.Accounttype__c = '已交易客户';
                        update acc ; 
                        System.debug('更新客户类型完成');
                        System.debug('输入税号重复，直接从sap拉取数据回CRM,连同编号一起拉');
                        logInfo.RequestURL__c = extsp.Request_URL__c;
                        logInfo.RequestBody__c = JSON.serialize(sapRequest) ; 
                        logInfo.RespondBody__c = sapCustomResponse ; 
                        logInfo.IsSuccess__c = true;
                        insert logInfo ; 
                        return ; 
                    } 
                }else{
                    reqBody.ktokd = acc.CustomerAccountGroup__c  ;    //客户科目组
                    reqBody.land1 = acc.Country__c  ;   //国家代码
                    reqBody.name1 = acc.Name  ;    //公司地址名（公司全称）
                    reqBody.sortl = acc.Shortname__c  ;    //简称-排序字段
                    reqBody.ort01 = acc.City__c  ;    //城市
                    reqBody.pstlz = acc.Postalcode__c  ;    //邮政编码
                    // reqBody.regio = acc.Area__c  ;    //地区（州、省）
                    if (!String.isBlank(acc.Area__c) && acc.Area__c.contains('_')) {
                        // reqBody.regio = acc.Area__c.remove(acc.Area__c.substring(0,acc.Area__c.indexOf('_')+1));
                        reqBody.regio = acc.Area__c.substringAfter('_');
                     }
                    reqBody.smtp_addr = acc.Mailbox__c  ;    //邮箱
                    reqBody.spras = '1';    //语言代码
                    reqBody.stras = acc.Street__c  ;    //街道（详细地址）
                    reqBody.taxnum = acc.Officialcode__c  ;    //业务合作伙伴税号，统一社会信息证代码（三证合一）
                    reqBody.taxtype = 'CN0';    //税号类别
                    reqBody.telf1 = acc.Phone__c;    //电话号码: 拨区号 + 号码
                    reqBody.telf2 = acc.Phone;    //第一个移动电话号码：区号 + 电话号码
                    reqBody.telfx = acc.Fax;    //传真号
                    
                    Item1 item1=new Item1();
                    item1.akont=acc.ReconciliationSubjects__c; //总帐中的统驭科目
                    item1.bukrs=company.CompanySelfCode__c; //公司代码
                    //创建客户时，传与销售视图相同的付款条件代码
                    item1.zterm1=acc.PaymentTerms__c; //付款条件代码
                    
                    Item2 item2=new Item2();
                    item2.zterm=acc.PaymentTerms__c; //付款条件代码
                    item2.kalks=acc.PricingProcess__c; //用于定价过程确定的客户分类
                    item2.konda=acc.PriceGroup__c; //价格组
                    item2.ktgrd=acc.AccountAllocationGroup__c; //客户组的账户分配
                    item2.spart=acc.ProductGroup__c; //产品组
                    item2.takld=acc.TaxType__c; //客户税分类
                    item2.vkorg=acc.SalesrOrganization__c; //销售组织
                    item2.vsbed=acc.ShippingConditions__c; //装运条件
                    item2.vtweg=acc.DistributionChannels__c; //分销渠道
                    item2.waers='CNY'; //货币码
        
                    List<Item1> itemList1 = new  List<Item1>();
                    itemList1.add(item1);
                    
                    List<Item2> itemList2 = new  List<Item2>();
                    itemList2.add(item2);
        
                    reqBody.itemList1=itemList1;
                    reqBody.itemList2=itemList2;

                    String response = Utils.callOut2(JSON.serialize(reqBody),ext.Request_URL__c,'Controller_SAPCustomerSave',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        
                    System.debug('调用成功，response响应结果--->>>>>'+response);
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    SyncSAPCustom(response,logInfo,acc,false,false);
                }
            }
        } catch (Exception e ) {
            String msg = '返回错误' +e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage(); 
            logInfo.IsSuccess__c = false;
            logInfo.RespondBody__c = sapCustomResponse;
            logInfo.ErrorMessage__c = '行号:'+e.getLineNumber() + '\n Apex类：'+e.getStackTraceString() + '\n 错误信息:\n' + e.getMessage(); 
            insert logInfo;
        }
    }

    public static Void SyncSAPCustom(String response,Interface_Log__c logInfo,Account acc,Boolean isTaxduplicate,Boolean isAccduplicate ){

        if(response.substring(0,5) == 'Error') {
            logInfo.IsSuccess__c = false;
            logInfo.ErrorMessage__c =response; 
            logInfo.RespondBody__c = response;
        }else{
            ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
            logInfo.RespondBody__c = response;
            if (resBody.code == 200) {
                logInfo.IsSuccess__c = true;
                acc.AccountNumber = resBody.data;
                acc.Accounttype__c = '已交易客户';
                acc.AccountSyncSAPMsg__c  = resBody.message ; 
                update acc ; 
            }else{
                System.debug('resBody.message===>>>'+resBody.message);
                acc.AccountSyncSAPMsg__c  = resBody.message ; 
                update acc ; 
                logInfo.IsSuccess__c = false;
                logInfo.ErrorMessage__c = resBody.message; 
            }
            insert logInfo ; 
            return ; 
        }
    }

    public class RequestBody {
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
        public List<Item1> itemList1{get;set;}
        public List<Item2> itemList2{get;set;}
    }

    public class Item2 {
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
        public String bzirk{get;set;} //销售地区
        
    }

    public class Item1 {
        public String akont{get;set;}//总帐中的统驭科目
        public String bukrs{get;set;}//公司代码
        public String zterm1{get;set;} //付款条件代码
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public String data{get;set;} 
    }

    public class SAPCustomRequestBody {
        public String kunnr{get;set;}
        public String stcd{get;set;}
        public String updateDate{get;set;}   //日期(格式yyyy-MM-dd),示例值(2021-08-01)
    }

    public class SAPResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        public String kunnr{get;set;}   //客户编号,示例值(160764)
        public String land1{get;set;}   //国家代码
        public String name1Kna1{get;set;} //公司地址名（公司全称）
        public String regio{get;set;}   //地区（州、省）
        public String sortl{get;set;}   //排序字段（简称、检索项）
        public String stcd5{get;set;}   //税号
        public String street{get;set;}   //街道（详细地址）
    }
    
}