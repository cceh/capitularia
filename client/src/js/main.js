/** @module client/main */

/**
 * Main entry point.
 *
 * @file
 *
 * @author Marcello Perathoner
 */

import { createApp } from 'vue';

import $             from 'jquery';
import axios         from 'axios';

import { App, router, store } from '../components/app.vue';

const app = createApp (App);

app.use (router);
app.use (store);

/**
 * Ascend the VM tree until you find an api_url and use it as prefix to build
 * the full API url.
 *
 * @param {String} url - Url suffix
 *
 * @returns {String} Full API url
 */

app.config.globalProperties.build_full_api_url = function (url) {
    let vm = this;
    /* eslint-disable-next-line no-constant-condition */
    while (true) {
        if (vm.api_url) {
            return vm.api_url + url;
        }
        if (!vm.$parent) {
            break;
        }
        vm = vm.$parent;
    }
    return url;
};

/**
 * Make a GET request to the API server.
 *
 * @param {String} url  - Url suffix
 * @param {Object} data - Params for axios call
 *
 * @returns {Promise}
 */

app.config.globalProperties.get = function (url, data = {}) {
    return axios.get (this.build_full_api_url (url), data);
};

app.config.globalProperties.post = function (url, data = {}) {
    return axios.post (this.build_full_api_url (url), data);
};

app.config.globalProperties.put = function (url, data = {}) {
    return axios.put (this.build_full_api_url (url), data);
};


/**
 * Trigger a native event.
 *
 * vue.js custom `events´ do not bubble, so they are useless.  Trigger a real
 * event that bubbles and can be caught by vue.js.
 *
 * @param {string} name - event name
 * @param {array}  data - data
 */

app.config.globalProperties.$trigger = function (name, data) {
    // $ (this.$el).trigger (event, data);

    const event = new CustomEvent (name, {
        'bubbles' : true,
        'detail'  : { 'data' : data },
    });
    this.$el.dispatchEvent (event);
};

$ (document).off ('.data-api'); // turn off bootstrap's data api

// The browser triggers hashchange only on window.  We want it on every app.
$ (window).on ('hashchange', function () {
    // Concoct an event that you can actually catch with vue.js. (jquery events
    // are not real native events.)  This event does not bubble.
    const event = new CustomEvent ('hashchange');
    $ ('.want_hashchange').each (function (i, e) {
        e.dispatchEvent (event);
    });
});

app.mount ('#app');
