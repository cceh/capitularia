<template>
  <router-view />
</template>

<script>
/**
 * The Vue.js application
 *
 * @component app
 * @author Marcello Perathoner
 */

import { createRouter, createWebHistory } from 'vue-router';
import { createStore } from 'vuex';

import _        from 'lodash';
import { json } from 'd3';

import maps     from './cap_maps.vue';

const routes = [
    { 'path' : '/client/maps', 'component' : maps },
];

export const router = createRouter ({
    'history' : createWebHistory (),
    'routes'  : routes,
});

export const store = createStore ({
    'state' : {
        'dates' : {          // date range of manuscripts to consider
            'notbefore' : 0, // year
            'notafter'  : 0,
        },
        'capitularies'      : '',  // space separated list of capitularies
        'area_layer_shown'  : '',  // map areas to show
        'place_layer_shown' : '',  // type of artifacts to count: mss, msp or cap
        'geo_layers'        : { 'layers' : [] },
        'tile_layers'       : { 'layers' : [] },
    },
    'mutations' : {
        toolbar_range (state, toolbar) {
            _.merge (state, {
                'dates' : {
                    'notbefore' : Number (toolbar.dates.notbefore),
                    'notafter'  : Number (toolbar.dates.notafter),
                },
                'capitularies' : toolbar.capitularies,
            });
        },
        toolbar_area_layer_shown (state, toolbar) {
            this.state.area_layer_shown = toolbar.area_layer_shown;
        },
        toolbar_place_layer_shown (state, toolbar) {
            this.state.place_layer_shown = toolbar.place_layer_shown;
        },
    },
    'getters' : {
        'xhr_params' : state => ({
            'notbefore'    : state.dates.notbefore,
            'notafter'     : state.dates.notafter,
            'capitularies' : state.capitularies,
        }),
        'area_layer_shown'  : state => state.area_layer_shown,
        'place_layer_shown' : state => state.place_layer_shown,
        'geo_layers'        : state => state.geo_layers,
        'tile_layers'       : state => state.tile_layers,
    },
});

export const App = {
    data () {
        return {
        };
    },
    'computed' : {
        api_url () { return api_base_url; },
    },
    mounted () {
        const vm = this;
        const xhrs = [
            json (vm.build_full_api_url ('geo/'),  { 'credentials' : 'include' }),
            json (vm.build_full_api_url ('tile/'), { 'credentials' : 'include' }),
        ];
        Promise.all (xhrs).then (function (responses) {
            const [json_geo, json_tile] = responses;
            vm.$store.state.geo_layers  = json_geo;
            vm.$store.state.tile_layers = json_tile;
        });
    },
};

export default App;

</script>

<style lang="scss">
@import "../css/bootstrap-custom";

/* bootstrap */
@import '~bootstrap';

/* List of icons at: http://astronautweb.co/snippet/font-awesome/ */
@import "~/themes/Capitularia/src/css/fonts";
// @import "~@fortawesome/fontawesome-free/scss/fontawesome";
// @import "~@fortawesome/fontawesome-free/scss/solid";

</style>
