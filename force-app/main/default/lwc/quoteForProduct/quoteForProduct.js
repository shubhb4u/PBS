import { LightningElement, api, wire, track } from "lwc";
import Success_Icon from "@salesforce/resourceUrl/PBS_Success_Icon";
import createQuoteWithLineItems from "@salesforce/apex/QuoteController.createQuoteWithLineItems";
import getProduct from "@salesforce/apex/getProductDetails.getProductDetails";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import PRODUCT_NAME from "@salesforce/schema/product2.name";


export default class QuoteForProduct extends LightningElement {
    @api recordId; // Id of the current product record
    @track productName;
    @track quantity;
    @track expirationDate;
    @track reason;
    @track cardHidden = false;
    @track cardVisible = false;
    @track quoteSubmitted = false;
    @track currentRecordId;
    @api effectiveAccountId;
    @track contactId;
    @track insertedQuoteData;
    successIcon = Success_Icon;

    connectedCallback() {
        this.currentRecordId = this.recordId;
        console.log("recordId -->>" + this.recordId);
        // this.getProductName();
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

    @wire(getRecord, { recordId: this.currentRecordId, fields: [PRODUCT_NAME] })
    product({ data, error }) {
        if (data) {
            this.productName = getFieldValue(data, PRODUCT_NAME);
            console.log("data ->>>", this.name);
        } else if (error) {
            console.error("Error fetching user data:", error);
        }
    }


    handleClick() {
        this.cardHidden = true;
        this.cardVisible = true;
    }

    handleQuantityChange(event) {
        this.quantity = event.target.value;
    }

    handleDateChange(event) {

        const selectedDate = event.target.value;
        // const formattedDate = selectedDate.split('T')[0];
        this.expirationDate = selectedDate;

        console.log('expirationDate-..>>', this.expirationDate);
        console.log('expirationDate-..>>', typeof(this.expirationDate));
        
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
    }


    handleRequestQuote() {
        createQuoteWithLineItems({
            productId: this.recordId,
            quantity: this.quantity,
            reason: this.reason,
            contactId: this.contactId,
            expirationDate: this.expirationDate
        })
            .then((result) => {
                console.log("Quote created successfully:", result);
                this.quoteSubmitted = true;
                
                this.insertedQuoteData = result;
                console.log('insertedQuoteData -->>',  this.insertedQuoteData);
            })
            .catch((error) => {
                console.error("Error creating quote:", error);
            });
    }
}
