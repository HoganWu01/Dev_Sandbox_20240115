import { LightningElement, api } from 'lwc';

export default class accountLayerShip extends LightningElement {
	@api recordId;
    clickedNodeRecordId;

    showAddContact;
    showRemoveContact;

    handleAddContact(event){
        console.log('add contact in');
        this.showAddContact = true;
        this.clickedNodeRecordId = event.detail.currentNodeRecordId;
    }

    handleRemoveContact(event){
        this.showRemoveContact = true;
        this.clickedNodeRecordId = event.detail.currentNodeRecordId;
    }

    handleAddContactSuccess(){
        this.showAddContact = false;
        this.template.querySelector('[data-id="g6Graph"]').reRenderGraph();
    }

    handleCloseAddContact(){
        this.showAddContact = false;
    }

    handleRemoveContactSuccess(){
        this.showRemoveContact = false;
        this.template.querySelector('[data-id="g6Graph"]').reRenderGraph();
    }

    handleCancelRemoveContact(){
        this.showRemoveContact = false;
    }
}