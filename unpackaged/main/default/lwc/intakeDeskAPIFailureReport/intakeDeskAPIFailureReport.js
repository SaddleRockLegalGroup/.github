import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { exportCSVFile } from 'c/utils';

import getIntakeDeskAPIFailureReport from '@salesforce/apex/IntakeDeskLWCReportController.getIntakeDeskAPIFailureReport';

const columns = [
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', hideDefaultActions: 'true', initialWidth: 140,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        },
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Integration Transaction Id', fieldName: 'Id', hideDefaultActions: 'true', initialWidth: 170,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'External ID', fieldName: 'External_ID__c', hideDefaultActions: 'true', initialWidth: 100,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Integration Transaction Name', fieldName: 'Name', hideDefaultActions: 'true', initialWidth: 220,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Vendor', fieldName: 'brioapi__Vendor__c', hideDefaultActions: 'true', initialWidth: 170,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Intake Vendor', fieldName: 'FX_Intake_Vendor__c', hideDefaultActions: 'true', initialWidth: 100,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Status', fieldName: 'brioapi__Status__c', hideDefaultActions: 'true', initialWidth: 80,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Request', fieldName: 'brioapi__Request__c', hideDefaultActions: 'true', initialWidth: 400, wrapText: true,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Response', fieldName: 'brioapi__Response__c', hideDefaultActions: 'true', initialWidth: 400, wrapText: true,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Audited', fieldName: 'Audited__c', type: 'boolean', hideDefaultActions: 'true', initialWidth: 70,
        cellAttributes: { style: 'vertical-align: top;' }
    }
];

export default class IntakeDeskAPIFailureReport extends NavigationMixin(LightningElement) {
    columns = columns;
    @track integrations;
    @track isLoaded = false;
    @track hasData;
    reportTitle;

    @wire(getIntakeDeskAPIFailureReport)
    intakeRecords({ data, error }) {
        this.isLoaded = true;
        if (data) {
            this.integrations = data;
            if (data == undefined || data == null || data == '' || data.length == 0) {
                this.hasData = false;
                this.reportTitle = 'Intake Desk | API Failures Report (0)';
            } else {
                this.hasData = true;
                this.reportTitle = 'Intake Desk | API Failures Report (' + data.length + ')';
            }
        } else if (error) {
            this.hasData = false;
            this.reportTitle = 'Intake Desk | API Failures Report (0)';
        }
    }

    headers = {
        CreatedDate: "Created Date",
        Id: "Integration Transaction Id",
        External_Id__c: "External ID",
        Name: "Integration Transaction Name",
        brioapi__Vendor__c: "Vendor",
        FX_Intake_Vendor__c: "Intake Vendor",
        brioapi__Status__c: "Status",
        brioapi__Request__c: "Request",
        brioapi__Response__c: "Response",
        Audited__c: "Audited"
    }

    handleDownloadCSV() {
        exportCSVFile(this.headers, this.integrations, "Intake_Desk__API_Failures_Report");
    }
}