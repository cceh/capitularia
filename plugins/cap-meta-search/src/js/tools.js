/**
 * Utility functions for the meta-search applet.
 * @module plugins/cap-meta-search/tools
 */

import axios from 'axios';
import { Tab, Tooltip } from 'bootstrap';
import _ from 'lodash';

/**
 * The id of the "Obertext".
 * @type {string}
 */
export const bk_id = 'bk-textzeuge';

/**
 * A color palette.
 */
export const Palette = '8888881f77b42ca02cd62728e7ba52ff7f0e9467bd8c564be377c217becf'
                     + 'aec7e8ffbb7898df8aff9896c5b0d5c49c94f7b6d2dbdb8d9edae57f7f7f';

/**
 * Insert a CSS color palette into the DOM making it active.
 *
 * @function insert_css_palette
 *
 * @param {string} css - The color palette as string.
 */
export function insert_css_palette (palette) {
    const css = palette.match (/.{6}/g)
        .map ((color, index) => `[data-index="${index}"] .background-from-index { background-color: #${color}22 }`)
        .join ('\n');
    const style = document.createElement ('style');
    style.setAttribute ('type', 'text/css');
    style.appendChild (document.createTextNode (css));
    document.querySelector ('head').appendChild (style);
}

/**
 * This calls the API on the API server
 *
 * @param {string} endpoint  The endpoint relative to the API root.
 * @param {URLSearchParams} data The query to send.
 * @returns {Promise} Promise resolved when call completed.
 */
export function api (endpoint, data = new URLSearchParams ()) {
    const fd = new FormData ();
    fd.set ('endpoint', endpoint);
    fd.set ('action', 'cap_lib_query_api');
    return axios.post (cap_lib.ajaxurl, fd, { 'params' : data });
}

/**
 * A key that sorts numbers right
 *
 * @param {string} s Any string.
 * @returns {string} A key derived from the string that sorts numbers right.
 */
export function sort_key (s) {
    function fixnum (match, dummy_offset, dummy_string) {
        return match.length.toString () + match;
    }
    return s.replace (/\d+/, fixnum);
}

function sort_key_doc (doc) {
    return sort_key (`${doc.ms_id}/${doc.cap_id}/${doc.chapter}`);
}

export function filter_group_docs (docs, category) {
    return Object.entries (
        _ (docs)
            .filter ((doc) => doc.category.includes (category))
            .sortBy (sort_key_doc)
            .groupBy ('ms_id')
            .value ()
    );
}

/**
 * Converts the stupid facets notation of Solr into an object dict
 * @param {Array} f solr array
 * @returns {Object}
 */
export function facets (f) {
    const d = {};
    for (let i = 0; i < f.length; i += 2) {
        d[f[i]] = f[i + 1];
    }
    return d;
}

export function update_bs_tooltips () {
    const bs_tooltips = [].slice.call (document.querySelectorAll ('[data-bs-toggle="tooltip"]'));
    bs_tooltips.map ((el) => new Tooltip (el));
}

export function update_bs_tabs () {
    const triggerTabList = document.querySelectorAll ('#tabheader a[data-bs-toggle="tab"]');
    triggerTabList.forEach ((triggerEl) => {
        const tabTrigger = new Tab (triggerEl);

        triggerEl.addEventListener ('click', (event) => {
            event.preventDefault ();
            tabTrigger.show ();
        });
    });
}

/**
 * Returns a parameter or the default value.
 *
 * @param {URLSearchParams} q params to pick from
 * @param {string} name name of the parameter
 * @param {string} def default value
 * @returns {string}
 */
export function get_url_search_param (q, name, def = null) {
    const v = q.get (name);
    if (v && v !== '') {
        return v;
    }
    return def;
}

/**
 * Creates an URLQueryParams object composed of the picked params.
 * @param {URLSearchParams} q params to pick from
 * @param {Array} picks array of keys to pick
 * @returns {URLSearchParams}
 */
export function pick_url_search_params (q, picks) {
    const r = new URLSearchParams ();
    q.forEach ((value, key) => {
        if (value && value !== '' && picks.includes (key)) {
            r.append (key, value);
        }
    });
    return r;
}
