trigger UpdateLeadFromSiteVisit on site_visit__c (After Insert,After update,before delete) {
    SiteVisitHelper.updateTargetSite(trigger.new,trigger.oldMap);
    SiteVisitHelper.projectStatus(trigger.new,trigger.oldMap);
    //SiteVisitHelper.handleDelete(trigger.new,trigger.oldMap);
}