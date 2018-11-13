/**
 * Service class to handle Project__c objects
 */
public class Projects {

    public Projects() {}

    /**
     * Update Projects after one or more payments have been made or deleted.  This is updating the Projects'
     * payment totals to match the now-existing Payments__c for each Project__c.
     */
    public void updateProjectPaymentInfo(Payment__c[] oldPayments,
                                         Payment__c[] newPayments) {

        // Get a set of all the projects impacted by a set of payment changes.
        // Note that these can be new payments, updated payments, or deleted or un-deleted payments.
        // Also, during Updates, the project ID in the oldPayment may be different than the one in the newPayment.
        // In that case, both of these projects were impacted and need new totaLs.
        Set<Id> impactedProjectIDs = new Set<Id>();
        impactedProjectIDs.addAll(returnProjectIDs(oldPayments));
        impactedProjectIDs.addAll(returnProjectIDs(newPayments));

        // Query the database to get the total payments now existing for each project.
        // Update those Project's totalPayments__c fields.
        // Be sure to handle the case where a provided project presently has no payments against it.
        Map<Id, ProjectSelector.ProjectInfo> projectsInfoMap = ProjectSelector.getProjectsByIdWithAggPayments(impactedProjectIDs);
        Project__c[] projectsToUpdate = new Project__c[] {};
        for (Id projectId : impactedProjectIDs) {
            ProjectSelector.ProjectInfo projInfo = projectsInfoMap.get(projectId);
            if (projInfo != null) {
                projectsToUpdate.add(new Project__c(Id = projInfo.project.Id,
                                                    TotalPayments__c = projInfo.calculatedTotalPaid));
            } else {
                // Need to handle the case where a proejct has no payments against it and therefore is not in the
                // returned map.  Be sure to update that project's total paid to 0 in case it was not previously 0.
                // This can happen in a payment delete scenario.
                projectsToUpdate.add(new Project__c(Id = projectId,
                                                    TotalPayments__c = 0));
            }
        }

        update projectsToUpdate;
    }

    /**
     * From a list of Payment__c records return the set of all found Project__c IDs.
     * @param payments - List of Payment__c records
     * @return - Set of found Project__c IDs
     */
    public static Set<Id> returnProjectIDs(Payment__c[] payments) {
        Set<Id> returnSet = new Set<Id>();

        if (payments != null) {
            for (Payment__c pmt : payments) {
                returnSet.add(pmt.project__c);
            }
        }

        return returnSet;
    }

}
