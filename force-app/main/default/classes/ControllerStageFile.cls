/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-17 10:16:37
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-09 08:59:11
 */
public without sharing class ControllerStageFile {
    
    public ControllerStageFile() {}

    @AuraEnabled
    public static Map<Object,Object> doInit(String recordId) {

        Map<Object,Object> map_return = new Map<Object,Object>();
        
        List<StageFile__c> sfList = new List<StageFile__c>();
        sfList = [SELECT documentId__c,Type__c,DocumenName__c,DocumenLink__c FROM StageFile__c WHERE ResourceId__c =: recordId];

        //《资源项目入库申请报告》
        List<SFVO> applicationList = new List<SFVO>();
        //《风/光资源项目风险排查报告》
        List<SFVO> riskreportList = new List<SFVO>();
        //《底图》
        List<SFVO> basemapList = new List<SFVO>();
        //《项目规划方案》
        List<SFVO> projectPlanningScenariosList = new List<SFVO>();
        //《资源开发协议》
        List<SFVO> resourceDevelopmentProtocolsList = new List<SFVO>();
        //前期批复文件或支持意见
        List<SFVO> preSupportOpinionList = new List<SFVO>();
        //《项目预可研编制报告》
        List<SFVO> prefeasibilitystudyList = new List<SFVO>();
        //《项目竞配方案》
        List<SFVO> matchSchemeList = new List<SFVO>();
        //《纳归批复文件》
        List<SFVO> generalApprovalDocumentsList = new List<SFVO>();
        //《政府所需编制报告》documenId
        List<SFVO> governmentRequiredReportList = new List<SFVO>();
        //《项目正式可研报告》
        List<SFVO> feasibilitystudyList = new List<SFVO>();
        //《核准批复文件》
        List<SFVO> approvalApprovalDocumentsList = new List<SFVO>();
        //政府批文
        List<SFVO> governmentApprovalList = new List<SFVO>();
        //《开工许可证》
        List<SFVO> obtainWorkPermitList = new List<SFVO>();
        //省级/地市资源政策文件
        List<SFVO> policydocumentList = new List<SFVO>();
        //业绩文件
        List<SFVO> achievementList = new List<SFVO>();
        //项目指标申报
        List<SFVO> indicatordeclarationList = new List<SFVO>();
        //土地租赁协议
        List<SFVO> LandLeaseAgreementList = new List<SFVO>();
        //项目经济性评估
        List<SFVO> ProjectEconomyAssessmentList = new List<SFVO>();
        //规划选址报告
        List<SFVO> SiteSelectionList = new List<SFVO>();
        //土地预审
        List<SFVO> PreTrialLandList = new List<SFVO>();
        //取得[压矿]批复文件
        List<SFVO> PressOreList = new List<SFVO>();
        //取得[地灾]批复文件
        List<SFVO> DisasterList = new List<SFVO>();
        //取得[环评]批复文件
        List<SFVO> EIAList = new List<SFVO>();
        //取得[地震]批复文件
        List<SFVO> EarthquakeList = new List<SFVO>();
        //取得[洪评]批复文件
        List<SFVO> FloodControlEvaluationList = new List<SFVO>();
        //取得[节能]批复文件
        List<SFVO> EnergyConservationList = new List<SFVO>();
        //取得[社稳]批复文件
        List<SFVO> SocialStabilityList = new List<SFVO>();
        //取得[安评]批复文件
        List<SFVO> SecurityAssessmentList = new List<SFVO>();
        //取得[林地（草勘）]批复文件
        List<SFVO> WoodlandSurveyList = new List<SFVO>();
        //取得[军事]批复文件
        List<SFVO> MilitaryList = new List<SFVO>();
        //取得[文物]批复文件
        List<SFVO> CulturalRelicList = new List<SFVO>();
        //取得[接入系统]批复文件 
        List<SFVO> AccessToSystemList = new List<SFVO>();

        for (StageFile__c sf : sfList) {
            SFVO vo = new SFVO();
            vo.type = sf.Type__c;
            vo.documentId = sf.DocumentId__c;
            vo.documenLink = sf.DocumenLink__c;
            vo.documentName = sf.DocumenName__c;

            //《资源项目入库申请报告》
            if (sf.Type__c == 'Application') {
                applicationList.add(vo);
            }
            //《风/光资源项目风险排查报告》
            if (sf.Type__c == 'Riskreport') {
                riskreportList.add(vo);
            }
            //《底图》
            if (sf.Type__c == 'Basemap') {
                basemapList.add(vo);
            }
            //《项目规划方案》
            if (sf.Type__c == 'ProjectPlanningScenarios') {
                projectPlanningScenariosList.add(vo);
            }
            //《资源开发协议》
            if (sf.Type__c == 'ResourceDevelopmentProtocols') {
                resourceDevelopmentProtocolsList.add(vo);
            }
            //前期批复文件或支持意见
            if (sf.Type__c == 'PreSupportOpinion') {
                preSupportOpinionList.add(vo);
            }
            //《项目预可研编制报告》
            if (sf.Type__c == 'Prefeasibilitystudy') {
                prefeasibilitystudyList.add(vo);
            }
            //《项目竞配方案》
            if (sf.Type__c == 'MatchScheme') {
                matchSchemeList.add(vo);
            }
            //《纳归批复文件》
            if (sf.Type__c == 'GeneralApprovalDocuments') {
                generalApprovalDocumentsList.add(vo);
            }
            //《政府所需编制报告》
            if (sf.Type__c == 'GovernmentRequiredReport') {
                governmentRequiredReportList.add(vo);
            }
            //《项目正式可研报告》
            if (sf.Type__c == 'Feasibilitystudy') {
                feasibilitystudyList.add(vo);
            }
            //《核准批复文件》
            if (sf.Type__c == 'ApprovalApprovalDocuments') {
                approvalApprovalDocumentsList.add(vo);
            }
            //政府批文
            if (sf.Type__c == 'GovernmentApproval') {
                governmentApprovalList.add(vo);
            }
            //《开工许可证》
            if (sf.Type__c == 'ObtainWorkPermit') {
                obtainWorkPermitList.add(vo);
            }
            //省级/地市资源政策文件
            if (sf.Type__c == 'Policydocument') {
                policydocumentList.add(vo);
            }
            //业绩文件
            if (sf.Type__c == 'Achievement') {
                achievementList.add(vo);
            }
            //项目指标申报
            if (sf.Type__c == 'Indicatordeclaration') {
                indicatordeclarationList.add(vo);
            }
            //土地租赁协议
            if (sf.Type__c == 'LandLeaseAgreement') {
                LandLeaseAgreementList.add(vo);
            }
            //项目经济性评估
            if (sf.Type__c == 'ProjectEconomyAssessment') {
                ProjectEconomyAssessmentList.add(vo);
            }
            //规划选址报告
            if (sf.Type__c == 'SiteSelection') {
                SiteSelectionList.add(vo);
            }
            //土地预审
            if (sf.Type__c == 'PreTrialLand') {
                PreTrialLandList.add(vo);
            }
            //取得[压矿]批复文件
            if (sf.Type__c == 'PressOre') {
                PressOreList.add(vo);
            }
            //取得[地灾]批复文件
            if (sf.Type__c == 'Disaster') {
                DisasterList.add(vo);
            }
            //取得[环评]批复文件
            if (sf.Type__c == 'EIA') {
                EIAList.add(vo);
            }
            //取得[地震]批复文件
            if (sf.Type__c == 'Earthquake') {
                EarthquakeList.add(vo);
            }
            //取得[洪评]批复文件
            if (sf.Type__c == 'FloodControlEvaluation') {
                FloodControlEvaluationList.add(vo);
            }
            //取得[节能]批复文件
            if (sf.Type__c == 'EnergyConservation') {
                EnergyConservationList.add(vo);
            }
            //取得[社稳]批复文件
            if (sf.Type__c == 'SocialStability') {
                SocialStabilityList.add(vo);
            }
            //取得[安评]批复文件
            if (sf.Type__c == 'SecurityAssessment') {
                SecurityAssessmentList.add(vo);
            }
            //取得[林地（草勘）]批复文件
            if (sf.Type__c == 'WoodlandSurvey') {
                WoodlandSurveyList.add(vo);
            }
            //取得[军事]批复文件
            if (sf.Type__c == 'Military') {
                MilitaryList.add(vo);
            }
            //取得[文物]批复文件
            if (sf.Type__c == 'CulturalRelic') {
                CulturalRelicList.add(vo);
            }
            //取得[接入系统]批复文件
            if (sf.Type__c == 'AccessToSystem') {
                AccessToSystemList.add(vo);
            }

        }

        map_return.put('Applications',applicationList);
        map_return.put('Riskreport',riskreportList);
        map_return.put('Basemap',basemapList);
        map_return.put('ProjectPlanningScenarios',projectPlanningScenariosList);
        map_return.put('ResourceDevelopmentProtocols',resourceDevelopmentProtocolsList);
        map_return.put('PreSupportOpinion',preSupportOpinionList);
        map_return.put('Prefeasibilitystudy',prefeasibilitystudyList);
        map_return.put('MatchScheme',matchSchemeList);
        map_return.put('GeneralApprovalDocuments',generalApprovalDocumentsList);
        map_return.put('GovernmentRequiredReport',governmentRequiredReportList);
        map_return.put('Feasibilitystudy',feasibilitystudyList);
        map_return.put('ApprovalApprovalDocuments',approvalApprovalDocumentsList);
        map_return.put('GovernmentApproval',governmentApprovalList);
        map_return.put('ObtainWorkPermit',obtainWorkPermitList);
        map_return.put('Policydocument',policydocumentList);
        map_return.put('Achievement',achievementList);
        map_return.put('Indicatordeclaration',indicatordeclarationList);
        map_return.put('LandLeaseAgreement',LandLeaseAgreementList);
        map_return.put('ProjectEconomyAssessment',ProjectEconomyAssessmentList);
        map_return.put('SiteSelection',SiteSelectionList);
        map_return.put('PreTrialLand',PreTrialLandList);
        map_return.put('PressOre',PressOreList);
        map_return.put('Disaster',DisasterList);
        map_return.put('EIA',EIAList);
        map_return.put('Earthquake',EarthquakeList);
        map_return.put('FloodControlEvaluation',FloodControlEvaluationList);
        map_return.put('EnergyConservation',EnergyConservationList);
        map_return.put('SocialStability',SocialStabilityList);
        map_return.put('SecurityAssessment',SecurityAssessmentList);
        map_return.put('WoodlandSurvey',WoodlandSurveyList);
        map_return.put('Military',MilitaryList);
        map_return.put('CulturalRelic',CulturalRelicList);
        map_return.put('AccessToSystem',AccessToSystemList);
        
        return map_return;
    }


    /**
     * @Descripttion: 生成【阶段文件】中间表信息
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static void saveSF(String documentIds, String documentNames,String radioValue, String recordId) {

        System.debug('documentIds----'+documentIds);
        //文件Id
        List<String> documentIdList = documentIds.split(',');
        //文件Name
        List<String> documentNameList = documentNames.split(',');

        List<StageFile__c> sfList = new List<StageFile__c>();

        Integer i = 0;
        for (String docId : documentIdList) {
            //生成【阶段文件】中间表信息
            StageFile__c sf = new StageFile__c();
            sf.DocumentId__c = docId;//文件Id
            sf.DocumenLink__c = '/lightning/r/ContentDocument/'+docId+'/view';//文件链接
            sf.DocumenName__c = documentNameList[i];//文件名
            sf.Type__c = radioValue;
            sf.ResourceId__c = recordId;
            sfList.add(sf);
            i++;
        }

        //【资源开发】 上的阶段文件 打勾
        Resource_Development__c updateType = new Resource_Development__c();
        updateType.Id = recordId;
        //《资源项目入库申请报告》   
        if (radioValue == 'Application') {
            updateType.Application__c = true;
        }
        //《风/光资源项目风险排查报告》
        if (radioValue == 'Riskreport') {
            updateType.Riskreport__c = true;
        }
        //《底图》
        if (radioValue == 'Basemap') {
            updateType.Basemap__c = true;
        }
        //《项目规划方案》
        if (radioValue == 'ProjectPlanningScenarios') {
            updateType.ProjectPlanningScenarios__c = true;
        }
        //《资源开发协议》
        if (radioValue == 'ResourceDevelopmentProtocols') {
            updateType.ResourceDevelopmentProtocols__c = true;
        }
        //前期批复文件或支持意见
        if (radioValue == 'PreSupportOpinion') {
            updateType.PreSupportOpinion__c = true;
        }
        //《项目预可研编制报告》
        if (radioValue == 'Prefeasibilitystudy') {
            updateType.Prefeasibilitystudy__c = true;
        }
        //《项目竞配方案》
        if (radioValue == 'MatchScheme') {
            updateType.MatchScheme__c = true;
        }
        //《纳归批复文件》
        if (radioValue == 'GeneralApprovalDocuments') {
            updateType.GeneralApprovalDocuments__c = true;
        }
        //《政府所需编制报告》
        if (radioValue == 'GovernmentRequiredReport') {
            updateType.GovernmentRequiredReport__c = true;
        }
        //《项目正式可研报告》
        if (radioValue == 'Feasibilitystudy') {
            updateType.Feasibilitystudy__c = true;
        }
        //《核准批复文件》
        if (radioValue == 'ApprovalApprovalDocuments') {
            updateType.ApprovalApprovalDocuments__c = true;
        }
        //政府批文
        if (radioValue == 'GovernmentApproval') {
            updateType.GovernmentApproval__c = true;
        }
        //《开工许可证》
        if (radioValue == 'ObtainWorkPermit') {
            updateType.ObtainWorkPermit__c = true;
        }
        //省级/地市资源政策文件
        if (radioValue == 'Policydocument') {
            updateType.Policydocument__c = true;
        }
        //业绩文件
        if (radioValue == 'Achievement') {
            updateType.Achievement__c = true;
        }
        //项目指标申报
        if (radioValue == 'Indicatordeclaration') {
            updateType.Indicatordeclaration__c = true;
        }
        //土地租赁协议
        if (radioValue == 'LandLeaseAgreement') {
            updateType.LandLeaseAgreement__c = true;
        }
        //项目经济性评估
        if (radioValue == 'ProjectEconomicAssessment') {
            updateType.ProjectEconomicAssessment__c = true;
        }
        //规划选址报告
        if (radioValue == 'SiteSelection') {
            updateType.SiteSelection__c = true;
        }
        //土地预审
        if (radioValue == 'PreTrialLand') {
            updateType.PreTrialLand__c = true;
        }
        //取得[压矿]批复文件
        if (radioValue == 'PressOre') {
            updateType.PressOre__c = true;
        }
        //取得[地灾]批复文件
        if (radioValue == 'Disaster') {
            updateType.Disaster__c = true;
        }
        //取得[环评]批复文件
        if (radioValue == 'EIA') {
            updateType.EIA__c = true;
        }
        //取得[地震]批复文件
        if (radioValue == 'Earthquake') {
            updateType.Earthquake__c = true;
        }
        //取得[洪评]批复文件
        if (radioValue == 'FloodControlEvaluation') {
            updateType.FloodControlEvaluation__c = true;
        }
        //取得[节能]批复文件
        if (radioValue == 'EnergyConservation') {
            updateType.EnergyConservation__c = true;
        }
        //取得[社稳]批复文件
        if (radioValue == 'SocialStability') {
            updateType.SocialStability__c = true;
        }
        //取得[安评]批复文件
        if (radioValue == 'SecurityAssessment') {
            updateType.SecurityAssessment__c = true;
        }
        //取得[林地（草勘）]批复文件
        if (radioValue == 'WoodlandSurvey') {
            updateType.WoodlandSurvey__c = true;
        }
        //取得[军事]批复文件
        if (radioValue == 'Military') {
            updateType.Military__c = true;
        }
        //取得[文物]批复文件
        if (radioValue == 'CulturalRelic') {
            updateType.CulturalRelic__c = true;
        }
        //取得[接入系统]批复文件 
        if (radioValue == 'AccessToSystem') {
            updateType.AccessToSystem__c = true;
        }

        insert sfList;

        update updateType;
    }

    /**
     * @Descripttion: 删除附件信息
     * @Author: Devin
     * @param {*}
     * @return {*}
     */
    @AuraEnabled
    public static Map<Object,Object> deleteDocument(String documentId) {

        System.debug('documentId---------'+documentId);

        Map<Object,Object> map_return = new Map<Object,Object>();

        try {
            
            //删除附件信息
            ContentDocument deleteContent = [SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument WHERE Id =: documentId];
    
            //删除【阶段文件】表数据
            StageFile__c deleteStageFile = [SELECT Id,ResourceId__c,Type__c FROM StageFile__c WHERE DocumentId__c =: documentId];

            //文件类型 + 资源Id  是否有同一个类型下的文件
            List<StageFile__c> remainderList = new List<StageFile__c>();

            remainderList = [SELECT Id 
                                FROM 
                                    StageFile__c 
                                WHERE 
                                    ResourceId__c =: deleteStageFile.ResourceId__c 
                                AND 
                                    Type__c =: deleteStageFile.Type__c
                                AND 
                                    DocumentId__c !=: documentId
                            ];
            
            if (remainderList.size() == 0) {
                //【资源开发】 上的阶段文件 勾 取消
                Resource_Development__c cancelType = new Resource_Development__c();
                cancelType.Id = deleteStageFile.ResourceId__c;
                //《资源项目入库申请报告》   
                if (deleteStageFile.Type__c == 'Application') {
                    cancelType.Application__c = false;
                }
                //《风/光资源项目风险排查报告》
                if (deleteStageFile.Type__c == 'Riskreport') {
                    cancelType.Riskreport__c = false;
                }
                //《底图》
                if (deleteStageFile.Type__c == 'Basemap') {
                    cancelType.Basemap__c = false;
                }
                //《项目规划方案》
                if (deleteStageFile.Type__c == 'ProjectPlanningScenarios') {
                    cancelType.ProjectPlanningScenarios__c = false;
                }
                //《资源开发协议》
                if (deleteStageFile.Type__c == 'ResourceDevelopmentProtocols') {
                    cancelType.ResourceDevelopmentProtocols__c = false;
                }
                //前期批复文件或支持意见
                if (deleteStageFile.Type__c == 'PreSupportOpinion') {
                    cancelType.PreSupportOpinion__c = false;
                }
                //《项目预可研编制报告》
                if (deleteStageFile.Type__c == 'Prefeasibilitystudy') {
                    cancelType.Prefeasibilitystudy__c = false;
                }
                //《项目竞配方案》
                if (deleteStageFile.Type__c == 'MatchScheme') {
                    cancelType.MatchScheme__c = false;
                }
                //《纳归批复文件》
                if (deleteStageFile.Type__c == 'GeneralApprovalDocuments') {
                    cancelType.GeneralApprovalDocuments__c = false;
                }
                //《政府所需编制报告》
                if (deleteStageFile.Type__c == 'GovernmentRequiredReport') {
                    cancelType.GovernmentRequiredReport__c = false;
                }
                //《项目正式可研报告》
                if (deleteStageFile.Type__c == 'Feasibilitystudy') {
                    cancelType.Feasibilitystudy__c = false;
                }
                //《核准批复文件》
                if (deleteStageFile.Type__c == 'ApprovalApprovalDocuments') {
                    cancelType.ApprovalApprovalDocuments__c = false;
                }
                //政府批文
                if (deleteStageFile.Type__c == 'GovernmentApproval') {
                    cancelType.GovernmentApproval__c = false;
                }
                //《开工许可证》
                if (deleteStageFile.Type__c == 'ObtainWorkPermit') {
                    cancelType.ObtainWorkPermit__c = false;
                }
                //省级/地市资源政策文件
                if (deleteStageFile.Type__c == 'Policydocument') {
                    cancelType.Policydocument__c = false;
                }
                //业绩文件
                if (deleteStageFile.Type__c == 'Achievement') {
                    cancelType.Achievement__c = false;
                }
                //项目指标申报
                if (deleteStageFile.Type__c == 'Indicatordeclaration') {
                    cancelType.Indicatordeclaration__c = false;
                }
                //土地租赁协议
                if (deleteStageFile.Type__c == 'LandLeaseAgreement') {
                    cancelType.LandLeaseAgreement__c = false;
                }
                //项目经济性评估
                if (deleteStageFile.Type__c == 'ProjectEconomicAssessment') {
                    cancelType.ProjectEconomicAssessment__c = false;
                }
                //规划选址报告
                if (deleteStageFile.Type__c == 'SiteSelection') {
                    cancelType.SiteSelection__c = false;
                }
                //土地预审
                if (deleteStageFile.Type__c == 'PreTrialLand') {
                    cancelType.PreTrialLand__c = false;
                }
                //取得[压矿]批复文件
                if (deleteStageFile.Type__c == 'PressOre') {
                    cancelType.PressOre__c = false;
                }
                //取得[地灾]批复文件
                if (deleteStageFile.Type__c == 'Disaster') {
                    cancelType.Disaster__c = false;
                }
                //取得[环评]批复文件
                if (deleteStageFile.Type__c == 'EIA') {
                    cancelType.EIA__c = false;
                }
                //取得[地震]批复文件
                if (deleteStageFile.Type__c == 'Earthquake') {
                    cancelType.Earthquake__c = false;
                }
                //取得[洪评]批复文件
                if (deleteStageFile.Type__c == 'FloodControlEvaluation') {
                    cancelType.FloodControlEvaluation__c = false;
                }
                //取得[节能]批复文件
                if (deleteStageFile.Type__c == 'EnergyConservation') {
                    cancelType.EnergyConservation__c = false;
                }
                //取得[社稳]批复文件
                if (deleteStageFile.Type__c == 'SocialStability') {
                    cancelType.SocialStability__c = false;
                }
                //取得[安评]批复文件
                if (deleteStageFile.Type__c == 'SecurityAssessment') {
                    cancelType.SecurityAssessment__c = false;
                }
                //取得[林地（草勘）]批复文件
                if (deleteStageFile.Type__c == 'WoodlandSurvey') {
                    cancelType.WoodlandSurvey__c = false;
                }
                //取得[军事]批复文件
                if (deleteStageFile.Type__c == 'Military') {
                    cancelType.Military__c = false;
                }
                //取得[文物]批复文件
                if (deleteStageFile.Type__c == 'CulturalRelic') {
                    cancelType.CulturalRelic__c = false;
                }
                //取得[接入系统]批复文件
                if (deleteStageFile.Type__c == 'AccessToSystem') {
                    cancelType.AccessToSystem__c = false;
                }

                update cancelType;
            }
    
            delete deleteContent;
            delete deleteStageFile;

            map_return.put('Messages','删除成功!');
            map_return.put('Type','S');
        } catch (Exception e) {
            System.debug('错误信息:'+e.getMessage());
            map_return.put('Messages','删除失败, 请联系系统管理员! 错误信息:'+e.getMessage());
            map_return.put('Type','E');
        }

        return map_return;

    }

    /**
     * @Descripttion: 只删除附件信息
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> deleteOnlyDocument(String documentIds) {

        System.debug('documentIds---------'+documentIds);

        Map<Object,Object> map_return = new Map<Object,Object>();

        try {

            //文件Id
            List<String> documentIdList = documentIds.split(',');
            
            //删除附件信息
            List<ContentDocument> deleteContent = [SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument WHERE Id IN: documentIdList];

            System.debug('deleteContent----'+deleteContent);
    
            delete deleteContent;

            map_return.put('Messages','删除成功!');
            map_return.put('Type','S');
        } catch (Exception e) {
            map_return.put('Messages','删除失败, 请联系系统管理员! 错误信息:'+e.getMessage());
            map_return.put('Type','E');
        }

        return map_return;

    }

    /**
     * @Descripttion: 下载文件
     * @Author: Devin
     * @param {*}
     * @return {*}
     */    
    @AuraEnabled
    public static Map<Object,Object> downloadDocument(String recordId) {

        Map<Object,Object> map_return = new Map<Object,Object>();

        List<StageFile__c> stageFileList = [SELECT Id,DocumentId__c FROM StageFile__c WHERE ResourceId__c =: recordId];

        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        List<SFVO> sfVoList = new List<SFVO>();
        
        for (StageFile__c sf : stageFileList) {
            SFVO vo = new SFVO();
            vo.documenLink = fullFileURL+'/sfc/servlet.shepherd/document/download/'+sf.DocumentId__c+'?operationContext=S1';
            sfVoList.add(vo);
        }

        map_return.put('downloadLink',sfVoList);
        map_return.put('Type','S');

        if (stageFileList == null || stageFileList.size() == 0) {
            map_return.put('Type','E');
            map_return.put('Messages','下载失败, 没有文件可下载!');
        }

        return map_return;
    }

    public class SFVO {
        @AuraEnabled
        public String type{get; set;}
        @AuraEnabled
        public String documentId{get; set;}
        @AuraEnabled
        public String documenLink{get; set;}
        @AuraEnabled
        public String documentName{get; set;}
    }
}