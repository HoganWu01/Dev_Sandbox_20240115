/*
 * @Author: IRVING
 * @Date: 2021-09-30 09:36:52
 * @LastEditTime: 2022-03-09 11:01:37
 * @LastEditors: Devin
 * @Description: 获取客户主数数据信息
 * @FilePath: \MINGYANG\force-app\main\default\classes\Controller_SAPCustomerUpdate.cls
 */
public without sharing class Controller_SAPCustomerUpdate {
    /**
     * @description: accId  客户ID   taxNumber  三证合一（税号）
     * @param {*}
     * @return {*}
     */    
    @future (callout=true)
    public static Void SAPCustomerUpdate(){

        Interface_Log__c logInfo = new Interface_Log__c();

        RequestBody req = new RequestBody();  

        External_System_Param__c ext = External_System_Param__c.getValues('sapUpdateCustomer');

        String response = '';

        try {

            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'Controller_SAPCustomerUpdate';

            InterfaceParam__c ipc = new InterfaceParam__c();
            ipc = [SELECT Id,NAME,SyncDate__c FROM InterfaceParam__c WHERE NAME = 'SAPCustomerUpdate' AND SyncDate__c!=null ] ; 
            
            Datetime interDate =  ipc.SyncDate__c ; 
            
            req.updateDate = interDate.format('yyyy-MM-dd') ; 

            
            System.debug('JSON.serialize(req)---'+JSON.serialize(req));

            response = Utils.callOut(JSON.serialize(req),ext.Request_URL__c,'Controller_SAPCustomerUpdate',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
        

            System.debug('调用成功，response响应结果--->>>>>'+response);

            logInfo.RequestBody__c = JSON.serialize(req);

            if(response.substring(0,5) == 'Error'){
                logInfo.RespondBody__c = response;
                insert logInfo;
                return ;
            }else{
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);

                logInfo.RespondBody__c = response;
                if (resBody.code == 200) {
                    
                    logInfo.IsSuccess__c = true;

                    if(resBody.data !=null) {

                        List<String> kunnrs = new List<String>();  //客户编号

                        if(resBody.data!=null){
                            for (Data data : resBody.data) {
                                kunnrs.add(data.kunnr) ;
                            }
                        }

                        if(kunnrs.size()==0 || kunnrs==null ){
                            logInfo.IsSuccess__c = false;
                            logInfo.ErrorMessage__c = '返回的数据的客户编码集合为空';
                            insert logInfo;
                            return ;
                        }


                        //SAP数据同步回CRM
                        List<Account> UpdateAccList = new List<Account>();

                        UpdateAccList = [SELECT ID,
                                                Accounttype__c,
                                                FromSAP__c,
                                                AccountAllocationGroup__c,   //账户分配组
                                                ReconciliationSubjects__c,    //统驭科目
                                                CompanyCode__c,    //公司id
                                                CompanyCode__r.CompanySelfCode__c,  //公司对象的公司代码
                                                PricingProcess__c,     //定价过程
                                                PriceGroup__c,      //价格组
                                                CustomerAccountGroup__c,   //科目组
                                                AccountNumber,    //客户编号
                                                Country__c,      //国家代码
                                                Name,         //名称
                                                Area__c,     //地区
                                                Shortname__c,     //简称
                                                ProductGroup__c,    //产品组
                                                Officialcode__c,   //（三证合一）
                                                Street__c,
                                                TaxType__c ,    //税分类
                                                SalesrOrganization__c,    //销售机构
                                                ShippingConditions__c,   //装运条件
                                                DistributionChannels__c,   //分销渠道
                                                PaymentTerms__c, //付款条件
                                                AccountSyncSAPMsg__c   //客户同步SAP返回信息
                                            FROM
                                                Account
                                            WHERE
                                                AccountNumber!=Null And AccountNumber IN :kunnrs] ;

                        System.debug('UpdateAccList========>>>'+UpdateAccList);

                        //客户编号  Name
                        Map<String,String> NumNameMap = new Map<String,String>();
                        Map<String,String> NumCountryMap = new Map<String,String>();
                        Map<String,String> NumStreetMap = new Map<String,String>();
                        Map<String,String> NumAreaMap = new Map<String,String>();
                        Map<String,String> NumShortnameMap = new Map<String,String>();
                        Map<String,String> NumOfficialcodeMap = new Map<String,String>();   //税号

                        for (Data data : resBody.data) {
                            NumNameMap.put(data.kunnr, data.name1Kna1);
                            NumCountryMap.put(data.kunnr, data.land1);
                            NumStreetMap.put(data.kunnr, data.street);

                            //地区： 国家_地区  devin update 2022/3/9
                            if (String.isNotBlank(data.land1) && String.isNotBlank(data.regio)) {
                                NumAreaMap.put(data.kunnr, data.land1 + '_' +data.regio);
                            }
                            NumShortnameMap.put(data.kunnr, data.sortl);
                            NumOfficialcodeMap.put(data.kunnr, data.stcd5);

                        }

                        //=====先把复选框字段改成true跳过验证规则  使已交易客户可以更新数据
                        for (Account acc : UpdateAccList) {
                            acc.FromSAP__c = true ;
                        }

                        if (UpdateAccList.size()>0) {
                            update UpdateAccList ;
                            System.debug('更新客户字段为true完成');
                        }

                        List<Account> lastUpdateAcc = new List<Account>();

                        //定时器调用--SAP数据更新回CRM
                        //更新客户数据

                        for (Account acc : UpdateAccList) {
                            acc.Name = NumNameMap.get(acc.AccountNumber);
                            acc.Country__c = NumCountryMap.get(acc.AccountNumber);
                            acc.Street__c = NumStreetMap.get(acc.AccountNumber);
                            acc.Area__c = NumAreaMap.get(acc.AccountNumber);
                            acc.Shortname__c = NumShortnameMap.get(acc.AccountNumber);
                            acc.Officialcode__c = NumOfficialcodeMap.get(acc.AccountNumber);

                            lastUpdateAcc.add(acc);
                        }


                        if (lastUpdateAcc.size()>0) {
                            update lastUpdateAcc ;
                            System.debug('更新客户操作完成');
                        }

                        //验证规则  类型和基本数据不能同时update 所以要分开
                        if (lastUpdateAcc.size()>0) {
                            for (Account acc : lastUpdateAcc) {
                                acc.Accounttype__c = '已交易客户';
                            }
                        }

                        if (lastUpdateAcc.size()>0) {
                            update lastUpdateAcc ;
                            System.debug('更新客户类型操作完成');
                        }


                        //------需要把复选框字段更新回false 使得已交易客户默认不可以编辑某些字段
                        for (Account acc : lastUpdateAcc) {
                            acc.FromSAP__c = false ;
                        }

                        if (lastUpdateAcc.size()>0) {
                            update lastUpdateAcc ;
                            System.debug('更新客户的复选框字段为false');
                        }

                    }

                    //更新接口参数表时间  通过定时器调用才需要更新日期
                    ipc.SyncDate__c = System.toDay() ;
                    update ipc ;
                    System.debug('更新日期操作完成');

                }else{
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
        public String kunnr{get;set;}
        public String stcd{get;set;}
        public String updateDate{get;set;}   //日期(格式yyyy-MM-dd),示例值(2021-08-01)
    }


    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public List<Data> data{get;set;} 
    }

    public class Data {
        //public String akont{get;set;}   //统驭科目
        //public String bukrs{get;set;}   //公司代码
        // public String cmBukrs{get;set;}   //公司代码（扩充）,示例值(6000)
        // public String cmCname{get;set;}   //创建者工号,示例值(A06397)
        // public String cmVkorg{get;set;}   //销售组织（扩充）
        // public String kalks{get;set;}   //客户定价过程
        // public String konda{get;set;}   //价格组
        // public String ktgrd{get;set;}   //客户组的账户分配
        // public String ktokd{get;set;}   //客户账户组
        public String kunnr{get;set;}   //客户编号,示例值(160764)
        public String land1{get;set;}   //国家代码
        public String name1Kna1{get;set;} //公司地址名（公司全称）
        public String regio{get;set;}   //地区（州、省）
        public String sortl{get;set;}   //排序字段（简称、检索项）
        //public String spart{get;set;}   //产品组
        public String stcd5{get;set;}   //税号
        public String street{get;set;}   //街道（详细地址）
        //public String taxkd{get;set;}   //客户税分类
        // public String telf1{get;set;}   //
        // public String telfx{get;set;}   //
        // public String updat{get;set;}   //
        // public String vbund{get;set;}   //贸易伙伴的公司标识
        // public String vkorg{get;set;}   //销售机构
        // public String vsbed{get;set;}   //装运条件
        // public String vtweg{get;set;}   //分销渠道        
        // public String zterm{get;set;}   //付款条件代码
    }

   
}