<template>
  <card :card_id="d.card_id"
        :position_target="d.position_target"
        :data-fcode="geo_fcode"
        class="map-popup-vm card-floating">
    <card-caption class="bg-fcode" draggable="true" :slidable="true" :closable="true">
      <h5 class="card-title">
        {{ geo_name }} ({{ geo_fcode }})
      </h5>
    </card-caption>

    <div class="card-slide">
      <div class="card-header">
        <toolbar :toolbar="toolbar">
          <layer-selector v-model="toolbar.place_layer_shown"
                          layer_type="place"
                          :layers="geo_layers.layers">
            <h6 class="card-subtitle">
              {{ rows.length }}
            </h6>
          </layer-selector>
        </toolbar>
      </div>

      <template v-if="toolbar.place_layer_shown == 'mss'">
        <div class="m-2">
          <chart :data="chart_data" />
        </div>

        <div class="scroller mb-0">
          <table class="table table-sm table-mss">
            <thead>
              <tr>
                <th>Manuscript</th>
                <th>Created</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in rows" :key="row.ms_id" :title="row.ms_title">
                <td><a :href="'/mss/' + row.ms_id">{{ row.ms_id }}</a></td>
                <td>{{ row.notbefore }}-{{ row.notafter }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <template v-if="toolbar.place_layer_shown == 'msp'">
        <div class="m-2">
          <chart :data="chart_data" />
        </div>

        <div class="scroller mb-0">
          <table class="table table-sm table-mss">
            <thead>
              <tr>
                <th>Manuscript</th>
                <th>Part</th>
                <th>Created</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in rows" :key="row.ms_id + row.msp_part" :title="row.ms_title">
                <td><a :href="'/mss/' + row.ms_id">{{ row.ms_id }}</a></td>
                <td>{{ row.msp_part }}</td>
                <td>{{ row.notbefore }}-{{ row.notafter }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <template v-if="toolbar.place_layer_shown == 'cap'">
        <div class="m-2">
          <chart :data="chart_data" />
        </div>

        <div class="scroller mb-0">
          <table class="table table-sm table-cap">
            <thead>
              <tr>
                <th>Capitulary</th>
                <th>Count</th>
                <th>Created</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in rows" :key="row.cap_id" :title="row.cap_title">
                <td><a :href="'/bk/' + row.cap_id">{{ row.cap_id }}</a></td>
                <td>{{ row.count }}</td>
                <td>{{ row.notbefore }}-{{ row.notafter }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </div>
  </card>
</template>

<script>
/**
 * This module implements the map popup.
 *
 * @component map_popup
 *
 * @author Marcello Perathoner
 */

import { mapGetters } from 'vuex';
import jQuery         from 'jquery';
import _              from 'lodash';
import { bin }        from 'd3';
import { parse }      from 'papaparse';

import card           from './widgets/card.vue';
import card_caption   from './widgets/card_caption.vue';
import toolbar        from './widgets/toolbar.vue';
import layer_selector from './widgets/layer_selector.vue';
import chart          from './widgets/cap_chart.vue';

import options        from '../js/toolbar_options.js';

/**
 * Transform a string so that numbers in the string sort naturally.
 *
 * Transform any contiguous run of digits so that it sorts
 * naturally during an alphabetical sort. Every run of digits gets
 * the length of the run prepended, eg. 123 => 3123, 123456 =>
 * 6123456.
 *
 * @function natural_sort
 *
 * @param {string} s - The input string
 *
 * @returns {string} The transformed string
 */

export function natural_sort (s) {
    s = s.replace ('foll.', 'fol.');
    s = s.replace ('pp.',   'p.');
    return s.replace (/\d+/g, (match, dummy_offset, dummy_string) => match.length + match);
}

const SORTFUNCS = {
    'mss' : (d) => natural_sort (d.ms_id),
    'msp' : (d) => natural_sort (d.ms_id + d.msp_part),
    'cap' : (d) => natural_sort (d.cap_id),
};

const ENDPOINTS = {
    'mss' : 'geo/mss.csv',
    'msp' : 'geo/msparts.csv',
    'cap' : 'geo/capitularies.csv',
};

export default {
    'components' : {
        'card'           : card,
        'card-caption'   : card_caption,
        'toolbar'        : toolbar,
        'layer-selector' : layer_selector,
        'chart'          : chart,
    },
    'props' : ['d'],
    data () {
        return {
            'geo_name'  : '',
            'geo_fcode' : '',
            'rows'      : [],
            'options'   : options,
            'toolbar'   : {
                'place_layer_shown' : this.$store.state.place_layer_shown,
            },
            'chart_data' : null,
        };
    },
    'computed' : {
        ... mapGetters ([
            'xhr_params',
            'area_layer_shown',
            'place_layer_shown',
            'geo_layers',
        ]),
    },
    'watch' : {
        'xhr_params' : function () {
            this.update ();
        },
        'toolbar.place_layer_shown' : function () {
            this.update ();
        },
    },
    created () {
        this.hist = {
            'mss' : bin ()
                .domain ([0, 2000])
                .thresholds ([800, 900, 1000, 1100, 1200])
                .value (this.calc_date),
            'msp' : bin ()
                .domain ([0, 2000])
                .thresholds ([800, 900, 1000, 1100, 1200])
                .value (this.calc_date),
            'cap' : bin ()
                .domain ([0, 2000])
                .thresholds ([768, 814, 840])
                .value (this.calc_date),
        };
    },
    mounted () {
        const vm = this;

        // this.toolbar.csv = () => this.download ('geo/msparts.csv');
        const p = vm.d.properties;
        vm.geo_name  = p.geo_name;
        vm.geo_fcode = p.geo_fcode;

        vm.update ();
    },
    'methods' : {
        calc_date (d) {
            if (d.notbefore && d.notafter) {
                return Math.floor ((+d.notbefore + +d.notafter) / 2.0);
            }
            return 0; // outside domain
        },
        category_name (bin) {
            if (bin.x0 === 0) {
                return 'undated';
            }
            if (bin.x0 === 1) {
                return `-${bin.x1}`;
            }
            if (bin.x1 >= 2000) {
                return `${bin.x0}-`;
            }
            return `${bin.x0}-${bin.x1}`;
        },
        update () {
            const vm   = this;
            const place_layer_shown = vm.toolbar.place_layer_shown;

            // get manuscripts inside area described by layer and geo_id
            vm.get (vm.build_url (vm.d)).then ((response) => {
                const parsed = parse (response.data, { 'header' : true, 'skipEmptyLines' : true });
                // console.log (parsed);
                vm.rows = _.sortBy (parsed.data, [SORTFUNCS[place_layer_shown]]);

                vm.chart_data = vm.hist[place_layer_shown] (vm.rows);
            });
        },
        build_url () {
            const p = this.d.properties;
            const xhr_params = {
                ... this.xhr_params,
                'geo_source' : p.geo_source,
                'geo_id'     : p.geo_id,
            };
            return ENDPOINTS[this.toolbar.place_layer_shown] + '?' + jQuery.param (xhr_params);
        },
        download () {
            window.open (this.build_full_api_url (this.build_url (), '_blank'));
        },
    },
};
</script>

<style lang="scss">
/* map_popup.vue */
@import "../css/bootstrap-custom";

div.map-popup-vm {
    position: absolute;
    background: rgba(255,255,255,0.9);

    .card-header {
        color: black;
    }
    .card-title {
        margin-bottom: 0;
    }
    .card-subtitle {
        margin-top: 0;
    }
    .layer-selector-vm {
        label {
            width: 2em;
        }
    }

    div.scroller {
        max-height: 30em;
        overflow-y: auto;
        table.table {
            background: transparent;
        }
    }

    table.relatives {
        margin-bottom: 0;

        th,
        td {
            padding-left: 0;
            padding-right: 0;
            text-align: right;

            &:first-child {
                padding-left: 1em;
            }

            &:last-child {
                padding-right: 1em;
            }

            &.ms {
                text-align: left;
            }
        }
    }

    &[data-fcode] {
        div.bg-fcode {
            opacity: 0.8;
            background: $place-color;
        }
    }
    &[data-fcode^="PCL"] {
        div.bg-fcode {
            background: $country-color;
        }
    }
    &[data-fcode^="ADM"] {
        div.bg-fcode {
            background: $region-color;
        }
    }

    div.chart-wrapper {
        max-height: 30em;
        overflow-y: auto;
        path {
            fill: none;
        }
    }
}

</style>
