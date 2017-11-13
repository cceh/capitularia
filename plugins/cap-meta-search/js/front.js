'use strict';

var cap_meta_search_front = (function ($) { // eslint-disable-line no-unused-vars
    function help_init () {
        $ ('.cap-meta-search-help').on ('click', function (dummy_event) {
            $ ('div.cap-meta-search-help-text').toggle ();
        });
        $ ('div.cap-meta-search-box [title]').tooltip ({
            'tooltipClass' : 'ui-tooltip-search',
            'position'     : {
                'my' : 'right top',
                'at' : 'right bottom+5',
            },
        });
    }

    function places_tree_init () {
        var container = $ ('#places');
        container.jstree ({
            'plugins'  : ['checkbox', 'sort', 'state', 'wholerow'],
            'checkbox' : {
                'three_state' : false,
                // 'cascade'     : 'down',
            },
            'core' : {
                'themes' : {
                    'icons' : false,
                    'dots'  : false,
                },
                'data' : {
                    'method' : 'POST',
                    'url'    : cap_meta_search_front_ajax_object.ajaxurl, // eslint-disable-line no-undef
                    'data'   : function (node) {
                        return {
                            'action' : 'on_cap_places',
                            'id'     : node.id,
                        };
                    },
                },
            },
        });

        $ ('div.cap-meta-search-box form').submit (function (event) {
            var data = $ (event.target).serializeArray ();
            var jstree = $ ('#places').jstree (true);
            $.each (jstree.get_selected (true), function (i, node) {
                if (node.data) {
                    data.push ({ 'name' : 'places[]', 'value' : node.data.id });
                }
            });
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
