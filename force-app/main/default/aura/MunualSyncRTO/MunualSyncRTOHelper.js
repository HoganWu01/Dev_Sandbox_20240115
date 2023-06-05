/*
 * @Author: your name
 * @Date: 2022-01-12 18:05:38
 * @LastEditTime: 2022-01-12 18:56:30
 * @LastEditors: your name
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: \MINGYANG\force-app\main\default\aura\MunualSyncRTO\MunualSyncRTOHelper.js
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
})