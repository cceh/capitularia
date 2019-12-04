/** @module client/main */

/**
 * Main entry point.
 *
 * @file
 *
 * @author Marcello Perathoner
 */

import $     from 'jquery';
import Vue   from 'vue';
import axios from 'axios';

import app   from '../components/app.vue';

/** @class Vue */

/**
 * Ascend the VM tree until you find an api_url and use it as prefix to build
 * the full API url.
 *
 * @param {Object} vm  - The Vue instance
 * @param {String} url - Url suffix
 *
 * @returns {String} Full API url
 */

Vue.prototype.build_full_api_url = function (url) {
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

Vue.prototype.get = function (url, data = {}) {
    return axios.get (this.build_full_api_url (url), data);
};

Vue.prototype.post = function (url, data = {}) {
    return axios.post (this.build_full_api_url (url), data);
};

Vue.prototype.put = function (url, data = {}) {
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

Vue.prototype.$trigger = function (name, data) {
    // $ (this.$el).trigger (event, data);

    const event = new CustomEvent (name, {
        'bubbles' : true,
        'detail'  : { 'data' : data },
    });
    this.$el.dispatchEvent (event);
};

/* eslint-disable no-new */
new Vue (app);

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
