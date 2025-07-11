import { LightningElement, api, track } from 'lwc';
import fetchLookupData from '@salesforce/apex/DynamicQuestionsController.fetchLookupData';
import updateAnswer from '@salesforce/apex/DynamicQuestionsController.updateAnswer';
import fetchLookupRecordById from '@salesforce/apex/DynamicQuestionsController.fetchLookupRecordById';
import { FlowNavigationBlockedEvent, FlowNavigationUnblockedEvent } from 'lightning/flowSupport';

// Debounce utility
function debounce(func, delay) {
    let timeout;
    return function(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), delay);
    };
}

export default class DynamicInputs extends LightningElement {
    @api answerType;
    @api label;
    @api helpText;
    @api options;
    @api required;
    @api lookupObject;
    @api buttonLabel;
    @api flowApiName;
    @api intakeId;
    @api answerId;
    @api StringValue = ''; 
    @api BooleanValue = false; 
    @api NumberValue = null; 
    @api DateValue = null; 
    @api PicklistValue = ''; 
    @api mappedField;

    @track searchKey = '';
    @track multiLookupOptions = [];
    @track selectedRecords = [];
    @track showFlow = false;
    @track flowInputVariables = [];
    selectedRecord = {};
    isSearchLoading = false;
    dirty = false; // Track if input is dirty (changed but not yet blurred/saved)

    _answer = '';
    @api
    get answer() {
        return this._answer;
    }
    set answer(val) {
        this._answer = val;
        this.tryPrepopulateLookup();
    }

    tryPrepopulateLookup() {
        if (this._answer && this.answerType === 'Lookup' && !this.selectedRecord?.value) {
            fetchLookupRecordById({ recordId: this._answer, objectApiName: this.lookupObject })
                .then((record) => {
                    if (record?.Id && record?.Name) {
                        this.selectedRecord = { value: record.Id, label: record.Name };
                        this.handelSelectRecordHelper();
                    }
                })
                .catch((error) => {
                    console.error('Error fetching lookup value from Flow input:', error);
                });
        }
    }

    connectedCallback() {
        if (this.answer) {
            if (this.isMultiSelectPicklist) {
                this.selectedRecords = this.answer.split(',').map(value => ({ value, label: value }));
            } else if (this.isCheckbox) {
                this.BooleanValue = this.answer === 'true';
            }
            if (this.isMultiLookup) {
                const recordIds = this.answer.split(',');
                console.log('Pre-selected multi-lookup values:', recordIds);
                fetchLookupData({ searchKey: '', objectApiName: this.lookupObject, recordIds })
                    .then((data) => {
                        this.selectedRecords = data
                            .filter(record => recordIds.includes(record.Id))
                            .map(record => ({ value: record.Id, label: record.Name }));
                    })
                    .catch((error) => {
                        console.error('Error fetching pre-selected multi-lookup values:', error);
                    });
            }
        } else {
            this.StringValue = this.answer;
        }

        this.tryPrepopulateLookup();
    }

    get picklistOptions() {
        const delimiter = this.isMultiSelectPicklist ? ';' : ',';
        return this.options
            ? this.options.split(delimiter).map(option => ({ label: option.trim(), value: option.trim() }))
            : [];
    }

    get isString() { return this.answerType === 'String'; }
    get isTextArea() { return this.answerType === 'TextArea'; }
    get isPicklist() { return this.answerType === 'Picklist'; }
    get isMultiSelectPicklist() { return this.answerType === 'MultiSelectPicklist'; }
    get isCheckbox() { return this.answerType === 'Checkbox'; }
    get isDate() { return this.answerType === 'Date'; }
    get isInteger() { return this.answerType === 'Integer'; }
    get isDateTime() { return this.answerType === 'DateTime'; }
    get isDecimal() { return this.answerType === 'Decimal'; }
    get isEmail() { return this.answerType === 'Email'; }
    get isPercent() { return this.answerType === 'Percent'; }
    get isURL() { return this.answerType === 'URL'; }
    get isCurrency() { return this.answerType === 'Currency'; }
    get isPhone() { return this.answerType === 'Phone'; }
    get isLookup() { return this.answerType === 'Lookup'; }
    get isMultiLookup() { return this.answerType === 'Multi-Record'; }
    get isAddress() { return this.answerType === 'Address'; }
    get isEncrypted() { return this.answerType === 'Encrypted'; }

