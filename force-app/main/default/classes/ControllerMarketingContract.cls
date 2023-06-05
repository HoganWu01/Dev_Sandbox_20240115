/*
 * @Author: Conner
 * @Date: 2021-09-23 10:04:41
 * @LastEditors: zxg
 * @LastEditTime: 2022-10-10 9:28:55
 * @Descripttion: 提交营销合同补充协议审批单
 */
global without sharing class ControllerMarketingContract {
    /**
     * @description: 提交营销合同补充协议审批单
     * @param  {*}
     * @return {*}
     */    
    @AuraEnabled(cacheable=false)
    global static String toCreateMarketingContract(Id recordId){
        Interface_Log__c logInfo = new Interface_Log__c();
        ContractSupplement__c contractSup = [SELECT Process_Id__c,Approval_Comments__c,SealApplication__c,Applicant_Num__c,ProtocolType__c,Owner_Department__c,
                                            WBS__c,Project_Manager__c,Project_Manager__r.Job_Number__c,xiangmu__c,ProjectType__c,
                                            ProjectArea__c,Approvalstatus__c,
                                            AgreementIntroduction__c,Chief_Representative__c,Chief_Representative__r.Job_Number__c,
                                            AccountName__c,AccountName__r.Name,AccountName__r.AccountNumber,PaymentRatioSum__c,
                                            Country__c,Business_Manager__c,Business_Manager__r.Job_Number__c, 
                                            CustomerMarketingDivision__c,
                                            ContractCapacity__c,TaxRate__c,Amount__c,ContractQuantity__c,Price__c,Contractname__r.Process_Id__c,Other_Protocol_Types__c,Seal_Org__c,
                                            Seal_Safekeep_Dept__c,Contractname__r.ProcessTheme__c,PaymentMethod__c,PaymentMethodOther__c,
                                            (SELECT Id,Document_Category__c,Document_Name__c,Seal_Company__c,Seal_Type__c,Seal_Numble__c FROM Marketing_Contract_Seal__r),
                                            (SELECT Id,CompanyName__c,SubjectIdentity__c FROM ContractSupplementOtherParties__r) ,
                                            (SELECT Id,Name,MachineModel__c,MachineCfg__c,MachineZj__c,MachineHeight__c,MachineName__c,Quantity__c,Unit__c,Remark__c FROM ContractSupplementSales__r) ,
                                            (SELECT Id,PaymentType__c,Paymentnode__c,FloatContent__c,Paymentratio__c FROM ContractSupplementPayment__r ORDER BY Name) 
                                            FROM ContractSupplement__c WHERE Id =: recordId];
        RequestBody reqBody = new RequestBody();
        String returnId = '';
        if (contractSup.Marketing_Contract_Seal__r.size()==0&&contractSup.SealApplication__c=='是'&&(contractSup.Country__c=='国内非关联方'||contractSup.Country__c=='国内关联方')) {
            return 'NoSeal';
        }
        if (contractSup.ProtocolType__c.contains('支付条款变更') && contractSup.PaymentRatioSum__c!=100) {
            return '付款比例总和不等于100%，请检查！';
        }
        List<String> sealCompayName = new List<String>(); //印章归属公司
        List<String> sealName = new List<String>(); //印章类别
        List<String> sealNumber = new List<String>(); //印章数量
        List<String> sealAdmins = new List<String>(); //印章保管员

        List<String> fd_bg_machine_cfg = new List<String>();//变更后风机信息明细表.单机容量（MW）,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_count = new List<String>();//变更后风机信息明细表.数量,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_height = new List<String>();//变更后风机信息明细表.塔筒高度（米）,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_name = new List<String>();//变更后风机信息明细表.机型,格式：'主机型'+'单机容量'+'-'+'叶轮直径'+'/'+'塔筒高度'，协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_remark = new List<String>();//变更后风机信息明细表.备注,协议类型为“机型或配置变更”时选填
        List<String> fd_bg_machine_type = new List<String>();//变更后风机信息明细表.主机型显示值,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_unit = new List<String>();//变更后风机信息明细表.单位,协议类型为“机型或配置变更”时必填
        List<String> fd_bg_machine_zj = new List<String>();//变更后风机信息明细表.叶轮直径（米）,协议类型为“机型或配置变更”时必填

        List<String> fd_bg_fkfs = new List<String>();//变更付款比例明细表.固定/浮动,协议类型为“支付条款变更”时必填,可填固定、浮动
        List<String> fd_bg_pay_fnode = new List<String>();//变更付款比例明细表.付款节点_浮动,协议类型为“支付条款变更”且选择浮动时必填
        List<String> fd_bg_pay_gnode = new List<String>();
        List<String> fd_bg_pay_hd_gnode = new List<String>();
        List<String> fd_bg_pay_proportion = new List<String>();//变更付款比例明细表.付款比例
        List<String> fd_company_name = new List<String>();//其他方明细表.公司全称
        List<String> fd_subject_identity = new List<String>();//其他方明细表.主体身份

        External_System_Param__c ext = External_System_Param__c.getValues('oaMarketingContractAdd');
        //印章相关信息
        for (Seal_Related_Information__c sealRelInfo : contractSup.Marketing_Contract_Seal__r) {
            if(contractSup.Country__c=='国内非关联方'||contractSup.Country__c=='国内关联方'){
                // if (sealRelInfo.Document_Category__c!=null) {
                //     fileCategory.add(sealRelInfo.Document_Category__c);
                // }
                // if (sealRelInfo.Document_Name__c!=null) {
                //     qualityFilename.add(sealRelInfo.Document_Name__c);
                // }else {
                //     qualityFilename.add('');
                // }
                if (sealRelInfo.Seal_Company__c!=null) {
                    String company = sealRelInfo.Seal_Company__c;
                    Integer tempPosition = company.indexOf('+MY+');
                    sealCompayName.add(company.substring(0,tempPosition));
                    if (tempPosition<0) {
                        sealAdmins.add('A04313');//印章保管员
                    }else {
                        sealAdmins.add(company.substring(tempPosition+4));//印章保管员
                    }
                }
                if (sealRelInfo.Seal_Type__c!=null) {
                    String temp = sealRelInfo.Seal_Type__c;
                    sealName.add(temp.substringAfterLast('-'));
                }
                if (sealRelInfo.Seal_Numble__c!=null) {
                    sealNumber.add(sealRelInfo.Seal_Numble__c);
                }
            } 
        }

        //其他方
        for (SupplementOtherParties__c info : contractSup.ContractSupplementOtherParties__r) {
            if (info.CompanyName__c!=null) {
                fd_company_name.add(info.CompanyName__c);
            }
            if (info.SubjectIdentity__c!=null) {
                fd_subject_identity.add(info.SubjectIdentity__c);
            }
        }
        
        //变更后风机信息
        for (SalesModelAndQuantity__c info : contractSup.ContractSupplementSales__r) {
            if (info.MachineCfg__c!=null) {
                fd_bg_machine_cfg.add(String.valueOf(info.MachineCfg__c));
            }
            if (info.Quantity__c!=null) {
                fd_bg_machine_count.add(String.valueOf(info.Quantity__c));
            }
            if (info.MachineHeight__c!=null) {
                fd_bg_machine_height.add(info.MachineHeight__c==null?'':String.valueOf(info.MachineHeight__c));
            }
            if (info.MachineName__c!=null) {
                fd_bg_machine_name.add(info.MachineName__c);
            }
            if (info.Remark__c!=null) {
                fd_bg_machine_remark.add(info.Remark__c);
            }
            if (info.MachineModel__c!=null) {
                fd_bg_machine_type.add(info.MachineModel__c);
            }
            if (info.Unit__c!=null) {
                fd_bg_machine_unit.add(info.Unit__c);
            }
            if (info.MachineZj__c!=null) {
                fd_bg_machine_zj.add(info.MachineZj__c==null?'':String.valueOf(info.MachineZj__c));
            }
        }

        List<Utils.PickListValue> pickList = Utils.getPickListValue('Payment_Proportion__c','Paymentnode__c');
        Map<String,String> map_return = new Map<String,String>();
        for (Utils.PickListValue pick : picklist) {
            map_return.put(pick.FieldValue, pick.FieldLabel);
        }
        //变更付款比例
        for (Payment_Proportion__c info : contractSup.ContractSupplementPayment__r) {
            if (info.PaymentType__c!=null) {
                fd_bg_fkfs.add(info.PaymentType__c);
                if(info.PaymentType__c=='固定'){
                    fd_bg_pay_gnode.add(info.Paymentnode__c);
                    fd_bg_pay_hd_gnode.add(map_return.get(info.Paymentnode__c));
                    fd_bg_pay_fnode.add('');
                }else{
                    fd_bg_pay_gnode.add('');
                    fd_bg_pay_hd_gnode.add('');
                    fd_bg_pay_fnode.add(info.FloatContent__c);
                }
            }
            if (info.Paymentratio__c!=null) {
                fd_bg_pay_proportion.add(String.valueOf(info.Paymentratio__c));
            }
        }

        try {
            reqBody.fdId = String.isBlank(contractSup.Process_Id__c)?'':contractSup.Process_Id__c;//流程Id
            reqBody.auditNode = String.isBlank(contractSup.Approval_Comments__c)?'请审批':contractSup.Approval_Comments__c;
            reqBody.docCreator = contractSup.Applicant_Num__c; //创建人
            reqBody.fd_apply_seal = String.isBlank(contractSup.SealApplication__c)?'否':contractSup.SealApplication__c; //是否申请盖章
            reqBody.fd_applyer = contractSup.Applicant_Num__c; //申请人
            reqBody.fd_business_manager = contractSup?.Business_Manager__c==null?'':contractSup.Business_Manager__r.Job_Number__c; //商务经理
            reqBody.fd_customer_type = contractSup.Country__c; //客户类型
            reqBody.fd_deal_type = contractSup.ProtocolType__c; //协议类型
            reqBody.fd_jingban_charge = contractSup.Owner_Department__c; //经办部门设置,示例值(1000106)

            MarketBidDept__c marketBidDept = [SELECT Id,Name FROM MarketBidDept__c WHERE DeptId__c =: contractSup.CustomerMarketingDivision__c];
            reqBody.fd_market_hd_name = marketBidDept.Name; //客户营销分部名称
            reqBody.fd_market_sub = contractSup?.CustomerMarketingDivision__c==null?'':contractSup.CustomerMarketingDivision__c; //客户营销分部id

            //销售区域
            ProjectArea__c projectArea = [SELECT Id,Name,AreaPersonId__c,AreaPerson__c FROM ProjectArea__c WHERE fdid__c =: contractSup.ProjectArea__c];
            reqBody.fd_namezone_represent = projectArea.AreaPerson__c;//区域负责人名称 项目所属区域 自动带出
            reqBody.fd_project_code = contractSup.WBS__c; //项目编码
            reqBody.fd_project_manager = contractSup?.Project_Manager__c==null?'':contractSup.Project_Manager__r.Job_Number__c; //项目经理,示例值(A02323)
            reqBody.fd_project_name = String.isBlank(contractSup.xiangmu__c)?'':contractSup.xiangmu__c; //项目名称
            reqBody.fd_project_type = contractSup.ProjectType__c; //项目类型,可用值:陆上,海上,示例值(海上)
            reqBody.fd_war_zone = projectArea.Name; //项目所属区域
            reqBody.fd_xieyi_text_description = contractSup.AgreementIntroduction__c==null?'':contractSup.AgreementIntroduction__c; //协议内容简介
            reqBody.fd_zone_represent = projectArea.AreaPersonId__c; //区域负责人ID 项目所属区域 自动带出
            reqBody.fd_bg_capacity = String.valueOf(contractSup.ContractCapacity__c); //变更后合同容量, 协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_customer_code = contractSup.AccountName__c==null?'':(contractSup.AccountName__r.AccountNumber==null?'':contractSup.AccountName__r.AccountNumber); //变更后客户编码, 协议类型为“主体变更”时必填
            reqBody.fd_bg_customer_name = contractSup.AccountName__c==null?'':contractSup.AccountName__r.Name; //变更后客户实际值, 协议类型为“主体变更”时必填,格式：客户编码
            reqBody.fd_bg_customer_name_text = contractSup.AccountName__c==null?'':contractSup.AccountName__r.Name; //变更后客户实际值, 协议类型为“主体变更”时必填,格式：客户编码
            reqBody.fd_bg_fkfs = fd_bg_fkfs;//变更付款比例明细表.固定/浮动,协议类型为“支付条款变更”时必填,可填固定、浮动
            reqBody.fd_bg_ht_rate = contractSup.TaxRate__c;//变更后合同税率 ,协议类型为“支付条款变更”时必填
            reqBody.fd_bg_ht_total = String.valueOf(contractSup.Amount__c);//变更后合同总金额, 协议类型为“支付条款变更”时必填
            reqBody.fd_bg_machine_cfg = fd_bg_machine_cfg;//变更后风机信息明细表.机型配置(叶轮直径/塔筒高度),协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_machine_count = fd_bg_machine_count;//变更后风机信息明细表.数量,协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_machine_name = fd_bg_machine_name;//变更后风机信息明细表.机型,格式：主机型-机型配置，协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_machine_remark = fd_bg_machine_remark;//变更后风机信息明细表.备注,协议类型为“机型或配置变更”时选填
            reqBody.fd_bg_machine_type = fd_bg_machine_type;//变更后风机信息明细表.主机型显示值,协议类型为“机型或配置变更”时必填
            // reqBody.fd_bg_machine_type_text = fd_bg_machine_type;//变更后风机信息明细表.主机型实际值,和显示值一样,协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_machine_unit = fd_bg_machine_unit;//变更后风机信息明细表.机型配置(叶轮直径/塔筒高度),协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_machine_height = fd_bg_machine_height;//变更后风机信息明细表.机型配置(叶轮直径/塔筒高度),协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_machine_zj = fd_bg_machine_zj;//变更后风机信息明细表.机型配置(叶轮直径/塔筒高度),协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_num = String.valueOf(contractSup.ContractQuantity__c);//变更后合同台数 ,协议类型为“机型或配置变更”时必填
            reqBody.fd_bg_pay_fnode = fd_bg_pay_fnode;//变更付款比例明细表.付款节点_浮动,协议类型为“支付条款变更”且选择浮动时必填
            reqBody.fd_bg_pay_gnode = fd_bg_pay_gnode;//变更付款比例明细表.付款节点_固定,协议类型为“支付条款变更”且选择固定时必填，可填预付款,投料款,到货款,预验收款,质保金款
            reqBody.fd_bg_pay_hd_gnode = fd_bg_pay_hd_gnode;
            reqBody.fd_bg_pay_mode = contractSup.PaymentMethod__c;//变更后付款方式 ,协议类型为“支付条款变更”时必填,可用值:电汇,银行承兑,商业承兑,现金,其他
            reqBody.fd_bg_other_pay_mode = contractSup.PaymentMethodOther__c;//变更后付款方式_其他 ,协议类型为“支付条款变更”，变更后付款方式为其他时必填
            reqBody.fd_bg_pay_proportion = fd_bg_pay_proportion;//变更付款比例明细表.付款比例,协议类型为“支付条款变更”时必填
            reqBody.fd_bg_price = String.valueOf(contractSup.Price__c);//变更后单价 ,协议类型为“支付条款变更”时必填
            reqBody.fd_bg_total_proportion = '100';//变更付款比例合计, 协议类型为“支付条款变更”时必填
            reqBody.fd_company_name = fd_company_name;//其他方明细表.公司全称
            reqBody.fd_old_ht_process = contractSup.Contractname__r.Process_Id__c==null?'':contractSup.Contractname__r.Process_Id__c;//原主合同会签流程ID
            reqBody.fd_old_ht_process_text = contractSup?.Contractname__r.ProcessTheme__c==null?'':contractSup?.Contractname__r.ProcessTheme__c;//原主合同会签流程主题
            reqBody.fd_other_deal = contractSup.Other_Protocol_Types__c==null?'':contractSup.Other_Protocol_Types__c; //其它协议类型协议类型为“其他”时必填
            reqBody.fd_seal_compay_name = sealCompayName; //印章归属公司 国别为“国内项目”且是否申请盖章为“是”时必填
            reqBody.fd_seal_name = sealName; //印章类别 国别为“国内项目”且是否申请盖章为“是”时必填
            reqBody.fd_seal_number = sealNumber; //盖章数量国别为“国内项目”且是否申请盖章为“是”时必填
            reqBody.fd_seal_org = String.isBlank(contractSup.Seal_Org__c)?'':contractSup.Seal_Org__c;//管理单位 conner
            reqBody.fd_seal_safekeep_dept = String.isBlank(contractSup.Seal_Safekeep_Dept__c)?'':contractSup.Seal_Safekeep_Dept__c;//印章保管部门 conner
            reqBody.fd_seal_admin = sealAdmins;//印章保管员 conner
            reqBody.fd_subject_identity = fd_subject_identity;//其他方明细表.主体身份

            // reqBody.fd_file_name = String.isBlank(contractSup.International_Document_Name__c)?'':contractSup.International_Document_Name__c; //明阳国际文件名称(国际印章审批)
            // reqBody.fd_gaiz_desc = String.isBlank(contractSup.International_Seal_Description__c)?'':contractSup.International_Seal_Description__c; //盖章说明(国际印章审批)
            // //需知道这个字段对应了什么
            // reqBody.fd_myseal_no = contractSup.International_Seals_Number__c==null?0:contractSup.International_Seals_Number__c; //明阳国际盖章数量(国际印章审批)
            // reqBody.fd_myseal_type = String.isBlank(contractSup.International_Seal_Type__c)?'':contractSup.International_Seal_Type__c; //明阳国际印章类型国别为“国际项目”时必填,可用值:明阳国际公章,投标专用章(国际印章审批)
            // // reqBody.fd_quality_filaname = qualityFilename; //资质文件名称文档类别为“3”时必填
            // reqBody.fd_vice_president = contractSup?.Regional_Vice_President__c==null?'':contractSup.Regional_Vice_President__r.Job_Number__c; //分管副总裁国别为“国内项目”且项目类型为“陆上”时必填
            // reqBody.fd_xieyi_whole_name = contractSup.AgreementFullName__c==null?'':contractSup.AgreementFullName__c; //协议各方全称
            // reqBody.n57 = contractSup?.Manager_Marketing_Division__c==null?'':contractSup.Manager_Marketing_Division__r.Job_Number__c; //营销分部执行总经理审核

            String response = Utils.callOut(JSON.serialize(reqBody),ext.Request_URL__c,'ControllerMarketingContract',ext.Request_Source__c,ext.Request_Method__c,ext.Request_Key__c,ext.Initialization_Vector__c);
            if (response.substring(0,5) == 'Error') {
                return response;
            }else {
                ResponseBody resBody = (ResponseBody)System.JSON.deserialize(response, ResponseBody.class);
                if (resBody.code == 200) {
                    String recTypeId = Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('Integrated_Record_Type').getRecordTypeId();

                    //先判断是否是驳回状态，用于更新中间表状态
                    Boolean updateMiddleTableSign = false;
                    String findId = '';
                    if (!String.isBlank(contractSup.Process_Id__c)&&(contractSup.Approvalstatus__c=='11'||contractSup.Approvalstatus__c=='10')) {
                        updateMiddleTableSign = true;
                        findId = [SELECT Id FROM Integrated_Middle_Table__c WHERE Mapping_Object_Id__c =:contractSup.Id AND RecordTypeId =: recTypeId].Id;
                    }

                    //国内的印章审批，创建印章审批相关信息的父对象
                    if (contractSup.SealApplication__c=='是'&&(contractSup.Country__c=='国内非关联方'||contractSup.Country__c=='国内关联方')&&contractSup.Process_Id__c==null) {
                        Seal_Approval__c sealApp = new Seal_Approval__c();
                        sealApp.Marketing_Contract__c = contractSup.Id;
                        sealApp.Seal_Org__c = contractSup.Seal_Org__c;//管理单位
                        sealApp.SealKeep__c = contractSup.Seal_Safekeep_Dept__c;//印章保管部门
                        insert sealApp;
                    }

                    ContractSupplement__c updateReq = new ContractSupplement__c();
                    updateReq.Id = contractSup.Id;
                    updateReq.Process_Id__c = resBody.data.fdId;
                    updateReq.ApplicantionNumber__c = resBody.data.fdNumber;
                    updateReq.ProcessTheme__c = resBody.data.docSubject;
                    updateReq.Approvalstatus__c = '20';//审批中
                    returnId = resBody.data.fdId;
                    update updateReq;   //更新回流程id  
                    
                    //插入数据到集成中间表
                    Integrated_Middle_Table__c middleForm = new Integrated_Middle_Table__c();
                    if (updateMiddleTableSign) {
                        middleForm.id = findId;
                        middleForm.Approvalstatus__c = '20';//审批状态
                        update middleForm;
                    }else {
                        middleForm.RecordTypeId = recTypeId;//赋值记录类型
                        middleForm.Object_API__c = 'ContractSupplement__c';//对象API
                        middleForm.Mapping_Object_Id__c = contractSup.Id;//对应对象的Id
                        middleForm.Scheme_Type__c = null;//方案类型
                        middleForm.Final_Approval_Date__c = null;//最终审批通过日期
                        middleForm.Process_Id__c = resBody.data.fdId;//流程Id
                        middleForm.Approvalstatus__c = '20';//审批状态
                        if (contractSup.Country__c=='国际客户') {
                            middleForm.Is_International__c = true;//是否国际印章审批
                        }else {
                            middleForm.Is_International__c = false;
                        }
                        
                        insert middleForm;
                    }
                   

                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerMarketingContract';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = true;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;             
                }else {
                    logInfo.RequestURL__c = ext.Request_URL__c;
                    logInfo.ClassName__c = 'ControllerMarketingContract';
                    logInfo.RequestBody__c = JSON.serialize(reqBody);
                    logInfo.RespondBody__c = response;
                    logInfo.IsSuccess__c = false;
                    logInfo.ErrorMessage__c = '';
                    insert logInfo;
                    Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
                    return 'Error'+resBody.message+'\n日志编号:'+newLog.Name;
                }
            }
            return 'SUCCESS'+ext.OSS_URL__c+'&fdId='+returnId+'&loginName='+contractSup.Applicant_Num__c+'&identification=CRM';
        } catch (Exception e) {
            logInfo.RequestURL__c = ext.Request_URL__c;
            logInfo.ClassName__c = 'ControllerMarketingContract';
            logInfo.RequestBody__c = JSON.serialize(reqBody);
            logInfo.ErrorMessage__c = 'callout处理错误'+e.getLineNumber() + e.getStackTraceString() + ' ' + e.getMessage();
            insert logInfo;
            Interface_Log__c newLog = [SELECT Name FROM Interface_Log__c WHERE Id =: logInfo.Id];
            return 'Error'+logInfo.ErrorMessage__c+'\n日志编号:'+newLog.Name;
        }
    }

    public class RequestBody {
        public String fdId{get;set;}//已驳回携带流程id
        public String auditNode{get;set;}//审批意见
        public String docCreator{get;set;}//创建人
        public String fd_apply_seal{get;set;} //是否申请盖章
        public String fd_applyer;//申请人

        public String fd_bg_capacity;//变更后合同容量, 协议类型为“机型或配置变更”时必填
        public String fd_bg_customer_code;//变更后客户编码, 协议类型为“主体变更”时必填
        public String fd_bg_customer_name;//变更后客户实际值, 协议类型为“主体变更”时必填
        public String fd_bg_customer_name_text;//变更后客户显示值, 协议类型为“主体变更”时必填
        public List<String> fd_bg_fkfs;//变更付款比例明细表.固定/浮动,协议类型为“支付条款变更”时必填,可填固定、浮动
        public String fd_bg_ht_rate;//变更后合同税率 ,协议类型为“支付条款变更”时必填
        public String fd_bg_ht_total;//变更后合同总金额, 协议类型为“支付条款变更”时必填
        public List<String> fd_bg_machine_cfg;//变更后风机信息明细表.单机容量（MW）,协议类型为“机型或配置变更”时必填
        public List<String> fd_bg_machine_count;//变更后风机信息明细表.数量,协议类型为“机型或配置变更”时必填
        public List<String> fd_bg_machine_name;//变更后风机信息明细表.机型,格式：主机型-机型配置，协议类型为“机型或配置变更”时必填
        public List<String> fd_bg_machine_remark;//变更后风机信息明细表.备注,协议类型为“机型或配置变更”时选填
        public List<String> fd_bg_machine_type;//变更后风机信息明细表.主机型显示值,协议类型为“机型或配置变更”时必填
        // public List<String> fd_bg_machine_type_text;//变更后风机信息明细表.主机型实际值,和显示值一样,协议类型为“机型或配置变更”时必填
        public List<String> fd_bg_machine_unit;//变更后风机信息明细表.单位,协议类型为“机型或配置变更”时必填
        public List<String> fd_bg_machine_height;//变更后风机信息明细表.塔筒高度（米）,协议类型为“机型或配置变更”时必填
        public List<String> fd_bg_machine_zj;//变更后风机信息明细表.叶轮直径（米）,协议类型为“机型或配置变更”时必填
        public String fd_bg_num;//变更后合同台数 ,协议类型为“机型或配置变更”时必填
        public List<String> fd_bg_pay_fnode;//变更付款比例明细表.付款节点_浮动,协议类型为“支付条款变更”且选择浮动时必填
        public List<String> fd_bg_pay_gnode;//变更付款比例明细表.付款节点_固定,协议类型为“支付条款变更”且选择固定时必填，可填预付款,投料款,到货款,预验收款,质保金款
        public List<String> fd_bg_pay_hd_gnode;//变更付款比例明细表.付款节点_固定,协议类型为“支付条款变更”且选择固定时必填，填写名称
        public String fd_bg_pay_mode;//变更后付款方式 ,协议类型为“支付条款变更”时必填,可用值:电汇,银行承兑,商业承兑,现金,其他
        public String fd_bg_other_pay_mode;//变更后付款方式_其他 ,协议类型为“支付条款变更”，变更后付款方式为其他时必填
        public List<String> fd_bg_pay_proportion;//变更付款比例明细表.付款比例,协议类型为“支付条款变更”时必填
        public String fd_bg_price;//变更后单价 ,协议类型为“支付条款变更”时必填
        public String fd_bg_total_proportion;//变更付款比例合计, 协议类型为“支付条款变更”时必填

        public String fd_business_manager;//商务经理,示例值(A02323)
        public List<String> fd_company_name;//其他方明细表.公司全称
        public String fd_customer_type;//客户类型,可用值:国内关联方,国内非关联方,国际客户
        public String fd_deal_type;//协议类型(多值以;分割),可用值:主体变更,支付条款变更,机型或配置变更,其它,示例值(主体变更;支付条款变更)

        public String fd_jingban_charge;//所有人部门
        public String fd_market_hd_name;//客户营销分部名称
        public String fd_market_sub;//营销分部,可用值:营销一部,营销二部,营销三部,营销四部,营销五部,营销六部,其他,明阳国际,示例值(营销一部)
        public String fd_namezone_represent;//区域负责人名称
        public String fd_old_ht_process;//原主合同会签流程ID
        public String fd_old_ht_process_text;//原主合同会签流程主题名称
        public String fd_other_deal;//其它协议类型协议类型为“其他”时必填
        public String fd_project_code;//项目编码
        public String fd_project_manager;//项目经理,示例值(A02323)
        public String fd_project_name;//项目名称,示例值(项目名称)
        public String fd_project_type;//项目类型,可用值:陆上,海上,示例值(海上)
        public List<String> fd_seal_admin{get;set;}//印章管理员,是否申请盖章为“是”时必填    
        public List<String> fd_seal_compay_name;//印章归属公司 国别为“国内项目”且是否申请盖章为“是”时必填
        public List<String> fd_seal_name;//印章类别国别为“国内项目”且是否申请盖章为“是”时必填
        public List<String> fd_seal_number;//盖章数量国别为“国内项目”且是否申请盖章为“是”时必填
        public String fd_seal_org{get;set;}//管理单位,可用值:集团总裁办,基地,子公司,海上风电子公司,示例值(集团总裁办)   
        public String fd_seal_safekeep_dept{get;set;}//印章保管部门,示例值(总裁办综合部)
        public List<String> fd_subject_identity;//其他方明细表.主体身份
        public String fd_war_zone;//项目所属区域 国别为“国内项目”且项目类型为“陆上”时必填
        public String fd_xieyi_text_description;//协议内容简介,示例值(合同主体变更：xxxx有限公司变更为ssss工程有限公司；)
        public String fd_zone_represent;//区域代表 国别为“国内项目”且项目类型为“陆上”时必填

        // public String fd_country_in;//国别,可用值:国内项目,国际项目,示例值(国内项目)
        // // public List<String> fd_file_category;//文档类别
        // public String fd_file_name;//明阳国际文件名称 国别为“国际项目”时必填
        // public String fd_gaiz_desc;//盖章说明 国别为“国际项目”时必填
        // public Double fd_myseal_no;//明阳国际盖章数量 国别为“国际项目”时必填
        // public String fd_myseal_type;//明阳国际印章类型 国别为“国际项目”时必填,可用值:明阳国际公章,投标专用章
        // // public List<String> fd_quality_filaname;//资质文件名称文档类别为“3”时必填
        // public String fd_vice_president;//分管副总裁国别为“国内项目”且项目类型为“陆上”时必填
        // public String fd_xieyi_whole_name;//协议各方全称,示例值(明阳智慧能源集团股份公司)
        // public String n57;//流程参数，需传输节点人员：N57.营销分部执行总经理审核,示例值(A02323)
    }

    public class ResponseBody {
        public Integer code{get;set;}
        public String message{get;set;}
        public Data data{get;set;} 
    }
    public class Data {
        public String rtStatus{get;set;}
        public String rtMsg{get;set;}
        public String fdId{get;set;}
        public String docSubject{get;set;}
        public String fdNumber{get;set;}
    } 
}