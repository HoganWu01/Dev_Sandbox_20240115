/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-10-08 14:52:29
 * @LastEditors: Devin
 * @LastEditTime: 2021-10-08 14:54:48
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
    },

    //导航到某页面
    navigateToURL: function(url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})