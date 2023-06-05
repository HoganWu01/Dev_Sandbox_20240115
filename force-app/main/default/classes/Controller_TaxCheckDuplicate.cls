/*
 * @Author: irving
 * @Date: 2021-12-11 
 * @LastEditTime: 2022-03-09 11:46:43
 * @LastEditors: Devin
 * @Description: 税号查重
 */
public without sharing class Controller_TaxCheckDuplicate {

    @future (callout=true)   
    public static Void TaxCheckDuplicate(String recordId){

        System.debug('客户新建，税号查重接口进来了');

        Interface_Log__c logInfo = new Interface_Log__c();

        Account acc = new Account();
        acc = [SELECT Id,
                      Name,
                      Accounttype__c,
                      AccountSyncSAPMsg__c,
                      AccountNumber,
                      Country__c,
                      Area__c,
                      Officialcode__c,
                      Shortname__c,
                      Street__c
                      from Account where Id = :recordId] ; 
                    
        String sapCustomResponse = '';
        
        try {

            logInfo.ClassName__c = 'Controller_TaxCheckDuplicate';

            //调用sap接口判断三证合一是否已经存在===================
            System.debug('开始税号查重===》》》');
            External_System_Param__c extsp = External_System_Param__c.getValues('sapCustomer');
            SAPCustomRequestBody sapRequest = new SAPCustomRequestBody();

            System.debug('acc.Officialcode__c===========>>>'+acc.Officialcode__c);
            sapRequest.stcd = acc.Officialcode__c ; 
            System.debug('sapRequest.stcd===========>>>'+sapRequest.stcd);

            sapCustomResponse = Utils.callOut2(JSON.serialize(sapRequest),extsp.Request_URL__c,'Controller_TaxCheckDuplicate',extsp.Request_Source__c,extsp.Request_Method__c,extsp.Request_Key__c,extsp.Initialization_Vector__c);
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
                        // return ; 
                        
                    } 
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