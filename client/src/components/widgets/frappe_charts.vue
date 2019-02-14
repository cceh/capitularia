<template>
  <div class="vm-frappe-charts"></div>
</template>

<script>
import { Chart } from "frappe-charts";

export default {
    props: {
        'options' : {
            required: true,
            type: Object,
        },
    },
    data () {
        return {
        }
    },
    watch: {
        'options.data' : {
            handler () {
                this.chart.update (this.options.data);
            },
            'deep' : true,
        }
    },
    mounted () {
        this.chart = new Chart (this.$el, this.options)
    },
}
</script>

<style lang="scss">
/* frappe_charts.vue */

@import "bootstrap-custom";

@import "../../../node_modules/frappe-charts/dist/frappe-charts.min.css";
</style>
