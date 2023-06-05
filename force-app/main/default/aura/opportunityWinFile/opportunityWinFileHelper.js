/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-12-28 11:06:05
 * @LastEditors: Devin
 * @LastEditTime: 2021-12-28 11:50:37
 */
({
    //显示提示信息
    showToast: function(title, messgae,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": messgae,
            "type":type
        });
        toastEvent.fire();
    },

    navigateToURL: function(url) {
    
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
        "url": url
        });
        urlEvent.fire();
    },

    /**
     * @Descripttion: 初始化
     * @Author: Devin
     * @param {*} component
     * @param {*} event
     * @param {*} helper
     * @return {*}
     */    
    init: function(component, event, helper) {
        var action = component.get("c.doInit");
        action.setParams({
            recordId: component.get("v.recordId")
        });

        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            console.log('result----'+result);
            if (state === "SUCCESS") {
                component.set("v.WinFile",result.winFiles);
            } 
        })

        $A.enqueueAction(action);
    }
})