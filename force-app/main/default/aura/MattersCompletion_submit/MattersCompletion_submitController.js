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
        var action = cmp.get("c.initApprovalCompletion");
        var comment = cmp.get("v.comment");
        action.setParams(
            {
                "recordId":recordId
            }
        );
        action.setCallback(this,function(response) {
            console.log('response----'+response);
	        // var state = response.getState();
	        let result = response.getReturnValue();
            console.log('result----'+result);
            if(result!=null){
                // cmp.set('v.actualCompletionDate',result.actualCompletionDate);
                if(result.completionDescription != null || result.completionDescription != undefined){
                    cmp.set('v.completionDescription',result.completionDescription);
                }
            }
        });
        $A.enqueueAction(action);
    },

    doCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
  
    doSave: function(cmp, event, helper) {
        cmp.set("v.isLoading",true);
        var actualCompletionDate = cmp.get("v.actualCompletionDate");
        var completionDescription = cmp.get("v.completionDescription");
        console.log('actualCompletionDate----'+actualCompletionDate);
        console.log('completionDescription----'+completionDescription);
        if (actualCompletionDate == null || actualCompletionDate == '' || actualCompletionDate == undefined) {
            cmp.find('tipApp').focus();
            helper.showToast("提示", "请填写实际完成日期后再提交审批!", "ERROR");
            return;
        }
        if (completionDescription == null || completionDescription == '' || completionDescription == undefined) {
            cmp.find('tipApp2').focus();
            helper.showToast("提示", "请填写完成情况说明后再提交审批!", "ERROR");
            return;
        }
        var recordId = cmp.get("v.recordId");
        var comment = cmp.get("v.comment");
        var action = cmp.get("c.completionSubmit");//方法
        action.setParams(
            {
                "recordId":recordId,
                "comment":comment,
                "actualCompletionDate":actualCompletionDate,
                "completionDescription":completionDescription
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