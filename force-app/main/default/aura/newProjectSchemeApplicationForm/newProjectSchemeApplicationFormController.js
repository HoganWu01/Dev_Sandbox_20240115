/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-27 09:36:15
 * @LastEditors: Devin
 * @LastEditTime: 2021-10-21 15:52:46
 */
({
    init : function(component, event, helper) {
        var action = component.get("c.getSchemetype");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
	        console.log({state,result});
	        if (state == "SUCCESS") {
                component.set("v.schemetypeOptions", result.schemetypePick);
                component.set("v.roadPickOptions", result.roadPick);
                component.set("v.technicalexchangePickOptions", result.technicalexchangePick);
                component.set("v.projectfundingPickOptions", result.projectfundingPick);
	        } 
	    });
        $A.enqueueAction(action);

        //获取父级记录Id
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
        // component.set("v.parentId", addressableContext.attributes.recordId);

        component.set("v.parentId", component.get("v.pageReference").state.c__pId);
    },

    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    saveRecord : function(component, event, helper) {

        let parentId = component.get("v.parentId");
        let recordType = component.get("v.selectedValue");
        let optionValue = component.get("v.optionValue");

        console.log('recordType = '+recordType);
        console.log('optionValue = '+optionValue);

        if (recordType == undefined || optionValue == undefined) {
            helper.showToast("提示",'请填写完信息!', "ERROR");
            return;
        }

        var action = component.get("c.saveData");
        action.setParams({
	        'parentId':parentId,
	        'recordType':recordType,
	        'schemetype':optionValue
	    });
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
	        console.log({state,result});
	        if (state == "SUCCESS") {
                if (result.recordId != undefined) {
                    //提示信息
                    helper.showToast("提示", result.messages, "SUCCESS");
                    //导航页面
                    helper.navigateToURL("/lightning/r/Account/" + result.recordId + "/view");
                } else {
                    helper.showToast("提示",result.messages, "ERROR");
                }
	        } 
	    });
        $A.enqueueAction(action);

    },

    onGroup: function(component, event) {
        var selected = event.getSource().get("v.text");
        component.set("v.selectedValue", selected);

        var selectOptions;

        if (selected == "Schemetype") {
            selectOptions = component.get("v.schemetypeOptions");
        } else if(selected == "Roadsurvey") {
            selectOptions = component.get("v.roadPickOptions");
        } else if(selected == "Technicalexchange") {
            selectOptions = component.get("v.technicalexchangePickOptions");
        } else if(selected == "Projectfunding") {
            selectOptions = component.get("v.projectfundingPickOptions");
        }

        //默认取第一个指
        component.set("v.optionValue", selectOptions[0].FieldValue);

        component.set("v.options", selectOptions);
    },

    onChange: function (component) {
        var option = component.find('select').get('v.value');
        console.log('option------'+option);
        component.set("v.optionValue", option);
    },

    handleCancel: function(component, event, helper) {
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
    }
   
})