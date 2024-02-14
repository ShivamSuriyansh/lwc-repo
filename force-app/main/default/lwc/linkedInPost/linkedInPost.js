import { LightningElement,track } from 'lwc';
import postToLinkedIn from '@salesforce/apex/linkedInCallout.postToLinkedIn'

export default class LinkedInPost extends LightningElement {
    @track message;

    handleChange(event){
        this.message = event.target.value;
    }

    async Post(){
        if(!this.message){
            alert('Enter something before posting!');
            return;
        }
        await postToLinkedIn({Message: this.message});
    }

}