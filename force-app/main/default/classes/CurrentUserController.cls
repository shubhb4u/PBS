public with sharing class CurrentUserController {
    @AuraEnabled(cacheable=true)
    public static User getCurrentUser() {
        return [SELECT Id, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId()];
    }
}
