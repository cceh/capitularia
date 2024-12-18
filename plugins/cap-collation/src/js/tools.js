/**
 * Utility functions for the collation applet.
 * @module plugins/cap-collation/tools
 */

import axios from 'axios';
import jQuery from 'jquery';

import { Tooltip } from 'bootstrap';

/** The Wordpress Text Domain of the plugin. */
const DOMAIN = 'cap-collation';

// See: https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/

/**
 * The id of the "Obertext".
 * @type {string}
 */
export const bk_id = 'bk-textzeuge';

/**
 * The collation algorithms we support.
 */
export const cap_collation_algorithms = [
    { 'key' : 'needleman-wunsch-gotoh', 'name' : 'Needleman-Wunsch-Gotoh' },
];

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
 * Build a valid filename to save the config.
 *
 * @param {string} str The string to encode.
 * @returns {string} The encoded string.
 */
export function encodeRFC5987ValueChars (str) {
    return encodeURIComponent (str)
    // Note that although RFC3986 reserves '!', RFC5987 does not,
    // so we do not need to escape it
        .replace (/['()]/g, escape) // i.e., %27 %28 %29
        .replace (/\*/g, '%2A')
    // The following are not required for percent-encoding per RFC5987,
    // so we can allow for a little better readability over the wire: |`^
        .replace (/%(?:7C|60|5E)/g, unescape);
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
    s = s.replace (/\d+/, fixnum);
    return s;
}

/**
 * Build an URL that represents one witness to be collated.
 *
 * @param {Object} w  The witness object
 * @returns {string}  The url
 */
export function build_witness_url (w) {
    const url = new URL ('https://example.org/');
    const params = new URLSearchParams ({});

    if (w.siglum) {
        params.append ('siglum', w.siglum);
    }
    if (w.type !== 'original') {
        params.append ('hands', 'XYZ');
    }
    url.pathname = w.ms_id;
    url.search = params;
    if (w.n > 1) {
        url.hash = w.n;
    }
    return url.toString ().substring (20);
}

/**
 * Calculate some attributes for a witness object: a human-readable title, i18n, sort key.
 *
 * @param {Object} w  The witness object to fix
 * @returns {Object}  The fixed witness object
 */
export function fix_witness (w) {
    // add 'checked' attribute for vue reactivity
    w.checked  = false;
    w.url = build_witness_url (w);

    const corresp = w.corresp ? `${w.corresp} : ` : '';
    const siglum = w.siglum ? ` [${w.siglum}]` : '';
    const corrected = w.type === 'later_hands' ? wp.i18n._x (' (corrected)', 'corrected version of capitularies', DOMAIN) : '';
    const n = w.n > '1' ? wp.i18n._x (' ($1. copy)', '2., 3., etc. copy of capitularies', DOMAIN).replace (/\$1/, w.n) : '';

    w.title = `${corresp}${w.ms_id}${siglum}${corrected}${n}`;
    w.short_title = `${w.ms_id}${siglum}${corrected}${n}`;

    w.sort_key    = w.title;
    w.title       = w.title.replace (
        /bk-textzeuge/,
        wp.i18n._x ('Edition by Boretius/Krause', 'title of the edition', DOMAIN)
    );
    w.short_title = w.short_title.replace (
        /bk-textzeuge/,
        wp.i18n._x ('Edition by Boretius/Krause', 'title of the edition', DOMAIN)
    );
    w.sort_key    = w.sort_key.replace (/bk-textzeuge/, '_bk-textzeuge'); // always sort this first
    w.sort_key    = sort_key (w.sort_key);
    return w;
}

/**
 * Parse a locus url into a witness object similar to one returned by the data server.
 *
 * Currently used only to calculate the title length in the results table.
 *
 * @param {string} url  The witness url
 * @returns {Object}  The witness object
 */
export function parse_locus_url (url) {
    const u = new URL (url, 'https://example.org/');
    const [, corresp, ms_id] = u.pathname.split ('/', 3);

    return fix_witness ({
        'corresp' : corresp,
        'ms_id'   : ms_id,
        'siglum'  : u.searchParams.get ('siglum') || '',
        'type'    : u.searchParams.get ('hands') === 'XYZ' ? 'later_hands' : 'original',
        'n'       : u.hash ? u.hash.substring (1) : '1',
    });
}

/**
 * Unroll collate struct
 *
 * Unrolls the witness list before sending it to the collation server.
 *
 * Turns this:
 *
 * .. code-block:: json
 *
 *    [
 *        {
 *            "corresp": "BK.40_4",
 *            "witnesses": [
 *                "bk-textzeuge",
 *                "vatikan-bav-chigi-f-iv-75"
 *            ]
 *        },
 *        {
 *            "corresp": "BK.137",
 *            "witnesses": [
 *                "bk-textzeuge",
 *                "kopenhagen-kb-1943-4",
 *                "paris-bn-lat-2718"
 *            ]
 *        }
 *    ]
 *
 * into this:
 *
 * .. code-block: json
 *
 *    [
 *       "BK.40_4/bk-textzeuge",
 *       "BK.40_4/vatikan-bav-chigi-f-iv-75",
 *       "BK.137/bk-textzeuge",
 *       "BK.137/kopenhagen-kb-1943-4",
 *       "BK.137/paris-bn-lat-2718",
 *    ]
 *
 * @param {Array} rolled  The collate struct
 * @returns {Array}  The unrolled witness array
 */

export function unroll_witnesses (rolled) {
    return [].concat (...rolled.map ((d) => d.witnesses.map ((w) => `${d.corresp}/${w}`)));
}

export function get_urls (elem) {
    // Get the "url" of all witnesses to collate in user-specified order
    const $table = jQuery (elem).closest ('table');
    return $table.find ('tr[data-url]').map (function () {
        return this.getAttribute ('data-url');
    }).get ();
}

export function update_bs_tooltips () {
    const bs_tooltips = [].slice.call (document.querySelectorAll ('[data-bs-toggle="tooltip"]'));
    bs_tooltips.map ((el) => new Tooltip (el));
}
