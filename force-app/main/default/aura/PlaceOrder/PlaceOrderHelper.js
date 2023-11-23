({
	initializationHelper: function (component, event) {
    let recordId = component.get("v.recordId");
    if (recordId) {
        const serverAction = component.get("c.queryData");
        serverAction.setParams({ "recordId": recordId });

        serverAction.setCallback(this, $A.getCallback(function (response) {
            if (response.getState() === "SUCCESS") {
                let data = response.getReturnValue();
                console.log('order id: ' + data);

                // Navigate to the Opportunity__c record page
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": data,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            } else {
                console.log("Error while fetching data");
            }
        }));

        $A.enqueueAction(serverAction);
    }
}

})