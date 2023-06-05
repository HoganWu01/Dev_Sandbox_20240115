import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedTasks from '@salesforce/apex/LwcProjectController.getRelatedTasks';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
    
    { label: '项目任务名', fieldName: 'Name', type: 'text' },
    { label: '前置任务名', fieldName: 'PreTask2__c', type: 'text'  },
    { label: '计划开始日期', fieldName: 'PlannedStartDate__c', type: 'date-local', editable: true },
    { label: '计划任务天数', fieldName: 'PlannedNumOfDays__c', type: 'number', editable: true },
    { label: '计划结束日期', fieldName: 'PlannedEndDate__c', type: 'date-local' },
    { label: '前置间隔天数', fieldName: 'PreInterval__c', type: 'number', editable: true }
];

export default class ProjectRelatedTaskList extends LightningElement {
    // 项目Id
    @api recordId;

    @track columns = COLUMNS;
    @track draftValues = [];

    @wire(getRelatedTasks, { projectId: '$recordId' })
    result;

    /**
     * 处理保存按钮事件。
     * @param {*} event 
     */
    handleSave(event) {
        console.log(event.detail.draftValues);
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        })
        console.log(recordInputs);
        this.doSave(recordInputs);
    }


    /**
     * 向服务器端执行保存。
     * @param {*} recordInputs 
     */
    doSave(recordInputs) {
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(result => {
            console.log(result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated',
                    variant: 'success'
                })
            );
            // 保存成功，清楚修改信息
            this.draftValues = [];

            return refreshApex(this.result);
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}