/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-11-01 17:04:02
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-01 17:58:50
 */
({
    init : function(component, event, helper) {
        console.log('初始化-------');
        console.log('父级Id-------'+component.get("v.pageReference").state.c__pId);
        var action = component.get("c.doInit");
        action.setParams({
	        'parentId':component.get("v.pageReference").state.c__pId
	    });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
	        console.log({state,result});
	        if (state == "SUCCESS") {

                if (result.Type == 'S') {
                    //提示信息
                    helper.showToast("提示", result.Messages, "SUCCESS");
                    //导航页面
                    helper.navigateToURL("/lightning/r/ResourceProjectApplication__c/" + result.recordId + "/view");
                } else {
                    //提示信息
                    helper.showToast("提示", result.Messages, "ERROR");
                    window.history.back();
                }
	        } 
	    });
        $A.enqueueAction(action);

    },
    
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
})