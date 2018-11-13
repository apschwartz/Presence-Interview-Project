({
    doInit: function (component, event, helper) {
        helper.getContactsWithPayments(component);
    },

    handlePaymentChangeEvent: function(component, event, helper) {
//        var message = event.getParam("paymentId");
        helper.getContactsWithPayments(component);
    }
})
