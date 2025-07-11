import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from 'lightning/platformResourceLoader';

import fileUploaderStyles from '@salesforce/resourceUrl/fileUploaderStyles';

export default class FileUploader extends LightningElement {
    @api recordId;

    renderedCallback() {
        Promise.all([
            loadStyle(this, fileUploaderStyles) // load file uploader drag/drop sizing
        ]);
    }

    get acceptedFormats() {
        // only accept csv, xls and xlsx files
        return ['.csv', '.xls', '.xlsx'];
    }

    handleUploadFinished(event) {
        // show toast on successful upload
        // errors are handled within the file uploader
        const evt = new ShowToastEvent({
            title: 'Success',
            message: ' File uploaded  successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }
}