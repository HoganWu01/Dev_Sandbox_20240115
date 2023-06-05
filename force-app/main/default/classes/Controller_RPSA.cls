/*
 * @Descripttion: 【资源项目方案申请】
 * @Author: Devin
 * @Date: 2021-09-30 13:50:39
 * @LastEditors: Devin
 * @LastEditTime: 2022-01-10 15:46:06
 */
public without sharing class Controller_RPSA {
    /**
     * @Descripttion: 获取记录类型对应的下拉选项
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> doInit() {

        Map<Object,Object> map_return = new Map<Object,Object>();

        //道路踏勘方案类型
        List<Utils.PickListValue> surveyTypePickValues = Utils.getPickListValue('Resource_Project_Scheme_Application__c','Survey_Type__c');
        //技术交流方案类型
        List<Utils.PickListValue> technicalCommunicationTypePickValues = Utils.getPickListValue('Resource_Project_Scheme_Application__c','TechnicalCommunicationType__c');
        //项目技术方案类型
        List<Utils.PickListValue> schemeTypeValues = Utils.getPickListValue('Resource_Project_Scheme_Application__c','Scheme_Type__c');
        //项目提资方案类型
        List<Utils.PickListValue> projectInformationExtractionTypePickValues = Utils.getPickListValue('Resource_Project_Scheme_Application__c','ProjectInformationExtractionType__c');

        map_return.put('surveyTypePick',surveyTypePickValues);//道路踏勘方案类型
        map_return.put('technicalCommunicationTypePick',technicalCommunicationTypePickValues);//技术交流方案类型
        map_return.put('schemeType',schemeTypeValues);//项目技术方案类型
        map_return.put('projectInformationExtractionTypePick',projectInformationExtractionTypePickValues);//项目提资方案类型

        return map_return;

    }

    /**
     * @Descripttion: 保存
     * @Author: Devin
     * @param {parentId} 父Id
     * @param {recordType} 对应记录类型
     * @param {schemetype} 方案类型
     * @return {*}
    */    
    @AuraEnabled
    public static Map<Object,Object> saveData(String parentId,String recordType,String schemetype) {

        Map<Object,Object> map_return = new Map<Object,Object>();

        try {

            //查询记录类型
            List<recordType> recordTypeList = [SELECT Id,DeveloperName ,Sobjecttype  FROM recordType WHERE sobjecttype = 'Resource_Project_Scheme_Application__c'];

            //Map<记录类型名字,记录类型Id>
            Map<String, String> recordMap = new Map<String, String>();
            for (recordType type : recordTypeList) {
                recordMap.put(type.DeveloperName ,type.Id);
            }

            //新建 【资源项目方案申请】
            Resource_Project_Scheme_Application__c rpsa = new Resource_Project_Scheme_Application__c();
           
            //根据父级Id 属于哪个对象  
            if (String.isNotBlank(parentId) && parentId != 'undefined') {
                Id pId = String.valueOf(parentId);
                String sObjName = pId.getSObjectType().getDescribe().getName();  
                system.debug('Object Name is ' + sObjName);

                if (sObjName == 'Resource_Development__c') {
                    rpsa.Resource_Development_Name__c = parentId;//资源开发

                    //自动带入字段的值，对应字段：省份>>省份，城市>>城市，区县>>县区，容量>>容量，期数>>期数
                    Resource_Development__c rd = [SELECT    Id,
                                                            Province__c,//省份
                                                            City__c,//城市
                                                            County__c,//区县
                                                            MW__c,//容量（MW）
                                                            Period__c//期数
                                                        FROM 
                                                            Resource_Development__c
                                                        WHERE 
                                                            Id =: parentId
                                                        ];
    
                    rpsa.Province__c = rd.Province__c;//省份
                    rpsa.City__c = rd.City__c;//城市
                    rpsa.District__c = rd.County__c;//区县
                    rpsa.Capacity__c = Decimal.valueOf(rd.MW__c);//容量
                    rpsa.Period__c = rd.Period__c;//期数
                }

                if (sObjName == 'Account') {
                    rpsa.Project_Group__c = parentId;//客户
                }

            }

            //记录类型
            if (recordMap.containsKey(recordType)) {
                rpsa.recordTypeId = recordMap.get(recordType);
            }

            if (recordType == 'Survey_Application') {
                rpsa.Survey_Type__c = schemetype;//道路踏勘方案类型
            }

            if (recordType == 'ResourceTechnicalExchange') {
                rpsa.TechnicalCommunicationType__c = schemetype;//技术交流方案类型
            }

            if (recordType == 'ResourceScenarioRequest') {
                rpsa.Scheme_Type__c = schemetype;//项目技术方案类型
            }

            if (recordType == 'ResourceDataExtraction') {
                rpsa.ProjectInformationExtractionType__c = schemetype;//项目提资方案类型
            }

            System.debug('psaf---------'+rpsa);

            insert rpsa;
            
            map_return.put('messages','创建成功，请完善表单内容并提交!');
            map_return.put('recordId',rpsa.Id);

        } catch (Exception e) {
            map_return.put('messages','创建失败, 请联系系统管理员! 错误信息:'+e.getMessage());
        }

        return map_return;

    }
}