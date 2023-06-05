/*
 * @Author: Conner
 * @Date: 2021-09-14 17:33:23
 * @LastEditors: Conner
 * @LastEditTime: 2021-11-24 11:30:16
 * @Descripttion: 
 */
({
    closeQA : function(component, event, helper) {
		$A.get('e.force:refreshView').fire();
		$A.get("e.force:closeQuickAction").fire();
	}
})