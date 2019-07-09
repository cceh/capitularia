export const bk_id = '_bk-textzeuge';

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
 * Encapsulate AJAX functionality
 */
export function ajax (action, data) {
    data.action = 'on_cap_collation_user_' + action;
    // add the nonce
    $.extend (data, cap_collation_user_front_ajax_object);
    const p = $.ajax ({
        'method' : 'POST',
        'url'    : cap_collation_user_front_ajax_object.ajaxurl,
        'data'   : data,
    });
    return p;
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
