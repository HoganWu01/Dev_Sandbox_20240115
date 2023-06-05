/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-09 15:08:57
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2021-10-12 17:07:52
 */
/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-09 15:08:57
 * @LastEditors: aug
 * @LastEditTime: 2021-10-12 15:08:04
 */
public with sharing class ControllerBusinessSubmit {
    public ControllerBusinessSubmit() {}

    /**
     * @Descripttion: 商机审批初始化
     * @Author: Devin
     * @param {*}
     * @return {*}
     */   
    @AuraEnabled 
    public static Map<Object,Object> initApproval(String recordId) {
        Opportunity opportunity = [SELECT  
                                         Id,
                                         Name,//业务机会名
                                         Account.Name,//客户全称
                                         capacity__c,//容量
                                         Salesdepartment__c,//所属大区/二级公司 
                                         Chiefgeneralmanager__c,//大区/二级公司总经理 
                                        //  Group__c,//项目所属集团
                                         Key_Account_General_Manager__c,//大客户总经理
                                         Customer_Secondary_Company__c,//客户二级公司
                                         Province__c,//省
                                         City__c,//市
                                         OpportunityApprovalStatus__c,   //商机创建审批状态    
                                         tolabel(MarketBidDept__c), //客户分部       
                                         Choose__c, //客户侧是否立项-进入当年建设盘子
                                         Approval__c, //     项目是否核准  
                                         Approvaltime__c,  //（预计）核准时间
                                         Date__c //（预计）建设计划时间
                                    FROM 
                                         Opportunity	
                                    WHERE 
                                        Id =: recordId
                                        ];
        
        Map<Object,Object> map_return = new Map<Object,Object>();
        String approvalRequired = '';//审批必填字段

        //by hogan edit time:2022/12/2
        if(opportunity.Approval__c != '是' && opportunity.Choose__c != true) {
            approvalRequired += '★【项目是否核准】、【客户侧是否立项-进入当年建设盘子】，至少一个为“是”。\n\r';
        }

        if(String.isBlank(opportunity.Approval__c) || opportunity.Approvaltime__c == null || opportunity.Date__c ==null){
            approvalRequired += '★必须填写“项目是否核准”、“（预计）核准时间”、“（预计）建设计划时间”！\n\r';
        }

        if(opportunity.MarketBidDept__c != '不涉及大客户'){
            List<OpportunityTeamMember> oppTeamList = [SELECT ID FROM OpportunityTeamMember 
            WHERE OpportunityId =: recordId and TeamMemberRole IN ('大客户经理','销售经理')];
            if (oppTeamList.size()==0) {
                approvalRequired += '★【商机】的【商机团队】必须至少包含以下两个【团队角色】其中之一：“区域销售经理”/“大客户销售经理”。\n\r';
            }
        }

        // //业务机会名
        // if(String.isBlank(opportunity.Name)) {
        //     approvalRequired += '业务机会名,';
        // }
        // //客户全称
        // if(String.isBlank(opportunity.Account.Name)) {
        //     approvalRequired += '客户全称,';
        // }
        // //容量
        // if(opportunity.capacity__c==null) {
        //     approvalRequired += '容量,';
        // }
        // //所属大区/二级公司
        // if(String.isBlank(opportunity.Salesdepartment__c)) {
        //     approvalRequired += '所属大区/二级公司,';
        // }
        // //大区/二级公司总经理 
        // if(String.isBlank(opportunity.Chiefgeneralmanager__c)) {
        //     approvalRequired += '大区/二级公司总经理,';
        // }
        // //项目所属集团
        // // if(String.isBlank(opportunity.Group__c)) {
        // //     approvalRequired += '项目所属集团,';
        // // }
        // //大客户总经理
        // if(String.isBlank(opportunity.Key_Account_General_Manager__c)) {
        //     approvalRequired += '大客户总经理,';
        // }
        // //客户二级公司
        // if(String.isBlank(opportunity.Customer_Secondary_Company__c)) {
        //     approvalRequired += '客户二级公司,';
        // }
        // //省
        // if(String.isBlank(opportunity.Province__c)) {
        //     approvalRequired += '省份,';
        // }
        // //市
        // if(String.isBlank(opportunity.City__c)) {
        //     approvalRequired += '城市,';
        // }
        
         
        if (String.isNotBlank(approvalRequired)) {
            approvalRequired = approvalRequired.substring(0, approvalRequired.length() - 2);
        }

        map_return.put('approvalRequired',approvalRequired);
        map_return.put('approvalStatus',opportunity.OpportunityApprovalStatus__c);
        
        return map_return;

    }

    /**
     * @Descripttion: 提交审批流
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static void businessSubmit(String recordId,String comment) { 

        System.debug('comment----'+comment);
        
        Approval.ProcessSubmitRequest apsr= new Approval.ProcessSubmitRequest();
        // apsr.setProcessDefinitionNameOrId('OppLeadConvApprV1');
        //留言内容和对象ID
        apsr.setComments(comment);
        apsr.setObjectId(recordId);
        apsr.setSubmitterId(UserInfo.getUserId());
        // 是否跳过标准
        apsr.setSkipEntryCriteria(true);
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
    }
}