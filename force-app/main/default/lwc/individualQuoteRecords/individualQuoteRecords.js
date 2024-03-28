import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import fetchQuoteDetails from '@salesforce/apex/IndividualQuoteRecords.getQuoteRecord';
import AcceptQuote from '@salesforce/apex/IndividualQuoteRecords.acceptQuoteRecord';
export default class IndividualQuoteRecords extends LightningElement {
    //@track queryParams = {};
    @track quoteId;
    @track showSuccessMessage=false;
    @track statusAccepted=false;
    @track quote;
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        // Once the component is connected, retrieve the URL parameters
        console.log('pageRef', this.pageRef);
        if (this.pageRef && this.pageRef.attributes) {
            console.log('Inside first if condition');
            const recordId = this.pageRef.attributes.recordId;
            console.log('recordId', recordId);
            if (recordId) {
                console.log('recordId inside if', recordId);
                this.quoteId=recordId;
                this.getQuoteDetails();
            }
        }
    }
    getQuoteDetails() {
        if (this.quoteId) {
            console.log('Quote Id ->>>', this.quoteId);
            // Fetch quotes only if contactId is available
            fetchQuoteDetails({ quoteId: this.quoteId })
                .then(result => {

                    console.log('Display Quote Details ->>>', result);
                    console.log('Quote Details ->>>', result.Status);
                    this.quote=result;
                    if(result.Status == 'Accepted'){
                        this.statusAccepted=true;
                    }
                    //this.Quotes = result;
                })
                .catch(error => {
                    console.error('Error fetching quotes:', error);
                });
        }
    }
    acceptQuote(){
        AcceptQuote({ quoteId: this.quoteId })
        .then(result => {
            if(result == 'success'){
                this.showSuccessMessage=true;
                console.log('Quote Accepted succesfully ->>>');
            }
            else{
                console.log('Quote Accept failed ->>>');
            }
        })
        .catch(error => {
            console.error('Error while accepting the quote:', error);
        });
    }
}