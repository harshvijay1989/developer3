public class SiteVisitHelper {
    public static void updateTargetSite(List<site_visit__c> triggernew,Map<Id,site_visit__c>oldMap){
        set<Id> leadIds = new Set<Id>();
        for(site_visit__c site : triggernew){
            if(site.Target_Site_Stage__c != null && (trigger.isInsert || site.Target_Site_Stage__c != oldMap.get(site.Id).Target_Site_Stage__c)){
                leadIds.add(site.Project__c);
            }
        } 
        if(!leadIds.isEmpty()){
            Map<Id,Lead__c> leadMap = new Map<Id,Lead__c>([select Id,Target_Site_Stage__c from Lead__c where id in :leadIds]);
            for(site_visit__c site : triggernew){
                if(site.Target_Site_Stage__c != null && (trigger.isInsert || site.Target_Site_Stage__c != oldMap.get(site.Id).Target_Site_Stage__c)){
                    Lead__c ld = leadMap.get(site.Project__c);
                    ld.Target_Site_Stage__c = site.Target_Site_Stage__c;
                    leadMap.put(site.Project__c,ld);
                }
            }
            update leadMap.values();
        }
        
    }
    public static void projectStatus(List<site_visit__c> triggernew,Map<Id,site_visit__c>oldMap){
        set<Id> leadIds = new Set<Id>();
        for(site_visit__c site : triggernew){
            if(site.Project_Status__c != null && (trigger.isInsert || site.Project_Status__c != oldMap.get(site.Id).Project_Status__c)){
                leadIds.add(site.Project__c);
            }
        } 
        if(!leadIds.isEmpty()){
            Map<Id,Lead__c> leadMap = new Map<Id,Lead__c>([select Id,ProjectStatus__c from Lead__c where id in :leadIds]);
            for(site_visit__c site : triggernew){
                if(site.Project_Status__c != null && (trigger.isInsert || site.Project_Status__c != oldMap.get(site.Id).Project_Status__c)){
                    Lead__c ld = leadMap.get(site.Project__c);
                    ld.ProjectStatus__c = site.Project_Status__c;
                    leadMap.put(site.Project__c,ld);
                }
            }
            update leadMap.values();
        }
    }
    public static void handleDelete(List<site_visit__c> triggernew,Map<Id,site_visit__c>oldMap){
        set<Id> leadIds = new Set<Id>();
        for(site_visit__c site : triggernew){
            if(site.Project_Status__c != null){
                leadIds.add(site.Project__c);
            }
        }
        if(!leadIds.isEmpty()){
            Map<Id,Lead__c> leadMap = new Map<Id,Lead__c>([select Id,ProjectStatus__c from Lead__c where id in :leadIds ]);
            for(site_visit__c site : triggernew){
                if(site.Project_Status__c != null && (trigger.isInsert || site.Project_Status__c != oldMap.get(site.Id).Project_Status__c)){
                    Lead__c ld = leadMap.get(site.Project__c);
                    ld.ProjectStatus__c = site.Project_Status__c;
                    leadMap.put(site.Project__c,ld);
                }
            }
            update leadMap.values();
        }
    }
}