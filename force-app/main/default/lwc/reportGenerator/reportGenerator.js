import {LightningElement, wire, track} from 'lwc';
import getCount from '@salesforce/apex/showingChartObjects.get_no_of_objects';

export default class ReportGenerator extends LightningElement {

    @track chartConfiguration;
    @track startDate;
    @track endDate;
    @track open=false;
    @track data=0;

    handleClick(){
        this.open=!this.open;
        if(!this.startDate || !this.endDate){
            window.confirm('please fill the required fields!!');
            return;
        }
        
        this.getData();
        this.data = 0;
    }

    handleStartDate(event){
        this.startDate = event.target.value;
    }
    handleEndDate(event){
        this.endDate = event.target.value;
        console.log('date: ',this.endDate);
    }

    async getData(){
        try {
            const data = await getCount({startDate: this.startDate,endDate: this.endDate});
            
            let chartData = data.objCounts;
            let chartLabels = data.objNames;

            console.log('chart: ',chartData,' ',chartLabels);

            this.chartConfiguration = {
                type: 'bar',
                data: {
                    labels: chartLabels,
                    datasets: [
                        {
                            label: '',
                            barPercentage: 0.5,
                            barThickness: 1,//6
                            maxBarThickness: 4,//8
                            minBarLength: 2,
                            backgroundColor: [
                                'rgba(255, 99, 132, 0.2)',
                                'rgba(255, 159, 64, 0.2)',
                                'rgba(255, 205, 86, 0.2)',
                                'rgba(75, 192, 192, 0.2)',
                                'rgba(54, 162, 235, 0.2)',
                                'rgba(153, 102, 255, 0.2)',
                                'rgba(201, 203, 207, 0.2)'
                              ],
                              borderColor: [
                                'rgb(255, 99, 132)',
                                'rgb(255, 159, 64)',
                                'rgb(255, 205, 86)',
                                'rgb(75, 192, 192)',
                                'rgb(54, 162, 235)',
                                'rgb(153, 102, 255)',
                                'rgb(201, 203, 207)'
                              ],
                              borderWidth: 1,
                            data: chartData,
                        },
                    ],
                },
                options: {
                },
            };
            console.log('data => ', data);
            this.data = data.objCounts.reduce((acc,curr)=>acc+curr,0);
            this.error = undefined;
        }
        catch(error) {
            this.error = error;
            console.log('error => ' + JSON.stringify(error));
            this.chartConfiguration = undefined;
        } 
    }
}