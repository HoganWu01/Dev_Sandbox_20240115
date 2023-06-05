/*
 * @Author: irving
 * @Date: 2021-11-03 15:47:41
 * @LastEditTime: 2021-11-03 16:27:00
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 */
({
    doInit : function(component, event, helper) {
        
    },

    ProjectSAP : function(component, event, helper) {
        //component.set("v.isLoading",true);
        var recordId = component.get("v.recordId");
        console.log('recordId---'+recordId);
        var info = {
            recordId:recordId
        }
        var action = component.get("c.SAPProjectAdd");
        action.setParams(info);
        action.setCallback(this,function(response){
            var status = response.getState();
           // var returnMessage = response.getReturnValue();
            component.set("v.isLoading",false);
            console.log('调用完成');
            
            // if(status=="SUCCESS")
            // {
            //    console.log('调用成功');
            //    let returnObj = JSON.parse(returnMessage);
            //    console.log('returnObj.message'+returnObj.message);
            //    if(returnObj.type=='S'){
            //     alert('同步成功');
            //     }else{
            //         alert(returnObj.message);
            //     }
            // }
            // else
            // {
            //    alert('同步失败');
            // }
            
        });
        $A.enqueueAction(action); 
    },
})