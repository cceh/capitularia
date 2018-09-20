(function ($) {

    function initSidebarToc () {
        var sidebar = $("div.sidebar-toc");
        var top = parseInt (sidebar.css ('top'));
        var height = $(window).height () - 2 * top + "px";
        sidebar.css ("max-height", height);
        sidebar.closest ('li').css ("height", "100%");
        sidebar.closest ('ul').css ("height", "100%");
    }

    $(document).ready (function () {
        // FIXME: somehow extract this value from bootstrap files
        // if ($('body').css ('content') == 'sm')
        if (window.matchMedia ('(min-width: 768px)').matches) {
            initSidebarToc ();
        }
    });

})(jQuery);
