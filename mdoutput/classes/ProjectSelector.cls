/**
 * Service class to hold all soql operations for Project__c
 */
public class ProjectSelector {
    private ProjectSelector() {
    }

    /**
     * public class representing a Project__c object.  Additonal fields are provided
     * for calciulated info.
     */
    public class ProjectInfo {
        public Project__c project {get; private set;}
        public Decimal calculatedTotalPaid {get; private set;}

        public ProjectInfo(Id projectId,
                           Decimal totalPaid) {
            this.project = new Project__c(Id = projectId);
            this.calculatedTotalPaid = totalPaid;
        }
    }

    /**
     * Return a list of Projects (ProjectInfo) with the total sum of payments for each project.
     * @param projectIDs - List of specific projects to query
     * @result - Map of Project IDs and ProjectInfo objects for each project found in projectIDs.
     *           NOTE: If a projectID was supplied but that project presently has no payments, then that project
     *                 will NOT be returned in this map.
     */
    public static Map<Id, ProjectInfo> getProjectsByIdWithAggPayments(Set<Id> projectIDs) {
        AggregateResult[] ProjectsWithAggPayments = [SELECT Project__c projectId,
                                                     sum(amountPaid__c) totalPaid
                                                     FROM Payment__c
                                                     WHERE Project__c IN :projectIDs
                                                     GROUP BY Project__c];

        Map<Id, ProjectInfo> result = new Map<Id, ProjectInfo>();
        for (AggregateResult ar : ProjectsWithAggPayments) {
            result.put( (Id)ar.get('projectId'), new ProjectInfo( (Id)ar.get('projectId'), (Decimal)ar.get('totalPaid')));
        }

        return result;
    }

}
