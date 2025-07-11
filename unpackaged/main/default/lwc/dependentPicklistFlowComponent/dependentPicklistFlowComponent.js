import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport'; // NEW import

export default class DependentPicklist extends LightningElement {
    @api objectApiName;
    objectRecordTypeId = '';

    @api picklist1Value;
    @api picklist1Field;

    @api picklist2Field;
    @api picklist2Label;
    @api picklist2Value;
    @api picklist2Placeholder;
    picklist2Data;
    picklist2Options;

    @api picklist3Field;
    @api picklist3Label;
    @api picklist3Value;
    @api picklist3Placeholder;
    picklist3Data;
    picklist3Options;

    @track objectInfo;
    @track picklistFieldValues;
    @track picklist3DataType = '';
    @track picklistsInitialized = false;

    // Save the array for the dual-listbox
    @track picklist3ValueArray = [];

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ data, error }) {
        if (data) {
            this.objectInfo = data;
            const recordTypeInfos = data.recordTypeInfos;
            this.objectRecordTypeId = Object.keys(recordTypeInfos).find(
                (recordTypeInfo) => recordTypeInfos[recordTypeInfo].name === 'Master'
            );
            this.tryInitializePicklists();
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: '$objectApiName', recordTypeId: '$objectRecordTypeId' })
    wiredPicklistData({ data, error }) {
        if (data) {
            this.picklistFieldValues = data.picklistFieldValues;
            this.tryInitializePicklists();
        }
    }

    tryInitializePicklists() {
        if (!this.objectInfo || !this.picklistFieldValues || this.picklistsInitialized) return;
        this.picklistsInitialized = true;

        if (this.picklist2Field && this.picklistFieldValues[this.picklist2Field]) {
            this.picklist2Data = this.picklistFieldValues[this.picklist2Field];
            if (this.picklist1Value && this.picklist1Value !== '') {
                const key = this.picklist2Data.controllerValues[this.picklist1Value];
                this.picklist2Options = this.picklist2Data.values.filter(opt => opt.validFor.includes(key))
                    .map(opt => ({ label: opt.label, value: opt.value }));
            } else {
                this.picklist2Options = this.picklist2Data.values.map(opt => ({ label: opt.label, value: opt.value }));
            }
        }

        if (this.picklist3Field && this.picklistFieldValues[this.picklist3Field]) {
            this.picklist3Data = this.picklistFieldValues[this.picklist3Field];
            const key = this.picklist3Data.controllerValues?.[this.picklist2Value];
            if (key != null) {
                this.picklist3Options = this.picklist3Data.values.filter(opt => opt.validFor.includes(key))
                    .map(opt => ({ label: opt.label, value: opt.value }));
            } else {
                this.picklist3Options = [];
            }
        }

        if (this.objectInfo.fields[this.picklist3Field]) {
            const type = this.objectInfo.fields[this.picklist3Field].dataType;
            this.picklist3DataType = type;
        }


        // Normalize and deserialize picklist3Value if MultiSelect
        if (this.isPicklist3MultiSelect && this.picklist3Value) {

            // Array comes with a unique serialized string
            if (
                Array.isArray(this.picklist3Value) &&
                this.picklist3Value.length === 1 &&
                typeof this.picklist3Value[0] === 'string' &&
                this.picklist3Value[0].includes(';')
            ) {
                console.warn('Unwrapping serialized array:', this.picklist3Value);
                this.picklist3Value = this.picklist3Value[0];
            }

            // Deserialize array
            if (typeof this.picklist3Value === 'string') {
                this.picklist3ValueArray = this.picklist3Value.split(';');
                console.log('Deserialized string -> array:', [...this.picklist3ValueArray]);
            } else if (Array.isArray(this.picklist3Value)) {
                this.picklist3ValueArray = [...this.picklist3Value];
                console.log('picklist3Value is already array:', [...this.picklist3ValueArray]);
            } else {
                console.warn('Unexpected picklist3Value type:', typeof this.picklist3Value);
            }
        }
    }

    get isPicklist3Visible() {
        return this.picklist3Options && this.picklist3Options.length > 0;
    }

    get isPicklist3MultiSelect() {
        return this.picklist3DataType === 'MultiPicklist';
    }

    /*handleComboChange(event) {
        if (event.target.name === this.picklist2Field) {
            this.picklist2Value = event.detail.value;
            // When changing picklist2, reset picklist3Value and its array
            this.picklist3Value = '';
            this.picklist3ValueArray = [];
            const key = this.picklist3Data.controllerValues[this.picklist2Value];
            this.picklist3Options = this.picklist3Data.values.filter(opt => opt.validFor.includes(key))
                .map(opt => ({ label: opt.label, value: opt.value }));
            this.syncPicklist3ValueArray();
        }

        if (event.target.name === this.picklist3Field) {
            if (this.isPicklist3MultiSelect) {
                // Save the array locally and serialize in picklist3Value
                this.picklist3ValueArray = [...event.detail.value];
                this.picklist3Value = this.picklist3ValueArray.join(';');
                for (let i = 0; i < this.picklist3ValueArray.length; i++) {
                    console.log(this.picklist3ValueArray[i]);
                }
                console.log('Serialized picklist3Value:', this.picklist3Value);
            } else {
                this.picklist3Value = event.detail.value;
            }
        }
    }*/

    handleComboChange(event) {
        if (event.target.name === this.picklist2Field) {
            this.picklist2Value = event.detail.value;
            this.dispatchEvent(new FlowAttributeChangeEvent('picklist2Value', this.picklist2Value));

            // Reset picklist3
            this.picklist3Value = '';
            this.picklist3ValueArray = [];

            const key = this.picklist3Data.controllerValues[this.picklist2Value];
            this.picklist3Options = this.picklist3Data.values.filter(opt => opt.validFor.includes(key))
                .map(opt => ({ label: opt.label, value: opt.value }));

            this.syncPicklist3ValueArray();
        }

        if (event.target.name === this.picklist3Field) {
            if (this.isPicklist3MultiSelect) {
                this.picklist3ValueArray = [...event.detail.value];
                this.picklist3Value = this.picklist3ValueArray.join(';');
            } else {
                this.picklist3Value = event.detail.value;
            }
            this.dispatchEvent(new FlowAttributeChangeEvent('picklist3Value', this.picklist3Value));
        }
    }

    syncPicklist3ValueArray() {
        if (!this.picklist3Field || !this.picklist3Options) return;

        if (this.isPicklist3MultiSelect && this.picklist3Value) {
            if (typeof this.picklist3Value === 'string') {
                this.picklist3ValueArray = this.picklist3Value.split(';');
                console.log('string → array:', [...this.picklist3ValueArray]);
            } else if (Array.isArray(this.picklist3Value)) {
                this.picklist3ValueArray = [...this.picklist3Value];
                console.log('already array:', [...this.picklist3ValueArray]);
            }
        }
    }
}