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

import _            from 'lodash';
import Vue          from 'vue';
import VueRouter    from 'vue-router';
import Vuex         from 'vuex';
import BootstrapVue from 'bootstrap-vue';
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
            'notbefore' :  500,
            'notafter'  : 2000,
        },
        'capitularies' : '', // space separated list of capitularies
        'type' : 'mss',      // type of artifacts to show mss, msp or cap
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
        toolbar_type (state, data) {
            this.state.type = data.type;
        },
    },
    'getters' : {
        'xhr_params' : state => ({
            'notbefore'    : state.dates.notbefore,
            'notafter'     : state.dates.notafter,
            'capitularies' : state.capitularies,
        }),
        'type' : state => state.type,
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
