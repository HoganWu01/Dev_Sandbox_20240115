global without sharing class OppManagerHandler {

    /**
     * @Descripttion: 商机更改二级战区/公司时查找基础数据找对应的二级公司经理、售前项目经理
     * @Author: Hogan
     * @LastEditors: Hogan
     * @LastEditTime: ###### Fri Sep 15 16:36:27 CST 2023
     * @param {*}
     * @return {*}
     */
    public static void FindManagerBySWZ(List<String> oppListFindManagerBySWZ) {


        List<Opportunity> oppList = [SELECT ID,
                                            ProjectArea__c,   //所属大区/二级公司
                                            Chiefgeneralmanager__c,   //大区/二级公司总经理
                                            Pre_Sales_Project_Manager__c //售前项目经理
                                            FROM Opportunity WHERE ID IN:oppListFindManagerBySWZ];

        if (oppList[0].ProjectArea__c==null) {
            return ; 
        }

        String recTypeId =Schema.SObjectType.BasicData__c.getRecordTypeInfosByDeveloperName().get('RecordType_BasicData_Sales').getRecordTypeId();

        List<BasicData__c> tableList = [SELECT Id,
                                                    MainChargeUser__c,
                                                    PreManagerUser__c 
                                                    FROM BasicData__c 
                                                    WHERE RecordTypeId =:recTypeId  
                                                    AND ProjectArea__c =:oppList[0].ProjectArea__c];


        if (tableList.size()==0) {
            return ; 
        }

        if(tableList[0].MainChargeUser__c != null){
            oppList[0].Chiefgeneralmanager__c = tableList[0].MainChargeUser__c;
        }

        if(tableList[0].PreManagerUser__c != null){
            oppList[0].Pre_Sales_Project_Manager__c = tableList[0].PreManagerUser__c;
        }

        upsert oppList ; 
    }

    /**
     * @Descripttion: 商机更改客户分部时查找基础数据找对应的分部总经理
     * @Author: Hogan
     * @LastEditors: Hogan
     * @LastEditTime: ###### Fri Sep 15 16:36:27 CST 2023
     * @param {*}
     * @return {*}
     */
    public static void FindManagerByMBD(List<String> oppListFindManagerByMBD) {


        List<Opportunity> oppList = [SELECT ID,
                                            MarketBidDept__c,   //客户分部
                                            Key_Account_General_Manager__c   //大客户总经理
                                            FROM Opportunity WHERE ID IN:oppListFindManagerByMBD];

        if (oppList[0].MarketBidDept__c==null) {
            return ; 
        }

        String recTypeId =Schema.SObjectType.BasicData__c.getRecordTypeInfosByDeveloperName().get('RecordType_BasicData_Customer').getRecordTypeId();

        List<BasicData__c> tableList = [SELECT Id,
                                                    MainChargeUser__c
                                                    FROM BasicData__c 
                                                    WHERE RecordTypeId =:recTypeId  
                                                    AND MarketBidDept__c =:oppList[0].MarketBidDept__c];


        if (tableList.size()==0) {
            return ; 
        }

        if(tableList[0].MainChargeUser__c != null){
            oppList[0].Key_Account_General_Manager__c = tableList[0].MainChargeUser__c;
        }

        upsert oppList ; 
    }
}