import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import listLicenses from '@salesforce/apex/LicenseAdminController.listLicenses';
import createLicense from '@salesforce/apex/LicenseAdminController.createLicense';
import revokeLicense from '@salesforce/apex/LicenseAdminController.revokeLicense';
import extendLicense from '@salesforce/apex/LicenseAdminController.extendLicense';

const COLUMNS = [
    { label: 'Number', fieldName: 'licenseNumber' },
    { label: 'Customer', fieldName: 'customerName' },
    { label: 'Product', fieldName: 'productCode' },
    { label: 'Seats', fieldName: 'seatCount', type: 'number' },
    { label: 'In use', fieldName: 'seatsInUse', type: 'number' },
    { label: 'Expiry', fieldName: 'expiryDate' },
    { label: 'Status', fieldName: 'status' },
    { label: 'Key', fieldName: 'maskedKey' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'Copy key', name: 'copy' },
                { label: 'Extend', name: 'extend' },
                { label: 'Revoke', name: 'revoke' }
            ]
        }
    }
];

export default class LicenseAdmin extends LightningElement {
    columns = COLUMNS;
    licenses = [];
    isLoading = true;
    isSaving = false;
    showCreate = false;
    showExtend = false;
    selectedId;
    issuedKey;

    customerName = '';
    accountId = null;
    productCode = '';
    seatCount = 1;
    expiryDate = '';
    extendDate = '';

    connectedCallback() {
        this.expiryDate = this.todayIso();
        this.load();
    }

    get isEmpty() {
        return !this.isLoading && this.licenses.length === 0;
    }

    get today() {
        return this.todayIso();
    }

    async load() {
        this.isLoading = true;
        try {
            this.licenses = await listLicenses();
        } catch (error) {
            this.toast('Could not load licenses', this.errorMessage(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    openCreate() {
        this.showCreate = true;
        this.showExtend = false;
        this.issuedKey = undefined;
    }

    cancelCreate() {
        this.showCreate = false;
    }

    cancelExtend() {
        this.showExtend = false;
        this.selectedId = undefined;
    }

    handleCustomerName(event) {
        this.customerName = event.target.value;
    }

    handleAccountChange(event) {
        this.accountId = event.detail.recordId;
    }

    handleProductCode(event) {
        this.productCode = event.target.value;
    }

    handleSeatCount(event) {
        this.seatCount = Number(event.target.value);
    }

    handleExpiryDate(event) {
        this.expiryDate = event.target.value;
    }

    handleExtendDate(event) {
        this.extendDate = event.target.value;
    }

    async saveCreate() {
        this.isSaving = true;
        try {
            const created = await createLicense({
                customerName: this.customerName,
                accountId: this.accountId,
                productCode: this.productCode,
                seatCount: this.seatCount,
                expiryDate: this.expiryDate
            });
            this.issuedKey = created.licenseKey;
            this.showCreate = false;
            this.customerName = '';
            this.accountId = null;
            this.productCode = '';
            this.seatCount = 1;
            this.toast('License created', 'Copy the new key. It is stored on the license.', 'success');
            await this.load();
        } catch (error) {
            this.toast('Could not create the license', this.errorMessage(error), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    async saveExtend() {
        this.isSaving = true;
        try {
            const updated = await extendLicense({
                licenseId: this.selectedId,
                newExpiry: this.extendDate
            });
            this.issuedKey = updated.licenseKey;
            this.showExtend = false;
            this.toast('License extended', 'The key was re-signed. Copy the new key.', 'success');
            await this.load();
        } catch (error) {
            this.toast('Could not extend the license', this.errorMessage(error), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    async handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'copy':
                await this.copyKey(row.licenseKey);
                break;
            case 'extend':
                this.selectedId = row.licenseId;
                this.extendDate = row.expiryDate < this.todayIso() ? this.todayIso() : row.expiryDate;
                this.showExtend = true;
                this.showCreate = false;
                break;
            case 'revoke':
                await this.revoke(row);
                break;
            default:
                break;
        }
    }

    async revoke(row) {
        if (row.status === 'Revoked') {
            this.toast('Already revoked', 'This license is already revoked.', 'info');
            return;
        }
        const confirmed = await LightningConfirm.open({
            message: `Revoke ${row.licenseNumber} for ${row.customerName}? Validation will fail immediately.`,
            label: 'Revoke license',
            theme: 'warning'
        });
        if (!confirmed) {
            return;
        }
        this.isSaving = true;
        try {
            await revokeLicense({ licenseId: row.licenseId });
            this.toast('License revoked', `${row.licenseNumber} is revoked.`, 'success');
            await this.load();
        } catch (error) {
            this.toast('Could not revoke the license', this.errorMessage(error), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    copyIssuedKey() {
        return this.copyKey(this.issuedKey);
    }

    async copyKey(value) {
        try {
            await navigator.clipboard.writeText(value);
            this.toast('Copied', 'The license key is on the clipboard.', 'success');
        } catch (error) {
            this.issuedKey = value;
            this.toast('Copy the key from the page', 'The browser blocked clipboard access.', 'info');
        }
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    errorMessage(error) {
        if (error && error.body && error.body.message) {
            return error.body.message;
        }
        return 'Something went wrong.';
    }

    todayIso() {
        const now = new Date();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        return `${now.getFullYear()}-${month}-${day}`;
    }
}
