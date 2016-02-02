(function ($) {

    function initSidebarToc () {
        // fills the navigation sidebar with links and makes it sticky

        var toc    = $("div.sidebar-toc > ul");

        toc.css ("display", "none");

        // Initializes the menu accordions

        $("li.dynamic-menu-item").each (function () {
            if ($(this).children ("ul").length > 0 ) {
                $(this).accordion ({ collapsible: true, active: "false", heightStyle: "content" });
                $(this).addClass ("big-accordion");
            }
        });

        // Remove dangling links

        toc.find ("a").each (function () {
            var href = $(this).attr ("href") || '';
            // jquery interprets #BK.123 as selector id=BK and class=123
            href = href.replace ('.', '\\.');
            href = href.replace (':', '\\:');
            if (href && $(href).length === 0) {
                $(this).parent ().parent ().css ("display", "none");
            }
        });

        toc.css ("display", "");

        // Make sidebar sticky

        var viewport_height = $(window).height ();
        var sidebar = $("div.sidebar-toc");
        sidebar.css ("height", viewport_height + "px");
        sidebar.sticky ({topSpacing: 0});
    }

    $(document).ready (function () {
        initSidebarToc ();
    });

})(jQuery);
