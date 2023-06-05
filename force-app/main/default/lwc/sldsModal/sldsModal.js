import { LightningElement, api } from 'lwc';

export default class SldsModal extends LightningElement {
    @api title;
    @api showSpinner;
    @api confirmButtonVariant;
    @api confirmButtonLabel;

    get confirmClass(){
        return this.confirmButtonVariant?'slds-button slds-button_' + this.confirmButtonVariant:'slds-button slds-button_brand';
    }

    get confirmLabel(){
        return this.confirmButtonLabel?this.confirmButtonLabel:'保存';
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    confirm(){
        this.dispatchEvent(new CustomEvent('confirm'));
    }
}