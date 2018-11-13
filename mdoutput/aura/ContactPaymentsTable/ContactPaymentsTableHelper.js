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


    deleteRecord: function (component, paymentId) {
        var action = component.get("c.deletePayment");
        action.setParams({ paymentId: paymentId });
        action.setCallback(this, function (actionResult) {
            console.log(JSON.stringify(actionResult.getState()));
            if (actionResult.getState() === 'SUCCESS') {
                this.doToast('Payment Deleted');
            }
            else {
                this.doToast('Payment Delete Failed: ' + actionResult.getError()[0].pageErrors[0].message);
            }
            var paymentUpdate = component.getEvent("paymentChangeEvent");
            paymentUpdate.fire();
        });
        $A.enqueueAction(action);
    }

})
