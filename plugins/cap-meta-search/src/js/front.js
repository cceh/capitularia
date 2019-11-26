'use strict';

var cap_meta_search_front = (function ($) { // eslint-disable-line no-unused-vars
    function help_init () {
        $ ('.cap-meta-search-help').on ('click', function (dummy_event) {
            $ ('div.cap-meta-search-help-text').toggle ();
        });
        $ ('div.cap-meta-search-box [title]').tooltip ({
            'placement' : 'bottom',
        });
    }

    var collator = new Intl.Collator ('de');

    function places_tree_init () {
        var container = $ ('#places');
        container.jstree ({
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
                    $.ajax (cap_lib.api_url + '/data/places.json/')
                        .then ((response) => {
                            callback (response.map (
                                function (r) {
                                    return { 'id' : r.geo_id, 'parent' : r.parent_id || '#', 'text' : r.geo_name };
                                }
                            ));
                        });
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

    $ (document).ready (function () {
        places_tree_init ();
        help_init ();
    });

    return {
    };
} (jQuery));
