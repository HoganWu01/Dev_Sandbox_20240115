/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-17 10:14:49
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-03 14:27:45
 */
({

    //显示提示信息
    showToast: function(title, messgae,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": messgae,
            "type":type
        });
        toastEvent.fire();
    },

    navigateToURL: function(url) {
    
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
        "url": url
        });
        urlEvent.fire();
    },

    /**
     * @Descripttion: 初始化
     * @Author: Devin
     * @param {*} component
     * @param {*} event
     * @param {*} helper
     * @return {*}
     */    
    init: function(component, event, helper) {
        var action = component.get("c.doInit");
        action.setParams({
            recordId: component.get("v.recordId")
        });

        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            console.log('result----'+result);
            if (state === "SUCCESS") {
                component.set("v.Applications",result.Applications);
                component.set("v.Riskreport",result.Riskreport);
                component.set("v.Basemap",result.Basemap);
                component.set("v.ProjectPlanningScenarios",result.ProjectPlanningScenarios);
                component.set("v.ResourceDevelopmentProtocols",result.ResourceDevelopmentProtocols);
                component.set("v.PreSupportOpinion",result.PreSupportOpinion);
                component.set("v.Prefeasibilitystudy",result.Prefeasibilitystudy);
                component.set("v.MatchScheme",result.MatchScheme);
                component.set("v.GeneralApprovalDocuments",result.GeneralApprovalDocuments);
                component.set("v.GovernmentRequiredReport",result.GovernmentRequiredReport);
                component.set("v.Feasibilitystudy",result.Feasibilitystudy);
                component.set("v.ApprovalApprovalDocuments",result.ApprovalApprovalDocuments);
                component.set("v.GovernmentApproval",result.GovernmentApproval);
                component.set("v.ObtainWorkPermit",result.ObtainWorkPermit);
                component.set("v.Policydocument",result.Policydocument);
                component.set("v.Achievement",result.Achievement);
                component.set("v.Indicatordeclaration",result.Indicatordeclaration);
                component.set("v.LandLeaseAgreement",result.LandLeaseAgreement);
                component.set("v.ProjectEconomyAssessment",result.ProjectEconomyAssessment);
                component.set("v.SiteSelection",result.SiteSelection);
                component.set("v.PreTrialLand",result.PreTrialLand);
                component.set("v.PressOre",result.PressOre);
                component.set("v.Disaster",result.Disaster);
                component.set("v.EIA",result.EIA);
                component.set("v.Earthquake",result.Earthquake);
                component.set("v.FloodControlEvaluation",result.FloodControlEvaluation);
                component.set("v.EnergyConservation",result.EnergyConservation);
                component.set("v.SocialStability",result.SocialStability);
                component.set("v.SecurityAssessment",result.SecurityAssessment);
                component.set("v.WoodlandSurvey",result.WoodlandSurvey);
                component.set("v.Military",result.Military);
                component.set("v.CulturalRelic",result.CulturalRelic);
                component.set("v.AccessToSystem",result.AccessToSystem);
            } 
        })

        $A.enqueueAction(action);
    }
})