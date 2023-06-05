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
})