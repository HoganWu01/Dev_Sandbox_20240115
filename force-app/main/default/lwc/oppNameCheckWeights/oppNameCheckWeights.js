import { LightningElement, wire, api } from 'lwc';
import getRelatedOpps from '@salesforce/apex/LwcOppNameCheckWeightsController.getRelatedOpps';

const columns = [
    { label: '项目编号', fieldName: 'projectNumber' },
    { label: '商机名称', fieldName: 'oppName', typeAttributes: { tooltip: { fieldName: 'oppName' } } },
    { label: '客户二级公司', fieldName: 'accName'},
    { label: '商机所有人', fieldName: 'owner' },
    { label: '重复率值', fieldName: 'weight', type: 'percent' }
];

export default class OppNameCheckWeights extends LightningElement {

    @api recordId;

    error;
    columns = columns;

    @wire(getRelatedOpps, { oppId: '$recordId' })
    opps;

}

