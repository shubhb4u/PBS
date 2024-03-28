/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class IndividualQuoteRecords {
    @AuraEnabled
    public static Quote getQuoteRecord(string quoteId) {
        system.debug('quoteId: '+quoteId);
        Quote quo;
        if(quoteId!=null){
            system.debug('Inside If:');
        quo=[select id,ContactId,QuoteNumber,Subtotal,Discount,GrandTotal,Status,Name,ExpirationDate,TotalPrice from Quote where Id = : quoteId limit 1];
        System.debug('qLidt:'+quo);
        }
        return quo;
    }
    @AuraEnabled
    public static string acceptQuoteRecord(string quoteId) {
        system.debug('quoteId: '+quoteId);
        Quote quo;
        if(quoteId!=null){
            system.debug('Inside If:');
        quo=[select id,ContactId,Status,Name,ExpirationDate,TotalPrice from Quote where Id = : quoteId limit 1];
        quo.Status = 'Accepted';
        update quo;
        System.debug('qLidt:'+quo);
        
        }
        if(quo.status == 'Accepted' ){
            return 'success';
        }
        else{
            return 'failed';
        }
    }
}