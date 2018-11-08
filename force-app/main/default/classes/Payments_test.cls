@istest
private without sharing class Payments_test {

    @istest
    private static void handleTrigger_test() {
        // Set up infrastructure for payment trigger tests.
        // Three base Projects and two base Contacts.
        Project__c project1 = new Project__c(Name = 'Project1'),
                   project2 = new Project__c(Name = 'Project2'),
                   project3 = new Project__c(Name = 'Project3');
        insert new Project__c[] {project1, project2, project3};
        Contact contact1 = new Contact(LastName = 'Contact1'),
                contact2 = new Contact(LastName = 'Contact2'),
                contact3 = new Contact(LastName = 'Contact3');
        insert new Contact[] {contact1, contact2, contact3};

        // Prepare one payment to Projects 1 & 2 from each Contact (not inserted).
        Date td = System.today();
        Payment__c pmt_P1C1 = new Payment__c(AmountPaid__c=1, DatePaid__c=td.addDays(-1), Project__c=project1.Id, Contact__c=contact1.Id);
        Payment__c pmt_P1C2 = new Payment__c(AmountPaid__c=2, DatePaid__c=td.addDays(-2), Project__c=project1.Id, Contact__c=contact2.Id);
        Payment__c pmt_P2C1 = new Payment__c(AmountPaid__c=3, DatePaid__c=td.addDays(-3), Project__c=project2.Id, Contact__c=contact1.Id);
        Payment__c pmt_P2C2 = new Payment__c(AmountPaid__c=4, DatePaid__c=td.addDays(-4), Project__c=project2.Id, Contact__c=contact2.Id);

        Test.startTest();

        // Insert payments, ensure Project__c and Contact rollups are properly populated
        insert new Payment__c[] {pmt_P1C1, pmt_P2C1};
        checkProjects(project1, 1, project2, 3);
        checkContact(contact1, 4, td.addDays(-1));

        // Insert two new payments
        insert new Payment__c[] {pmt_P1C2, pmt_P2C2};
        checkProjects(project1, 3, project2, 7);
        checkContact(contact2, 6, td.addDays(-2));

        // Change payment amounts and dates for Contact1
        pmt_P1C1.AmountPaid__c = 10;
        pmt_P1C1.DatePaid__c = td.addYears(-1);
        pmt_P2C1.AmountPaid__c = 30;
        pmt_P2C1.DatePaid__c = td.addYears(-2);
        update new Payment__c[] {pmt_P1C1, pmt_P2C1};
        checkProjects(project1, 12, project2, 34);
        checkContact(contact1, 40, td.addYears(-1));

        // Reassign one of contact1's payments to be from one project1 to project3 and
        //   from contact1 to contact3.
        // Expect both projects and both contacts to be updated
        pmt_P1C1.Project__c = project3.Id;      // Really changing payment P1C1 into P3C3.  P1C1 is now gone.
        pmt_P1C1.Contact__c = contact3.Id;
        update pmt_P1C1;
        checkProjects(project1, 2, project3, 10);
        checkContact(contact1, 30, td.addYears(-2));    // P2C1 is all that's left for contact1
        checkContact(contact3, 10, td.addYears(-1));    // Was P1C1's values.

        // Delete Contact1 & Contact2 payments for Project2
        delete new Payment__c[] {pmt_P2C1, pmt_P2C2};
        checkProject(project2, 0);
        checkContact(contact1, 0, null);    // Both P1C1 and P2C1 are both now gone.
        checkContact(contact2, 2, td.addDays(-2));  // P1C2 is all that's left.

        // Undelete a payment for Project2, Contact2
        undelete pmt_P2C2;
        checkProject(project2, 4);
        checkContact(contact2, 6, td.addDays(-2));
    }

    /**
     * Assert supplied Project has expected Total Payment rollup amount
     */
    private static void checkProject(Project__c project, Decimal expectedTotalPayment) {
        Project__c refreshedProject = [SELECT TotalPayments__c FROM Project__c WHERE Id = :project.Id];
        system.assertEquals(expectedTotalPayment, refreshedProject.TotalPayments__c, 'TotalPayments__c mismatch for Project '+Project.Name);
    }

    /**
     * Shortcut for checkProject() method.  Allow passing two projects with their expected total amounts.
     */
    private static void checkProjects(Project__c project1, Decimal expectedTotalPayment1,
                                      Project__c project2, Decimal expectedTotalPayment2) {
        checkProject(project1, expectedTotalPayment1);
        checkProject(project2, expectedTotalPayment2);
    }

    /**
     * Assert supplied Contact has expected Total Payment and Most Recent Paymewnt rollups
     */
    private static void checkContact(Contact contact, Decimal expectedTotalPayment, Date mostRecentProjectPaymentDate) {
        Contact refreshedContact = [SELECT TotalProjectPayments__c,
                                    mostRecentProjectPaymentDate__c
                                    FROM Contact
                                    WHERE Id = :contact.Id];
        system.assertEquals(expectedTotalPayment,
                            refreshedContact.TotalProjectPayments__c,
                            'TotalPayments__c mismatch for Project '+Contact.LastName);
        system.assertEquals(mostRecentProjectPaymentDate,
                            refreshedContact.mostRecentProjectPaymentDate__c,
                            'mostRecentProjectPaymentDate__c mismatch for contact '+Contact.LastName);
    }


}
