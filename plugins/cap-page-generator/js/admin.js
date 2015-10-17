function on_cap_action_file (element, action) {
    var e = jQuery (element);
    var tr = e.closest ('tr');

    var data = {
        'action':      'on_cap_action_file',
        'user_action': action,
        'path':        tr.attr ("data-path"),
        'slug':        tr.attr ("data-slug"),
    };
    data[ajax_object.ajax_nonce_param_name] = ajax_object.ajax_nonce;

    jQuery.ajax ({
        method: "POST",
        url: ajaxurl,
        data : data,
    }).done (function (response, status) {
        jQuery ('table.cap_page_gen_table_files tbody').html (response.rows);
    }).always (function (response, status) {
        var msg = jQuery ('div.cap_page_dash_message');
        msg.html (response.message);
        msg.slideDown ().delay (2000).slideUp ();
    });
}
