/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-12-28 15:47:50
 * @LastEditors: Devin
 * @LastEditTime: 2022-01-25 18:03:56
 */
({
    doRestart : function(cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.restartOpportunity");
        console.log('recordId-------'+recordId);
        action.setParams(
            {
                "recordId":recordId
            }
        );
        action.setCallback(this,function(response) {
	        var state = response.getState();
	        var result = response.getReturnValue();
            console.log('result--------------'+result);
	        if (state == 'SUCCESS') {

                if (result.stateType == 'success') {
                    cmp.set("v.showContent",false);
                } else if (result.stateType == 'warn') {
                    helper.showToast("提示", result.message, 'warning');
                } else {
                    helper.showToast("提示", result.message, "ERROR");
	        	    $A.get("e.force:closeQuickAction").fire(); 
                }
                
	        } else {
	        	helper.showToast("提示", result.message, "ERROR");
	        	$A.get("e.force:closeQuickAction").fire(); 
	        }
        });
        $A.enqueueAction(action);
    },

    doFinish : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
        $A.get('e.force:refreshView').fire(); 
    }
})