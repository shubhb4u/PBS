/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-23-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class DisplayQuoteRecords {
    @AuraEnabled
    public static List<Quote> DisplayQuoteRecs(string contactId) {
        if(ContactId!=null){
        List<Quote> qLidt=[select id,ContactId,Status,Name,ExpirationDate,TotalPrice from Quote where ContactId = : ContactId];
        System.debug('qLidt:'+qLidt);
        return qLidt;
        }else{
            List<Quote> qLidt1=[select id,ContactId from Quote where ContactId = '003Hp00002urk0KIAQ'];
           return qLidt1; 
        }
    }

    @AuraEnabled
    public static String getDownloadLink(String quoId) {

    List<ContentDistribution> conDistList = new List<ContentDistribution>();
    String downloadUrl;
    
    try {
        Set<Id> documentIds = new Set<Id>();
        
        List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :quoId];
        System.debug('cdls ->>>' + cdls);

        if (!cdls.isEmpty()) {
            for (ContentDocumentLink cdl : cdls) {
                documentIds.add(cdl.ContentDocumentId);
                System.debug('documentIds ->>>' + documentIds);
            }
        }

        // Getting the corresponding content document record 
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE Id IN :documentIds];
        if (!documents.isEmpty()) {
            System.debug('documents ->>>' + documents[0].Id);

            Set<Id> conDocIds = new Set<Id>();
            for (ContentDocument cd : documents) {
                if (cd.Id != null) {
                    conDocIds.add(cd.Id);
                }
            }

            conDistList = [SELECT Id, ContentDocumentId, ContentDownloadUrl,DistributionPublicUrl  FROM ContentDistribution WHERE ContentDocumentId IN :conDocIds ORDER BY CreatedDate DESC LIMIT 1];
            
            downloadUrl = String.valueOf(conDistList[0].ContentDownloadUrl);
            System.debug('downloadUrl ->>>' + downloadUrl);
            } else {
            // Handle the case when the documents list is empty
                System.debug('No documents found for the given quote.');
            }
        } catch (Exception e) {
            System.debug('Error fetching download link: ' + e.getMessage());
        }

        return downloadUrl;
    }
}
