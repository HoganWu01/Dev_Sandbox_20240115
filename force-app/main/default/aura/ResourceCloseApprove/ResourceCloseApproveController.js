({
    doSave : function(cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.resourceCloseApproval");
        action.setParams(
            {
                "recordId":recordId
            }
        );
        action.setCallback(this,function(response) {
	        var state = response.getState();
	        var result = response.getReturnValue();
	        if (state == 'SUCCESS' && result == '提交成功') {
	        	helper.showToast("提示", "提交审批成功!", "SUCCESS");

                $A.get("e.force:closeQuickAction").fire(); 
                $A.get('e.force:refreshView').fire(); 
	        } else {
	        	helper.showToast("提示", "提交审批失败!", "ERROR");
	        	$A.get("e.force:closeQuickAction").fire(); 
	        }
        });
        $A.enqueueAction(action);
    },
    doCancel : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }

})