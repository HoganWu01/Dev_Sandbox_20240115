/*
 * @Author: your name
 * @Date: 2021-09-02 15:11:37
 * @LastEditTime: 2021-09-02 20:35:46
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \mingyang\force-app\main\default\aura\clue\clueHelper.js
 */
({
    /**
     * 
   预计）建设计划时间，项目名称，项目容量，所属战区/二级子公司，总经理/首席代表，
   项目所属集团，执行总经理，客户二级公司，线索等级，省份，城市，线索内容，线索信息背景，线索来源，关键联系人姓名 
     */
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