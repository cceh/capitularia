/** cap_collation_user_front_ajax_object is set by wp_localize_script in function.php. */
/* global cap_collation_user_front_ajax_object */

/** The id of the "Obertext". */
export const bk_id = 'bk-textzeuge';

/**
 * The collation algorithms we support.  The Needleman-Wunsch-Gotoh algorithm
 * is available only with our special patched version of CollateX.
 */
export const cap_collation_algorithms = [
    { 'key' : 'dekker',                 'name' : 'Dekker' },
    { 'key' : 'gst',                    'name' : 'Greedy String Tiling' },
    { 'key' : 'medite',                 'name' : 'MEDITE' },
    { 'key' : 'needleman-wunsch',       'name' : 'Needleman-Wunsch' },
    { 'key' : 'needleman-wunsch-gotoh', 'name' : 'Needleman-Wunsch-Gotoh' },
];

/**
 * This calls the API on the API server
 */
export function api (url, data = {}) {
    data.status = cap_collation_user_front_ajax_object.status;

    const p = $.ajax ({
        'url'  : get_api_entrypoint () + url,
        'data' : data,
    });
    return p;
}

/**
 * Get the API entrypoint
 */
export function get_api_entrypoint () {
    return cap_collation_user_front_ajax_object.api_url;
}

/**
 * Build a valid filename to save the config.
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
 */
export function sort_key (s) {
    function fixnum (match, offset, string) {
        return match.length.toString () + match;
    }
    s = s.replace (/\d+/, fixnum);
    s = s.replace (/bk-textzeuge/, '_bk-textzeuge'); // always sort this first
    return s;
}

/**
 * Fix witness
 */
export function fix_witness (w) {
    const i18n = cap_collation_user_front_ajax_object;

    // add check for reactivity
    w.checked  = false;
    w.title    = w.siglum;
    w.title    = w.title.replace (/bk-textzeuge/, i18n.bktz_msg);
    w.title    = w.title.replace (/#(\d+)/,       i18n.copy_msg);
    w.title    = w.title.replace (/[?]hands=XYZ/, i18n.corr_msg);
    w.sort_key = sort_key (w.title);
    return w;
}

/**
 * Parse API response into separate pieces of data
 */
export function parse_witness_response (r) {
    let siglum = r.ms_id;
    if (r.type != 'original') {
        siglum += '?hands=XYZ';
    }
    if (r.n > 1) {
        siglum += '#' + r.n;
    }

    return fix_witness ({
        'siglum'   : siglum,
        'type'     : r.type,
    });
}


/**
 * Parse witness siglum into separate pieces of data
 */
export function parse_siglum (wit) {
    return fix_witness ({
        'siglum'   : wit,
        'type'     : wit.match (/[?]hands=XYZ/) ? 'later_hands' : 'original',
    });
}
