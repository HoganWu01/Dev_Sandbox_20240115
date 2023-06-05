/*
 * @Descripttion: 潜在客户触发器Handler
 * @Author: Devin
 * @Date: 2021-10-14 15:21:16
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2022-03-23 18:38:43
 */
public without sharing class LeadHandler implements Triggers.Handler {

    List<String> clueListFindManagerBySWZ = new List<String>();
   
    public void handle() {

        //2022-01-11  irving
        if (Trigger.isBefore && Trigger.isInsert) {

            for(Lead lead : (List<Lead>)Trigger.new) {
                //如果线索的线索名称*已经在系统存在
                System.debug('Projectname__c----'+lead.Projectname__c);
                Integer records = [SELECT count() FROM Lead WHERE Projectname__c =: lead.Projectname__c  ];
                if (records > 0) {
                    lead.addError('线索名称已重复，无法新建！请检查【风场项目名】、【期数】、【区县】字段是否补充完整，补充完整后可降低重复概率。若补充完整依然提示重复，则系统已存在相同线索，请勿新建！');
                }
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {

            //发起线索申报审批时,线索共享给大区/二级公司总经理  大客户总经理
            Set<Id> shareManageSet = new Set<Id>();

            //转换线索
            Set<Lead> convertedLeadSet = new Set<Lead>();

            for(Lead newLead : (List<Lead>)Trigger.new) {
                Lead oldLead = (Lead)Trigger.oldMap.get(newLead.Id);
                if (newLead.Approval__c && newLead.Approval__c != oldLead.Approval__c) {
                    //发起审批流
                    approvelLead(newLead.Id);
                }

                if (newLead.Approvalstatus__c=='审批中') {
                    shareManageSet.add(newLead.Id);
                }

                //所属大区/二级公司 找大区/二级公司总经理
                if (newLead.SalesDepartment__c!=oldLead.SalesDepartment__c) {
                    clueListFindManagerBySWZ.add(newLead.id);
                }

                //线索转换时  手机端自动生成商机
                if (newLead.Status == '已转化' && newLead.Status != oldLead.Status) {
                    convertedLeadSet.add(newLead);
                }
            }

            if (shareManageSet.size()>0) {
                shareAuthority(shareManageSet);
            }

            if (convertedLeadSet.size() > 0) {
                createOpportunity(convertedLeadSet);
            }
        }


        if (Trigger.isAfter && Trigger.isInsert) {
            for(Lead lead : (List<Lead>)Trigger.new) {
                if (lead.SalesDepartment__c!=null) {
                    clueListFindManagerBySWZ.add(lead.id);
                }
            }
        }

        if (clueListFindManagerBySWZ.size()>0) {
            FindManagerBySWZ(clueListFindManagerBySWZ);
        }
        
    }

    /**
     * @Descripttion: 线索审批
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    public void approvelLead(String recordId) {
        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
        apsr.setObjectId(recordId);
        apsr.setSubmitterId(UserInfo.getUserId());
        //提交审批结果
        Approval.ProcessResult rt;
        try{
            rt = Approval.process(apsr);
            if(rt.isSuccess()){
                System.debug('调用commit审批过程成功！');
            }
        }catch(Exception e){
            System.debug('调用commit审批过程产生异常：' + e.getMessage()); 
        }

        //无论成功是否 发起审批流成功后 清空【审批】字段
        Lead upLead = new Lead();
        upLead.Id = recordId;
        upLead.Approval__c = false;
        update upLead;
    }

    /**
     * @Descripttion: 发起线索申报审批时,线索共享给大区/二级公司总经理  大客户总经理
     * @Author: irving
     * @param {*}
     * @return {*}
     */   
    public void shareAuthority(Set<Id> shareManageSet) {


        List<Lead> LeadList = new List<Lead>();

        LeadList = [SELECT Id,
                            ExecutiveGeneralManage__c,  //大客户总经理*
                            ChiefGeneralManager__c  //大区/二级公司总经理*
                            FROM Lead WHERE Id IN: shareManageSet];

        List<leadShare> insertList = new List<leadShare>();

        for (Lead l : LeadList) {
            leadShare share = new leadShare();
            share.LeadId = l.Id;
            share.UserOrGroupId = l.ExecutiveGeneralManage__c;   //分配给---
            share.LeadAccessLevel = 'Read';
            insertList.add(share);
        }

        for (Lead l : LeadList) {
            leadShare share = new leadShare();
            share.LeadId = l.Id;
            share.UserOrGroupId = l.ChiefGeneralManager__c;   //分配给---
            share.LeadAccessLevel = 'Read';
            insertList.add(share);
        }


        Database.insert(insertList,false);

    }

    public void FindManagerBySWZ(List<String> clueListFindManagerBySWZ) {
        
        List<Lead> leadList = [select id,name,SalesDepartment__c,ChiefGeneralManager__c,Pre_Sales_Project_Manager__c from Lead where id in :clueListFindManagerBySWZ];

        if (leadList[0].Salesdepartment__c==null) {
            return ; 
        }

        String recTypeId =Schema.SObjectType.Integrated_Middle_Table__c.getRecordTypeInfosByDeveloperName().get('OppSubCompany_RecordType').getRecordTypeId();


        //和商机的中间表数据一模一样
        List<Integrated_Middle_Table__c> tableList = [SELECT Id,
                                                    OppChiefgeneralmanager__c,
                                                    Pre_Sales_Project_Manager__c,
                                                    Salesdepartment__c 
                                                    FROM Integrated_Middle_Table__c 
                                                    WHERE RecordTypeId =:recTypeId  
                                                    AND Salesdepartment__c =:leadList[0].Salesdepartment__c];


        if (tableList.size()==0  ||  tableList[0].OppChiefgeneralmanager__c==NULL) {
            return ; 
        }
        
        if(tableList[0].OppChiefgeneralmanager__c != null){
            leadList[0].Chiefgeneralmanager__c = tableList[0].OppChiefgeneralmanager__c;
        }

        if(tableList[0].Pre_Sales_Project_Manager__c != null){
            leadList[0].Pre_Sales_Project_Manager__c = tableList[0].Pre_Sales_Project_Manager__c;
        }

        upsert leadList ; 
        
    }

    /**
     * @Descripttion: 线索转换时, 生成商机记录  主要针对手机端情况
     * @Author: Devin 2021-12-23
     * @param {*}
     * @return {*}
     */   
    public void createOpportunity(Set<Lead> convertedLeadSet) {

        //线索Id
        Set<String> convertedLeadIdSet = new Set<String>();
        for (Lead lead : convertedLeadSet) {
            convertedLeadIdSet.add(lead.LeadId__c);
        }

        //查询出 是否是由 线索 转换生成的 商机
        List<Opportunity> opportunityList = new List<Opportunity>();

        opportunityList = [SELECT Id,LeadId__c FROM Opportunity WHERE LeadId__c IN: convertedLeadIdSet];

        //Map<LeadId__c,OppId>
        Map<String, String> oppMap = new Map<String, String>();

        for (Opportunity opp : opportunityList) {
            oppMap.put(opp.LeadId__c,opp.Id);
        }

        Set<Lead> convertLeadSet = new Set<Lead>();

        for (Lead convertLead : convertedLeadSet) {

            //没有生成商机时，系统自动创建商机
            if (!oppMap.containsKey(convertLead.LeadId__c)) {
                convertLeadSet.add(convertLead);
            }
        }

        List<Opportunity> convertOppList = new List<Opportunity>();
        for (Lead clead : convertLeadSet) {
            Opportunity convertOpp = new Opportunity();
            convertOpp.County__c = clead.County__c;//县区
            convertOpp.Country__c = clead.Country__c;//国家
            convertOpp.City__c = clead.City__c;//城市
            convertOpp.Chiefgeneralmanager__c = clead.ChiefGeneralManager__c;//大区/二级公司总经理
            convertOpp.Key_Account_General_Manager__c = clead.ExecutiveGeneralManage__c;//大客户总经理
            convertOpp.Customer_Secondary_Company__c = clead.Subcompany__c;//客户二级公司
            convertOpp.Choose__c = clead.Customer_Side_Approved__c;//客户侧是否立项-进入当年建设盘子
            convertOpp.Salesdepartment__c = clead.SalesDepartment__c;//所属大区/二级子公司
            convertOpp.Transfer2__c = clead.Transfer__c;//是否为线索转化商机
            convertOpp.Periods__c = clead.Numberofperiods__c;//期数（单位：期）
            convertOpp.Province__c = clead.Province__c;//省份
            convertOpp.LeadId__c = clead.Id;//线索Id
            convertOpp.Background__c = clead.Leadbackgrand__c;//商机信息背景
            convertOpp.Cluecontent__c = clead.Leadcontent__c;//商机内容
            convertOpp.Providername__c = clead.Providername__c;//商机内部推荐人姓名
            convertOpp.Providerdepartment__c = clead.Providerdepartment__c;//商机内部推荐人部门
            convertOpp.LeadOppRelatedName__c = clead.Projectname__c;//线索商机对应名称
            convertOpp.ClueSource__c = clead.Leadsource__c	;//商机来源
            convertOpp.OpportunityApprovalStatus__c = '线索转化通过';//商机创建审批状态
            convertOpp.Opportunitylevel__c = clead.Leadlevel__c;//商机等级
            // convertOpp.capacity__c = Decimal.valueOf(clead.Projectcapacity__c);//容量（单位：MW)
            // convertOpp.Group__c = clead.Group__c;//项目所属集团（客户最高级母公司）
            convertOpp.Approval__c = clead.Approvedornot__c;//项目是否核准
            convertOpp.Wind_Farm_Project_Name__c = clead.Windfieldprojectname__c;//风场项目名 （如：锡铁山，若无可不填）
            convertOpp.Date__c = clead.Prebuildstartdate__c;//建设计划时间
            convertOpp.Estimated_Bidding_Time__c = clead.ExpectedBidtime__c;//招标时间
            convertOpp.Approvaltime__c = clead.Expectedapptime__c;//核准时间
            convertOpp.StageName = '线索管理';//阶段	
            convertOpp.Name = clead.Company;//名字	
            Integer numberOfDays = Date.daysInMonth(System.today().year(), System.today().month());
            Date lastDayOfMonth = Date.newInstance(System.today().year(), System.today().month(), numberOfDays);
            convertOpp.CloseDate = lastDayOfMonth;//结束日期  取每个月的最后一天	

            convertOppList.add(convertOpp);
        }

        System.debug('convertOppList--------'+convertOppList);

        insert convertOppList;
    }
}