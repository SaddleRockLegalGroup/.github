import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getIntakeRecords from '@salesforce/apex/PartnerPortalController.getIntakeRecords';

const columns = [
    { label: 'Intake Name', fieldName: 'Name', hideDefaultActions: 'true' },
    { label: 'Case Type', fieldName: 'Case_Type_Name__c', hideDefaultActions: 'true' },
    { label: 'Client Name', fieldName: 'FX_Client_Name__c', hideDefaultActions: 'true' },
    { label: 'Sub-Status', fieldName: 'Sub_Status__c', hideDefaultActions: 'true' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', hideDefaultActions: 'true' ,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    { label: 'Referral Partner Name', fieldName: 'Referral_Partner_Name__c', hideDefaultActions: 'true' },
    { label: 'Referred Out Date', fieldName: 'litify_pm__Referred_Out_Date__c', type: 'date', hideDefaultActions: 'true',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    { label: 'View Intake', type: 'button', hideDefaultActions: 'true',
        typeAttributes: {
            label: 'View',
            name: 'view'
        }
    }
];

export default class PartnerIntake extends NavigationMixin(LightningElement) {
    columns = columns;
    @track intakes;
    @track displayRecord = false;
    @track intakeId;
    @track intake;
    @track splitFeePercent;
    @track isLoaded = false;
    @track hasData;

    @wire(getIntakeRecords)
    intakeRecords({ data, error }) {
        this.isLoaded = true;
        if (data) {
            this.intakes = data;
            if (data == undefined || data == null || data == '' || data.length == 0) {
                this.hasData = false;
            } else {
                this.hasData = true;
            }
        } else if (error) {
            this.hasData = false;
        }
    }

    handleRowAction(event) {
        this.intakeId = event.detail.row.Id;
        for (let i in this.intakes) {
            if (this.intakes[i].Id == this.intakeId) {
                this.intake = this.intakes[i];
                let splitFee = this.intake.Split_Fee_Percentage__c;
                this.splitFeePercent = splitFee != undefined ? splitFee + '%' : 'None';
            }
        }
        this.displayRecord = true;
    }

    hideModal() {
        this.displayRecord = false;
    }
}