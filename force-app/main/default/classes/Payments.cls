public class Payments {
    public Payments() {}

    /**
     * Trigger handler for Payment__c objects.
     * Assumes Trigger context.
     */
    public static void handleTrigger() {

        // After payments are written to the database, need to update Project__c and Contact objects
        // with the correct payment roll-up information.
        if (trigger.isAfter) {
            new Projects().updateProjectPaymentInfo(trigger.old, trigger.new);
            new Contacts().updateContactPaymentInfo(trigger.old, trigger.new);
        }
    }

}
