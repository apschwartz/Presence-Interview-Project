({
    init: function (component, event, helper) {
        helper.init(component);
    },

    setShowMe: function (component, event, helper) {
        var params = event.getParam('arguments');
        component.set('v.showMe', params.showMe);
        // Reinitialize component if it's being shown.
        if (params.showMe) {
            helper.init(component);
        }
    },

    handleCancel: function (component, event, helper) {
        component.set('v.showMe', false);
    },

    saveComplete: function (component, event, helper) {
        var saveResult = event.getParams().response;
        var paymentUpdate = component.getEvent("paymentChangeEvent");
        paymentUpdate.setParams({ "paymentId": saveResult.Id });
        paymentUpdate.fire();

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Saved",
            "message": "Payment Saved"
        });
        toastEvent.fire();

        component.set("v.showMe", false);

    },

    errors: function (component, event, helper) {
        var statusVal = event.getParam("error");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error!",
            "message": statusVal.message
        });
        toastEvent.fire();
    },

})
