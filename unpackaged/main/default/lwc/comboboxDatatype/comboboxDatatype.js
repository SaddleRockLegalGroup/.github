import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/customPicklistStyles';

export default class ComboboxDatatype extends LightningElement {
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api variant;
    @api name;
    @api typeAttributes;

    showPicklist = false;
    picklistValueChanged = false;

    renderedCallback() {
        Promise.all([
            loadStyle(this, CustomDataTableResource),
        ]).then(() => { });
        if (!this.guid) {
            this.guid = this.template.querySelector('.picklistBlock').getAttribute('id');
            this.dispatchEvent(
                new CustomEvent('itemregister', {
                    bubbles: true,
                    composed: true,
                    detail: {
                        callbacks: {
                            reset: this.reset,
                        },
                        template: this.template,
                        guid: this.guid,
                        name: 'c-combobox-datatype'
                    }
                })
            );
        }
    }

    dispatchCustomEvent(eventName, context, value, name) {
        this.dispatchEvent(new CustomEvent(eventName, {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: context, value: value, name: name }
            }
        }));
    }

    async handleChange(event) {
        event.preventDefault();
        this.picklistValueChanged = true;
        this.value = event.detail.value;
        console.log('val'+this.value);           
        this.showPicklist = false;
        this.dispatchCustomEvent('valuechange', this.context, this.value, this.name);
    }

    handleClick(event) {
        event.preventDefault();
        event.stopPropagation();
        this.showPicklist = true;
        this.dispatchCustomEvent('edit', this.context, this.value, this.name);
    }
    
    handleBlur(event) {
        event.preventDefault();
        this.showPicklist = false;
        if (!this.picklistValueChanged)
            this.dispatchCustomEvent('customtblur', this.context, this.value, this.name);
    }

    reset = (context) => {
        if (this.context !== context) {
            this.showPicklist = false;
        }
    }
}