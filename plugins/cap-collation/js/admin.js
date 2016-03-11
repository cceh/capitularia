function add_ajax_action (data, action) {
    /* the AJAX action */
    data.action = action;
    /* the AJAX nonce  */
    data[ajax_object.ajax_nonce_param_name] =
        ajax_object.ajax_nonce;
    return data;
}

function get_manuscripts_list () {
    // Get sigla of all manuscript to collate
    var manuscripts = [];
    jQuery ('table.manuscripts-collated tbody tr').each (function () {
        manuscripts.push (jQuery (this).attr ('data-siglum'));
    });
    return manuscripts;
}

function get_normalizations () {
    return jQuery ('#normalizations').val ().split ("\n");
}

function get_sections_params () {
    var data = {
        'bk': jQuery ('#bk').val (),
    };
    return data;
}

function get_manuscripts_params () {
    var data = {
        'corresp': jQuery ('#section').val (),
    };
    data = jQuery.extend (data, get_sections_params ());
    return data;
}

function get_collation_params () {
    var data = {
        'algorithm':            jQuery ('#algorithm').val (),
        'levenshtein_distance': jQuery ('#levenshtein_distance').val (),
        'levenshtein_ratio':    jQuery ('#levenshtein_ratio').val (),
        'segmentation':         jQuery ('#segmentation').prop ('checked'),
        'transpositions':       jQuery ('#transpositions').prop ('checked'),
        'manuscripts':          get_manuscripts_list (),
        'normalizations':       get_normalizations (),
    };
    data = jQuery.extend (data, get_manuscripts_params ());
    return data;
}

/* Save parameters to a user-local file. */

function save_params () {
    var params = get_collation_params ();
    var url = 'data:text/plain,' + encodeURIComponent (JSON.stringify (params, null, 2));
    var e = document.getElementById ("save-fake-download");
    e.setAttribute ("href", url);
    e.setAttribute (
        "download",
        "save-" + encodeRFC5987ValueChars (params.corresp.toLowerCase ()) + ".txt"
    );
    e.click ();

    return false;
}

function click_on_load_params (fileInput) {
    var e = document.getElementById ("load-params");
    e.click ();
}

/* Load parameters from a user-local file. */

function load_params (fileInput) {
    var files = fileInput.files;
    if (files.length != 1) {
        return false;
    }

    var reader = new FileReader ();
    reader.onload = function (e) {
        var json = JSON.parse (e.target.result);

        /* Set the control value and then call the onclick function. */
        jQuery ('#bk').val (json.bk);
        on_cap_load_sections (function () {

            /* Set the control value and then call the onclick function. */
            jQuery ('#section').val (json.corresp);
            on_cap_load_manuscripts (function () {

                jQuery ('#algorithm').val (json.algorithm);
                jQuery ('#levenshtein_distance').val (json.levenshtein_distance);
                jQuery ('#levenshtein_ratio').val (json.levenshtein_ratio);
                jQuery ('#segmentation').prop ('checked', json.segmentation);
                jQuery ('#transpositions').prop ('checked', json.transpositions);

                /*
                 * Deal with manuscript tables.  First move *all* manuscripts to the
                 * ignored table.  Then move manuscripts to collate back in sorted
                 * order.
                 */
                var collated = jQuery ('table.manuscripts-collated tbody');
                var ignored  = jQuery ('table.manuscripts-ignored tbody');
                collated.find ('tr').appendTo (ignored);
                for (var i = 0; i < json.manuscripts.length; i++) {
                    var siglum = json.manuscripts[i];
                    var tr = ignored.find ('tr[data-siglum="' + siglum + '"]');
                    tr.appendTo (collated);
                }
            });
        });

    };
    reader.readAsText (files[0]);

    return false; // Don't submit form
}


