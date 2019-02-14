<template>
  <div class="maps-vm"
       @mss-tooltip-open="on_mss_tooltip_open"
       @destroy-card="on_destroy_map_popup">

    <toolbar :toolbar="toolbar" class="mx-2 my-2">
      <form class="form-inline">
        <div class="form-group">
          <label class="mr-2" for="notbefore">Consider only mss. created between </label>
          <b-form-input id="notbefore"
                        v-model="toolbar.dates.notbefore"
                        type="number"
                        v-b-tooltip.hover
                        title="Enter a year."
                        ></b-form-input>
        </div>
        <div class="form-group">
          <label class="mr-2" for="notafter">and</label>
          <b-form-input id="notafter"
                        v-model="toolbar.dates.notafter"
                        type="number"
                        v-b-tooltip.hover
                        title="Enter a year."
                        ></b-form-input>
        </div>
        <div class="form-group">
          <label class="mr-2" for="capitularies">and containing any of these Capitularies: </label>
          <b-form-input id="capitularies"
                        v-model="toolbar.capitularies"
                        type="text"
                        v-b-tooltip.hover
                        title="Enter a space-separated list of BK nos (eg. 39 40 BK139-141 M1 M10-25)."
                        ></b-form-input>
        </div>

        <label class="mr-2" for="type">Show count of</label>
        <button-group id="type" type="radio" v-model="toolbar.type"
                      :options="options.type" />
      </form>

    </toolbar>

    <slippy-map :toolbar="toolbar" />

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

import _         from 'lodash';

import map       from 'map.vue';

import toolbar       from 'widgets/toolbar.vue';
import button_group  from 'widgets/button_group.vue';
import map_popup     from 'map_popup.vue';

import options       from 'toolbar_options.js';

export default {
    'components' : {
        'slippy-map'   : map,
        'toolbar'      : toolbar,
        'map-popup'    : map_popup,
        'button-group' : button_group,
    },
    'data'  : function () {
        return {
            'toolbar' : {
                'dates' : {
                    'notbefore' :  500,
                    'notafter'  : 2000,
                },
                'capitularies' : '',
                'type'         : 'mss',
            },
            'info_panels' : [],
            'options'     : options,
            'next_id'     : 1,
        };
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
        'toolbar.type' : function () {
            this.$store.commit ('toolbar_type', this.toolbar);
        },
    },
    'methods' : {
        on_mss_tooltip_open (event) {
            // event.detail.data = the d3 data on the SVG element
            const d = _.cloneDeep (event.detail.data);
            d.card_id = this.next_id++;
            this.info_panels.push (d);
        },
        on_destroy_map_popup (event) {
            const card_id = event.detail.data;
            this.info_panels = this.info_panels.filter (d => d.card_id !== card_id)
        },
    },
};
</script>

<style lang="scss">
/* maps.vue */
@import "bootstrap-custom";

div.info-panels {
    height: 0;
    width: 30em;
}

#notbefore, #notafter {
    width: 5em;
}

</style>
