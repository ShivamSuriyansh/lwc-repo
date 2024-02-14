import { LightningElement,api,track } from 'lwc';
import authUrl from '@salesforce/apex/razorpay.authUrl'

export default class RazorPayForm extends LightningElement {
    @track url;

    async authUrlGen(){
        const url = await authUrl();
        console.log(url);
    }
}