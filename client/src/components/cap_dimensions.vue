<template>
  <div class="dimensions-vm">
    <div class="header">
      <toolbar ref="tb" :toolbar="toolbar" class="maps-vm-toolbar px-2 py-2">
        <form class="row">
          <div class="col-auto">
            <label class="mr-2" for="notbefore">mss. created between</label>
            <input id="notbefore"
                   v-model="toolbar.dates.notbefore"
                   class="form-control form-control-sm"
                   type="number"
                   data-bs-toggle="tooltip"
                   data-bs-placement="bottom"
                   title="Enter a year.">
          </div>
          <div class="col-auto">
            <label class="mr-2" for="notafter">and</label>
            <input id="notafter"
                   v-model="toolbar.dates.notafter"
                   class="form-control form-control-sm"
                   type="number"
                   data-bs-toggle="tooltip"
                   data-bs-placement="bottom"
                   title="Enter a year.">
          </div>
        </form>
      </toolbar>
    </div>

    <div class="wrapper">
      <chart :data="chart_data" />
    </div>
  </div>
</template>

<script>
/**
 * This module shows manuscript dimensions.
 *
 * @component dimensions
 * @author Marcello Perathoner
 */

import _              from 'lodash';
import { bin }        from 'd3';
import { parse }      from 'papaparse';

import toolbar        from './widgets/toolbar.vue';
import chart          from './widgets/cap_chart.vue';

export default {
    'components' : {
        'chart'   : chart,
        'toolbar' : toolbar,
    },
    'data' : function () {
        return {
            'toolbar' : {
                'dates' : {
                    'notbefore' : 500,
                    'notafter'  : 2000,
                },
            },
            'chart_data' : null,
        };
    },
    'watch' : {
        'toolbar.dates' : {
            'handler' : _.debounce (function () {
                this.update ();
            }, 500),
            'deep' : true,
        },
    },
    'methods' : {
        calc_date (d) {
            if (d.notbefore && d.notafter) {
                return Math.floor ((+d.notbefore + +d.notafter) / 2.0);
            }
            return 0; // outside domain
        },
        update () {
            const vm = this;
            vm.chart_data = bin ()
                .domain ([0, 2000])
                .thresholds ([800, 900, 1000, 1100, 1200])
                .value (this.calc_date) (vm.rows);
        },
    },
    mounted () {
        const vm = this;
        vm.get ('dimensions').then ((response) => {
            const parsed = parse (response.data, { 'header' : true, 'skipEmptyLines' : true });
            // console.log (parsed);
            vm.rows = parsed.data;
            vm.update ();
        });
    },
};
</script>

<style lang="scss">
/* maps.vue */
@import "../css/bootstrap-custom";

html, body, #app { height : 100% }

div.dimensions-vm {

    display   : flex;
    flex-flow : column;
    height    : 100%;

    div.header {
        flex: 0 1 auto;
    }

    div.wrapper {
        flex: 1 1 auto;
        position: relative;
    }

    div.info-panels {
        height: 0;
        width: 30em;
    }

    .maps-vm-toolbar {
        background: $card-cap-bg;
    }

    #notbefore, #notafter {
        width: 5em;
    }
}
</style>
