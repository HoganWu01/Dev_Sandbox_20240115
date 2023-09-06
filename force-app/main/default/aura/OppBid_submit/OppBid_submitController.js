/*
 * @Author: Hogan
 * @Date: ###### Tue Jul 25 18:03:47 CST 2023
 * @LastEditTime: ###### Tue Jul 25 18:03:49 CST 2023
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \mingyang\force-app\main\default\aura\OppBid_submit\OppBid_submitController.js
 */
({
    init : function(cmp, event, helper) {
        cmp.set("v.isLoading",true);
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.bidSubmit");
        var comment = cmp.get("v.comment");
        action.setParams(
            {
                "recordId":recordId
               
            }
        );
        action.setCallback(this,function(response) {
            cmp.set("v.isLoading",false);
	        var state = response.getState();
	        let result = response.getReturnValue();
            console.log('result----'+result);
            
            if (state === "SUCCESS") {
                
                if(result.type == 'A'){
                    helper.showToast("提示", "立项申请审批通过后才能申请投标！", "WARNING");
                }else if (result.type == 'S') {
                    helper.showToast("提示", result.messages, "SUCCESS");
                } else {
                    helper.showToast("提示", result.messages, "ERROR");
                }

                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else {
                helper.showToast("提示", result.messages, "ERROR");
            }   

            
        });
        $A.enqueueAction(action);
    }

})