'use strict';

var cap_collation_admin = (function ($) { // eslint-disable-line no-unused-vars
    function add_ajax_action (data, action) {
        data.action = action;
        $.extend (data, cap_collation_admin_ajax_object); // eslint-disable-line no-undef
        return data;
    }

    function get_manuscripts_list () {
        // Get sigla of all manuscript to collate
        var manuscripts = [];
        $ ('table.cap-collation-table-witnesses tbody input:checked').each (function () {
            manuscripts.push ($ (this).val ());
        });
        return manuscripts;
    }

    function get_ignored_manuscripts_list () {
        // Get sigla of all manuscript to ignore
        var manuscripts = [];
        $ ('table.cap-collation-table-witnesses tbody input:not(:checked)').each (function () {
            manuscripts.push ($ (this).val ());
        });
        return manuscripts;
    }

    function get_normalizations () {
        return $ ('#normalizations').val ().split ('\n');
    }

    function get_sections_params () {
        var data = {
            'bk' : $ ('#bk').val (),
        };
        return data;
    }

    function get_manuscripts_params () {
        var data = {
            'corresp' : $ ('#section').val (),
        };
        data = $.extend (data, get_sections_params ());
        return data;
    }

    function get_collation_params () {
        var data = {
            'later_hands'          : $ ('#later_hands').prop ('checked'),
            'algorithm'            : $ ('#algorithm').val (),
            'levenshtein_distance' : $ ('#levenshtein_distance').val (),
            'levenshtein_ratio'    : $ ('#levenshtein_ratio').val (),
            'segmentation'         : $ ('#segmentation').prop ('checked'),
            'transpositions'       : $ ('#transpositions').prop ('checked'),
            'manuscripts'          : get_manuscripts_list (),
            'ignored'              : get_ignored_manuscripts_list (),
            'normalizations'       : get_normalizations (),
        };
        data = $.extend (data, get_manuscripts_params ());
        return data;
    }

    /**
     * Check or uncheck checkboxes according to manuscript list
     *
     * @param sigla   List of sigla of the manuscripts to check or uncheck
     * @param checked To check or to uncheck
     */

    function check_from_list (sigla, checked) {
        var $checkboxes = $ ('table.cap-collation-table-witnesses tbody input');
        $checkboxes.each (function () {
            var $checkbox = $ (this);
            if ($.inArray ($checkbox.val (), sigla) !== -1) {
                $checkbox.prop ('checked', checked);
            }
        });
    }

    /**
     * Sort the sigla to the top of the table.
     *
     * @param sigla   List of sigla of the manuscripts
     */

    function sort_from_list (sigla) {
        var $tbody = $ ('table.cap-collation-table-witnesses tbody');
        $.each (sigla.reverse (), function (index, siglum) {
            var $tr = $tbody.find ('tr[data-siglum="' + siglum + '"]');
            $tr.prependTo ($tbody); // sort to the top
        });
    }

    function check_all (checked) {
        $ ('table.cap-collation-table-witnesses tbody input').prop ('checked', checked);
    }

    function encodeRFC5987ValueChars (str) {
        return encodeURIComponent (str)
        // Note that although RFC3986 reserves '!', RFC5987 does not,
        // so we do not need to escape it
            .replace (/['()]/g, escape) // i.e., %27 %28 %29
            .replace (/\*/g, '%2A')
        // The following are not required for percent-encoding per RFC5987,
        // so we can allow for a little better readability over the wire: |`^
            .replace (/%(?:7C|60|5E)/g, unescape);
    }

    /* Save parameters to a user-local file. */

    function save_params () { // eslint-disable-line no-unused-vars
        var params = get_collation_params ();
        var url = 'data:text/plain,' + encodeURIComponent (JSON.stringify (params, null, 2));
        var e = document.getElementById ('save-fake-download');
        e.setAttribute ('href', url);
        e.setAttribute (
            'download',
            'save-' + encodeRFC5987ValueChars (params.corresp.toLowerCase ()) + '.txt'
        );
        e.click ();

        return false;
    }

    function click_on_load_params (fileInput) { // eslint-disable-line no-unused-vars
        var e = document.getElementById ('load-params');
        e.click ();
    }

    function clear_manuscripts () {
        var $div     = $ ('#manuscripts-div');
        var deferred = $.Deferred ();

        $div.slideUp (function () {
            deferred.resolve ();
        });
        return deferred.promise ();
    }

    function clear_collation () {
        var $div = $ ('#collation-tables');
        var deferred = $.Deferred ();

        $div.fadeOut (function () {
            $div.children ().remove ();
            deferred.resolve ();
        });
        return deferred.promise ();
    }

    function add_spinner ($parent) {
        var spinner = $ ('<div class="spinner-div"><span class="spinner is-active" /></div>');
        spinner.hide ();
        $parent.append (spinner);
        spinner.fadeIn ();
        return spinner;
    }

    function clear_spinners () {
        var spinners = $ ('div.spinner-div');
        spinners.fadeOut (function () {
            $ (this).detach (); // Do not use remove here or promise () won't work.
        });
        return spinners.promise ();
    }

    function handle_message (div, response) {
        clear_spinners ().done (function () {
            if (response) {
                var msg = $ (response.message).hide ().prependTo (div);
                msg.fadeIn ();
                /* Adds a 'dismiss this notice' button. */
                $ (document).trigger ('wp-plugin-update-error');
            }
        });
    }

    function on_cap_load_sections (onReady) {
        var data = get_sections_params ();

        clear_manuscripts ();
        clear_collation ();

        var div = $ ('#collation-capitulary');
        add_spinner (div);

        $.ajax ({
            'method' : 'POST',
            'url'    : ajaxurl,
            'data'   : add_ajax_action (data, 'on_cap_load_sections'),
        }).done (function (response) {
            clear_spinners ().done (function () {
                $ ('#section').html (response.html);
                if (onReady !== undefined) {
                    onReady ();
                }
            });
        }).always (function (response) {
            handle_message (div, response);
        });
        return false;  // don't submit form
    }

    function on_cap_load_manuscripts (onReady) {
        var data = get_manuscripts_params ();
        var manuscripts = get_manuscripts_list ();
        var ignored = get_ignored_manuscripts_list ();
        var $div = $ ('#manuscripts-div');

        var p1 = clear_manuscripts ();
        var p2 = clear_collation ();
        var p3 = $.ajax ({
            'method' : 'POST',
            'url'    : ajaxurl,
            'data'   : add_ajax_action (data, 'on_cap_load_manuscripts'),
        });

        $.when (p1, p2).done (function () {
            add_spinner ($ ('#collation-capitulary'));
        });

        $.when (p1, p2, p3).done (function () {
            // var $tbody = $ ('#manuscripts-tbody');
            // $ (p3.responseJSON.html).appendTo ($tbody);
            var $wrapper = $ ('div.witness-list-table-wrapper');
            $wrapper.empty ();
            $ (p3.responseJSON.html).appendTo ($wrapper);
            check_all (true);
            check_from_list (ignored, false);
            sort_from_list (ignored);
            sort_from_list (manuscripts);
            clear_spinners ().done (function () {
                $div.slideDown ();
                $ ('div.accordion').accordion ({
                    'collapsible' : true,
                    'active'      : false,
                });
                if (onReady !== undefined) {
                    onReady ();
                }
            });
        }).always (function () {
            handle_message ($div, p3.responseJSON);

            $ ('table.cap-collation-table-witnesses').disableSelection ().sortable ({
                'items' : 'tr[data-siglum]',
            });
        });
        return false;  // don't submit form
    }

    function on_cap_load_collation () {         // eslint-disable-line no-unused-vars
        var data = get_collation_params ();

        var p1 = clear_collation ();
        var p2 = $.ajax ({
            'method' : 'POST',
            'url'    : ajaxurl,
            'data'   : add_ajax_action (data, 'on_cap_load_collation'),
        });

        p1.done (function () {
            var $div = $ ('#manuscripts-div');
            add_spinner ($div);
        });

        var $div = $ ('#collation-tables');
        $.when (p1, p2).done (function () {
            $ (p2.responseJSON.html).appendTo ($div);
            clear_spinners ().done (function () {
                $div.fadeIn ();
                $div.find ('div.accordion').accordion ({
                    'collapsible' : true,
                    'active'      : false,
                });
            });
        }).always (function () {
            handle_message ($div, p2.responseJSON);

            var data_rows = $ ('tr[data-siglum]');
            data_rows.hover (function () {
                $div.find ('tr[data-siglum="' + $ (this).attr ('data-siglum') +  '"]').addClass ('highlight-witness');
            }, function () {
                data_rows.each (function () {
                    $ (this).removeClass ('highlight-witness');
                });
            });
        });
        return false;  // don't submit form
    }

    /*
     * Activate the 'select all' checkboxes on the tables.
     * Stolen from wp-admin/js/common.js
     */

    function make_cb_select_all (ev, ui) { // eslint-disable-line no-unused-vars
        ui.panel
            .find ('thead, tfoot')
            .find ('.check-column :checkbox')
            .on ('click.wp-toggle-checkboxes', function (event) {
                var $this = $ (this);
                var $table = $this.closest ('table');
                var controlChecked = $this.prop ('checked');
                var toggle = event.shiftKey || $this.data ('wp-toggle');

                $table.children ('tbody')
                    .filter (':visible')
                    .children ()
                    .children ('.check-column')
                    .find (':checkbox')
                    .prop ('checked', function () {
                        if ($ (this).is (':hidden,:disabled')) {
                            return false;
                        }

                        if (toggle) {
                            return !$ (this).prop ('checked');
                        }
                        if (controlChecked) {
                            return true;
                        }

                        return false;
                    });

                $table.children ('thead,  tfoot')
                    .filter (':visible')
                    .children ()
                    .children ('.check-column')
                    .find (':checkbox')
                    .prop ('checked', function () {
                        if (toggle) {
                            return false;
                        }
                        if (controlChecked) {
                            return true;
                        }
                        return false;
                    });
            });
    }

    /* Load parameters from a user-local file. */

    function load_params (fileInput) { // eslint-disable-line no-unused-vars
        var files = fileInput.files;
        if (files.length !== 1) {
            return false;
        }

        var reader = new FileReader ();
        reader.onload = function (e) {
            var json = JSON.parse (e.target.result);

            /* Set the control value and then call the onclick function. */
            $ ('#bk').val (json.bk);
            on_cap_load_sections (function () {
                /* Set the control value and then call the onclick function. */
                $ ('#section').val (json.corresp);
                on_cap_load_manuscripts (function () {
                    $ ('#algorithm').val (json.algorithm);
                    $ ('#levenshtein_distance').val (json.levenshtein_distance);
                    $ ('#levenshtein_ratio').val (json.levenshtein_ratio);
                    $ ('#segmentation').prop ('checked', json.segmentation);
                    $ ('#transpositions').prop ('checked', json.transpositions);
                    $ ('#normalizations').val (json.normalizations.join ('\n'));
                    check_all (false);
                    check_from_list (json.manuscripts, true);
                    sort_from_list (json.ignored);
                    sort_from_list (json.manuscripts);
                });
            });
        };
        reader.readAsText (files[0]);

        return false; // Don't submit form
    }

    $ (document).ready (function () {
        clear_manuscripts ();
        clear_collation ();
    });

    return {
        'on_cap_load_sections'    : on_cap_load_sections,
        'on_cap_load_manuscripts' : on_cap_load_manuscripts,
        'on_cap_load_collation'   : on_cap_load_collation,
        'load_params'             : load_params,
        'save_params'             : save_params,
        'click_on_load_params'    : click_on_load_params,
    };
} (jQuery));
