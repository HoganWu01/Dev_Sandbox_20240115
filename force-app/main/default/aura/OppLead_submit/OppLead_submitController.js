/*
 * @Author: Hogan
 * @Date: 2022-12-05 14:29:45
 * @LastEditTime: 2022-12-05 14:29:45
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \mingyang\force-app\main\default\aura\OppLead_submit\OppLead_submit.js
 */
({
    init : function(cmp, event, helper) {
    },

    doCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
  
    doSave: function(cmp, event, helper) {
        cmp.set("v.isLoading",true);
        var recordId = cmp.get("v.recordId");
        var comment = cmp.get("v.comment");
        var action = cmp.get("c.businessSubmit");//方法
        action.setParams(
            {
                "recordId":recordId,
                "comment":comment
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