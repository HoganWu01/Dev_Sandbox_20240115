/*
 * @Author: your name
 * @Date: 2021-10-16 18:41:33
 * @LastEditTime: 2021-10-29 09:47:28
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \MINGYANG\force-app\main\default\aura\CreateProjectTask\CreateProjectTaskController.js
 */
({

    // 初始化
    init : function(component, event, helper) { 
       
        var action = component.get("c.selectTaskType");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
                component.set("v.options", result.picklist);
                console.log('options===>>>'+result.picklist[0].FieldValue);
                component.set("v.optionValue",result.picklist[0].FieldValue );
	    });
        $A.enqueueAction(action);

        component.set("v.parentId", component.get("v.pageReference").state.c__pId);
    },

    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    PullTask : function(component, event, helper) {

        component.set("v.loaded", true);

        component.set("v.parentId", component.get("v.pageReference").state.c__pId);

        let parentId = component.get("v.parentId");
        let TaskType = component.get("v.optionValue");

        console.log('parentId-----'+parentId);
        console.log('TaskType-----'+TaskType);

        var action = component.get("c.ImportProjectTask");
        action.setParams({
	        'parentId':parentId,
            'TaskType':TaskType
	    });
	    action.setCallback(this, function(response) {
            component.set("v.loaded", false);
	        var state = response.getState();
	        let result = response.getReturnValue();
	        console.log({state,result});
	        if (state == "SUCCESS") {
                if (result.type=='S') {
                    //提示信息
                    helper.showToast("提示", result.messages, "SUCCESS");

                    $A.get('e.force:refreshView').fire();
                    //返回
                    window.history.back();
                } else {
                    helper.showToast("提示",result.messages, "ERROR");
                }
	        } 
	    });
        $A.enqueueAction(action);

    },

    onchange: function (component) {
        var option = component.find('select').get('v.value');
        console.log('option------'+option);
        component.set("v.optionValue", option);
    },

    handleCancel: function(component, event, helper) {
        window.history.back();
    }
})