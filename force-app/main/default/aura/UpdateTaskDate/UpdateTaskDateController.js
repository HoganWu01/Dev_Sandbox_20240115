/*
 * @Author: irving
 * @Date: 2021-10-17 15:27:02
 * @LastEditTime: 2021-10-29 16:11:45
 * @LastEditors: Devin
 * @Description: In User Settings Edit
 * @FilePath: \MINGYANG\force-app\main\default\aura\UpdateTaskDate\UpdateTaskDateController.js
 */
({
    // 初始化
    init : function(component, event, helper) { 
        component.set("v.parentId", component.get("v.pageReference").state.c__pId);
    },

    updateTaskDate : function(component, event, helper) {

        component.set("v.loaded", true);

        let parentId = component.get("v.parentId");  //项目id
        let payDate = component.get("v.payDate");//时间
        let taskId = component.get("v.taskId");//项目任务Id

        console.log('parentId-----'+parentId);
        console.log('taskId-----'+taskId);
        console.log('payDate-----'+payDate);

        if (taskId == undefined || payDate == null) {
            component.set("v.loaded", false);
            helper.showToast("提示",'请填写信息完整!', "ERROR");
            return;
        }

        var action = component.get("c.UpdateTaskDate");
        action.setParams({
	        'parentId':parentId,
            'payDate':payDate,
            'pointTaskId':taskId
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
                    window.history.back();
                } else {
                    helper.showToast("提示",result.messages, "ERROR");
                }
	        } else {
                helper.showToast("提示","系统出错, 请联系系统管理员!", "ERROR");
            }
	    });
        $A.enqueueAction(action);

    },

    handleCancel: function(component, event, helper) {
        window.history.back();
    },

    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    handleComponentEvent : function(component, event, helper) {
        var valueFromChild = event.getParam("selectedRecord");
        console.log('valueFromChild---'+valueFromChild);
        component.set("v.taskId", valueFromChild);
    }
})