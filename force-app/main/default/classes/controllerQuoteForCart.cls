/**
 * @description       : Creates a quote based on the provided cart ID and product details
 * @author            : Shubham Mazumdar
 * Project            : PBS
 * @last modified on  : 03-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class controllerQuoteForCart {

    @AuraEnabled
    public static Quote createQuoteWithLineItemsFromCart(String cartId, String reason, String contactId) {

        
        // try {

            // Retrieve the User's Contact record
            Contact userContact = [SELECT Id, Name, email, Phone, accountId FROM Contact WHERE Id = :contactId LIMIT 1];
            System.debug('User Contact: ' + userContact);

            // Retrieve AccountId from userContact
            List<Account> accList = [SELECT Id, Name, PBS_Type__c FROM Account WHERE Id = :userContact.accountId AND isBuyer = true LIMIT 1];
            // if (accList.isEmpty()) {
            //     throw new AuraHandledException('Account not found or not eligible for quote creation');
            // }
            Account acc = accList[0];
            System.debug('account is ->>   '+ acc);

            // Get PriceBookId
            Id priceBookId = getPriceBookId(acc.PBS_Type__c);
            System.debug('priceBookId is ->>   '+ priceBookId);

            // Create Opportunity
            Opportunity opp = createOpportunity(acc.Id, priceBookId);
            System.debug('opp is ->>   '+ opp);

            // Create Quote
            Quote quote = createQuote(opp.Id, reason, contactId);
            System.debug('quote is ->>   '+ quote);

            //Get the priceBook entries

            // Create Quote Line Items and Opportunity Line Items from Cart
            List<QuoteLineItem> quoteLineItems = createQuoteLineItems(cartId, quote.Id, opp.Id, priceBookId);
            
            return quote;

        // } catch (Exception e) {
        //     throw new AuraHandledException('Error creating quote: ' + e.getMessage());
        // }
    }

    private static Id getPriceBookId(String type) {
        String pbName = (type == 'Platinum') ? 'Etg B2B DevOrg Price Book' : (type == 'Gold') ? 'Gold' : 'Standard';
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = :pbName LIMIT 1];
        return pb.Id;
    }

    public static Opportunity createOpportunity(Id accId, Id priceBookId) {
        Opportunity opp = new Opportunity(
            Name = 'Quote opp ' + Date.today(),
            AccountId = accId,
            CurrencyIsoCode = 'USD',
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            Pricebook2Id = priceBookId,
            Probability = 10
        );
        insert opp;
        return opp;
    }

    public static Quote createQuote(Id oppId, String reason, Id contactId) {
        
        Quote newQuote = new Quote(
            Status = 'Draft',
            Name = 'Quote Test ' + Date.today(),
            Email = 'quotetest@gmail.com',
            ExpirationDate = Date.today().addDays(30),
            Description = reason,
            OpportunityId = oppId,
            ContactId = contactId
        );
        insert newQuote;
        return newQuote;
    }

    public static List<QuoteLineItem> createQuoteLineItems(String cartId, Id quoteId, Id oppId, Id priceBookId) {
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

        List<CartItem> cartItems = [SELECT Id, Quantity, Product2Id, ListPrice, TotalAmount FROM CartItem WHERE CartId = :cartId];
        for (CartItem item : cartItems) {
            oppLineItems.add(new OpportunityLineItem(
                OpportunityId = oppId,
                Product2Id = item.Product2Id,
                Quantity = item.Quantity,
                
                // ListPrice = item.ListPrice, Field in not writeable
                TotalPrice = item.TotalAmount
            ));

            //Get priceBookEntries for creating quoteLineItems - 
            List<PricebookEntry> pricebookEntry = [SELECT Id, Pricebook2Id, unitPrice FROM PricebookEntry WHERE Product2Id = :item.Product2Id 
            AND Pricebook2Id =: priceBookId];

            quoteLineItems.add(new QuoteLineItem(
                QuoteId = quoteId,
                PricebookEntryId = pricebookEntry[0].Id,
                Product2Id = item.Product2Id,
                UnitPrice = item.ListPrice,
                Quantity = item.Quantity
            ));
        }

        if (!oppLineItems.isEmpty()) {
            insert oppLineItems;
        }

        if (!quoteLineItems.isEmpty()) {
            insert quoteLineItems;
        }

        return quoteLineItems;
    }
}
