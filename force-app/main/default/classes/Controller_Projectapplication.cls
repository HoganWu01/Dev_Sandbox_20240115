/*
 * @Descripttion: 营销项目立项申请 控制类
 * @Author: Devin
 * @Date: 2021-10-11 14:09:50
 * @LastEditors: Devin
 * @LastEditTime: 2021-10-25 15:49:20
 */
public with sharing class Controller_Projectapplication {

    public Controller_Projectapplication(ApexPages.StandardController stdController) {

        String PId = ApexPages.currentPage().getParameters().get('PId');
        System.debug('PId----'+PId);
    }

    
    /**
     * @Descripttion: parentId 商机Id
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static OpportunityVo doInit(String parentId) {

        Opportunity opp = [SELECT   Id,
                                    Name,//商机名称
                                    Salesdepartment__c,//所属大区/二级公司
                                    toLabel(MarketBidDept__c),//客户分部
                                    Customer_Secondary_Company__r.Name,//客户二级公司
                                    Province__c,//省份
                                    City__c,//城市
                                    County__c,//县区
                                    Wind_Farm_Project_Name__c,//风场项目名
                                    Periods__c,//期数
                                    capacity__c,//容量（MW）
                                    Approvaltime__c,//预计）核准时间
                                    Estimated_Bidding_Time__c//预计）招标时间
                                FROM 
                                    Opportunity  
                                WHERE 
                                    Id =: parentId
                                ];

        OpportunityVo oppVo = new OpportunityVo();
        oppVo.name = opp.Name;
        oppVo.salesdepartment = opp.Salesdepartment__c;
        oppVo.marketBidDept = opp.MarketBidDept__c;
        oppVo.customerSecondaryCompany = opp.Customer_Secondary_Company__r.Name;
        oppVo.province = opp.Province__c;
        oppVo.city = opp.City__c;
        oppVo.county = opp.County__c;
        oppVo.windFarmProjectName = opp.Wind_Farm_Project_Name__c;
        oppVo.periods = opp.Periods__c;
        oppVo.capacity = opp.capacity__c;
        oppVo.approvaltime = opp.Approvaltime__c;
        oppVo.estimatedBiddingTime = opp.Estimated_Bidding_Time__c;

        return oppVo;

    }

    /**
     * @Descripttion: 
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> saveData(String parentId, Date approvaltime, Date estimatedBiddingTime) {
        Map<Object,Object> map_return = new Map<Object,Object>();

        System.debug('------------+'+parentId);

        try {
            
            //【营销项目立项申请】
            Projectapplication__c pa = new Projectapplication__c();
            //根据父级Id 属于哪个对象  
            if (String.isNotBlank(parentId) && parentId != 'undefined') {
                Id pId = String.valueOf(parentId);
                String sObjName = pId.getSObjectType().getDescribe().getName();  
                if (sObjName == 'Opportunity') {
                    pa.Oppty__c = parentId;//商机

                    Opportunity opp = [SELECT   Id,Name,
                                    Salesdepartment__c,//所属大区/二级公司
                                    MarketBidDept__c,//客户分部
                                    Customer_Secondary_Company__c,//客户二级公司
                                    Province__c,//省份
                                    City__c,//城市
                                    County__c,//县区
                                    Wind_Farm_Project_Name__c,//风场项目名
                                    Periods__c,//期数
                                    capacity__c,//容量（MW）
                                    Approvaltime__c,//预计）核准时间
                                    Estimated_Bidding_Time__c,//预计）招标时间
                                    // Group__c,//项目所属集团
                                    Account.Id//客户全称
                                FROM 
                                    Opportunity  
                                WHERE 
                                    Id =: parentId
                                ];

                    pa.Salesdepartment__c = opp.Salesdepartment__c;
                    pa.MarketBidDept__c = opp.MarketBidDept__c;
                    pa.Secondarycompany__c = opp.Customer_Secondary_Company__c;
                    pa.Province__c = opp.Province__c;
                    pa.City__c = opp.City__c;
                    pa.County__c = opp.County__c;
                    pa.Name__c = opp.Wind_Farm_Project_Name__c;
                    pa.Periods__c = opp.Periods__c;
                    pa.MW__c = String.valueOf(opp.capacity__c);
                    pa.Approvaltime__c = approvaltime;
                    pa.Pretime__c = estimatedBiddingTime;
                    pa.Group__c = opp.Account.Id;//客户全称
                    // pa.ProjectName__c = opp.Name;//项目名称
                }
            }

            insert pa;
            map_return.put('messages','创建成功，请完善表单内容并提交!');
            map_return.put('recordId',pa.Id);
        } catch (Exception e) {
            map_return.put('messages','提交失败, 请联系系统管理员! 错误信息:'+e.getMessage());
        }

        return map_return;
    }

    public class OpportunityVo {
        @AuraEnabled
        public String name;//商机名称
        @AuraEnabled
        public String salesdepartment;//所属大区/二级公司
        @AuraEnabled
        public String marketBidDept;//客户分部
        @AuraEnabled
        public String customerSecondaryCompany;//客户二级公司
        @AuraEnabled
        public String province;//省份
        @AuraEnabled
        public String city;//城市
        @AuraEnabled
        public String county;//县区
        @AuraEnabled
        public String windFarmProjectName;//风场项目名
        @AuraEnabled
        public String periods;//期数
        @AuraEnabled
        public Decimal capacity;//容量（MW）
        @AuraEnabled
        public Date approvaltime;//预计）核准时间
        @AuraEnabled
        public Date estimatedBiddingTime;//预计）招标时间

    }
}