/**
 * Initializes the meta search applet.
 * @module plugins/cap-meta-search/front
 */

import { createApp } from 'vue';

import jQuery from 'jquery';
import jstree from 'imports-loader?imports=default|jquery|jQuery!jstree'; // eslint-disable-line no-unused-vars

import { Tooltip } from 'bootstrap';

import App from './main.vue';
import CapTab from './cap-tab.vue';
import CapPager from './cap-pager.vue';
import * as tools from './tools.js';

const DOMAIN = 'cap-meta-search';

/**
 * A wrapper to call the Wordpress translate function
 * See: https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/
 *
 * @param   {string} text The untranslated text.
 * @returns {string}      The translated string.
 */
function $t (text) {
    return wp.i18n.__ (text, DOMAIN);
}

/**
 * A wrapper to call the Wordpress translate function
 *
 * @param   {string} singular The untranslated singular text.
 * @param   {string} plural   The untranslated plural text.
 * @param   {number} number   The number talked about.
 * @returns {string}          The translated string, singular or plural.
 */
function $n (singular, plural, number) {
    return wp.i18n._n (singular, plural, number, DOMAIN);
}

const app = createApp (App);

// the vm.$t function
app.config.globalProperties.$t = $t;
app.config.globalProperties.$n = $n;

// the v-translate directive
app.directive ('translate', (el) => {
    el.innerText = wp.i18n.__ (el.innerText.trim (), DOMAIN);
});

app.component ('cap-tab', CapTab);
app.component ('cap-pager', CapPager);

app.mount ('#cap-meta-search-app');

/**
 * Initialize the help button in the widget.
 */
function help_init () {
    jQuery ('.cap-meta-search-help').on ('click', (dummy_event) => {
        jQuery ('div.cap-meta-search-help-text').toggle ();
    });
    const bs_tooltips = [].slice.call (document.querySelectorAll ('[data-bs-toggle="tooltip"]'));
    bs_tooltips.map ((el) => new Tooltip (el, { 'placement' : 'left' }));
}

/** A collator for the German language */
const collator = new Intl.Collator ('de');

/**
 * Initialize the tree view of places in the widget.
 */
function places_tree_init () {
    const places = new URLSearchParams (window.location.search).getAll ('places[]');
    console.log(places);

    jQuery ('#places').jstree ({
        'plugins'  : ['checkbox', 'sort', 'wholerow'],
        'checkbox' : {
            'three_state' : false,
            // 'cascade' : 'up',
            // 'cascade' : 'down',
        },
        'sort' : function (a, b) {
            return collator.compare (this.get_text (a), this.get_text (b));
        },
        'core' : {
            'worker' : false,
            'themes' : {
                'icons' : false,
                'dots'  : false,
            },
            // See: https://www.jstree.com/docs/json/
            'data' : function (node, callback) {
                const params = new URLSearchParams ({ 'lang' : document.documentElement.lang.substring (0, 2) });
                tools.api ('/data/places.json/', params)
                    .then ((response) => callback (response.data.map (
                        (r) => ({
                            'id'     : r.geo_id,
                            'parent' : r.parent_id || '#',
                            'text'   : r.geo_name,
                            'state'  : {
                                'selected' : places.includes (r.geo_id),
                            }
                        })
                    )))
            },
        },
    });

    jQuery ('div.cap-meta-search-box form').submit ((event) => {
        const data = jQuery (event.target).serializeArray ();
        const jst = jQuery ('#places').jstree (true);
        jQuery.each (jst.get_selected (true), (i, node) => {
            data.push ({ 'name' : 'places[]', 'value' : node.id });
            // used by "You searched for: X"
            data.push ({ 'name' : 'placenames[]', 'value' : node.text });
        });
        // submit to the wordpress search page
        window.location.href = `/?${jQuery.param (data)}`;
        event.preventDefault ();
    });
}

help_init ();
places_tree_init ();
