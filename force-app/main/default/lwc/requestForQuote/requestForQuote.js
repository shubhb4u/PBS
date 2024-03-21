import { LightningElement, api, wire, track } from "lwc";
import Success_Icon from "@salesforce/resourceUrl/PBS_Success_Icon";
import createQuoteWithLineItemsFromCart from "@salesforce/apex/QuoteController.createQuoteWithLineItemsFromCart";
import getPreviousQuotes from "@salesforce/apex/QuoteController.getPreviousQuotes";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";


import { CartSummaryAdapter } from "commerce/cartApi";


export default class requestForQuote extends LightningElement {


    @api recordId;
    @track cardHidden = false;
    @track cardVisible = false;
    @track quoteSubmitted = false;
    @api effectiveAccountId;
    @track contactId;
    @track currentCartidId;
    @track reason;
    @track insertedQuoteData =  [];
    successIcon = Success_Icon;


    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            this.cartSummary  = data;
            console.log("Cart Id", data.cartId);
            this.currentCartidId = data.cartId;
        } else if (error) {
            console.error(error);
        }
    }

    //Getting the current logged in customer  contact -
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user({ data, error }) {
        if (data) {
            this.contactId = getFieldValue(data, CONTACT_ID);
            console.log("data ->>>", this.contactId);

        } else if (error) {
            console.error("Error fetching user data:", error);
        }
    }

    handleClick() {
        this.cardHidden = true;
        this.cardVisible = true;
        this.insertedQuoteData = getPreviousQuotes(this.contactId);
        console.log('insertedQuoteData -->>',  this.insertedQuoteData);
    }

    handleReasonChange(event){
        this.reason = event.target.value;
    }

    handleRequestQuote() {
        createQuoteWithLineItemsFromCart({
            cartId: this.currentCartidId,
            productId: '01tHp00000B7IqpIAF',
            quantity: 3,
            reason: this.reason,
            contactId: this.contactId
        })
            .then((result) => {
                console.log("Quote created successfully:", result);
                this.quoteSubmitted = true;
                
            })
            .catch((error) => {
                console.error("Error creating quote:", error);
            });
    }
    
}