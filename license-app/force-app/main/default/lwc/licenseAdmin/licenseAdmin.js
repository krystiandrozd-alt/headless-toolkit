import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import listLicenses from '@salesforce/apex/LicenseAdminController.listLicenses';
import listOfferings from '@salesforce/apex/LicenseAdminController.listOfferings';
import installSampleCatalog from '@salesforce/apex/LicenseAdminController.installSampleCatalog';
import previewIssue from '@salesforce/apex/LicenseAdminController.previewIssue';
import createLicense from '@salesforce/apex/LicenseAdminController.createLicense';
import createLicenseWithTier from '@salesforce/apex/LicenseAdminController.createLicenseWithTier';
import attachAddOn from '@salesforce/apex/LicenseAdminController.attachAddOn';
import revokeLicense from '@salesforce/apex/LicenseAdminController.revokeLicense';
import extendLicense from '@salesforce/apex/LicenseAdminController.extendLicense';
import topUpCredits from '@salesforce/apex/LicenseAdminController.topUpCredits';
import listLedger from '@salesforce/apex/LicenseAdminController.listLedger';

const COLUMNS = [
    { label: 'Number', fieldName: 'licenseNumber' },
    { label: 'Customer', fieldName: 'customerName' },
    { label: 'Product', fieldName: 'productCode' },
    { label: 'Tier', fieldName: 'tierCode' },
    { label: 'Seats', fieldName: 'seatCount', type: 'number' },
    { label: 'In use', fieldName: 'seatsInUse', type: 'number' },
    { label: 'Credits', fieldName: 'creditBalance', type: 'number' },
    { label: 'Expiry', fieldName: 'expiryDate' },
    { label: 'Status', fieldName: 'status' },
    { label: 'Key', fieldName: 'maskedKey' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'Copy key', name: 'copy' },
                { label: 'Credits', name: 'credits' },
                { label: 'Add-on', name: 'addon' },
                { label: 'Extend', name: 'extend' },
                { label: 'Revoke', name: 'revoke' }
            ]
        }
    }
];

const LEDGER_COLUMNS = [
    { label: 'Entry', fieldName: 'entryNumber' },
    { label: 'Type', fieldName: 'entryType' },
    { label: 'Amount', fieldName: 'amount', type: 'number' },
    { label: 'Balance after', fieldName: 'balanceAfter', type: 'number' },
    { label: 'Note', fieldName: 'note' },
    { label: 'When', fieldName: 'createdDate' }
];

export default class LicenseAdmin extends LightningElement {
    columns = COLUMNS;
    ledgerColumns = LEDGER_COLUMNS;
    licenses = [];
    offerings = [];
    ledger = [];
    isLoading = true;
    isSaving = false;
    showCreate = false;
    showExtend = false;
    showCredits = false;
    showAddOn = false;
    selectedId;
    issuedKey;
    previewWarnings = '';
    previewSummary = '';

    customerName = '';
    accountId = null;
    productCode = '';
    tierCode = '';
    selectedAddOns = [];
    seatCount = 1;
    expiryDate = '';
    extendDate = '';
    topUpAmount = 100;
    topUpNote = '';
    topUpKey = '';
    addOnCode = '';

    connectedCallback() {
        this.expiryDate = this.todayIso();
        this.topUpKey = this.newKey('topup');
        this.load();
    }

    get isEmpty() {
        return !this.isLoading && this.licenses.length === 0;
    }

    get catalogEmpty() {
        return this.offerings.length === 0;
    }

    get today() {
        return this.todayIso();
    }

    get tierOptions() {
        const product = (this.productCode || '').trim();
        return this.offerings
            .filter((offering) => offering.offeringType === 'Tier' && (!product || offering.productCode === product))
            .map((offering) => ({
                label: `${offering.label} (${offering.code})`,
                value: offering.code
            }));
    }

    get hasAddOnChoices() {
        return this.addOnOptions.length > 0;
    }

    get addOnOptions() {
        const product = (this.productCode || '').trim();
        return this.offerings
            .filter((offering) => offering.offeringType === 'AddOn' && (!product || offering.productCode === product))
            .map((offering) => ({
                label: `${offering.label} (${offering.code})`,
                value: offering.code
            }));
    }

    get selectedLicense() {
        return this.licenses.find((row) => row.licenseId === this.selectedId);
    }

    get creditHeadline() {
        const balance = this.selectedLicense ? this.selectedLicense.creditBalance : 0;
        return `Balance: ${balance}. A repeated idempotency key does not add credits twice.`;
    }

