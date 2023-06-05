/*
 * @Descripttion: 
 * @Author: Hogan
 * @Date: 2023-04-24 16:00:00
 * @LastEditors: Hogan
 * @LastEditTime: 2023-04-24 16:00:00
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
    }
})