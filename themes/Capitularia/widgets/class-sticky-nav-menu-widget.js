(function ($) {

    function initSidebarToc () {
        var viewport_height = $(window).height ();
        var sidebar = $("div.sidebar-toc");
        sidebar.css ("height", viewport_height + "px");
        sidebar.sticky ({topSpacing: 0});
    }

    $(document).ready (function () {
        // FIXME: somehow extract this value from bootstrap files
        // if ($('body').css ('content') == 'sm')
        if (window.matchMedia ('(min-width: 768px)').matches) {
            initSidebarToc ();
        }
    });

})(jQuery);
