<template>
  <div class="maps-vm"
       @mss-tooltip-open="on_mss_tooltip_open"
       @destroy-card="on_destroy_map_popup">
    <div class="header">
      <toolbar ref="tb" :toolbar="toolbar" class="maps-vm-toolbar px-2 py-2">
        <form class="row">
          <div class="col-auto">
            <label class="mr-2" for="place_layers">Show count of</label>
            <layer-selector id="place_layers"
                            v-model="toolbar.place_layer_shown"
                            layer_type="place"
                            :addnone="true"
                            :layers="geo_layers.layers" />
          </div>
          <div class="col-auto">
            <label class="mr-2" for="notbefore">considering mss. created between</label>
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
          <div class="col-auto">
            <label class="mr-2" for="capitularies">and containing any of these Capitularies:</label>
            <input id="capitularies"
                   v-model="toolbar.capitularies"
                   class="form-control form-control-sm"
                   type="text"
                   data-bs-toggle="tooltip"
                   data-bs-placement="bottom"
                   title="Enter a space-separated list of BK nos (eg. 39 40 BK139-141 M1 M10-25).">
          </div>
          <div class="col-auto">
            <label class="mr-2" for="area_layers">Map overlay:</label>
            <layer-selector id="area_layers"
                            v-model="toolbar.area_layer_shown"
                            layer_type="area"
                            :addnone="true"
                            :layers="geo_layers.layers" />
          </div>
        </form>
      </toolbar>
    </div>

    <div class="wrapper">
      <slippy-map :toolbar="toolbar" />
    </div>

    <div class="info-panels">
      <map-popup v-for="d in info_panels" :key="d.card_id" :d="d" />
    </div>
  </div>
</template>

<script>
/**
 * This module implements a map with some controls to query the database.
 *
 * @component maps
 * @author Marcello Perathoner
 */

import { mapGetters } from 'vuex';

import _              from 'lodash';

import map            from './cap_map.vue';
import map_popup      from './map_popup.vue';
import toolbar        from './widgets/toolbar.vue';
import layer_selector from './widgets/layer_selector.vue';

export default {
    'components' : {
        'slippy-map'     : map,
        'toolbar'        : toolbar,
        'map-popup'      : map_popup,
        'layer-selector' : layer_selector,
    },
    'data' : function () {
        return {
            'toolbar' : {
                'dates' : {
                    'notbefore' : 500,
                    'notafter'  : 2000,
                },
                'capitularies'      : '',
                'place_layer_shown' : 'mss',
                'area_layer_shown'  : 'countries_888',
            },
            'info_panels' : [],
            'next_id'     : 1,
        };
    },
    'computed' : {
        ... mapGetters ([
            'geo_layers',
            'tile_layers',
        ]),
    },
    'watch' : {
        'toolbar.dates' : {
            'handler' : _.debounce (function () {
                this.$store.commit ('toolbar_range', this.toolbar);
            }, 500),
            'deep' : true,
        },
        'toolbar.capitularies' : {
            'handler' : _.debounce (function () {
                this.$store.commit ('toolbar_range', this.toolbar);
            }, 500),
            'deep' : true,
        },
        'toolbar.area_layer_shown' : function () {
            this.$store.commit ('toolbar_area_layer_shown', this.toolbar);
        },
        'toolbar.place_layer_shown' : function () {
            this.$store.commit ('toolbar_place_layer_shown', this.toolbar);
        },
    },
    mounted () {
        const vm = this;
        window.addEventListener ('resize', vm.on_resize);
    },
    'methods' : {
        on_mss_tooltip_open (event) {
            // event.detail.data == the d3 data on the SVG element
            const d = _.cloneDeep (event.detail.data);
            d.card_id = this.next_id++;
            this.info_panels.push (d);
        },
        on_destroy_map_popup (event) {
            const card_id = event.detail.data;
            this.info_panels = this.info_panels.filter (d => d.card_id !== card_id);
        },
    },
};
</script>

<style lang="scss">
/* maps.vue */
@import "../css/bootstrap-custom";

html, body, #app { height : 100% }

div.maps-vm {

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
