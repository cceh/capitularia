(function ($) {

    function initSidebarToc () {
        var viewport_height = $(window).height ();
        var sidebar = $("div.sidebar-toc");
        sidebar.css ("height", viewport_height + "px");
        sidebar.sticky ({topSpacing: 0});
    }

    $(document).ready (function () {
        initSidebarToc ();
    });

})(jQuery);
