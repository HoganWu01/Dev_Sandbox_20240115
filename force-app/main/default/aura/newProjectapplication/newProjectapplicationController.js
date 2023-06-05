/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-10-11 14:07:18
 * @LastEditors: Devin
 * @LastEditTime: 2021-10-13 17:39:17
 */
({
    // 初始化
    init : function(component, event, helper) {

        // //获取父级记录Id
        // var pageRef = component.get("v.pageReference");
        // console.log(JSON.stringify(pageRef));
        // var state = pageRef.state; // state holds any query params
        // console.log('state = '+JSON.stringify(state));
        // var base64Context = state.inContextOfRef;
        // console.log('base64Context = '+base64Context);
        // if (base64Context.startsWith("1\.")) {
        //     base64Context = base64Context.substring(2);
        //     console.log('base64Context = '+base64Context);
        // }
        // var addressableContext = JSON.parse(window.atob(base64Context));
        
        component.set("v.parentId", component.get("v.pageReference").state.c__pId);

        var action = component.get("c.doInit");
        action.setParams({
	        'parentId':component.get("v.pageReference").state.c__pId
	    });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
            console.log('result------'+result);
	        if (state == "SUCCESS") {
                component.set("v.opportunityObject", result);
	        } 
	    });
        $A.enqueueAction(action);

        
    },

    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    //下一步
    saveRecord : function(component, event, helper) {

        let parentId = component.get("v.parentId");
        let approvaltime = component.get("v.opportunityObject.approvaltime");
        let estimatedBiddingTime = component.get("v.opportunityObject.estimatedBiddingTime");

        console.log('parentId-----'+parentId);
        console.log('approvaltime-----'+approvaltime);
        console.log('estimatedBiddingTime-----'+estimatedBiddingTime);

        var action = component.get("c.saveData");
        action.setParams({
	        'parentId':parentId,
            'approvaltime':approvaltime,
            'estimatedBiddingTime':estimatedBiddingTime
	    });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
	        console.log({state,result});
	        if (state == "SUCCESS") {
                if (result.recordId != undefined) {
                    //提示信息
                    helper.showToast("提示", result.messages, "SUCCESS");

                    $A.get('e.force:refreshView').fire();
                    //导航页面
                    helper.navigateToURL("/lightning/r/Projectapplication__c/" + result.recordId + "/view");
                } else {
                    helper.showToast("提示",result.messages, "ERROR");
                }
	        } 
	    });
        $A.enqueueAction(action);

    },

    handleCancel: function(component, event, helper) {
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
    }
})