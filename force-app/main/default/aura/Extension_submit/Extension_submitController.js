/*
 * @Author: Hogan
 * @Date: 2023-04-24 16:00:00
 * @LastEditTime: 2023-04-24 16:00:00
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \mingyang\force-app\main\default\aura\Extension_submit\Extension_submit.js
 */
({
    init : function(cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.initApprovalExtension");
        var comment = cmp.get("v.comment");
        action.setParams(
            {
                "recordId":recordId
            }
        );
        action.setCallback(this,function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
            console.log('result----'+result);
            cmp.set('v.extensionReasonTemp',result.extensionReasonTemp);
            cmp.set('v.planCompletionDateTemp',result.planCompletionDateTemp);
        });
        $A.enqueueAction(action);
    },

    doCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
  
    doSave: function(cmp, event, helper) {
        cmp.set("v.isLoading",true);
        var planCompletionDateTemp = cmp.get("v.planCompletionDateTemp");
        var extensionReasonTemp = cmp.get("v.extensionReasonTemp");
        console.log('planCompletionDateTemp----'+planCompletionDateTemp);
        console.log('extensionReasonTemp----'+extensionReasonTemp);
        if (planCompletionDateTemp == null || planCompletionDateTemp == '' || planCompletionDateTemp == undefined) {
            cmp.find('tipApp').focus();
            helper.showToast("提示", "请填写计划完成日期后再提交审批!", "ERROR");
            return;
        }
        if (extensionReasonTemp == null || extensionReasonTemp == '' || extensionReasonTemp == undefined) {
            cmp.find('tipApp2').focus();
            helper.showToast("提示", "请填写延期原因后再提交审批!", "ERROR");
            return;
        }
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.extensionSubmit");//方法
        action.setParams(
            {
                "recordId":recordId,
                "planCompletionDateTemp":planCompletionDateTemp,
                "extensionReasonTemp":extensionReasonTemp
            }
        );
        action.setCallback(this,function(response) {
            cmp.set("v.isLoading",false);
	        var state = response.getState();
            if (state == "SUCCESS") {
                helper.showToast("提示", "提交审批成功!", "SUCCESS");
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else {
                helper.showToast("提示", "提交审批失败", "ERROR");
            }   
        });
        $A.enqueueAction(action);
    }
})