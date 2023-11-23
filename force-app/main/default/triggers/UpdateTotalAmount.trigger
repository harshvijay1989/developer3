trigger UpdateTotalAmount on Opportunity_Product__c (after insert, after update, after delete) {
    Set<Id> opportunityIds = new Set<Id>();

    // Collect the Opportunity IDs from the affected Opportunity Line Items
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Opportunity_Product__c item : Trigger.new) {
            opportunityIds.add(item.OpportunityId__c);
        }
    } else if (Trigger.isDelete) {
        for (Opportunity_Product__c item : Trigger.old) {
            opportunityIds.add(item.OpportunityId__c);
        }
    }

    // Query the related Opportunity records
    List<Opportunity__c> opportunitiesToUpdate = [SELECT Id, (SELECT TotalPrice__c FROM Opportunity_Products__r) FROM Opportunity__c WHERE Id IN :opportunityIds];

    // Update Total Amount on Opportunities
    for (Opportunity__c opp : opportunitiesToUpdate) {
        Decimal totalAmount = 0;
        for (Opportunity_Product__c item : opp.Opportunity_Products__r) {
            totalAmount += item.TotalPrice__c;
        }
        opp.Amount__c = totalAmount;
    }
    System.debug('opportunitiesToUpdate'+opportunitiesToUpdate);

    // Perform the update
    if (!opportunitiesToUpdate.isEmpty()) {
        update opportunitiesToUpdate;
    }
}