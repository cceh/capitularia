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
    }).done (function (response) {
        alert ('Got this from the server: ' + response.data.message);
    });
}
