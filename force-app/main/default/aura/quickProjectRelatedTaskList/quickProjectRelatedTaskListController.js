({
    init: function (component, event, helper) {
        var pageReference = component.get('v.pageReference');

        // 以Action的方式打开了该Aura控件
        if (!pageReference) {
            var recordId = component.get('v.recordId');
            // console.log('Action Mode，Record ID = ' + recordId);

            pageReference = {
                type: "standard__component",
                attributes: {
                    componentName: "c__quickProjectRelatedTaskList"
                },
                state: {
                    "c__recordId": recordId
                }
            };

            var navigation = component.find("navigationService");

            // new tab
            navigation.generateUrl(pageReference)
                .then(function (url) {
                    window.open(url);
                });

            // 关闭Action Panel
            $A.get("e.force:closeQuickAction").fire();

            return;
        }

        // 以Url的方式打开了该Aura控件
        var recordId = pageReference.state.c__recordId;
        component.set('v.recordId', recordId);
    }
})