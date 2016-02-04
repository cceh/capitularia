function on_cap_load_sections () {
    var bk = jQuery ('#bk').val ();

    var data = {
        'action': 'on_cap_load_sections',      /* the AJAX action */
        'bk':     bk,
    };
    data[ajax_object.ajax_nonce_param_name] = ajax_object.ajax_nonce;

    var div = jQuery ('#collation-sections');
    div.html ('<div class="spinner-div"><span class="spinner is-active" /></div>');

    jQuery.ajax ({
        method: "POST",
        url: ajaxurl,
        data : data,
    }).done (function (response, status) {
        jQuery ('div.spinner-div').fadeOut ().remove ();
        jQuery (response.html).hide ().appendTo (div).slideDown ();
    }).always (function (response, status) {
        jQuery ('div.spinner-div').fadeOut ().remove ();
        jQuery (response.message).hide ().appendTo (div).slideDown ();
        /* Adds a 'dismiss this notice' button. */
        jQuery (document).trigger ('wp-plugin-update-error');
    });
    return false;  // don't submit form
}

function on_cap_load_manuscripts () {
    var data = {
        'action':         'on_cap_load_manuscripts',      /* the AJAX action */
        'corresp':              jQuery ('#section').val (),
        'algorithm':            jQuery ('#algorithm').val (),
        'levenshtein_distance': jQuery ('#levenshtein_distance').val (),
        'levenshtein_ratio':    jQuery ('#levenshtein_ratio').val (),
        'segmentation':         jQuery ('#segmentation').prop ('checked'),
        'transpositions':       jQuery ('#transpositions').prop ('checked'),
    };
    data[ajax_object.ajax_nonce_param_name] = ajax_object.ajax_nonce;

    var div = jQuery ('#collation-tables');
    div.html ('<div class="spinner-div"><span class="spinner is-active" /></div>');

    jQuery.ajax ({
        method: "POST",
        url: ajaxurl,
        data : data,
    }).done (function (response, status) {
        jQuery ('div.spinner-div').fadeOut ().remove ();
        jQuery (response.html).hide ().appendTo (div).slideDown ();
    }).always (function (response, status) {
        jQuery ('div.spinner-div').fadeOut ().remove ();
        jQuery (response.message).hide ().appendTo (div).slideDown ();
        /* Adds a 'dismiss this notice' button. */
        jQuery (document).trigger ('wp-plugin-update-error');
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
