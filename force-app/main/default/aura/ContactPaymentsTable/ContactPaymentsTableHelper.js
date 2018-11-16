({
    doToast: function (message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Delete Result",
            "message": message
        });
        toastEvent.fire();
    },

    // This should become a static resource function.  
    doApexCall: function (action) {
        return new Promise(function (resolve, reject) {
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (state === "ERROR") {
                    reject(response.getError());
                 }
            });
            $A.enqueueAction(action);
        });
    },

    deleteRecord: function (component, paymentId, helper) {
        var action = component.get("c.deletePayment");
        action.setParams({ paymentId: paymentId });
        this.doApexCall(action)
            .then($A.getCallback(function (result) {
                helper.doToast('Payment Deleted');
            })).catch($A.getCallback(function (errors) {
                helper.doToast('Payment Delete failed:' + errors[0].pageErrors[0].message);
            })).then($A.getCallback(function (result) {
                // always executed after Then or Catch above.
                var paymentUpdate = component.getEvent("paymentChangeEvent");
                paymentUpdate.fire();
            }));
    }

})
