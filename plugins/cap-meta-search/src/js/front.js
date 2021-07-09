/** @module plugins/meta-search */

/**
 * The meta search applet.
 * @file
 */

import $ from 'jquery';
import jstree from 'imports-loader?imports=default|jquery|jQuery!jstree';

import { Tooltip } from 'bootstrap';

/**
 * Initialize the help button in the widget.
 *
 * @alias module:plugins/meta-search.help_init
 */
function help_init () {
    $ ('.cap-meta-search-help').on ('click', function (dummy_event) {
        $ ('div.cap-meta-search-help-text').toggle ();
    });
    const bs_tooltips = [].slice.call (document.querySelectorAll ('[data-bs-toggle="tooltip"]'));
    bs_tooltips.map ((el) => new Tooltip (el, { 'placement' : 'left' } ));
}

/** @ignore */
var collator = new Intl.Collator ('de');

/**
 * Initialize the places tree view in the widget.
 *
 * @alias module:plugins/meta-search.places_tree_init
 */
function places_tree_init () {
    $ ('#places').jstree ({
        'plugins'  : ['checkbox', 'sort', 'state', 'wholerow'],
        'checkbox' : {
            'three_state' : false,
            // 'cascade'     : 'down',
        },
        'sort' : function (a, b) {
            return collator.compare (this.get_text (a), this.get_text (b));
        },
        'core' : {
            'themes' : {
                'icons' : false,
                'dots'  : false,
            },
            // See: https://www.jstree.com/docs/json/
            'data' : function (node, callback) {
                $.ajax (cap_lib.api_url + '/data/places.json/?lang=' + document.documentElement.lang.substring (0, 2))
                    .then ((response) => callback (response.map (
                            function (r) {
                                return { 'id' : r.geo_id, 'parent' : r.parent_id || '#', 'text' : r.geo_name };
                            }
                    )));
            },
        },
    });

    $ ('div.cap-meta-search-box form').submit (function (event) {
        var data = $ (event.target).serializeArray ();
        var jstree = $ ('#places').jstree (true);
        $.each (jstree.get_selected (true), function (i, node) {
            data.push ({ 'name' : 'places[]', 'value' : node.id });
            // used by "You searched for: X"
            data.push ({ 'name' : 'placenames[]', 'value' : node.text });
        });
        // submit to the wordpress search page
        window.location.href = '/?' + $.param (data);
        event.preventDefault ();
    });
}

help_init ();
places_tree_init ();
