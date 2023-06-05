/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-10-08 14:52:29
 * @LastEditors: Devin
 * @LastEditTime: 2021-10-29 09:48:18
 */
({
    init : function(cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.initAccount");
        action.setParams(
            {
                "recordId":recordId
            }
        );
        action.setCallback(this,function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
            var retrunResult = "" ;

            if(result){
                for (let i = 0; i < result.length; i++) {
                    console.log("result[i]===" + result[i]);
                    if(i==result.length-1){
                        retrunResult += result[i];
                    }else{
                        retrunResult += result[i]+" , ";
                    }
                
                }
                if (result.length>0) {
                    cmp.set('v.clueComment',"请填写必填字段： "+retrunResult);
                    cmp.set('v.isButtonActive',true);
                    cmp.set('v.isShowTip',true);
                }
            }
            
        });
        $A.enqueueAction(action);
    },

    doCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
  
    doSave: function(cmp, event, helper) {
  
        var recordId = cmp.get("v.recordId");
        var approveComment = cmp.get("v.approveComment");
        console.log('approveComment----'+approveComment);
        var action = cmp.get("c.accountApproval");
        action.setParams(
            {
                "recordId":recordId,
                "approveComment":approveComment
            }
        );
        action.setCallback(this,function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
            console.log('state----'+state);

            if (state == "SUCCESS") {

                console.log('成功了');

                if (result.type == 'S') {
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