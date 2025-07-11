import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { exportCSVFile } from 'c/utils';

import getIntakeDeskMissingDocReport from '@salesforce/apex/IntakeDeskLWCReportController.getIntakeDeskMissingDocReport';

const columns = [
    { label: 'Type of Payload to Resend', fieldName: 'FX_Type_of_Payload_to_Resend__c', hideDefaultActions: 'true', initialWidth: 190,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Intake Name', fieldName: 'Name', hideDefaultActions: 'true', initialWidth: 140,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    /*{ label: 'Intake Id', fieldName: 'Id', hideDefaultActions: 'true', initialWidth: 170,
        cellAttributes: { style: 'vertical-align: top;' }
    },*/
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', hideDefaultActions: 'true', initialWidth: 100,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        },
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Client/Caller First Name', fieldName: 'FX_Caller_First_Name__c', hideDefaultActions: 'true', initialWidth: 160,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Client/Caller Last Name', fieldName: 'FX_Caller_Last_Name__c', hideDefaultActions: 'true', initialWidth: 160,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Email', fieldName: 'litify_pm__Email__c', hideDefaultActions: 'true', initialWidth: 270,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Status and Sub-Status', fieldName: 'FX_Status_and_Sub_Status__c', hideDefaultActions: 'true', initialWidth: 150, wrapText: true,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Intake Desk Qualified', fieldName: 'Intake_Desk_Qualified__c', hideDefaultActions: 'true', initialWidth: 150,
        cellAttributes: { style: 'vertical-align: top;' }
    },
    { label: 'Count of Signed Retainers', fieldName: 'Count_of_Signed_Retainers__c', hideDefaultActions: 'true', initialWidth: 180,
        cellAttributes: { style: 'vertical-align: top;' }
    }
];

export default class IntakeDeskMissingDocReport extends NavigationMixin(LightningElement) {
    columns = columns;
    @track intakes;
    @track displayRecord = false;
    @track isLoaded = false;
    @track hasData;
    reportTitle;

    @wire(getIntakeDeskMissingDocReport)
    intakeRecords({ data, error }) {
        this.isLoaded = true;
        if (data) {
            this.intakes = data;
            if (data == undefined || data == null || data == '' || data.length == 0) {
                this.hasData = false;
                this.reportTitle = 'Intake Desk | Intakes with Missing Docs OR Payload (0)';
            } else {
                this.hasData = true;
                this.reportTitle = 'Intake Desk | Intakes with Missing Docs OR Payload (' + data.length + ')';
            }
        } else if (error) {
            this.hasData = false;
            this.reportTitle = 'Intake Desk | Intakes with Missing Docs OR Payload (0)';
        }
    }

    headers = {
        FX_Type_of_Payload_to_Resend__c: "Type of Payload to Resend",
        Name: "Intake Name",
        Id: "Intake Id",
        CreatedDate: "Created Date",
        FX_Caller_First_Name__c: "Client/Caller First Name",
        FX_Caller_Last_Name__c: "Client/Caller Last Name",
        litify_pm__Email__c: "Email",
        FX_Status_and_Sub_Status__c: "Status and Sub-Status",
        Intake_Desk_Qualified__c: "Intake Desk Qualified",
        Count_of_Signed_Retainers__c: "Count of Signed Retainers"
    }

    handleDownloadCSV() {
        exportCSVFile(this.headers, this.intakes, "Intake_Desk__Intakes_with_Missing_Docs_OR_Payload");
    }
}