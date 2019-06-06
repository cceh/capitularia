<template>
  <div class="maps-vm"
       @mss-tooltip-open="on_mss_tooltip_open"
       @destroy-card="on_destroy_map_popup">

    <toolbar :toolbar="toolbar" class="maps-vm-toolbar px-2 py-2" ref="tb">
      <form class="form-inline">
        <layer-selector v-model="toolbar.place_layer_shown"
                        class="mr-2"
                        size="sm"
                        layer_type="place"
                        :addnone="true"
                        :layers="geo_layers.layers">Show count of</layer-selector>

        <div class="form-group">
          <label class="mr-2" for="notbefore">considering mss. created between</label>
          <b-form-input id="notbefore"
                        v-model="toolbar.dates.notbefore"
                        size="sm"
                        type="number"
                        v-b-tooltip.hover
                        title="Enter a year."
                        ></b-form-input>
        </div>
        <div class="form-group">
          <label class="mr-2" for="notafter">and</label>
          <b-form-input id="notafter"
                        v-model="toolbar.dates.notafter"
                        size="sm"
                        type="number"
                        v-b-tooltip.hover
                        title="Enter a year."
                        ></b-form-input>
        </div>
        <div class="form-group">
          <label class="mr-2" for="capitularies">and containing any of these Capitularies:</label>
          <b-form-input id="capitularies"
                        v-model="toolbar.capitularies"
                        size="sm"
                        type="text"
                        v-b-tooltip.hover
                        title="Enter a space-separated list of BK nos (eg. 39 40 BK139-141 M1 M10-25)."
                        ></b-form-input>
        </div>
      </form>

      <form class="form-inline">
        <layer-selector v-model="toolbar.area_layer_shown"
                        size="sm"
                        layer_type="area"
                        :addnone="true"
                        :layers="geo_layers.layers">Map overlay:</layer-selector>
      </form>

    </toolbar>

    <slippy-map :toolbar="toolbar" :style="`top: ${toolbar_height}px`" />

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

import { mapGetters } from 'vuex'

import $        from 'jquery';
import * as d3  from 'd3';
import _        from 'lodash';

import map      from 'map.vue';

import toolbar        from 'widgets/toolbar.vue';
import button_group   from 'widgets/button_group.vue';
import layer_selector from 'widgets/layer_selector.vue';
import map_popup      from 'map_popup.vue';

export default {
    'components' : {
        'slippy-map'     : map,
        'toolbar'        : toolbar,
        'map-popup'      : map_popup,
        'button-group'   : button_group,
        'layer-selector' : layer_selector,
    },
    'data'  : function () {
        return {
            'toolbar' : {
                'dates' : {
                    'notbefore' :  500,
                    'notafter'  : 2000,
                },
                'capitularies'      : '',
                'place_layer_shown' : 'mss',
                'area_layer_shown'  : 'countries_888',
            },
            'info_panels'    : [],
            'next_id'        : 1,
            'toolbar_height' : 50,
        };
    },
    'computed' : {
        ... mapGetters ([
            'geo_layers',
            'tile_layers',
        ])
    },
    'watch' : {
        'toolbar.dates' : {
            handler : _.debounce (function () {
                this.$store.commit ('toolbar_range', this.toolbar);
            }, 500),
            'deep' : true,
        },
        'toolbar.capitularies' : {
            handler : _.debounce (function () {
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
    'methods' : {
        on_mss_tooltip_open (event) {
            // event.detail.data == the d3 data on the SVG element
            const d = _.cloneDeep (event.detail.data);
            d.card_id = this.next_id++;
            this.info_panels.push (d);
        },
        on_destroy_map_popup (event) {
            const card_id = event.detail.data;
            this.info_panels = this.info_panels.filter (d => d.card_id !== card_id)
        },
        on_resize () {
            this.toolbar_height = $ (this.$refs.tb.$el).outerHeight ();
        },
    },
    mounted () {
        const vm = this;
        window.addEventListener ('resize', vm.on_resize);
        vm.on_resize ();
    },
};
</script>

<style lang="scss">
/* maps.vue */
@import "bootstrap-custom";

div.maps-vm {

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
