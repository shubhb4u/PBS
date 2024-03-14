public with sharing class QuoteController {

    @AuraEnabled
    public static Id createQuoteWithLineItems(String productId, Integer quantity, String reason, Id contactId) {
        // Get the current user's Id
        Id currentUserId = UserInfo.getUserId();
        System.debug('Current User Id: ' + currentUserId);

        // Retrieve the User's ContactId
        Id userContactId = contactId;
        System.debug('User Contact Id: ' + userContactId);

        // Retrieve the User's Contact record
        Contact userContact = [SELECT Id, Name, email, Phone FROM Contact WHERE Id = :userContactId LIMIT 1];
        System.debug('User Contact: ' + userContact);


        //Get PriiceBookId  - 
        Id priceBookId = getpriceBookId();

        // Get the product price from PriceBook
        priceBookEntry pbEntry = getProductPrice(productId, priceBookId);
        //System.debug('Unit Price for Product (' + productId + '): ' + unitPrice);

        // Create a new quote
        Id quoteId = createQuote(currentUserId, userContact, priceBookId, reason);
        System.debug('New Quote Id: ' + quoteId);

        // Create quote line items
        if (quoteId != null) {
            createQuoteLineItems(quoteId, productId, quantity, pbEntry);
        }

        return quoteId;
    }

    //Retrieve pricebook to be used to select products for Quote line items  -  
    // ---->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Modify this hardcoded pricebookid later - ---------------------------------------
    private static Id getpriceBookId(){

        id priceBookId;
        List<Pricebook2> pb = [Select id, name from Pricebook2  where name = 'Etg B2B DevOrg Price Book'];
        priceBookId = pb[0].id;
        System.debug(priceBookId);
        return priceBookId;
    }

    // Retrieve the UnitPrice for the specified product
    private static PricebookEntry getProductPrice(String productId, Id priceBookId) {
        
        PricebookEntry pbEntry;
        try {
            pbEntry = [SELECT id,UnitPrice FROM PricebookEntry WHERE Product2Id = :productId and Pricebook2Id =: priceBookId LIMIT 1];
            System.debug(pbEntry);

        } catch (Exception e) {
            System.debug('Error fetching product price: ' + e.getMessage());
        }
    
        return pbEntry;
    }


    // Create a new quote record
    private static Id createQuote(Id userId, Contact userContact, Id pbId, String reason) {
        Quote newQuote = new Quote();
        newQuote.Name = 'New Quote ' + userContact.Name;
        newQuote.OwnerId = userId; // Assign the current user as the owner of the quote
        newQuote.ContactId = userContact.Id;
        //newQuote.ExpirationDate  = expDate;
        newQuote.description  = reason;
        newQuote.status  = 'Draft';
        newQuote.email  =  userContact.email;
        newQuote.phone  =  userContact.Phone;
        newQuote.Pricebook2Id =  pbId;
        insert newQuote;
        System.debug('new quote  -->> '  +  newQuote);
        return newQuote.Id;
    }

    // Create quote line items for the specified product and quantity
    private static void createQuoteLineItems(Id quoteId, String productId, Integer quantity, PricebookEntry pbEntry ) {
        System.debug('Entered quoteLineItem  -->> ');
        if(pbEntry != null) {
            System.debug('Creation started quoteLineItem  -->> ');
            // Create a new quote line item
            QuoteLineItem quoteLineItem = new QuoteLineItem();
            quoteLineItem.QuoteId = quoteId;
            quoteLineItem.Product2Id = productId;
            quoteLineItem.PricebookEntryId = pbEntry.Id;
            quoteLineItem.Quantity = quantity;
            quoteLineItem.UnitPrice = pbEntry.UnitPrice;
            insert quoteLineItem;
            System.debug('new quoteLineItem  -->> '  +  quoteLineItem);
        } else {
            // Handle scenario where PricebookEntry is null
            System.debug('Error: PricebookEntry is null.');
        }
    }
}



    