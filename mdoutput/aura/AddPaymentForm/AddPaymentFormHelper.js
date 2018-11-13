({
    init: function (component) {
        // If a payment attribute has been provided, then use it to set the 
        // default for the contactId attribute.
        var payment = component.get('v.payment');
        if (payment != null) {
            component.set('v.contactId', payment.Contact__c);
        }
    }
})
