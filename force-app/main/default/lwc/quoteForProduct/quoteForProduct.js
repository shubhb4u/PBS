import { LightningElement, api, wire, track } from "lwc";
import Success_Icon from "@salesforce/resourceUrl/PBS_Success_Icon";
import createQuoteWithLineItems from "@salesforce/apex/QuoteController.createQuoteWithLineItems";
import getProduct from "@salesforce/apex/getProductDetails.getProductDetails";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";

export default class QuoteForProduct extends LightningElement {
    @api recordId; // Id of the current product record
    @track productName;
    @track quantity;
    // @track expirationDate;
    @track reason;
    @track cardHidden = false;
    @track cardVisible = false;
    @track quoteSubmitted = false;
    @track currentRecordId;
    @api effectiveAccountId;
    @track contactId;
    successIcon = Success_Icon;

    connectedCallback() {
        this.currentRecordId = this.recordId;
        console.log("recordId -->>" + this.currentRecordId);
        console.log("effectiveAccountId -->>" + this.effectiveAccountId);
    }

    //Getting the current logged in customer  contact - 
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user({data, error}) {
        if (data) {
            this.contactId = getFieldValue(data, CONTACT_ID);
            console.log('data ->>>', this.contactId);
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }

    // get contactId() {
        
    //     return getFieldValue(this.user.data, CONTACT_ID);
    // }

    @wire(getProduct, { productId: "$recordId" })
    product;

    handleClick() {
        this.cardHidden = true;
        this.cardVisible = true;
    }

    handleQuantityChange(event) {
        this.quantity = event.target.value;
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
    }

    handleRequestQuote() {
        createQuoteWithLineItems({
            productId: this.currentRecordId,
            quantity: this.quantity,
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
