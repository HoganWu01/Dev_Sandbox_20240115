/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-11-02 09:44:45
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-23 14:45:19
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
	        console.log('result----'+result);
	        if (state == "SUCCESS") {
                component.set("v.companyRecordTypeList", result.recordType);
	        } 
	    });
        $A.enqueueAction(action);

    },
    
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    //记录类型发生改变
    onGroup: function(component, event) {
        var selected = event.getSource().get("v.text");
        component.set("v.selectedValue", selected);
    },

    //下一步
    saveRecord: function(component, event,helper) {
        console.log('记录类型Id---'+component.get("v.selectedValue"));

        if (component.get("v.selectedValue") == undefined) {
            //提示信息
            helper.showToast("提示", '请填写记录类型信息!', "ERROR");
            return;
        }
        var action = component.get("c.doSave");
        action.setParams({
	        'parentId':component.get("v.pageReference").state.c__pId,
	        'recordTypeId':component.get("v.selectedValue")
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
                    helper.navigateToURL("/lightning/r/CompanyRegisterApplication__c/" + result.recordId + "/view");
                } else {
                    //提示信息
                    helper.showToast("提示", result.Messages, "ERROR");
                    window.history.back();
                }
	        } 
	    });
        $A.enqueueAction(action);
    },
    
    //取消
    handleCancel: function(component, event, helper) {
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
    }

})