    get selectedRecordLabel() {
        return this.selectedRecord?.label || '';
    }

    get selectedRecordId() {
        return this.selectedRecord?.value || '';
    }

    get hasSelectedRecord() {
        return this.selectedRecord && this.selectedRecord.value;
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.isSearchLoading = true;
        if (this.searchKey && this.lookupObject) {
            fetchLookupData({ searchKey: this.searchKey, objectApiName: this.lookupObject, recordIds: null })
                .then((data) => {
                    this.multiLookupOptions = data.map((record) => ({
                        label: record.Name,
                        value: record.Id
                    }));
                    this.isSearchLoading = false;
                })
                .catch((error) => {
                    console.error('Error fetching lookup data:', error);
                });
        } else {
            this.multiLookupOptions = [];
            this.isSearchLoading = false;
        }
    }

    handleMultiLookupSelection(event) {
        const selectedId = event.currentTarget.dataset.id || event.target.getAttribute('data-recid');
        const selectedOption = this.multiLookupOptions.find(option => 
            option.value === selectedId || option.Id === selectedId
        );

        if (!selectedOption) return;

        if (this.isLookup) {
            this.selectedRecord = { value: selectedOption.value || selectedOption.Id, label: selectedOption.label || selectedOption.Name };
            this.answer = this.selectedRecord.value;
            this.handelSelectRecordHelper?.();
        } 
        else if (this.isMultiLookup) {
            const selectedValue = selectedOption.value || selectedOption.Id;
            const selectedLabel = selectedOption.label || selectedOption.Name;

            if (!this.selectedRecords.some(record => record.value === selectedValue)) {
                this.selectedRecords = [...this.selectedRecords, { value: selectedValue, label: selectedLabel }];
            }

            this.answer = this.selectedRecords.map(r => r.value).join(',');
        }

        if (this.answerId) {
            updateAnswer({ answerId: this.answerId, answerValue: this.answer })
                .then(() => console.log('Saved answer from selection:', this.answer))
                .catch(error => console.error('Error saving answer:', error));
        }

        this.searchKey = '';
        this.multiLookupOptions = [];
    }

    handleRemoveSelectedRecord() {
        this.selectedRecord = {};
        this.answer = '';

        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        if (searchBoxWrapper) {
            searchBoxWrapper.classList.remove('slds-hide');
            searchBoxWrapper.classList.add('slds-show');
        }

        if (this.answerId) {
            updateAnswer({ answerId: this.answerId, answerValue: '' })
                .then(() => console.log('Answer__c record cleared'))
                .catch((error) => console.error('Error clearing Answer__c record:', error));
        }
    }

    // Debounced version of updateAnswer
    debouncedUpdateAnswer = debounce(function(answerId, answerValue) {
        console.log('Debounced: Calling updateAnswer Apex method...');
        updateAnswer({ answerId, answerValue })
            .then(() => console.log('Answer__c record updated successfully'))
            .catch((error) => console.error('Error updating Answer__c record:', error))
            .finally(() => {
                this.dirty = false;
            });
    }, 300);