    async load() {
        this.isLoading = true;
        try {
            const [licenses, offerings] = await Promise.all([listLicenses(), listOfferings()]);
            this.licenses = licenses;
            this.offerings = offerings;
        } catch (error) {
            this.toast('Could not load licenses', this.errorMessage(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async loadSample() {
        this.isSaving = true;
        try {
            await installSampleCatalog();
            this.offerings = await listOfferings();
            this.toast('Sample catalog ready', 'Starter, Pro, Enterprise, and the sample add-ons are available.', 'success');
        } catch (error) {
            this.toast('Could not install the sample catalog', this.errorMessage(error), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    openCreate() {
        this.showCreate = true;
        this.showExtend = false;
        this.showCredits = false;
        this.showAddOn = false;
        this.issuedKey = undefined;
        this.previewWarnings = '';
        this.previewSummary = '';
    }

    cancelCreate() {
        this.showCreate = false;
    }

    cancelExtend() {
        this.showExtend = false;
        this.selectedId = undefined;
    }

    cancelCredits() {
        this.showCredits = false;
    }

    cancelAddOn() {
        this.showAddOn = false;
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

    handleTierChange(event) {
        this.tierCode = event.detail.value;
        const tier = this.offerings.find((offering) => offering.code === this.tierCode);
        if (tier) {
            this.productCode = tier.productCode;
            if (tier.defaultSeats) {
                this.seatCount = tier.defaultSeats;
            }
            if (tier.durationDays) {
                this.expiryDate = this.plusDays(tier.durationDays);
            }
        }
        this.refreshPreview();
    }

    handleAddOns(event) {
        this.selectedAddOns = event.detail.value;
        this.refreshPreview();
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

    handleTopUpAmount(event) {
        this.topUpAmount = Number(event.target.value);
    }

    handleTopUpNote(event) {
        this.topUpNote = event.target.value;
    }

    handleTopUpKey(event) {
        this.topUpKey = event.target.value;
    }

    handleAddOnCode(event) {
        this.addOnCode = event.detail.value;
    }

    async refreshPreview() {
        if (!this.tierCode) {
            this.previewWarnings = '';
            this.previewSummary = '';
            return;
        }
        try {
            const preview = await previewIssue({
                customerName: this.customerName,
                accountId: this.accountId,
                productCode: this.productCode,
                tierCode: this.tierCode,
                addOnCodes: this.selectedAddOns
            });
            this.previewWarnings = preview.allowed ? '' : preview.warnings;
            this.previewSummary = preview.allowed
                ? `${preview.seatCount} seats, expires ${preview.expiryDate}, ${preview.includedCredits} credits, features ${preview.features || 'none'}.`
                : '';
        } catch (error) {
            this.previewWarnings = this.errorMessage(error);
            this.previewSummary = '';
        }
    }

    async saveCreate() {
        this.isSaving = true;
        try {
            const created = this.tierCode
                ? await createLicenseWithTier({
                      customerName: this.customerName,
                      accountId: this.accountId,
                      tierCode: this.tierCode,
                      seatCount: this.seatCount,
                      expiryDate: this.expiryDate,
                      addOnCodes: this.selectedAddOns
                  })
                : await createLicense({
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
            this.tierCode = '';
            this.selectedAddOns = [];
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

    async saveTopUp() {
        this.isSaving = true;
        try {
            const result = await topUpCredits({
                licenseId: this.selectedId,
                amount: this.topUpAmount,
                idempotencyKey: this.topUpKey,
                note: this.topUpNote
            });
            this.toast(result.status, result.message, result.status === 'SUCCESS' || result.status === 'IDEMPOTENT_REPLAY' ? 'success' : 'warning');
            this.topUpKey = this.newKey('topup');
            this.ledger = await listLedger({ licenseId: this.selectedId });
            await this.load();
        } catch (error) {
            this.toast('Could not top up credits', this.errorMessage(error), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    async saveAddOn() {
        this.isSaving = true;
        try {
            await attachAddOn({ licenseId: this.selectedId, addOnCode: this.addOnCode });
            this.showAddOn = false;
            this.toast('Add-on attached', this.addOnCode, 'success');
            await this.load();
        } catch (error) {
            this.toast('Could not attach the add-on', this.errorMessage(error), 'error');
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
                this.showCredits = false;
                this.showAddOn = false;
                break;
            case 'credits':
                await this.openCredits(row);
                break;
            case 'addon':
                this.selectedId = row.licenseId;
                this.productCode = row.productCode;
                this.addOnCode = '';
                this.showAddOn = true;
                this.showCreate = false;
                this.showExtend = false;
                this.showCredits = false;
                break;
            case 'revoke':
                await this.revoke(row);
                break;
            default:
                break;
        }
    }

    async openCredits(row) {
        this.selectedId = row.licenseId;
        this.showCredits = true;
        this.showCreate = false;
        this.showExtend = false;
        this.showAddOn = false;
        this.topUpKey = this.newKey('topup');
        try {
            this.ledger = await listLedger({ licenseId: row.licenseId });
        } catch (error) {
            this.ledger = [];
            this.toast('Could not load the ledger', this.errorMessage(error), 'error');
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
        return this.plusDays(0);
    }

    plusDays(days) {
        const now = new Date();
        now.setDate(now.getDate() + days);
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        return `${now.getFullYear()}-${month}-${day}`;
    }

    newKey(prefix) {
        return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
    }
}
