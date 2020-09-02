"use strict";

var _interopRequireDefault = require("@babel/runtime/helpers/interopRequireDefault");

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.get_api_entrypoint = get_api_entrypoint;
exports.api = api;
exports.encodeRFC5987ValueChars = encodeRFC5987ValueChars;
exports.sort_key = sort_key;
exports.fix_witness = fix_witness;
exports.parse_witness_response = parse_witness_response;
exports.parse_siglum = parse_siglum;
exports.unroll_witnesses = unroll_witnesses;
exports.get_sigla = get_sigla;
exports.cap_collation_algorithms = exports.bk_id = void 0;

var _toConsumableArray2 = _interopRequireDefault(require("@babel/runtime/helpers/toConsumableArray"));

/** @module plugins/collation/tools */

/**
 * @file Contains utility functions for the collation applet.
 */

/** cap_collation_user_front_ajax_object is set by wp_localize_script in function.php. */

/* global cap_collation_user_front_ajax_object */

/**
 * The id of the "Obertext".
 * @type {string}
 */
var bk_id = 'bk-textzeuge';
/**
 * The collation algorithms we support.  The Needleman-Wunsch-Gotoh algorithm
 * is available only with our special patched version of CollateX.
 */

exports.bk_id = bk_id;
var cap_collation_algorithms = [{
  'key': 'dekker',
  'name': 'Dekker'
}, {
  'key': 'gst',
  'name': 'Greedy String Tiling'
}, {
  'key': 'medite',
  'name': 'MEDITE'
}, {
  'key': 'needleman-wunsch',
  'name': 'Needleman-Wunsch'
}, {
  'key': 'needleman-wunsch-gotoh',
  'name': 'Needleman-Wunsch-Gotoh'
}];
/**
 * Get the API entrypoint
 *
 * @returns {string} The root URL of the API server.
 */

exports.cap_collation_algorithms = cap_collation_algorithms;

function get_api_entrypoint() {
  return cap_collation_user_front_ajax_object.api_url;
}
/**
 * This calls the API on the API server
 *
 * @param {string} url  The endpoint relative to the API root.
 * @param {Object} data The data to send.
 * @returns {Promise} Promise resolved when call completed.
 */


function api(url) {
  var data = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
  data.status = cap_collation_user_front_ajax_object.status;
  var p = $.ajax({
    'url': get_api_entrypoint() + url,
    'data': data
  });
  return p;
}
/**
 * Build a valid filename to save the config.
 *
 * @param {string} str The string to encode.
 * @returns {string} The encoded string.
 */


function encodeRFC5987ValueChars(str) {
  return encodeURIComponent(str) // Note that although RFC3986 reserves '!', RFC5987 does not,
  // so we do not need to escape it
  .replace(/['()]/g, escape) // i.e., %27 %28 %29
  .replace(/\*/g, '%2A') // The following are not required for percent-encoding per RFC5987,
  // so we can allow for a little better readability over the wire: |`^
  .replace(/%(?:7C|60|5E)/g, unescape);
}
/**
 * A key that sorts numbers right
 *
 * @param {string} s Any string.
 * @returns {string} A key derived from the string that sorts numbers right.
 */


function sort_key(s) {
  function fixnum(match, dummy_offset, dummy_string) {
    return match.length.toString() + match;
  }

  s = s.replace(/\d+/, fixnum);
  return s;
}
/**
 * Prepare a witness for display, add human-readable title, i18n.
 *
 * @param {Object} w  The witness to fix
 * @returns {Object}  The fixed witness object
 */


function fix_witness(w) {
  var i18n = cap_collation_user_front_ajax_object; // add check for reactivity

  w.checked = false;
  w.title = w.siglum;
  w.title = w.title.replace(/#(\d+)/, i18n.copy_msg);
  w.title = w.title.replace(/[?]hands=XYZ/, i18n.corr_msg);
  w.sort_key = w.title;
  w.title = w.title.replace(/bk-textzeuge/, i18n.bktz_msg);
  w.sort_key = w.sort_key.replace(/bk-textzeuge/, '_bk-textzeuge'); // always sort this first

  w.sort_key = sort_key(w.sort_key);
  return w;
}
/**
 * Parse API server response into witness object
 *
 * @param {Object} r  The server response
 * @returns {Object}  The witness struct
 */


function parse_witness_response(r) {
  var siglum = r.ms_id;

  if (r.type !== 'original') {
    siglum += '?hands=XYZ';
  }

  if (r.n > 1) {
    siglum += '#' + r.n;
  }

  return fix_witness({
    'siglum': siglum,
    'type': r.type
  });
}
/**
 * Parse witness siglum into witness object
 *
 * @param {string} siglum  The witness siglum
 * @returns {Object}  The witness object
 */


function parse_siglum(siglum) {
  return fix_witness({
    'siglum': siglum,
    'type': siglum.match(/[?]hands=XYZ/) ? 'later_hands' : 'original'
  });
}
/**
 * Unroll collate struct
 *
 * @param {Array} rolled  The collate struct
 * @returns {Array}  The unrolled witness array
 *
 * Turns this:
    [
        {
            "corresp": "BK.40_4",
            "witnesses": [
                "bk-textzeuge",
                "vatikan-bav-chigi-f-iv-75"
            ]
        },
        {
            "corresp": "BK.137",
            "witnesses": [
                "bk-textzeuge",
                "kopenhagen-kb-1943-4",
                "paris-bn-lat-2718"
            ]
        }
    ]
 * into this:
 * [
 *    "BK.40_4/bk-textzeuge",
 *    "BK.40_4/vatikan-bav-chigi-f-iv-75",
 *    "BK.137/bk-textzeuge",
 *    "BK.137/kopenhagen-kb-1943-4",
 *    "BK.137/paris-bn-lat-2718",
 * ]
 */


function unroll_witnesses(rolled) {
  var _ref;

  return (_ref = []).concat.apply(_ref, (0, _toConsumableArray2.default)(rolled.map(function (d) {
    return d.witnesses.map(function (w) {
      return "".concat(d.corresp, "/").concat(w);
    });
  })));
}

function get_sigla(item) {
  // Get the sigla of all witnesses to collate in user-specified order
  return $(item).closest('table').find('tr[data-siglum]').map(function () {
    return this.getAttribute('data-siglum');
  }).get();
}

//# sourceMappingURL=tools.js.map