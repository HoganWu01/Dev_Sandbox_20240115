import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableContacts from "@salesforce/apex/OpportunityMembershipController.getAvailableContacts";
import addRelation from "@salesforce/apex/OpportunityMembershipController.addRelation";
import searchContact from "@salesforce/apex/OpportunityMembershipController.searchContact";
export default class opportunityMembershipAddContact extends LightningElement {
 @api accountId;
    @api clickedNodeRecordId;
    isLoading = false;
    showList = false;
    showTip = false;
    recordOrderId = '';
    contactName = '';
    contactValue = '';
    jobHospitalViewValue = '';
    contactData = '';
    addContactType = '选择已有联系人';
    addContactTypeOptions = [
        {'label': '选择已有联系人', 'value': '选择已有联系人'},
        {'label': '新建联系人', 'value': '新建联系人'}
        ];

    addExistedContact = true;
    availableContactOptions;
    selectedContactId;
    isAccountMembership = true;
    availableContactOptionsPlaceholderLabel;
    showSpinner;

    get parentContactId(){
        if(this.clickedNodeRecordId && this.clickedNodeRecordId.startsWith('003')){
            return this.clickedNodeRecordId;
        }
    }
     handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.isLoading = true;
            this.queryTerm = evt.target.value;
            searchContact({
                name:this.queryTerm
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
                        this.availableContactOptionsPlaceholderLabel = '未找到已有的联系人';
                    }
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                "title": '错误',
                "message": '获取已有联系人出错',
                variant:'error'
            }));
        });
        }
    }
    connectedCallback(){
    	console.log('------------+' + this.accountId);
        getAvailableContacts({
            oppotunityId: this.accountId
        })
        .then(result => {
            let contactOptions = [];
            result.forEach(con=>{
                contactOptions.push({label:con.Name,value:con.Id});
            });
            this.availableContactOptions = contactOptions;

            if(result.length > 0){
                this.selectedContactId = result[0].Id;
            } else {
                this.availableContactOptionsPlaceholderLabel = '未找到已有的联系人';
            }
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                "title": '错误',
                "message": '获取已有联系人出错',
                variant:'error'
            }));
        });
    }

    selectContactType(event){
        this.addExistedContact = event.detail.value == '选择已有联系人';
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
                // 这个必填判断应该不需要，不过 input-field required 并没有在 submit 时报错
                const department = this.template.querySelector('[data-id="existed-department-field"]').value;
                if(department){
                    this.template.querySelector('[data-id="addExistedContactForm"]').submit();
                    this.showSpinner = true;
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        "title": '错误',
                        "message": '请填写必填字段',
                        variant:'error'
                    }));
                }
            } else { 
                this.dispatchEvent(new ShowToastEvent({
                    "title": '错误',
                    "message": '请选择已有的联系人',
                    variant:'error'
                }));
            }
         
        } else {
            this.template.querySelector('[data-id="addNewContactForm"]').submit();
            this.showSpinner = true;
        }
        //判断选择的节点是商机还是联系人，是商机则建立商机联系人关系
        
           
    }

    handleSuccessSavingAddExistedContactForm(event){
        this.showSpinner = false;
        // if(this.clickedNodeRecordId){
            addRelation({
            	opportunityId: this.accountId,
            	contactId:  event.detail.id
            }).then(result => {
            
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                "title": '错误',
                "message": '保存关系出错',
                variant:'error'
            }));
        });
        // }
        this.dispatchEvent(new ShowToastEvent({
            "title": '成功',
            "message": '联系人更新成功',
            variant:'success'
        }));
        this.dispatchEvent(new CustomEvent('success'));
    }

    handleErrorOnAddExistedContactForm(event){
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({
            "title": '错误',
            "message": '联系人更新失败，错误信息：' + event.detail.message,
            variant:'error'
        }));
    }

    handleSuccessSavingAddNewContactForm(event){
        this.showSpinner = false;
        let createRecord = event.detail.id;
        this.recordOrderId = createRecord;
        this.contactValue = createRecord;
        // if(this.clickedNodeRecordId){
            addRelation({
            	opportunityId: this.accountId,
            	contactId:  event.detail.id
            }).then(result => {
            
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                "title": '错误',
                "message": '保存关系出错',
                variant:'error'
            }));
        });
        // }
        this.dispatchEvent(new ShowToastEvent({
            "title": '成功',
            "message": '联系人新建成功',
            variant:'success'
        }));
        this.dispatchEvent(new CustomEvent('success'));
    }

    handleErrorOnAddNewContactForm(event){
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({
            "title": '错误',
            "message": '联系人新建失败，错误信息：' + event.detail.message,
            variant:'error'
        }));
    }

    handleSelectJobHospital(event) {
        this.showJobHospital = false;
        this.jobHospitalIdField = event.currentTarget.id;
        this.jobHospitalIdField = this.jobHospitalIdField.slice(0,18);
        this.contactValue = this.contactData.find(con=>con.Id==this.jobHospitalIdField);
        console.log('contactValue===' + this.contactValue);
        
        this.contactName = this.contactValue.Name;
        this.contactValue = this.contactValue.Id;
        console.log('contactName===' + this.contactName);
        this.isLoading = false;
        this.showList = false;
    }
   
}