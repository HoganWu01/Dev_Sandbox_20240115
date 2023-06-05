/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-17 10:14:49
 * @LastEditors: Devin
 * @LastEditTime: 2021-11-02 15:48:17
 */
({
    init : function(component, event, helper) {
        helper.init(component, event, helper);
    },

    onGroup: function(component, event) {
        var selected = event.getSource().get("v.text");
        component.set("v.radioValue", selected);
    },

    //上传文件
    handleUploadFinished: function (component, event,helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");

        var documentIds = [];
        var documentNames = [];

        // Get the file name
        uploadedFiles.forEach(file => 
            documentIds.push(file.documentId)
        );

        uploadedFiles.forEach(file => 
            documentNames.push(file.name)
        );

        console.log('documentIds----'+documentIds);
        console.log('documentNames----'+documentNames);

        var radioValue = component.get("v.radioValue");

        if (radioValue == undefined) {
            //提示信息
            helper.showToast("提示",'请先选择阶段类型,再上传文件!', "ERROR");

            //没有选择阶段类型时, 删除已上传的文件
            var action = component.get("c.deleteOnlyDocument");
            action.setParams({
                documentIds: documentIds.toString()
            });

            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                console.log({state,result});
            })

            $A.enqueueAction(action);
            $A.get('e.force:refreshView').fire();
            return;
        }

        var action = component.get("c.saveSF");
        action.setParams({
            documentIds: documentIds.toString(),
            documentNames: documentNames.toString(),
            radioValue: radioValue,
            recordId: component.get("v.recordId")
        });

        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('生成SF成功!');
                //提示信息
                helper.showToast("提示", "上传文件成功!", "SUCCESS");

                //重新请求初始化接口
                helper.init(component, event, helper);

                $A.get('e.force:refreshView').fire();
            } else {
                console.log('生成SF失败!');
            }
        })

        $A.enqueueAction(action);
        
    },

    //删除
    handleClick : function (component, event,helper) {
        var documentId = event.getSource().get("v.value")
        console.log('documentId---'+documentId);

        var action = component.get("c.deleteDocument");
        action.setParams({
            documentId: documentId
        });

        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            console.log('result----'+result);
            if (state === "SUCCESS") {
                if (result.Type == 'S') {
                    //提示信息
                    helper.showToast("提示",result.Messages, "SUCCESS");

                    helper.init(component, event, helper);

                    $A.get('e.force:refreshView').fire();
                } else {
                    //提示信息
                    helper.showToast("提示",result.Messages, "ERROR");
                }
            } else {
                //提示信息
                helper.showToast("提示",'删除失败, 请联系系统管理员!', "ERROR");
            } 
        })

        $A.enqueueAction(action);
    },

    // 下载
    download: function (component, event,helper) {

        var action = component.get("c.downloadDocument");
        action.setParams({
            recordId: component.get("v.recordId")
        });

        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            console.log('result----'+result);
            if (state === "SUCCESS") {
                if (result.Type == 'S') {

                    var downloads = result.downloadLink;
                    for(var i=0;i<downloads.length;i++) {
                        console.log('downloads----'+downloads[i].documenLink);
                        //下载
                        helper.navigateToURL(downloads[i].documenLink);
                        // window.open(downloads[i].documenLink);
                    }
                } else {
                    //提示信息
                    helper.showToast("提示",result.Messages, "ERROR");
                }
            } else {
                //提示信息
                helper.showToast("提示",'删除失败, 请联系系统管理员!', "ERROR");
            } 
        })

        $A.enqueueAction(action);

    },

    backhander: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})