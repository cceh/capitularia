import Vue from 'vue';

import 'jquery-ui/ui/disable-selection';
import 'jquery-ui/ui/widgets/sortable';

import Main from './main.vue';

// wrapper to call the Wordpress translate function
// See: https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/
function $t (text) {
    return wp.i18n.__ (text, 'cap-collation');
}

// the vm.$t function
Vue.prototype.$t = function (text) {
    return $t (text);
};

// the v-translate directive
Vue.directive ('translate', function (el) {
    el.innerText = $t (el.innerText);
});

// the {{ 'text' | translate }} filter
Vue.filter ('translate', function (text) {
    return $t (text);
});

const app = new Vue ({
    el: '#cap-collation-app',
    components: {
        'cap-collation-app' : Main,
    },
});
