(function ($) {

    function initSidebarToc () {
        // fills the navigation sidebar with links and makes it sticky

        var toc    = $("div.sidebar-toc > ul");
        var toc_is = $(".menu-dyn-is");

        toc.css ("display", "none");

        // Nach BK Nummern
        // obsolete. done by php now
        var toc_bk = $(".menu-dyn-bk");
        if (toc_bk.length) {
            var milestones = $("span.milestone");
            if (milestones.length) {
                milestones.uniqueId ();
                milestones.each (function () {
                    var text = $(this).attr ("id");
                    text = text.replace (/_.*$/, "");
                    text = text.replace (".", " ");
                    toc_bk.append ("<li><a href='#" + $(this).attr("id") + "'>" + text + "</a></li>");
                });
            } else {
                toc_bk.parent ().css ("display", "none");
            }
        }

        // Nach interner Struktur

        if (toc_is.length && $("#inhaltsverzeichnis").length) {
            // Move element
            toc_is.replaceWith ($("#inhaltsverzeichnis > ul"));
        } else {
            toc_is.parent ().css ("display", "none");
        }

        // Make accordion

        toc.children ("li").addClass ("big-accordion");
        toc.find ("li").each (function () {
            if ($(this).children ("ul").length > 0 ) {
                $(this).accordion ({ collapsible: true, active: "false", heightStyle: "content" });
            }
        });

        // Remove dangling links

        toc.find ("a").each (function () {
            var href = $(this).attr ("href") || '';
            // jquery interprets #BK.123 as selector id=BK and class=123
            href = href.replace ('.', '\\.');
            if (href && $(href).length == 0) {
                $(this).parent ().parent ().css ("display", "none");
            }
        });

        toc.css ("display", "");
        var viewport_height = $(window).height ();
        $("div.sidebar-toc").css ("height", viewport_height + "px");
        $("div.sidebar-toc").sticky ({topSpacing: 0});
    }

    $(document).ready (function () {
        initSidebarToc ();
    });

})(jQuery);
