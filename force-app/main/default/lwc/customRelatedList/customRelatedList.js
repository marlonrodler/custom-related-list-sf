import { LightningElement, api, track } from 'lwc';
import getRelatedListFields from '@salesforce/apex/CustomRelatedListController.getRelatedListFields';
import getRecords from '@salesforce/apex/CustomRelatedListController.getRecords';

export default class CustomRelatedList extends LightningElement {

    @api recordId;
    @api relatedObject;
    @api relatedFields;
    @track fields = [];
    @track fieldsToDisplay = [];
    @track records = [];
    @track relatedListApiNames = [];

    connectedCallback() {
        this.handlerSplitFields();
        this.handlerGetRelatedListFields(this.relatedObject, this.fields);
        this.handlerGetRecords(this.recordId, this.relatedObject, this.fields);
    }

    handlerSplitFields() {
        if (!!this.relatedFields) {
            this.relatedFields.split(',').forEach(field => {
                this.fields.push(field.trim());
            });
        }
    }

    async handlerGetRelatedListFields(relatedObject, fields) {
        try {
            let result = await getRelatedListFields({ objectName: relatedObject, relatedListNames: fields });
            if(result.error) {
                console.log(result.error);
            }
            for (var key in result.mapRelatedListFields) {
                this.fieldsToDisplay.push({ value: result.mapRelatedListFields[key], key: key });
            }
            this.relatedListApiNames = result.relatedListApiNames;
        } catch (error) {
            console.log(error);
        }
    }

    async handlerGetRecords(recordId, relatedObject, fields) {
        try {
            let response = await getRecords({ recordId: recordId, objectName: relatedObject, relatedListNames: fields });

            let result = {}
            let arrRecords = [];
            response.forEach(item => {
                for (let key in item) {
                    this.extract(result, item, key, key)
                }
                arrRecords.push(result);
                result = {};
            })

            this.generateRegistries(arrRecords, this.fieldsToDisplay);
        } catch (error) {
            console.error(error);
        }
    }

    extract(result, item, key, fullKey) {
        if (typeof item[key] != 'object') {
            result[fullKey] = item[key];
            return result;
        }
        for (let i in item[key]) {
            this.extract(result, item[key], i, fullKey + '.' + i)
        }
        return result;
    }

    generateRegistries(records, fieldsToDisplay) {
        records.forEach(record => {
            let registry = [];
            fieldsToDisplay.forEach(field => {
                registry.push(record[field.key]);
            });
            this.records.push(registry);
        });
    }

}
