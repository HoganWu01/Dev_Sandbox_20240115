import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import removeAccount from '@salesforce/apex/AccountLayerShipController.removeAccount';

export default class accountLayershipRemoveAccount extends LightningElement {
	@api accountId;

    showSpinner;

    get showConfirmMessage(){
        return '是否从关系中删除该客户？';
    }

    handleRemoveContact(){
        this.showSpinner = true;

        removeAccount({
            accountId:this.accountId
        })
        .then(result => {
            this.showSpinner = false;
            this.dispatchEvent(new CustomEvent('success'));
        })
        .catch(error => {
            const pageErrors = error.body.pageErrors;
            const fieldErrors = error.body.fieldErrors;
            let errorMessage;

            if(pageErrors && pageErrors[0]){
                errorMessage = pageErrors[0].message || '未知错误';
            } else if (fieldErrors){
                errorMessage = '未知错误';
            }

            this.dispatchEvent(new ShowToastEvent({
                title:'错误',
                message:'删除失败，错误信息：' + errorMessage,
                variant:'error'
            }));

            this.showSpinner = false;
        });
    }

    handleCancelRemove(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}