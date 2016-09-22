function on_cap_action_file (e, action) {
    var $e     = jQuery (e);
    var $tr    = $e.closest ('tr');
    var $table = $e.closest ('table');
    var $form  = $e.closest ('form');

    var data = {
        'action':      'on_cap_action_file',      /* the AJAX action */
        'user_action': action,
        'section':     $tr.attr ("data-section"),
        'filename':    $tr.attr ("data-filename"),
        'slug':        $tr.attr ("data-slug"),
        'paged':       $form.attr ("data-paged"),
    };
    data[ajax_object.ajax_nonce_param_name] = ajax_object.ajax_nonce;

    var msg_div    = jQuery ('div.cap_page_dash_message');
    var status_div = $tr.find ('td.column-status');
    var spinner    = jQuery ("<div class='cap_page_spinner'></div>").progressbar ({value: false});
    spinner.hide ().appendTo (status_div).fadeIn ();

    jQuery.ajax ({
        method: "POST",
        url: ajaxurl,
        data : data,
    }).done (function (response, status) {
        $table.find ('tbody').html (response.rows);
    }).always (function (response, status) {
        spinner.fadeOut ().remove ();
        jQuery (response.message).hide ().appendTo (msg_div).slideDown ();
        /* Adds a 'dismiss this notice' button. */
        jQuery (document).trigger ('wp-plugin-update-error');
    });
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

function get_url_parameter (name) {
    var search = window.location.search.substring (1);
    var params = search.split ('&');
    for (var i = 0; i < params.length; i++) {
        var name_val = params[i].split ('=');
        if (name_val[0] == name)
        {
            return name_val[1];
        }
    }
    return null;
}

function init_tabs () {
    var tabs = jQuery ("#tabs" );
    tabs.tabs ({
        /*
         * Display a Wordpress spinner.
         *
         * See: https://make.wordpress.org/core/2015/04/23/spinners-and-dismissible-admin-notices-in-4-2/
         */
        beforeLoad: function (event, ui) {
            ui.panel.html ('<div class="spinner-div"><span class="spinner is-active" /></div>');
        },
        load: function (event, ui) {
            make_cb_select_all (event, ui);
        },
    });
    /*
     * Remove lots of troublesome jQuery-ui styles that we would otherwise have
     * to undo in css because they clash with Wordpress style.
     */
    tabs.parent ().find ('*').removeClass (
        'ui-widget-content ui-widget-header ui-tabs-panel ui-corner-all ui-corner-top ui-corner-bottom'
    );

    /* open the right tab */
    var section = get_url_parameter ('section');
    if (section) {
        var index = tabs.find ('a[data-section="' + section + '"]').parent ().index ();
        tabs.tabs ("option", "active", index);
    }

}

jQuery (document).ready (function () {
    init_tabs ();
});
