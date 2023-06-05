/*
 * @Descripttion: 【方案申请】
 * @Author: Devin
 * @Date: 2021-09-27 14:05:04
 * @LastEditors: Devin
 * @LastEditTime: 2021-10-21 11:36:28
 */
public without sharing class Controller_PSAF {

    /**
     * @Descripttion: 获取方案类型
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> getSchemetype() {

        Map<Object,Object> map_return = new Map<Object,Object>();

        //方案类型
        List<Utils.PickListValue> schemetypePickValues = Utils.getPickListValue('Project_Scheme_Application_Form__c','Schemetype__c');
        //设备运输道路踏勘方案类型
        List<Utils.PickListValue> roadPickValues = Utils.getPickListValue('Project_Scheme_Application_Form__c','RoadSurveyType__c');
        //技术交流类型
        List<Utils.PickListValue> technicalexchangePickValues = Utils.getPickListValue('Project_Scheme_Application_Form__c','Technicalexchange__c');
        //项目提资方案类型
        List<Utils.PickListValue> projectfundingPickValues = Utils.getPickListValue('Project_Scheme_Application_Form__c','Projectfunding__c');

        map_return.put('schemetypePick',schemetypePickValues);//方案类型
        map_return.put('roadPick',roadPickValues);//设备运输道路踏勘方案类型
        map_return.put('technicalexchangePick',technicalexchangePickValues);//技术交流类型
        map_return.put('projectfundingPick',projectfundingPickValues);//项目提资方案类型

        return map_return;

    }

    /**
     * @Descripttion: 
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
            List<recordType> recordTypeList = [SELECT Id,DeveloperName ,Sobjecttype  FROM recordType WHERE sobjecttype = 'Project_Scheme_Application_Form__c'];

            System.debug('recordTypeList---------'+recordTypeList);
            System.debug('recordType---------'+recordType);

            //Map<记录类型名字,记录类型Id>
            Map<String, String> recordMap = new Map<String, String>();
            for (recordType type : recordTypeList) {
                recordMap.put(type.DeveloperName ,type.Id);
            }

            //查询商机的信息
            Opportunity opp = [SELECT   Id,
                                        Salesdepartment__c, //所属大区/二级公司
                                        // Group__c, //项目所属集团
                                        Account.Id,//客户全称
                                        Province__c, //省份
                                        City__c, //城市
                                        County__c, //县区
                                        Wind_Farm_Project_Name__c, //风场项目名
                                        capacity__c, //容量（MW）
                                        Projecttype__c, //项目类型
                                        Periods__c //期数
                                    FROM
                                        Opportunity
                                    WHERE 
                                        Id =: parentId
                                    ];
            

            Project_Scheme_Application_Form__c psaf = new Project_Scheme_Application_Form__c();

            if (opp != null) {
                psaf.ProjectTheater__c  = opp.Salesdepartment__c;//项目所属战区
                psaf.Group__c  = opp.Account.Id;//客户全称
                psaf.Province__c  = opp.Province__c;//省份
                psaf.City__c  = opp.City__c;//城市
                psaf.District__c  = opp.County__c;//县区
                psaf.Windfarmprojectname__c  = opp.Wind_Farm_Project_Name__c;//风场项目名
                psaf.Capacity__c  = opp.capacity__c;//容量
                psaf.Projecttype__c  = opp.Projecttype__c;//项目类型
                psaf.Period__c  = opp.Periods__c;//期数
            }
            //商机
            if (String.isNotBlank(parentId) && parentId != 'undefined') {
                psaf.Oppty__c = parentId;
            }

            //记录类型
            if (recordMap.containsKey(recordType)) {
                psaf.recordTypeId = recordMap.get(recordType);
            }

            if (recordType == 'Schemetype') {
                psaf.Schemetype__c = schemetype;//项目技术方案
            }

            if (recordType == 'Roadsurvey') {
                psaf.RoadSurveyType__c = schemetype;//设备运输道路踏勘
            }

            if (recordType == 'Technicalexchange') {
                psaf.Technicalexchange__c = schemetype;//技术交流
            }

            if (recordType == 'Projectfunding') {
                psaf.Projectfunding__c = schemetype;//项目提资
            }

            System.debug('psaf---------'+psaf);

            insert psaf;
            
            map_return.put('messages','创建成功，请完善表单内容并提交!');
            map_return.put('recordId',psaf.Id);

        } catch (Exception e) {
            map_return.put('messages','创建失败, 请联系系统管理员! 错误信息:'+e.getMessage());
        }

        return map_return;

    }


}