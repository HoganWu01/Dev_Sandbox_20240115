public with sharing class LwcOppNameCheckWeightsController {
    /**
     * 获取商机列表
     */
    @AuraEnabled(cacheable=true)
    public static List<OppEntity> getRelatedOpps(String oppId) {

        List<OppEntity> oppEntityList = new List<OppEntity>();

        Opportunity currOpp = [SELECT Id, Name, ProjectNumber__c, Account.Name, Owner.Name, 
        Account.Shortname__c, City__c, County__c, Province__c, Wind_Farm_Project_Name__c, capacity__c FROM Opportunity WHERE Id =: oppId];

        List<Opportunity> oppList = [SELECT Id, Name, ProjectNumber__c, Account.Name, Owner.Name, 
        Account.Shortname__c, City__c, County__c, Province__c, Wind_Farm_Project_Name__c, capacity__c
                FROM Opportunity WHERE Id != :oppId and OpportunityApprovalStatus__c != '草稿'];

        for (Opportunity o : oppList) {
            Decimal weight = 0;
            if (o.Account.Shortname__c == currOpp.Account.Shortname__c &&
                o.Province__c == currOpp.Province__c &&
                o.City__c == currOpp.City__c) { //客户简称、省份、城市 重复

                weight += 49;

                if (o.capacity__c == currOpp.capacity__c) { //容量 重复
                    weight += 10;
                }

                if (o.County__c == currOpp.County__c) { //县区 重复
                    weight += 10;
                }
            }
            
            String windFarmCurr = currOpp.Wind_Farm_Project_Name__c.replaceAll('风电','').replaceAll('项目','');

            String windFarmStr = o.Wind_Farm_Project_Name__c.replaceAll('风电','').replaceAll('项目','');

            if (windFarmFun(windFarmCurr, windFarmStr)) { //大于两个字符重复
                weight += 30;
            }

            if (weight >= 30) {
                OppEntity oEnt = new OppEntity();
                oEnt.Id = o.Id;
                oEnt.projectNumber = o.ProjectNumber__c;
                oEnt.oppName = o.Name;
                oEnt.accName = o.Account.Name;
                oEnt.owner = o.Owner.Name;
                oEnt.weight = weight / 100;
                oppEntityList.add(oEnt);
            }
        }
        return oppEntityList;
    }

    public static Boolean windFarmFun(String currStr, String oppStr){
        Integer dupCount = 0; //重复次数

        String[] stringCharacters = currStr.replaceAll(' ','').split('');
        String firstElement = stringCharacters.remove(0);

        // String[] charArray = currStr.toCharArray(); 
        for (String c : stringCharacters) {

            Integer count = 0;

            Integer origialLength = oppStr.length();
            oppStr = oppStr.replace(c, '');
            Integer newLength = oppStr.length();

            count = origialLength - newLength;
            if (count > 0) { //说明循环该字符有重复，记1
                dupCount++;
                if (dupCount>2) { //大于两个字符重复，不再循环
                    return true;
                }
            }
        }
        return false;
    }

    public class OppEntity {
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String projectNumber{get;set;}
        @AuraEnabled
        public String oppName{get;set;}
        @AuraEnabled
        public String accName{get;set;}
        @AuraEnabled
        public String owner{get;set;}
        @AuraEnabled
        public Decimal weight{get;set;}
    } 
}