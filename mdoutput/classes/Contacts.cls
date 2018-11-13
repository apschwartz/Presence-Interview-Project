/**
 * Service class to handle Contact objects
 */
public class Contacts {

    /**
     * Update Contacts after one or more payments have been made or deleted.  This is updating the Contacts'
     * Total Project Payment and Most Recent Payment Date to match the now-existing
     * Payments__c for each Contact.
     */
    public void updateContactPaymentInfo(Payment__c[] oldPayments,
                                         Payment__c[] newPayments) {

        // Get a set of all the contacts impacted by a set of payment changes.
        // Note that these can be new payments, updated payments, or deleted or un-deleted payments.
        // Also, during Updates, the Contact Id in the oldPayment may be different than the one in the newPayment.
        // In that case, both of these contacts were impacted and need new rollups.
        Set<Id> impactedContactIDs = new Set<Id>();
        impactedContactIDs.addAll(returnContactIDs(oldPayments));
        impactedContactIDs.addAll(returnContactIDs(newPayments));

        // Query the database to get the total payments and most recent payment now existing for each contact.
        // Update those Project's totalPayments__c fields.
        // Be sure to handle the case where a provided contact presently has no payments against it.
        Map<Id, ContactSelector.ContactInfo> contactsInfoMap = ContactSelector.getContactsByIdWithAggInfo(impactedContactIDs);
        Contact[] contactsToUpdate = new Contact[] {};
        for (Id contactId : impactedContactIDs) {
            ContactSelector.ContactInfo contactInfo = contactsInfoMap.get(contactId);
            if (contactInfo != null) {
                contactsToUpdate.add(new Contact(Id = contactInfo.contact.Id,
                                                 TotalProjectPayments__c = contactInfo.calculatedTotalProjectPayments,
                                                 MostRecentProjectPaymentDate__c = contactInfo.calculatedMostRecentProjectPaymentDate));
            } else {
                // Need to handle the case where a contact has no payments against it and therefore is not in the
                // returned map.  Be sure to update that contacts's total paid to 0 and most recent payment
                // date to null, in case it was not previously 0 & null.
                // This can happen in a payment delete scenario.
                contactsToUpdate.add(new Contact(Id = contactId,
                                                 TotalProjectPayments__c = 0,
                                                 MostRecentProjectPaymentDate__c = null));
            }
        }

        update contactsToUpdate;
    }

    /**
     * From a list of Payment__c records return the set of all found Contact IDs.
     * @param payments - List of Payment__c records
     * @return - Set of found Contact IDs
     */
    public static Set<Id> returnContactIDs(Payment__c[] payments) {
        Set<Id> returnSet = new Set<Id>();

        if (payments != null) {
            for (Payment__c pmt : payments) {
                returnSet.add(pmt.contact__c);
            }
        }

        return returnSet;
    }


}
