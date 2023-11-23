public class ListViewController {
   /*@AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRecord(String objName) {
        System.debug('Obj Name : '+objName);
        List<Map<String, Object>> records = new List<Map<String, Object>>();

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objName);
        System.debug('objectType : '+objectType);
        if (objectType != null) {
            Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
            System.debug('objDescribe : '+objDescribe);
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
			System.debug('fieldMap : '+fieldMap);

            String query = 'SELECT ';
            for (String fieldName : fieldMap.keySet()) {
                query += fieldName+', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM ' + objName;
			System.debug('Query : '+query);

            List<SObject> sObjects = Database.query(query);

            for (SObject sObj : sObjects) {
                Map<String, Object> recordMap = new Map<String, Object>();
                
                for (Schema.SObjectField field : sObj.getSObjectType().getDescribe().fields.getMap().values()) {
                    String fieldName = field.getDescribe().getName();
                    recordMap.put(fieldName, sObj.get(fieldName));
                }
                records.add(recordMap);
            }
        } else {
            System.debug('Invalid object name: ' + objName);
        }
        System.debug('Size : '+records.size());
        return records;
    }*/
    public static List<Map<String, Object>> getRecord(String apiName, String label, String objName){
    	System.debug('Api Name: ' + apiName);
        System.debug('New Label: ' + label);
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        MetadataService.SessionHeader_element sessionHeader = new MetadataService.SessionHeader_element();
        String sessionID = UtilsGetSessionId.getSessionIdFromVFPage(Page.GetSessionIdFromVFPage);
        sessionHeader.sessionId = sessionID;
        service.SessionHeader = sessionHeader;
        
        MetadataService.ListView existingListView = new MetadataService.ListView();
        existingListView.fullName = objName + '.' + apiName;
        
        try {
            MetadataService.ReadListViewResult result = (MetadataService.ReadListViewResult) service.readMetadata('ListView', new String[] { objName + '.' + apiName });
            
            MetadataService.IReadResult result2 = service.readMetadata('ListView', new String[] { objName + '.' + apiName });
            
            //syste
            //MetadataService.readListViewResponse_element result2 = (MetadataService.readListViewResponse_element) service.readMetadata('ListView', new String[] { objName + '.' + apiName });
            System.debug('Result====> '+result);
            System.debug('Result 2 ====> '+result2);
          //  System.debug('Result getResult====> '+result2.getResult());
            if (result.records != null && result.records.size() > 0) {
                //system.debug('records : '+result.getResult());
                //system.debug('records size: '+result.records.size());
                MetadataService.ListView listView = (MetadataService.ListView) result.records[0];
                System.debug('listViewlistView123'+listView);
                listView.label = label;
                system.debug('List view Column : '+listView.columns+' Filter : '+listView.filterScope);
                System.debug('List view division : '+listView.division+'Shared to : '+listView.sharedTo);
                System.debug('List view division : '+listView.label+'Queue : '+listView.queue);
                System.debug('List view Fiters : '+listView.filters);
                String query = 'SELECT ';
                query += listView.columns+', ';
                query = query.removeEnd(', ');
                query += ' FROM ' + objName;
                System.debug('Query : '+query);
                List<SObject> sObjects = Database.query(query);
                
                for (SObject sObj : sObjects) {
                    Map<String, Object> recordMap = new Map<String, Object>();
                    
                    for (Schema.SObjectField field : sObj.getSObjectType().getDescribe().fields.getMap().values()) {
                        String fieldName = field.getDescribe().getName();
                        recordMap.put(fieldName, sObj.get(fieldName));
                    }
                    records.add(recordMap);
                } 
            }
            System.debug('Size : '+records.size());
            return records;
        } 
        catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }  
        return null;
    }
    public static String getListViewApi(String listApiName){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v49.0/ui-api/list-info/Account/'+listApiName);
        req.setMethod('GET');
        string autho = 'Bearer '+userInfo.getSessionId();
        req.setHeader('Authorization', autho);        
        Http http = new Http();
        HTTPresponse res= http.send(req);
        string response = res.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.debug('responseresponse123'+response);
        System.debug('mm'+m);
        List<Object> fieldList = (List<Object>) m.get('displayColumns');  
        System.debug('fieldList==> '+fieldList);
        String listviewFieldName = '';
        for(Object fields : fieldList){
            System.debug('fields==> '+fields);
            String mp = String.valueOf(fields);
			listviewFieldName = listviewFieldName + mp.Substring(mp.indexof('=')+1,mp.indexof(','))+',';
        }        
        return listviewFieldName.removeEnd(',');
    }
    @AuraEnabled
    public static void insertList(String name, String apiName, String objName){
        System.debug('Name : '+name);
        System.debug('Api Name : '+apiname);
        System.debug('Obj Name : '+objName);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();                         
        MetadataService.ListView listView = new MetadataService.ListView();
        MetadataService.SessionHeader_element sessionHeader = new MetadataService.SessionHeader_element();
        String sessionID = UtilsGetSessionId.getSessionIdFromVFPage(Page.GetSessionIdFromVFPage);
        sessionHeader.sessionId = sessionID;
        service.SessionHeader = sessionHeader;
        listView.fullName = objName+'.'+apiName;
        listView.filterScope = 'Everything';
        listView.label = name;
        List<MetadataService.SaveResult> results =                        
            service.createMetadata(
                new MetadataService.Metadata[] { listView }); 
        if(!results.isEmpty()){
            for (MetadataService.SaveResult result : results) {
                if (result.success) {
                    system.debug('Succeeded'); 
                } else { 
                    System.debug(JSON.serialize(result.errors[0].message));
                }   
            }
        } else{
            system.debug('Result is null');
        }
    }
    @AuraEnabled
    public static void renameList(String apiName, String label, String objName) {
        System.debug('Api Name: ' + apiName);
        System.debug('New Label: ' + label);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        MetadataService.SessionHeader_element sessionHeader = new MetadataService.SessionHeader_element();
        String sessionID = UtilsGetSessionId.getSessionIdFromVFPage(Page.GetSessionIdFromVFPage);
        sessionHeader.sessionId = sessionID;
        service.SessionHeader = sessionHeader;
        
        MetadataService.ListView existingListView = new MetadataService.ListView();
        existingListView.fullName = objName + '.' + apiName;
        
        try {
            MetadataService.ReadListViewResult result = (MetadataService.ReadListViewResult) service.readMetadata('ListView', new String[] { objName + '.' + apiName });
            if (result.records != null && result.records.size() > 0) {
                MetadataService.ListView listView = (MetadataService.ListView) result.records[0];
                listView.label = label; 
                System.debug('List view Column : '+listView.columns+' Filter : '+listView.filterScope);
                List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { listView }); 
                if (!results.isEmpty()) {
                    for (MetadataService.SaveResult saveResult : results) {
                        if (saveResult.success) {
                            System.debug('List view updated successfully');
                        } else {
                            System.debug(JSON.serialize(saveResult.errors[0].message));
                        }
                    }
                } else {
                    System.debug('Result is null');
                }
            } else {
                System.debug('List view not found');
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteList(String apiName, String objName) {
        System.debug('Api Name: ' + apiName);
        System.debug('Obj Name: ' + objName);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        MetadataService.SessionHeader_element sessionHeader = new MetadataService.SessionHeader_element();
        String sessionID = UtilsGetSessionId.getSessionIdFromVFPage(Page.GetSessionIdFromVFPage);
        sessionHeader.sessionId = sessionID;
        service.SessionHeader = sessionHeader;
        
        try {
            String fullName = objName + '.' + apiName;
            MetadataService.deleteMetadata_element deleteElement = new MetadataService.deleteMetadata_element();
            deleteElement.type_x = 'ListView';
            deleteElement.fullNames = new String[]{fullName};
                
             MetadataService.DeleteResult[] deleteResult = service.deleteMetadata(deleteElement.type_x, deleteElement.fullNames);
            
            if (deleteResult != null && deleteResult.size() > 0) {
                for (MetadataService.DeleteResult deleteResultItem : deleteResult) {
                    if (deleteResultItem.success) {
                        System.debug('List view deleted successfully');
                    } else {
                        System.debug(JSON.serialize(deleteResultItem.errors[0].message));
                    }
                }
            } else {
                System.debug('Result is null');
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
    class displayColumnsWrapper{
    String fieldApiName;
    String label;
    String sortable;
    }
}