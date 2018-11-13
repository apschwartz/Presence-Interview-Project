/**
 * Service class to hold all soql operations for Contact.
 */
public class ContactSelector {

    /**
     * public class representing a Contact object.  Additonal fields are provided
     * for calciulated info.
     */
    public class ContactInfo {
        public Contact contact {get; private set;}
        public Decimal calculatedTotalProjectPayments {get; private set;}
        public Date calculatedMostRecentProjectPaymentDate {get; private set;}

        public ContactInfo(Id ContactId,
                           Decimal totalPaid,
                           Date mostRecentPaymentDate) {
            this.contact = new Contact(Id = contactId);
            this.calculatedTotalProjectPayments = totalPaid;
            this.calculatedMostRecentProjectPaymentDate = mostRecentPaymentDate;
        }
    }

    /**
     * Return a list of Contacts (ContactInfo) with the total sum of payments and
     * most recent payment date for each contact.
     * @param projectIDs - List of specific projects to query
     * @result - Map of Contact IDs and ContactInfo objects for each contact found in contactIDs.
     *           NOTE: If a ContactID was supplied but that contact presently has no payments, then that contact
     *                 will NOT be returned in this map.
     */
    public static Map<Id, ContactInfo> getContactsByIdWithAggInfo(Set<Id> contactIDs) {
        AggregateResult[] getContactsByIdWithAggInfo = [SELECT Contact__c contactId,
                                                        sum(amountPaid__c) totalPaid,
                                                        max(datePaid__c) latestPaidDate
                                                        FROM Payment__c
                                                        GROUP BY Contact__c];

        Map<Id, ContactInfo> result = new Map<Id, ContactInfo>();
        for (AggregateResult ar : getContactsByIdWithAggInfo) {
            result.put( (Id)ar.get('contactId'),
                        new ContactInfo( (Id)ar.get('contactId'),
                                         (Decimal)ar.get('totalPaid'),
                                         (Date)ar.get('latestPaidDate')));
        }

        return result;
    }

    /**
     * Return all Contacts that have Payment__c records along with a
     * subselect of Payment records.
     */
    public static Contact[] getContactsWithPaymentInfo() {
        return [SELECT Name,
                MostRecentProjectPaymentDate__c,
                TotalProjectPayments__c,
                (Select Name,
                 AmountPaid__c,
                 DatePaid__c,
                 Project__r.Name
                 From Payments__r
                 Order By DatePaid__c DESC, CreatedDate DESC)
                FROM Contact
                WHERE Id IN (Select Contact__c From Payment__c)
                ORDER BY Name ASC];

    }

}
