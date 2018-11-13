({
    getContactsWithPayments: function (component) {
        var action = component.get('c.getContactsWithPayments');
        // Set up the callback
        action.setCallback(this, function (actionResult) {
            var contacts = actionResult.getReturnValue();
            
            // Flatten contact.Project__r.Name to contact.ProjectName__f
            contacts.forEach(function(c){
                c.Payments__r.forEach(function(p) {
                    p.ProjectName__f = p.Project__r.Name;
                });
              });

            component.set('v.contacts', contacts);
        });
        $A.enqueueAction(action);
    }
})
