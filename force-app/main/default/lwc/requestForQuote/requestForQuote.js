import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import createQuoteWithLineItemsWebCart from '@salesforce/apex/QuoteController.createQuoteWithLineItemsWebCart';
import getCartDetails from '@salesforce/apex/QuoteController.getCartDetails';

export default class RequestForQuote extends LightningElement {
    @track cardHidden = false;
    @track cardVisible = false;
    @track quoteNeededBy;
    @track reasonForQuote;
    @track quoteSubmitted = false;
    @track cart;
    @api recordId; // Use recordId provided by Lightning Web Component
    @wire(CurrentPageReference)
    pageRef;

    connectedCallback() {
        // Fetch cart details based on the recordId when the component is connected to the DOM
        this.getCartDetails();
    }

    getCartDetails() {
        // Call Apex method to retrieve cart details based on recordId
        getCartDetails({ recordId: this.recordId })
            .then(result => {
                this.cart = result;
            })
            .catch(error => {
                console.error('Error fetching cart details:', error);
            });
    }

   

    handleClick() { 
        // Handle click event if needed
    }

    handleQuoteNeededByChange(event) {
        // Handle quote needed by change if needed
        this.quoteNeededBy = event.target.value;
    }

    handleReasonForQuoteChange(event) {
        // Handle reason for quote change if needed
        this.reasonForQuote = event.target.value;
    }

    handleSubmit() {
        // Call Apex method to create quote and quote line items
        if (this.cart) {
            createQuoteWithLineItemsWebCart({ cart: this.cart })
                .then(result => {
                    // Handle success response
                    console.log('Quote created successfully:', result);
                    this.quoteSubmitted = true;
                })
                .catch(error => {
                    // Handle error response
                    console.error('Error creating quote:', error);
                });
        } else {
            console.error('No cart details available.');
        }
    }
}
