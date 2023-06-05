import { LightningElement, api } from 'lwc';
import removeContact from '@salesforce/apex/OpportunityMembershipController.removeContact';

export default class opportunityMembershipRemoveContact extends LightningElement {
@api contactId;

    showSpinner;

    get showConfirmMessage(){
        return '是否从关系中删除该联系人？';
    }

    handleRemoveContact(){
        this.showSpinner = true;

        removeContact({
            contactId:this.contactId
        })
        .then(result => {
        	console.log('成功的');
            this.showSpinner = false;
            this.dispatchEvent(new CustomEvent('success'));
        })
        .catch(error => {
            const pageErrors = error.body.pageErrors;
            const fieldErrors = error.body.fieldErrors;
            let errorMessage;
            console.log('失败的');
            if(pageErrors && pageErrors[0]){
                errorMessage = pageErrors[0].message || '未知错误';
            } else if (fieldErrors){
                errorMessage = '未知错误';
            }

            // this.dispatchEvent(new ShowToastEvent({
            //     title:'错误',
            //     message:'删除失败，错误信息：' + errorMessage,
            //     variant:'error'
            // }));

            this.showSpinner = false;
        });
    }

    handleCancelRemove(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}