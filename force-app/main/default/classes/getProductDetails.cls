public with sharing class getProductDetails {

        @AuraEnabled(cacheable=true)
        public static Product2 getProductDetails(Id recordId) {
            try {
                return [SELECT Name FROM Product2 WHERE Id = :recordId LIMIT 1];
            } catch (Exception e) {
                throw new AuraHandledException('Error fetching product details: ' + e.getMessage());
            }
        }

        
    
}