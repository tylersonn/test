global class RetrieveCustomerRecordsScheduledApex implements Schedulable {

    global void execute(SchedulableContext sc) {
        List<Order__c> ordersToInsert = new List<Order__c>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://test.com');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            List<Object> jsonResponse = (List<Object>) JSON.deserializeUntyped(res.getBody());
            for (Object obj : jsonResponse) {
                Map<String, Object> orderMap = (Map<String, Object>) obj;
                Order__c orderRecord = new Order__c(
                    OrderedDate__c = Date.valueOf((String) orderMap.get('orderDate')),
                    OrderNumber__c = (String) orderMap.get('orderNumber'),
                    Name = (String) orderMap.get('customerName'),
                    ShippingAddress__c = (String) orderMap.get('address'),
                    ShippingCity__c = (String) orderMap.get('city'),
                    ShippingCountry__c = (String) orderMap.get('country'),
                    ShippingPostalCode__c = (String) orderMap.get('zipCode')
                );
                ordersToInsert.add(orderRecord);
            }
        }
        
        if (!ordersToInsert.isEmpty()) {
            try {
                insert ordersToInsert;
            } catch (DmlException e) {
                System.debug('Failed to insert Order records: ' + e.getMessage());
            }
        }
    }
}

// To schedule this class to run daily at 12:00 PM
// System.schedule('Daily Order Retrieval', '0 0 12 * * ?', new RetrieveCustomerRecordsScheduledApex());