(function ($) {
    'use strict';

    function initSidebarToc() {
        // fills the navigation sidebar with links

        var toc = $('div.sidebar-toc > ul');

        toc.css('display', 'none');

        // Initializes the sidebar menu collapsibles

        $('li.dynamic-menu-item').each(function () {
            var $this = $(this);
            var id = $this.attr('id');
            if ($this.children('ul').length > 0) {
                $this.children('a').addClass('has-opener');
                $('<a class="opener"/>').prependTo($this).attr('data-toggle', 'collapse').attr('data-target', '#' + id + '-ul').addClass('collapsed');
                $this.children('ul').attr('id', id + '-ul').addClass('collapse');
            }
        });

        // Remove dangling links

        toc.find('a[href]').each(function () {
            // jquery interprets #BK.123 as selector id=BK and class=123
            var href = $(this).attr('href');
            if (href[0] === '#') {
                href = '#' + $.escapeSelector(href.slice(1));
                if ($(href).length === 0) {
                    $(this).parent().parent().css('display', 'none');
                }
            }
        });

        toc.css('display', '');
    }

    $(document).ready(function () {
        initSidebarToc();
    });
})(jQuery);

//# sourceMappingURL=front.js.map