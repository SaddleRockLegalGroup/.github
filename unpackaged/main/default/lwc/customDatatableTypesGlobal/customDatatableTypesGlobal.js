import LightningDatatable from 'lightning/datatable';
import customPicklist from './customPicklist.html';

export default class CustomDatatableTypesGlobal extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: customPicklist,
            standardCellLayout: true,
            typeAttributes: ['placeholder', 'options', 'value', 'context', 'variant', 'name']
        }
    };
}