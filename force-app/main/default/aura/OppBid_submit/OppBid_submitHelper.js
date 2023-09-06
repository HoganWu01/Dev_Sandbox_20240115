/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-09-09 15:08:57
 * @LastEditors: Devin
 * @LastEditTime: 2021-09-15 15:13:52
 */
({
    showToast: function(title, messgae,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": messgae,
            "type":type
        });
        toastEvent.fire();
    },
})