({
    // 初始化
    init : function(component, event, helper) {
        var action = component.get("c.doInit");
	    action.setCallback(this, function(response) {
	        var state = response.getState();
	        let result = response.getReturnValue();
	        console.log({state,result});
	        if (state == "SUCCESS") {
                component.set("v.surveyTypePick", result.surveyTypePick);
                component.set("v.technicalCommunicationTypePick", result.technicalCommunicationTypePick);
                component.set("v.schemeType", result.schemeType);
                component.set("v.projectInformationExtractionTypePick", result.projectInformationExtractionTypePick);
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
        console.log('打印'+JSON.stringify(component.get("v.pageReference").state));
        component.set("v.parentId", component.get("v.pageReference").state.c__pId);
    },

    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    //下一步
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

                    $A.get('e.force:refreshView').fire();
                    //导航页面
                    helper.navigateToURL("/lightning/r/Account/" + result.recordId + "/view");
                } else {
                    helper.showToast("提示",result.messages, "ERROR");
                }
	        } 
	    });
        $A.enqueueAction(action);

    },

    //记录类型发生改变
    onGroup: function(component, event) {
        var selected = event.getSource().get("v.text");
        component.set("v.selectedValue", selected);

        var selectOptions;

        if (selected == "Survey_Application") {
            selectOptions = component.get("v.surveyTypePick");//道路踏勘方案类型
        } else if(selected == "ResourceTechnicalExchange") {
            selectOptions = component.get("v.technicalCommunicationTypePick");//技术交流方案类型
        } else if(selected == "ResourceScenarioRequest") {
            selectOptions = component.get("v.schemeType");//项目技术方案类型
        } else if(selected == "ResourceDataExtraction") {
            selectOptions = component.get("v.projectInformationExtractionTypePick");//项目提资方案类型
        }

        //默认取第一个指
        component.set("v.optionValue", selectOptions[0].FieldValue);

        component.set("v.options", selectOptions);
    },

    //下拉选项发生改变
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