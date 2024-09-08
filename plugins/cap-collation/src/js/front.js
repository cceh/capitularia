/**
 * Initializes the collation applet.
 * @module plugins/cap-collation/front
 */

import { createApp } from 'vue';

import 'jquery-ui/ui/disable-selection';
import 'jquery-ui/ui/widgets/sortable';

import App from './main.vue';

// wrapper to call the Wordpress translate function
// See: https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/
function $t (text) {
    return wp.i18n.__ (text, 'cap-collation');
}

const app = createApp (App);

// the vm.$t function
app.config.globalProperties.$t = $t;

// the v-translate directive
app.directive ('translate', (el) => {
    el.innerText = $t (el.innerText.trim ());
});

app.mount ('#cap-collation-app');
