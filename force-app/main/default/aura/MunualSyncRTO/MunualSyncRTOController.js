/*
 * @Author: irving
 * @Date: 2022-01-12 18:05:38
 * @LastEditTime: 2022-01-12 18:56:50
 * @LastEditors: Please set LastEditors
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: \MINGYANG\force-app\main\default\aura\MunualSyncRTO\MunualSyncRTOController.js
 */
({
    doSave : function(cmp, event, helper) {
        var recordId = cmp.get("v.recordId");
        var action = cmp.get("c.SaveProjectPoints");
        action.setParams(
            {
                "recordId":recordId
            }
        );
        action.setCallback(this,function(response) {
	        var state = response.getState();
	        var result = response.getReturnValue();
            
	        if (state == 'SUCCESS' ) {
	        	helper.showToast("提示", "同步成功!", "SUCCESS");

                $A.get("e.force:closeQuickAction").fire(); 
                $A.get('e.force:refreshView').fire(); 
	        } else {
	        	helper.showToast("提示", "同步失败!", "ERROR");
	        	$A.get("e.force:closeQuickAction").fire(); 
	        }
        });
        $A.enqueueAction(action);
    },
    doCancel : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }

})