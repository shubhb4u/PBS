public with sharing class QuoteController {


    @AuraEnabled
    public static List<Quote> createQuoteWithLineItems(String cartId, String productId, Integer quantity, String reason, String contactId) {


        // Get the current user's Id
        Id currentUserId = UserInfo.getUserId();
        System.debug('Current User Id: ' + currentUserId);

        // Retrieve the User's ContactId
        String userContactId = contactId;
        System.debug('User Contact Id: ' + userContactId);

        // Retrieve the User's Contact record
        Contact userContact = [SELECT Id, Name, email, Phone, accountId FROM Contact WHERE Id = :userContactId LIMIT 1];
        System.debug('User Contact: ' + userContact);


        //Retrieve AccountId from userContact - 
        List<Account> accList = [Select Id, name from account where Id =: userContact.accountId limit 1];
        Id accId = accList[0].Id;
        System.debug('acc is: ' +  accList[0].name);

        //Get PriiceBookId  - 
        Id priceBookId = getpriceBookId();

        // Get the product price from PriceBook
        priceBookEntry pbEntry = getProductPrice(productId, priceBookId);
        //System.debug('Unit Price for Product (' + productId + '): ' + unitPrice);

        //Create a new opportunity - 
        opportunity opp = createOpp(accId, productId, pbentry);
        Id oppId  = opp.id;
        System.debug('oppId is ->.' + oppId);

        // Create a new quote
        List<Quote> quoteList = createQuote(currentUserId, userContact, priceBookId, reason, opp);
        System.debug('New Quote Id: ' + quoteList[0].Id);

        // Create quote line items
        if (quoteList[0].Id != null && oppId != null) {
            createQuoteLineItems(quoteList[0].Id, productId, quantity, pbEntry);
        }

        return quoteList;
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

    public static opportunity createOpp(Id accId, String ProducId, PricebookEntry pbEntry){
        
        Opportunity opp = new Opportunity();
            
            opp.name = 'Quote creation opp '+ Date.today();
            opp.accountId = accId;
            opp.currencyIsoCode = 'USD';
            opp.closeDate  =  Date.today()+30;
            opp.StageName =  'Prospecting';
            opp.amount = pbEntry.UnitPrice;
            insert opp;
            
        return opp;
    }


    // Create a new quote record
    private static List<Quote> createQuote(Id userId, Contact userContact, Id pbId, String reason, opportunity opp) {

        List<Quote> createdQuote =  new List<Quote>();
        Quote newQuote = new Quote();
        newQuote.Name = 'New Quote ' + userContact.Name;
        newQuote.OwnerId = userId; // Assign the current user as the owner of the quote
        newQuote.ContactId = userContact.Id;
        newQuote.ExpirationDate  = opp.closeDate;
        newQuote.description  = reason;
        newQuote.status  = 'Draft';
        newQuote.email  =  userContact.email;
        newQuote.phone  =  userContact.Phone;
        newQuote.Pricebook2Id =  pbId;
        NewQuote.OpportunityId = opp.Id;
        createdQuote.add(newQuote);

        if(!createdQuote.isEmpty()){
            insert createdQuote;
        }
        // insert newQuote;
        System.debug('new quote  -->> '  +  newQuote);
        return createdQuote;
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

    @AuraEnabled
    public static List<Quote> createQuoteWithLineItemsFromCart(String cartId, String productId, Integer quantity, String reason, String contactId) {


        // Get the current user's Id
        Id currentUserId = UserInfo.getUserId();
        System.debug('Current User Id: ' + currentUserId);

        // Retrieve the User's ContactId
        String userContactId = contactId;
        System.debug('User Contact Id: ' + userContactId);

        // Retrieve the User's Contact record
        Contact userContact = [SELECT Id, Name, email, Phone, accountId FROM Contact WHERE Id = :userContactId LIMIT 1];
        System.debug('User Contact: ' + userContact);

        //Retrieve AccountId from userContact - 
        List<Account> accList = [Select Id, name from account where Id =: userContact.accountId limit 1];
        Id accId = accList[0].Id;
        System.debug('acc is: ' +  accList[0].name);

        //Get PriiceBookId  - 
        Id priceBookId = getpriceBookId();

        // Get the product price from PriceBook
        priceBookEntry pbEntry = getProductPrice(productId, priceBookId);
        //System.debug('Unit Price for Product (' + productId + '): ' + unitPrice);

        //Create a new opportunity - 
        opportunity opp = createOpp(accId, productId, pbentry);
        Id oppId  = opp.id;
        System.debug('oppId is ->.' + oppId);

        // Create a new quote
        List<Quote> quoteList = createQuote(currentUserId, userContact, priceBookId, reason, opp);
        System.debug('New Quote Id: ' + quoteList[0].Id);

        // Create quote line items
        if (quoteList[0].Id != null && oppId != null) {
            createQuoteLineItems(quoteList[0].Id, productId, quantity, pbEntry);
        }

        return quoteList;
    }


    @AuraEnabled(cacheable=true)
    public static List<Quote> getPreviousQuotes(String  contactId) {
 
        List<Quote> previousQuotes = [Select id, name, status, expirationDate from quote where createdById =: contactId];
        return previousQuotes;

    }

}