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

import Vue          from 'vue';
import VueRouter    from 'vue-router';
import Vuex         from 'vuex';
import BootstrapVue from 'bootstrap-vue';

import _            from 'lodash';
import * as d3      from 'd3';
import url          from 'url';

import maps         from 'maps.vue';

Vue.use (Vuex);
Vue.use (BootstrapVue);
Vue.use (VueRouter);

const routes = [
    { 'path' : '/client/maps', 'component' : maps, },
];

const router = new VueRouter ({
    'mode'   : 'history',
    'routes' : routes,
});

const store = new Vuex.Store ({
    'state' : {
        'dates' : {    // date range of manuscripts to consider
            'notbefore' : 0, // year
            'notafter'  : 0,
        },
        'capitularies'      : '',  // space separated list of capitularies
        'area_layer_shown'  : '',  // map areas to show
        'place_layer_shown' : '',  // type of artifacts to count: mss, msp or cap
        'geo_layers'        : [],
        'tile_layers'       : [],
    },
    'mutations' : {
        toolbar_range (state, data) {
            _.merge (state, {
                'dates' : {
                    'notbefore' : Number (data.dates.notbefore),
                    'notafter'  : Number (data.dates.notafter),
                },
                'capitularies' : data.capitularies,
            });
        },
        toolbar_area_layer_shown (state, data) {
            this.state.area_layer_shown = data.area_layer_shown;
        },
        toolbar_place_layer_shown (state, data) {
            this.state.place_layer_shown = data.place_layer_shown;
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
    },
});

export default {
    'router' : router,
    'store'  : store,
    'el': app,
    data () {
        return {
        };
    },
    'computed' : {
        api_url () { return url.resolve (api_base_url, '/'); },
    },
    mounted () {
        const vm = this;
        const xhrs = [
            d3.json (vm.build_full_api_url ('geo/')),
            d3.json (vm.build_full_api_url ('tile/')),
        ];
        Promise.all (xhrs).then (function (responses) {
            const [json_geo, json_tile] = responses;
            vm.$store.state.geo_layers  = json_geo.layers;
            vm.$store.state.tile_layers = json_tile.layers;
        });
    },
};

</script>

<style lang="scss">
@import "bootstrap-custom";

/* bootstrap */
@import "../../node_modules/bootstrap/scss/bootstrap";
@import "../../node_modules/bootstrap-vue/dist/bootstrap-vue.css";

/* List of icons at: http://astronautweb.co/snippet/font-awesome/ */
@import "../../node_modules/@fortawesome/fontawesome-free/css/fontawesome.css";
@import "../../node_modules/@fortawesome/fontawesome-free/scss/solid.scss";

</style>
