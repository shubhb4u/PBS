import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchQuotes from '@salesforce/apex/DisplayQuoteRecords.DisplayQuoteRecs';
import getDownloadLink from '@salesforce/apex/DisplayQuoteRecords.getDownloadLink';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";

export default class DisplayQuoteRecords extends NavigationMixin(LightningElement) {
    @track Quotes;
    @track contactId;
    @track quoteId;
    @track downloadPdfUrl  = '';
    // @track conDist =  [];
    // @track showDownloadButton;

    connectedCallback() {
        console.log('Welcome to DisplayQuotezre:');
        console.log('contactId:', this.contactId);
    }

    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user({ data, error }) {
        if (data) {
            this.contactId = getFieldValue(data, CONTACT_ID);
            console.log('DisplayQuoteRecords data ->>>', this.contactId);
            console.log('DisplayQuoteRecords contactId ->>>', this.contactId);
            this.retrieveQuotes();
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }

    // Fetch the contactId of the current user
    retrieveQuotes() {
        if (this.contactId) {
            console.log('DisplayQuoteRecords this.contactId ->>>', this.contactId);
            // Fetch quotes only if contactId is available
            fetchQuotes({ contactId: this.contactId })
                .then(result => {
                    console.log('DisplayQuoteRecords resultes ->>>', result);
                    this.Quotes = result;
                })
                .catch(error => {
                    console.error('Error fetching quotes:', error);
                });
        }
    }


    handleViewCode(event) {
        const quoteId = event.target.dataset.quoteId;
        const quoteName = event.target.dataset.quoteName; // Retrieve quote name dynamically
        

        // Construct the URL with dynamic parameters
        const url = `/quote/${quoteId}/${quoteName}`;
        // const url = `/quote/${quoteId}/view`;
        console.log('url is ->>>', url);

        // Navigate to the constructed URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }

    // Fetch the contactId of the current user
    handleDownloadQuotePdf(event) {

        this.quoteId = event.target.dataset.quoteDownid;
        console.log('Quoite id for download pdf is ->>', this.quoteId);

        if (this.quoteId) {
            console.log( 'Quote Id for downloading quote is -->> '  + this.quoteId);
            // Fetch quotes only if contactId is available
            getDownloadLink({ quoId : this.quoteId })
                .then(result => {
                    console.log('Download link is  ->>>', result);
                    this.downloadPdfUrl = result;
                    
                    console.log('conDist ->>' +this.conDist);

                    // Navigate to the constructed URL
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: this.downloadPdfUrl
                        }
                    });
                    
                })
                .catch(error => {
                    console.error('Error fetching download link:', error);
                });
        }
    }
}