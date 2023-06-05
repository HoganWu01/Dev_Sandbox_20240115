/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-12-28 15:47:50
 * @LastEditors: Devin
 * @LastEditTime: 2021-12-29 12:15:56
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
    }
})