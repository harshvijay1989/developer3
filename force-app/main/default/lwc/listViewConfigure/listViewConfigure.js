import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getListUi } from 'lightning/uiListApi';
import insertList from '@salesforce/apex/ListViewController.insertList';
import renameList from '@salesforce/apex/ListViewController.renameList';
import deleteList from '@salesforce/apex/ListViewController.deleteList';
// import getRecord from '@salesforce/apex/ListViewController.getRecord';

const COLS = [
    { label: 'First Name', fieldName: 'FirstName', editable: true },
    { label: 'Last Name', fieldName: 'LastName', editable: true },
    { label: 'Title', fieldName: 'Title', editable: true },
    { label: 'Phone', fieldName: 'Phone', type: 'phone', editable: true },
    { label: 'Email', fieldName: 'Email', type: 'email', editable: true }
];
export default class ListViewConfigure extends LightningElement {
    columns = COLS;
    draftValues = [];
    @api objectApiName = '';
    @api fieldSetName = '';
    title_1 = '';
    titleApiName = '';
    @track titleName = '';
    @track listName='';
    @track listApiName='';

    // @wire(getContacts)
    // contacts;
    // get fieldList() {
    //     return Object.entries(this.records.data[0]);
    // }
    @track fieldList = [];
    @track records = [];

    // @wire(getRecord, { objName: '$objectApiName' })
    // wiredRecords({ error, data }) {
    //     if (data) {
    //         console.log('Data : '+JSON.stringify(data));
    //         this.fieldList = Object.keys(data[0]);
    //         const tableData = data.map(t => Object.values(t));
    //         console.log('FieldList : '+JSON.stringify(this.fieldList)); 
    //         this.records = tableData;
    //         //console.log('record : '+JSON.stringify(this.records));
    //         for(var i=0; i<this.records.length;i++){
    //             for(var j=0; j<this.fieldList.length;j++){

    //                 //console.log('Field : '+this.fieldList[j]+'record : '+this.records[i][j]);
    //             }
    //         }
    //     }else if (error) {
    //         console.error('Error retrieving list view:', error);
    //     }
    // }

    // async handleSave(event) {
    //     const updatedFields = event.detail.draftValues;
    //     this.draftValues = [];

    //     try {
    //         await updateContacts({ contactsForUpdate: updatedFields });
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Success',
    //                 message: 'Contacts updated',
    //                 variant: 'success'
    //             })
    //         );
    //         await refreshApex(this.contacts);
    //     } catch (error) {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error while updating or refreshing records',
    //                 message: error.body.message,
    //                 variant: 'error'
    //             })
    //         );
    //     }
    // }
    showDropdown = false;
    showNewModal = false;

    toggleDropdown() {
        this.showDropdown = !this.showDropdown;
    }

    @track listViewData;
    showListViewDropdown = false;

    @wire(getListUi, { objectApiName: '$objectApiName' })
    listUi({ error, data }) {
        if (data) {
            console.log('Data@  : ' + JSON.stringify(data));
            this.listViewData = data.lists;
            this.title_1 = this.listViewData[0].label;
            this.titleApiName = this.listViewData[0].apiName;
        } else if (error) {
            console.error('Error retrieving list view:', error);
        }
    }

    handleNewClick() {
        this.showNewModal = true;
        this.showDropdown = false;
    }
    closeNewModal() {
        this.showNewModal = false;
    }

    handleSwitchListView() {
        this.showListViewDropdown = !this.showListViewDropdown;
    }
    handleListViewClick(event) {
        const listViewApiName = event.target.dataset.value;
        this.title_1 = listViewApiName;
        this.titleApiName = event.target.dataset.name;
        this.showListViewDropdown = false;
    }

    showRenameModal = false;
    handleRenameClick() {
        this.showRenameModal = true;
        this.showDropdown = false;
    }
    closeRenameModal() {
        this.showRenameModal = false;
    }
    handleRename(event) {
        this.titleName = event.target.value;
    }
    handleRenameSave() {
        this.showRenameModal = false;
        const recId ='';
        console.log('Title : ' + this.title_1);
        for(var i=0;i<this.listViewData.length;i++){
            if(this.listViewData[i].label == this.title_1){
                console.log(this.listViewData[i].label);
                this.recId = this.listViewData[i].id;
                break;
            }
        }
        console.log('Api Name : '+this.titleApiName);
        console.log('Obj Name : '+this.objectApiName);
        renameList({ apiName: this.titleApiName, label:this.titleName, objName : this.objectApiName})
            .then(result => {
                console.log('It is successfull');   
            })
            .catch(error => {
                console.error('It is an error ====>',JSON.stringify(error) );
            })
    }
    handleName(event){
        this.listName = event.target.value;
        // console.log('List name : '+this.listName);
    }
    handleApiName(event){
        this.listApiName = event.target.value;
        //console.log('List Api name : '+this.listApiName);
    }
    handleNewSave(){
        console.log('Obj name : '+this.objectApiName);
        this.showNewModal = false;
        insertList({ name: this.listName, apiName:this.listApiName, objName : this.objectApiName})
            .then(result => {
                console.log('It is successfull');   
            })
            .catch(error => {
                console.error('It is an error ====>',JSON.stringify(error) );
            })
    }
    @track deleteListModal = false;
    handleDeleteClick(){
        this.showDropdown=false;
        this.deleteListModal = true;
    }
    closeModal() {
        this.deleteListModal = false;
    }
    deleteListView() {
        this.deleteListModal = false;
        deleteList({apiName:this.titleApiName, objName : this.objectApiName})
            .then(result => {
                console.log('It is successfull');   
            })
            .catch(error => {
                console.error('It is an error ====>',JSON.stringify(error) );
            })
    }
    showCloneModal = false;
    handleCloneClick(){
        this.showDropdown = false;
        this.showCloneModal = true;
    }
    closeCloneModal(){
        this.showCloneModal = false;
    }
    showFieldsModal = false;
    handleFieldsClick(){
        this.showDropdown = false;
        this.showFieldsModal = true;
        
    }
    closeFieldsModal(){
        this.showFieldsModal = false;
    }
}