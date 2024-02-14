import { LightningElement,track,api } from 'lwc';
import chartjs from "@salesforce/resourceUrl/ChartJs";
import gaugejs from "@salesforce/resourceUrl/gaugeChart";
import {loadScript} from 'lightning/platformResourceLoader';  
import fetch from '@salesforce/apex/gaugeFetch.fetchingStudents';  

export default class GaugeChart extends LightningElement {
    @track score = 0;
    @api recordId;
    @track maxMarks = 0;

    gaugeConfig = {
        type: "tsgauge",
        data: {
          datasets: [
            {
              backgroundColor : [
                "#027e46",
                "#669900",
                "#ffcc00",
                "#ff9900",
                "#c23934",
                "#ff6600",
                "#cc3300",
                "#993300",
                "#660000",
                "#990000"
            ],
              borderWidth: 0,
              gaugeData: {
                value: 7777,
                valueColor: "#ff7143"
              },
              label: "My First Dataset",
              gaugeLimits: [0,10,20,30,40,50,60,70,80,90,100]
            }
          ],
          value: "Score"
        },
        options: {
          events: [],
          showMarkers: true
        }
      };

      async renderedCallback() {
        if (!this.isChartJsInitialized) {
          await loadScript(this, chartjs);
          await loadScript(this, gaugejs);
        } else {
          return;
        }
        this.isChartJsInitialized = true;
        try {
          this.gaugeConfig.data.datasets[0].gaugeData.value = this.score;
          this.gaugeConfig.data.datasets[0].gaugeData.valueColor =this.calculateValueColor();
          const canvas = document.createElement("canvas");
          this.refs.chart.appendChild(canvas);
          const ctx = canvas.getContext("2d");
          this.chart = new window.Chart(ctx, this.gaugeConfig);
          this.changeScoreValue();
        } catch (error) {
          this.error = error;
        }
      }

      changeScoreValue() {
        // this.timerId = setTimeout(() => {
        //   if (this.timerId) clearTimeout(this.timerId);
        //   if (this.score < 100) {
        //     this.setGaugeValue(this.score + 4000);
        //   } else {
        //     this.setGaugeValue(this.score);
        //   }
        //   this.changeScoreValue(7000);
        // }, 40000);
      }

      calculateValueColor() {
        if (this.score < 10) {
            return "#027e46";
        } else if (this.score < 20) {
            return "#669900";
        } else if (this.score < 30) {
            return "#ffcc00";
        } else if (this.score < 40) {
            return "#ff9900";
        } else if (this.score < 50) {
            return "#c23934";
        } else if (this.score < 60) {
            return "#ff6600";
        } else if (this.score < 70) {
            return "#cc3300";
        } else if (this.score < 80) {
            return "#993300";
        } else if (this.score < 90) {
            return "#660000";
        } else {
            return "#990000";
        }
    }
    
    

      setGaugeValue(value) {
        if (this.score !== value) {
          this.score = value;
          this.gaugeConfig.data.datasets[0].gaugeData.value = value;
          this.gaugeConfig.data.datasets[0].gaugeData.valueColor =this.calculateValueColor();
          this.chart.update();
        }
      }

      async handleClick(){
        try {
            this.maxMarks = await fetch(); 
            console.log('Marks :',this.maxMarks);
            this.setGaugeValue(this.maxMarks);
        } catch (error) {
            alert('error while fetching contacts!');
        }
      }
      
      disconnectedCallback() {
        if (this.timerId) clearTimeout(this.timerId);
      }
}