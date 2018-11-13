@istest
public with sharing class ContactPaymentsManagerController_test {

    @testSetup
    static void testSetup() {
        // Set up infrastructure
        // Two Projects and two Contacts
        // contact1 has two payents.  contact2 has zero payments.
        Project__c project1 = new Project__c(Name = 'Project1'),
                   project2 = new Project__c(Name = 'Project2');
        insert new Project__c[] {project1, project2};
        Contact contact1 = new Contact(LastName = 'Contact1'),
                contact2 = new Contact(LastName = 'Contact2');
        insert new Contact[] {contact1, contact2};
        Date td = System.today();
        Payment__c pmt_P1C1 = new Payment__c(AmountPaid__c=1, DatePaid__c=td.addDays(-1), Project__c=project1.Id, Contact__c=contact1.Id),
                pmt_P2C1 = new Payment__c(AmountPaid__c=3, DatePaid__c=td.addDays(-3), Project__c=project2.Id, Contact__c=contact1.Id);
        insert new Payment__c[] {pmt_P1C1, pmt_P2C1};
    }

    @istest
    public static void getContactsWithPayments_test() {
        Test.startTest();
        Contact[] contactsResult = ContactsPaymentsManagerController.getContactsWithPayments();
        Test.stopTest();

        system.assertEquals(1, contactsResult.size());
        system.assertEquals('Contact1', contactsResult[0].Name);
        system.assertEquals(2, contactsResult[0].Payments__r.size());

    }

    @istest
    public static void deletePayment_test() {
        Payment__c payment1 = [SELECT Id FROM Payment__c LIMIT 1];

        Test.startTest();
        ContactsPaymentsManagerController.deletePayment(payment1.Id);
        Test.stopTest();
        
        Integer numberOfPayments = [SELECT count() FROM Payment__c];
        system.assertEquals(1, numberOfPayments);

    }
}
