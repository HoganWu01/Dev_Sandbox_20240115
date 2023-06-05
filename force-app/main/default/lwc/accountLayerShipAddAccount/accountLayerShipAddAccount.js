import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableAccount from "@salesforce/apex/AccountLayerShipController.getAvailableAccount";
import searchAccount from "@salesforce/apex/AccountLayerShipController.searchAccount";

export default class OperationPlanMapAddContact extends LightningElement {
    @api accountId;
    @api clickedNodeRecordId;
    showTip = false;
    BeenGroup = false;
    isLoading = false;
    showList = false;
    contactName = '';
    contactValue = '';
    contactData = '';
    addContactType = '选择已有客户';
    addContactTypeOptions = [
        {'label': '选择已有客户', 'value': '选择已有客户'}
        ];

    addExistedContact = true;
    availableContactOptions;
    selectedContactId;
    isAccountMembership = true;
    availableContactOptionsPlaceholderLabel;
    showSpinner;

    get ParentId(){
        if(this.clickedNodeRecordId){
            console.log('this.clickedNodeRecordId ===' + this.clickedNodeRecordId);
            return this.clickedNodeRecordId;
        }
    }

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.isLoading = true;
            this.queryTerm = evt.target.value;
            searchAccount({
                name:this.queryTerm,
                accountId:this.accountId
            })
            .then(result => {
                let contactOptions = [];
                result.forEach(con=>{
                    console.log('con ====>' + con.Name);
                    contactOptions.push({label:con.Name,value:con.Id});
                    this.contactData = result;
                });
                this.availableContactOptions = contactOptions;

                if(result.length > 0){
                        this.showList = true;
                        this.showTip = false;
                        this.selectedContactId = result[0].Id;
                    } else {
                        this.showTip = true;
                        this.showList = false;
                        this.isLoading = false;
                        this.availableContactOptionsPlaceholderLabel = '未找到已有的客户';
                    }
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                "title": '错误',
                "message": '获取已有客户出错',
                variant:'error'
            }));
        });
        }
    }

    connectedCallback(){
    	console.log("进来了");
        getAvailableAccount({
            accountId:this.accountId
        })
        .then(result => {
            let contactOptions = [];
            result.forEach(con=>{
                contactOptions.push({label:con.Name,value:con.Id});
            });
            this.availableContactOptions = contactOptions;
            console.log(result.length + 'result[0].Id=' + result[0].Id);
            if(result.length > 0){
                this.selectedContactId = result[0].Id;
            } else {
                this.availableContactOptionsPlaceholderLabel = '未找到已有的联系人';
            }
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                "title": '错误',
                "message": '获取已有客户出错',
                variant:'error'
            }));
        });
    }

    selectContactType(event){
        this.addExistedContact = event.detail.value == '选择已有客户';
    }

    closeAddContact(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    selectExistedContact(event){
        this.selectedContactId = event.detail.value;
    }

    submitAddContact(){
        if(this.addExistedContact){
            if(this.contactValue){
            	this.template.querySelector('[data-id="addExistedContactForm"]').submit();
                this.showSpinner = true;
            } else { 
                this.dispatchEvent(new ShowToastEvent({
                    "title": '错误',
                    "message": '请选择已有的客户',
                    variant:'error'
                }));
            }
        } else {
            this.template.querySelector('[data-id="addNewContactForm"]').submit();
            this.showSpinner = true;
        }
    }

    handleSuccessSavingAddExistedContactForm(){
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({
            "title": '成功',
            "message": '客户更新成功',
            variant:'success'
        }));
        this.dispatchEvent(new CustomEvent('success'));
    }

    handleErrorOnAddExistedContactForm(event){
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({
            "title": '错误',
            "message": '客户更新失败，错误信息：' + event.detail.message,
            variant:'error'
        }));
    }

    handleSuccessSavingAddNewContactForm(){
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({
            "title": '成功',
            "message": '客户新建成功',
            variant:'success'
        }));
        this.dispatchEvent(new CustomEvent('success'));
    }

    handleErrorOnAddNewContactForm(event){
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({
            "title": '错误',
            "message": '客户新建失败，错误信息：' + event.detail.message,
            variant:'error'
        }));
    }
     handleSelectJobHospital(event) {
        this.showJobHospital = false;
        this.jobHospitalIdField = event.currentTarget.id;
        this.jobHospitalIdField = this.jobHospitalIdField.slice(0,18);
        this.contactValue = this.contactData.find(con=>con.Id==this.jobHospitalIdField);
        
        this.contactName = this.contactValue.Name;
        this.contactValue = this.contactValue.Id;
        console.log('contactValue===' + this.contactValue);
        console.log('contactName===' + this.contactName);
        this.isLoading = false;
        this.showList = false;
    }
}