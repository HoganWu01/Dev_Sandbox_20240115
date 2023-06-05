/*
 * @Author: Conner
 * @Date: 2021-12-08 15:41:25
 * @LastEditors: Conner
 * @LastEditTime: 2021-12-15 11:41:54
 * @Descripttion: 
 */
import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import callGetApprovalRecords from '@salesforce/apex/Controller_OAGetApprovalRecords.callGetApprovalRecords';
export default class GetRecordOA extends LightningElement {
    @api recordId;
    isLoadedOrderUI = false;  
    connectedCallback() {
        callGetApprovalRecords({recordId:this.recordId})
        .then((result)=>{
            if(result.substring(0,5)=='Error'){
                let eventT = new ShowToastEvent({
                    title: 'ERROR',
                    message: result.substring(5),
                    variant: 'error'
                });
                this.dispatchEvent(eventT);
                this.isLoadedOrderUI = true;
                this.dispatchEvent(new CustomEvent('close'));
            }else{
                let eventT = new ShowToastEvent({
                    title: 'SUCCESS',
                    message: '刷新成功!!!',
                    variant: 'SUCCESS'
                });
                this.dispatchEvent(eventT);
                this.isLoadedOrderUI = true;
                this.dispatchEvent(new CustomEvent('close'));
            }
        })
        .catch((error)=>{
            let temp = '';
            if (Array.isArray(error.body)) {
                temp = error.body.map(e => e.message).join(', ');
            } 
            else if (typeof error.body.message === 'string') {
                temp = error.body.message;
            }
            let eventT = new ShowToastEvent({
                title: 'ERROR',
                message: '接口出错,请联系管理员'+temp,
                variant: 'error'
            });
            this.dispatchEvent(eventT);
            this.isLoadedOrderUI = true;
            this.dispatchEvent(new CustomEvent('close'));
        })
        
        
        
    }  
}