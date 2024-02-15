import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createSession from '@salesforce/apex/stripeCheckout.createSession';

export default class StripeIntegration extends NavigationMixin(LightningElement) {
    @track url;

    async handlePay() {
        this.url = await createSession();
        this.navigateToUrl();
    }

    navigateToUrl() {
        if (this.url) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.url
                }
            });
        }
    }
}
