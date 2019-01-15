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
import url          from 'url';

import map          from '../components/map.vue';

Vue.use (Vuex);
Vue.use (BootstrapVue);
Vue.use (VueRouter);

const routes = [
    { 'path' : '/client/map', 'component' : map, },
];

const router = new VueRouter ({
    'mode'   : 'history',
    'routes' : routes,
});

const store = new Vuex.Store ({
    'state' : {
        'ranges'    : [],
        'leitzeile' : [],
        'passage'   : {
            'pass_id' : 0,
            'hr'      : '',
        },
        'current_application' : {
            'name' : 'ntg',
        },
        'current_user' : {
            'is_logged_in' : false,
            'is_editor'    : false,
            'username'     : 'anonymous',
        },
    },
    'mutations' : {
        passage (state, data) {
            Object.assign (state, data);
        },
        current_app_and_user (state, data) {
            state.current_application = data[0];
            state.current_user        = data[1];
        },
    },
    'getters' : {
        'passage' : state => state.passage,
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
    'watch' : {
        api_url () { return this.update_globals; },
    },
    'methods' : {
        update_globals () {
            const requests = [
                this.get ('application.json'),
                this.get ('user.json'),
            ];
            Promise.all (requests).then ((responses) => {
                store.commit ('current_app_and_user', [
                    responses[0].data.data,
                    responses[1].data.data,
                ]);
            });
        },
    },
    mounted () {
        // this.update_globals ();
    },
};

</script>

<style lang="scss">
@import "../css/bootstrap-custom.scss";

/* bootstrap */
@import "../../node_modules/bootstrap/scss/bootstrap";
@import "../../node_modules/bootstrap-vue/dist/bootstrap-vue.css";

/* List of icons at: http://astronautweb.co/snippet/font-awesome/ */
@import "../../node_modules/@fortawesome/fontawesome-free/css/fontawesome.css";
@import "../../node_modules/@fortawesome/fontawesome-free/css/solid.css";

</style>
