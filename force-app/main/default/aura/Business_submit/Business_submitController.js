/*
 * @Author: Aug
 * @Date: 2021-09-03 16:29:45
 * @LastEditTime: 2021-10-12 16:16:42
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \mingyang\force-app\main\default\aura\Business_submit\Business_submitController.js
 */
({
    init : function(cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.initApproval");
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
            if(result.approvalRequired != null && result.approvalRequired != '') {
                cmp.set('v.clueComment',result.approvalRequired);
            }
            
            if (result.approvalStatus == '审批中' || result.approvalStatus == '审批通过') {
                cmp.set('v.isButtonActive',true);
            }
        });
        $A.enqueueAction(action);
    },

    doCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
  
    doSave: function(cmp, event, helper) {
        cmp.set("v.isLoading",true);
        var clueCommentValue = cmp.get("v.clueComment");
        console.log('clueCommentValue----'+clueCommentValue);
        if (clueCommentValue != null && clueCommentValue != '' && clueCommentValue != undefined) {
            cmp.find('tipApp').focus();
            helper.showToast("提示", "不符合提报条件, 请完善后再提交审批!", "ERROR");
            return;
        }
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