// Delegate all trigger handling to the associated object's trigger handler
trigger PaymentTrigger on Payment__c (before insert,
                                      before update,
                                      before delete,
                                      after insert,
                                      after update,
                                      after delete,
                                      after undelete) {
    Payments.handleTrigger();
}