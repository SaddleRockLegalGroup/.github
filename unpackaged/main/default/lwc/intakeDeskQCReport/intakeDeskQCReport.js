import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { exportCSVFile } from 'c/utils';

import getIntakeDeskQCReport from '@salesforce/apex/IntakeDeskLWCReportController.getIntakeDeskQCReport';
import updateIntakeStatus from '@salesforce/apex/IntakeDeskLWCReportController.updateIntakeStatus';

const PICKLIST_OPTIONS = [
    { label: '--None--', value: '' }, 
    { label: 'New', value: 'New' }, 
    { label: 'In Progress', value: 'In Progress' },
    { label: 'Completed', value: 'Completed' }
];

export default class IntakeDeskQCReport extends NavigationMixin(LightningElement) {
    @track intakes = [];
    @track isLoaded = false;
    @track hasData;
    @track displayRecord = false;
    reportTitle;
    options = PICKLIST_OPTIONS;

    intakeData;

    columns = [
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', hideDefaultActions: 'true', initialWidth: 120,
            typeAttributes: {
                day: "numeric",
                month: "numeric",
                year: "numeric"
            },
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'QC Issue', fieldName: 'QC_Type__c', hideDefaultActions: 'true', initialWidth: 80,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Intake Vendor', fieldName: 'Intake_VendorName__c', hideDefaultActions: 'true', initialWidth: 100,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Intake Name', fieldName: 'Name', hideDefaultActions: 'true', initialWidth: 140,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Intake Id', fieldName: 'Id', hideDefaultActions: 'true', initialWidth: 160,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Intake Desk ID', fieldName: 'FX_Intake_Desk_ID__c', hideDefaultActions: 'true', initialWidth: 110,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Full Name', fieldName: 'FX_Full_Name__c', hideDefaultActions: 'true', initialWidth: 140,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Case Type', fieldName: 'Case_Type_Name_del__c', hideDefaultActions: 'true', initialWidth: 80,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Status', fieldName: 'litify_pm__Status__c', hideDefaultActions: 'true', initialWidth: 100,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Sub-Status', fieldName: 'Sub_Status__c', hideDefaultActions: 'true', initialWidth: 120, wrapText: true,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Intake Desk Action', fieldName: 'fx_Intake_Desk_Action__c', hideDefaultActions: 'true', initialWidth: 140,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Intake Desk EOF Reason', fieldName: 'Automated_QC_Notes__c', hideDefaultActions: 'true', initialWidth: 200, wrapText: true,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Turn Down Reason', fieldName: 'litify_pm__Turn_Down_Reason__c', hideDefaultActions: 'true', initialWidth: 200, wrapText: true,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Intake Desk Status', 
            type: 'picklist', 
            fieldName: 'Intake_Desk_Status__c', 
            editable: false, 
            initialWidth: 330,
            typeAttributes: { 
                value: { fieldName: 'Intake_Desk_Status__c' },
                placeholder: 'Select Intake Desk Status ...',
                options: PICKLIST_OPTIONS,
                context: { fieldName: 'Id' },
                name: 'Intake Desk Status'
            },
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'Intake Note', fieldName: 'Intake_Note__c', hideDefaultActions: 'true', initialWidth: 400, wrapText: true,
            cellAttributes: { style: 'vertical-align: top;' }
        },
        { label: 'View Intake', type: 'button', hideDefaultActions: 'true', initialWidth: 160,
            typeAttributes: {
                label: 'View',
                name: 'view'
            }
        }
    ];
    
    @wire(getIntakeDeskQCReport)
    intakeRecords({ data, error }) {
        this.isLoaded = true;
        this.intakeData = data;
        if (data) {
            this.intakes = this.intakeData.map(intake => ({
                ...intake,
                CreatedDate: intake.CreatedDate,
                QC_Type__c: intake.QC_Type__c,
                Intake_VendorName__c: intake.Intake_VendorName__c,
                Name: intake.Name,
                Id: intake.Id,
                FX_Intake_Desk_ID__c: intake.FX_Intake_Desk_ID__c,
                FX_Full_Name__c: intake.FX_Full_Name__c,
                Case_Type_Name_del__c: intake.Case_Type_Name_del__c,
                litify_pm__Status__c: intake.litify_pm__Status__c,
                Sub_Status__c: intake.Sub_Status__c,
                Intake_Desk_Status__c: intake.Intake_Desk_Status__c,
                fx_Intake_Desk_Action__c: intake.fx_Intake_Desk_Action__c,
                Automated_QC_Notes__c: intake.Automated_QC_Notes__c,
                litify_pm__Turn_Down_Reason__c: intake.litify_pm__Turn_Down_Reason__c,
                Intake_Note__c: intake.Intake_Note__c
                })
            );

            if (data == undefined || data == null || data == '' || data.length == 0) {
                this.hasData = false;
                this.reportTitle = 'Intake Desk | QC - EOF/Dupe/DQ Report (0)';
            } else {
                this.hasData = true;
                this.reportTitle = 'Intake Desk | QC - EOF/Dupe/DQ Report (' + data.length + ')';
            }
        } else if (error) {
            this.hasData = false;
            this.reportTitle = 'Intake Desk | QC - EOF/Dupe/DQ Report (0)';
        }
    }

    headers = {
        CreatedDate: "Created Date",
        QC_Type__c: "QC Issue",
        Intake_VendorName__c: "Intake Vendor",
        Name: "Intake Name",
        Id: "Intake Id",
        FX_Intake_Desk_ID__c: "Intake Desk ID",
        FX_Full_Name__c: "Full Name",
        Case_Type_Name_del__c: "Case Type",
        litify_pm__Status__c: "Status",
        Sub_Status__c: "Sub-Status",
        //Intake_Desk_Review__c: "Intake Desk Review",
        fx_Intake_Desk_Action__c: "Intake Desk Action",
        Automated_QC_Notes__c: "Intake Desk EOF Reason",
        litify_pm__Turn_Down_Reason__c: "Turn Down Reason",
        Intake_Desk_Status__c: "Intake Desk Status",
        Intake_Note__c: "Intake Note"
    }

    handleRowAction(event) {
        this.intakeId = event.detail.row.Id;
        for (let i in this.intakes) {
            if (this.intakes[i].Id == this.intakeId) {
                this.intake = this.intakes[i];
            }
        }
        this.displayRecord = true;
    }

    hideModal() {
        this.displayRecord = false;
    }

    handleDownloadCSV() {
        exportCSVFile(this.headers, this.intakes, "Intake_Desk__QC_EOF_Dupe_DQ_Report");
    }

    async handleValueChange(event) {
        this.isLoaded = false;

        const result = await updateIntakeStatus({ intakeId: event.detail.data.context, status: event.detail.data.value});
        if (result == 'Success') {
            this.isLoaded = true;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated successfully!',
                    variant: 'success'
                })
            );
        } else {
            this.isLoaded = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: 'Record update failed',
                    variant: 'error'
                })
            );
        }
    }
}