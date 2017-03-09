function on_cap_meta_search_toggle_help () { // eslint-disable-line no-unused-vars
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