    handleChange(event) {
        this.dirty = true;
        const value = event.target.value;
        const inputElement = event.target;

        let isValid = true;

        // Custom validation for the Encrypted field (SSN pattern)
        if (this.isEncrypted) {
            const fullSSNPattern = /^(?!000|666|9\d{2})\d{3}[- ]?(?!00)\d{2}[- ]?(?!0000)\d{4}$/;
            const lastFourPattern = /^(?!0000)\d{4}$/;

            if (!fullSSNPattern.test(value) && !lastFourPattern.test(value)) {
                inputElement.setCustomValidity('Please enter a valid 9-digit SSN or the last 4 digits. Dashes optional.');
                isValid = false;
            } else {
                inputElement.setCustomValidity('');
            }
            inputElement.reportValidity();
        }

        if (this.required && !value) {
            inputElement.reportValidity();
            isValid = false;
        }

        // Normalize value for picklist and date
        let normalizedValue = value;
        if (this.isPicklist || this.isMultiSelectPicklist) {
            normalizedValue = Array.isArray(value) ? value.join(',') : (value ?? '');
        }
        if (this.isDate || this.isDateTime) {
            normalizedValue = value ?? '';
        }

        if (this.isCheckbox) {
            this.answer = event.target.checked.toString();
        } else if (this.isPicklist || this.isMultiSelectPicklist) {
            this.answer = normalizedValue;
        } else if (this.isAddress) {
            const address = event.detail;
            this.answer = JSON.stringify({
                street: address.street,
                city: address.city,
                province: address.province,
                postalCode: address.postalCode,
                country: address.country
            });
        } else if (this.isEncrypted) {
            if (isValid) {
                this.answer = value ? value.toString() : '';
            } else {
                // Don't update answer if invalid
                this.dirty = true;
                return;
            }
        } else if (this.isDate || this.isDateTime) {
            this.answer = normalizedValue;
        } else {
            this.answer = value ? value.toString() : '';
        }

        // Debug logs for troubleshooting
        console.log('handleChange: answerId:', this.answerId);
        console.log('handleChange: answer:', this.answer);
        console.log('handleChange: answerType:', this.answerType);

        // Debounced save to server if answerId is present
        if (this.answerId) {
            this.debouncedUpdateAnswer(this.answerId, this.answer);
        } else {
            this.dirty = false;
        }
    }

    handelSelectRecordHelper() {
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        if (lookupInputContainer) lookupInputContainer.classList.remove('slds-is-open');

        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        if (searchBoxWrapper) {
            searchBoxWrapper.classList.remove('slds-show');
            searchBoxWrapper.classList.add('slds-hide');
        }
    }

    toggleResult(event) {
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer?.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                clsList?.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList?.remove('slds-is-open');
                break;
        }
    }

    handleButtonClick() {
        console.log('Button clicked:', this.buttonLabel); 
        if (this.flowApiName) {
            console.log('Flow name:', this.flowApiName); // Log the flow name
            this.flowInputVariables = [
                {
                    name: 'intakeId',
                    type: 'String',
                    value: this.intakeId
                }
            ];
            this.showFlow = true;
        }
    }

    closeModal() {
        this.showFlow = false;
    }    

    handleFlowStatusChange(event) {
        console.log('Flow status:', event.detail.status);

        if (event.detail.status === 'FINISHED' && event.detail.outputVariables) {
            console.log('Flow finished with output variables:', event.detail.outputVariables);

            const recordIdsOutput = event.detail.outputVariables.find(v => v.name === 'recordIds');
            if (recordIdsOutput?.value) {
                console.log('Record IDs received from flow:', recordIdsOutput.value);
                this.answer = recordIdsOutput.value;

                const recordIds = this.answer.split(',');

                // Fetch all records corresponding to the returned IDs
                fetchLookupData({ searchKey: '', objectApiName: this.lookupObject, recordIds })
                    .then((data) => {
                        const newRecords = data.map(record => ({ value: record.Id, label: record.Name }));

                        // Merge new records with existing selectedRecords, avoiding duplicates
                        const mergedRecords = recordIds.map(id => {
                            return newRecords.find(record => record.value === id) ||
                                   this.selectedRecords.find(record => record.value === id);
                        }).filter(record => record); // Remove undefined entries

                        // Update selectedRecords with the merged array
                        this.selectedRecords = [...mergedRecords];
                        console.log('Pills updated with merged records:', this.selectedRecords);
                    })
                    .catch((error) => {
                        console.error('Error fetching selected records for pills:', error);
                    });

                // Update the Answer__c record
                if (this.answerId) {
                    updateAnswer({ answerId: this.answerId, answerValue: this.answer })
                        .then(() => console.log('Answer__c record updated with flow output'))
                        .catch(error => console.error('Error saving Answer__c from flow output:', error));
                }
            }

            this.showFlow = false; // Hide the flow modal
        }
    }
}