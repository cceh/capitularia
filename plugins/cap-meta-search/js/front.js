function on_cap_meta_search_extract_metadata (post_id, xml_path) {
    var e = jQuery (element);
    var tr = e.closest ('tr');

    var data = {
        'action'      : 'on_cap_action_file',
        'user_action' : 'metadata',
        'path'        : xml_path,
        'post_id'     : post_id,
    };
    data[ajax_object.ajax_nonce_param_name] = ajax_object.ajax_nonce;

    var msg_div    = jQuery ('div.cap_page_dash_message');
    var status_div = tr.find ('td.column-status');
    var spinner    = jQuery ('<div class="cap_page_spinner"></div>').progressbar ({ 'value' : false });
    spinner.hide ().appendTo (status_div).fadeIn ();

    jQuery.ajax ({
        'method' : 'POST',
        'url'    : ajaxurl,
        'data'   : data,
    }).done (function (response) {
        jQuery ('table.cap_page_gen_table_files tbody').html (response.rows);
    }).always (function (response) {
        spinner.fadeOut ().remove ();
        jQuery (response.message).hide ().appendTo (msg_div).slideDown ();
    });
}

function on_cap_meta_search_toggle_help () {
    var div = jQuery ('div.cap-meta-search-help-text');
    div.toggle ();
}

function cap_meta_search_widget_init_tooltips () {
    jQuery ('div.cap-meta-search-box [title]').tooltip ({
        'position' : {
            'my' : 'right top',
            'at' : 'left-5 top-5',
        },
    });
}

jQuery (document).ready (function () {
    cap_meta_search_widget_init_tooltips ();
});
