/**
 * Some utility function for the Page Generator admin interface.
 * @module plugins/cap-page-generator/admin
 */

// do not import $ from 'jquery';
// use the WP-provided jquery in the backend
const $ = window.jQuery;

/**
 * The inverse of the jQuery.param () function.
 *
 * @param s {string} A string in the form "p=1&q=2"
 * @return {Object} { p : 1, q : 2 }
 */

function deparam (s) {
    return s.split ('&').reduce ((params, param) => {
        const [key, value] = param.split ('=').map (
            (v) => decodeURIComponent (v.replace ('+', ' '))
        );
        params[key] = value;
        return params;
    }, {});
}

/**
 * Add action parameters to AJAX request data.
 *
 * @param {Object} data The AJAX request data.
 * @param {Object} action The AJAX action.
 * @return {Object} The AJAX request data augmented.
 */

function add_ajax_action (data, action) {
    data.action = action;
    $.extend (data, cap_lib);
    return data;
}

/**
 * Perform an action on a TEI file.
 *
 * The user clicked somewhere inside the table row listing that file.
 *
 * @param {Event} event The click event
 */

function on_cap_action_file (event) {
    event.preventDefault ();

    const $e     = $ (event.target);
    const $tr    = $e.closest ('tr');
    const $table = $e.closest ('table');
    const $form  = $e.closest ('form');

    const data = {
        'user_action' : $e.attr ('data-action'),
        'section'     : $tr.attr ('data-section'),
        'filename'    : $tr.attr ('data-filename'),
        'slug'        : $tr.attr ('data-slug'),
        'paged'       : $form.attr ('data-paged'),
    };

    const msg_div    = $ ('div.cap_page_dash_message');
    const status_div = $tr.find ('td.column-status');
    const spinner    = $ ('<div class="cap_page_spinner"></div>').progressbar ({ 'value' : false });
    spinner.hide ().appendTo (status_div).fadeIn ();

    $.ajax ({
        'method' : 'POST',
        'url'    : ajaxurl,
        'data'   : add_ajax_action (data, 'on_cap_action_file'),
    }).done ((response) => {
        $table.find ('tbody').html (response.rows);
    }).always ((response) => {
        spinner.fadeOut ().remove ();
        $ (response.message).hide ().appendTo (msg_div).slideDown ();
        /* Adds a 'dismiss this notice' button. */
        $ (document).trigger ('wp-plugin-update-error');
    });
}

/**
 * Perform an action on a tab.
 *
 * The user clicked on a tab. The tab contents must now be loaded.
 *
 * @param {Event} event The click event
 */

function on_cap_load_section (event) {
    event.preventDefault ();

    const $this = $ (this);
    const $form  = $this.closest ('form');
    const q = deparam ($this.attr ('href').split ('?')[1] || '');

    const data = {
        'section' : $form.attr ('data-section'),
        'paged'   : q.paged || 1,
    };

    const status_div = $form.parent ();
    const spinner    = $ ('<div class="spinner-div"><span class="spinner is-active" /></div>');
    spinner.hide ().appendTo (status_div).fadeIn ();

    $.ajax ({
        'method' : 'POST',
        'url'    : ajaxurl,
        'data'   : add_ajax_action (data, 'on_cap_load_section'),
    }).done ((response) => {
        $form.closest ('div[role=tabpanel]').html (response);
    }).always (() => {
        spinner.fadeOut ().remove ();
    });
}

/**
 * Activate the 'select all' checkboxes on the tables.
 *
 * Check or uncheck all checkboxes when the user clicks on the "select all"
 * checkbox.  Stolen from wp-admin/js/common.js
 *
 * @param {Event} ev (unused) The tab loaded event emited by jQuery-ui
 * @param {Element} ui The tab element
 */

function make_cb_select_all (ev, ui) {
    ui.panel
        .find ('thead, tfoot')
        .find ('.check-column :checkbox')
        .on ('click.wp-toggle-checkboxes', function (event) {
            const $this          = $ (this);
            const $table         = $this.closest ('table');
            const controlChecked = $this.prop ('checked');
            const toggle         = event.shiftKey || $this.data ('wp-toggle');

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
                .prop ('checked', () => {
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

/**
 * Get a parameter from the URL in the browser location bar.
 *
 * @param {string} name The name of the parameter
 * @return {?string} The value of the parameter or null
 */

function get_url_parameter (name) {
    const urlParams = new URLSearchParams (window.location.search);
    return urlParams.get (name);
}

/**
 * Initialize the jQuery tab interface.
 */

function init_tabs () {
    const tabs = $ ('#tabs');
    tabs.tabs ({
        /*
         * Display a Wordpress spinner.
         *
         * See: https://make.wordpress.org/core/2015/04/23/spinners-and-dismissible-admin-notices-in-4-2/
         */
        'beforeLoad' : function (event, ui) {
            ui.panel.html ('<div class="spinner-div"><span class="spinner is-active" /></div>');
        },
        'load' : function (event, ui) {
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
    const section = get_url_parameter ('section');
    if (section) {
        const index = tabs.find (`a[data-section="${section}"]`).parent ().index ();
        tabs.tabs ('option', 'active', index);
    }
}

$ (() => {
    init_tabs ();
    $ ('body').on ('click', 'div.cap-page-generator-dashboard div.tablenav-pages a', on_cap_load_section);
    $ ('body').on ('click', 'a.cap-page-generator-action', on_cap_action_file);
});
