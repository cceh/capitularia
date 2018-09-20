'use strict';

var cap_meta_search_admin = function ($) {
    // eslint-disable-line no-unused-vars
    function add_ajax_action(data, action) {
        data.action = action;
        $.extend(data, cap_meta_search_admin_ajax_object); // eslint-disable-line no-undef
        return data;
    }

    function on_reload_places() {
        var $this = $(this);

        var status_div = $this.closest('div');
        var msg_div = $('div.cap_message');
        var spinner = $('<div class="spinner-div"><span class="spinner is-active" /></div>');
        spinner.hide().appendTo(status_div).fadeIn();

        var data = {};

        $.ajax({
            'method': 'POST',
            'url': ajaxurl,
            'data': add_ajax_action(data, 'on_cap_reload_places')
        }).done(function (response) {
            var cls = response.success ? 'notice-success' : 'notice-error';
            $('<div class="notice ' + cls + ' is-dismissible">' + response.data.message + '</div>').hide().appendTo(msg_div).slideDown();
            /* Adds a 'dismiss this notice' button. */
            $(document).trigger('wp-plugin-update-error');
        }).always(function (dummy_response) {
            spinner.fadeOut().remove();
        });
    }

    return {
        'on_reload_places': on_reload_places
    };
}(jQuery);

//# sourceMappingURL=admin.js.map