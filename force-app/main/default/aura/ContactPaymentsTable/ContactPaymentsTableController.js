({
    init: function (cmp, event, helper) {
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];

        cmp.set('v.columns', [
            { label: 'Project Name', fieldName: 'ProjectName__f', type: 'text' },
            { label: 'Amount Paid', fieldName: 'AmountPaid__c', type: 'currency', initialWidth: 150, typeAttributes: { currencyCode: 'USD' } },
            {
                label: 'Date Paid', fieldName: 'DatePaid__c', type: 'date-local', initialWidth: 150, typeAttributes: {
                    month: "2-digit",
                    day: "2-digit",
                    year: "numeric"
                }
            },
            { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                component.set('v.editPayment', row);
                component.find("paymentForm").setShowMe(true);
                break;
            case 'delete':
                component.find('deleteConfirmDialog').askForConfirmation(
                    $A.getCallback(function (result) {
                        if (result == 'yes') {
                            helper.deleteRecord(component, row.Id, helper);
                        }
                    }));
                break;
        }
    }
})