function encodeRFC5987ValueChars (str) {
    return encodeURIComponent (str).
        // Note that although RFC3986 reserves "!", RFC5987 does not,
        // so we do not need to escape it
        replace (/['()]/g, escape). // i.e., %27 %28 %29
        replace (/\*/g, '%2A').
            // The following are not required for percent-encoding per RFC5987,
            // so we can allow for a little better readability over the wire: |`^
            replace (/%(?:7C|60|5E)/g, unescape);
}

function clear_sections () {
    jQuery ('#collation-sections').children ().slideUp ().remove ();
}

function clear_manuscripts () {
    jQuery ('#manuscripts-div').children ().slideUp ().remove ();
}

function clear_collation () {
    jQuery ('#collation-tables').children ().slideUp ().remove ();
}

function add_spinner (div) {
    var spinner = jQuery ('<div class="spinner-div"><span class="spinner is-active" /></div>');
    spinner.hide ();
    div.append (spinner);
    spinner.slideDown ();
    return spinner;
}

function clear_spinners () {
    var spinners = jQuery ('div.spinner-div');
    spinners.slideUp (function () {
        jQuery (this).remove ();
    });
}

function on_cap_load_sections (onReady) {
    var data = add_ajax_action (get_sections_params (), 'on_cap_load_sections');

    clear_sections ();
    clear_manuscripts ();
    clear_collation ();

    var div = jQuery ('#collation-sections');
    add_spinner (div);

    jQuery.ajax ({
        method: "POST",
        url: ajaxurl,
        data : data,
    }).done (function (response, status) {
        div.append (jQuery (response.html).hide ().slideDown ());
    }).always (function (response, status) {
        clear_spinners ();
        jQuery (response.message).hide ().appendTo (div).slideDown ();
        /* Adds a 'dismiss this notice' button. */
        jQuery (document).trigger ('wp-plugin-update-error');
        if (onReady !== undefined) {
            onReady ();
        }
    });
    return false;  // don't submit form
}

function on_cap_load_manuscripts (onReady) {
    var data = add_ajax_action (get_manuscripts_params (), 'on_cap_load_manuscripts');

    clear_manuscripts ();
    clear_collation ();

    var div = jQuery ('#manuscripts-div');
    add_spinner (div);

    jQuery.ajax ({
        method: "POST",
        url: ajaxurl,
        data : data,
    }).done (function (response, status) {
        jQuery (response.html).hide ().appendTo (div).slideDown ();
    }).always (function (response, status) {
        clear_spinners ();
        jQuery (response.message).hide ().appendTo (div).slideDown ();
        /* Adds a 'dismiss this notice' button. */
        jQuery (document).trigger ('wp-plugin-update-error');

        jQuery ('table.manuscripts').disableSelection ().sortable ({
            helper: 'clone',
            items: '*[data-siglum]',
            connectWith: 'table.manuscripts',
            cursor: 'pointer',
            receive: function (event, ui) {
                var tbody = jQuery (event.target).find ('tbody');
                if (ui.item.closest (tbody).size () === 0) {
                    ui.item.appendTo (tbody);
                }
	            /* to keep original row width while dragging. See also: admin.less */
                ui.item.css ('display', '');
            }
        });

        if (onReady !== undefined) {
            onReady ();
        }
    });
    return false;  // don't submit form
}

function on_cap_load_collation () {
    var data = add_ajax_action (get_collation_params (), 'on_cap_load_collation');

    clear_collation ();

    var div = jQuery ('#collation-tables');
    add_spinner (div);

    jQuery.ajax ({
        method: "POST",
        url: ajaxurl,
        data : data,
    }).done (function (response, status) {
        jQuery (response.html).hide ().appendTo (div).slideDown ();
    }).always (function (response, status) {
        clear_spinners ();
        jQuery (response.message).hide ().appendTo (div).slideDown ();
        /* Adds a 'dismiss this notice' button. */
        jQuery (document).trigger ('wp-plugin-update-error');

        var data_rows = jQuery ('tr[data-siglum]');
        data_rows.hover (function () {
            div.find ('tr[data-siglum="' + jQuery (this).attr ('data-siglum') +  '"]').addClass ('highlight-witness');
        }, function () {
            data_rows.each (function (index) {
                jQuery (this).removeClass ('highlight-witness');
            });
        });
    });
    return false;  // don't submit form
}

/*
 * Activate the 'select all' checkboxes on the tables.
 * Stolen from wp-admin/js/common.js
 */

function make_cb_select_all (event, ui) {
	ui.panel.find ('thead, tfoot').find ('.check-column :checkbox').on ('click.wp-toggle-checkboxes', function (event) {
		var $this = jQuery (this),
			$table = $this.closest( 'table' ),
			controlChecked = $this.prop('checked'),
			toggle = event.shiftKey || $this.data('wp-toggle');

		$table.children( 'tbody' ).filter(':visible')
			.children().children('.check-column').find(':checkbox')
			.prop('checked', function() {
				if ( jQuery (this).is(':hidden,:disabled') ) {
					return false;
				}

				if ( toggle ) {
					return ! jQuery (this).prop( 'checked' );
				} else if ( controlChecked ) {
					return true;
				}

				return false;
			});

		$table.children('thead,  tfoot').filter(':visible')
			.children().children('.check-column').find(':checkbox')
			.prop('checked', function() {
				if ( toggle ) {
					return false;
				} else if ( controlChecked ) {
					return true;
				}

				return false;
			});
	});
}

jQuery (document).ready (function () {
});
