public class PlaceOrderController {
    
    @AuraEnabled
    public static String queryData(Id recordId){
        Set<Id> accId = new Set<Id>();
        list<Account> accList = new  list<Account>();
        Opportunity__c opp = new Opportunity__c();
        List<Lead__c> leadList =[select id,Email__c,ContactNumber__c, Name,FirstName__c, LastName__c,Company__c,Customer__c   from Lead__c where id=:recordId];
        //List<contact> con =[select id,AccountId,Account.Name from Contact where Email =:lead.Email__c];
        for(Lead__c leadObj : leadList){
            if(leadObj.Customer__c != null){
                accId.add(leadObj.Customer__c);
            }
            else if(leadObj.Customer__c == null){
                Account custObj = new Account();
                custObj.Name =leadObj.Company__c;
                accList.add(custObj);
            }
        }
        if(!accList.isEmpty()){
            insert accList;
            contact con = new contact(LastName=leadList[0].Name,AccountId=accList[0].Id,Email=leadList[0].Email__c);
            insert con;
            opp.Close_Date__c=system.today()+7;
            opp.Name=accList[0].Name;
            opp.Primary_contact__c=con.Id;
            opp.RecordTypeId='0121m000000DsT8AAK';
            opp.Account_Name__c=accList[0].Id;
            opp.Project__c=recordId;
            insert opp;
        }
        if(!accId.isEmpty()){
            list <Account> newList = [select id,Name from Account where id in :accId];
            contact con=[select id from contact where id = :newList[0].Id];
            opp.Close_Date__c=system.today()+7;
            opp.Name=newList[0].Name;
            opp.Primary_contact__c=con.Id;
            opp.RecordTypeId='0121m000000DsT8AAK';
            opp.Account_Name__c=newList[0].Id;
            opp.Project__c=recordId;
            insert opp;
            
            
        }
       
        
        return opp.Id;
    }
        @AuraEnabled
    public static string saveSite(Id recordId){
            
        Site_Visit__c sv= new Site_Visit__c();
        sv.Project__c=recordId;
        sv.Target_Site_Stage__c='Installation';
        sv.Date__c=system.today();
        insert sv;
            
        
        return sv.Id;
        
        
    }
}