({
    askForConfirmation: function (component, event, helper) {
        var params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        component.set('v.showMe', true);
    },

    option1chosen: function (component, event, helper) {
        var callback = component.get('v.callback');
        component.set('v.showMe', false);
        callback(component.get('v.option1result'));
    },

    option2chosen: function (component, event, helper) {
        var callback = component.get('v.callback');
        component.set('v.showMe', false);
        callback(component.get('v.option2result'));
    },

})
