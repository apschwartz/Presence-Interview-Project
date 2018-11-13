public with sharing class ContactsPaymentsManagerController {

    /**
     * Return all contacts that have 1 or more payments.
     * For each contact return subselect list of payments made.
     */
    @AuraEnabled
    public static List <Contact> getContactsWithPayments() {
        return ContactSelector.getContactsWithPaymentInfo();
    }

    @AuraEnabled
    public static void deletePayment(Id paymentId){
      Payment__c payment = new Payment__c(Id = paymentId);
      delete payment;
    }

}
