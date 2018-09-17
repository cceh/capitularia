(function ($) {
    'use strict';

    function initSidebarToc () {
        // fills the navigation sidebar with links and makes it sticky

        var toc = $ ('div.sidebar-toc > ul');

        toc.css ('display', 'none');

        // Initializes the sidebar menu collapsibles

        $ ('li.dynamic-menu-item').each (function () {
            var $this = $ (this);
            var id = $this.attr ('id');
            if ($this.children ('ul').length > 0) {
                $ ('<a class="opener"/>').prependTo ($this)
                    .attr ('data-toggle', 'collapse')
                    .attr ('data-target', '#' + id + '-ul')
                    .addClass ('collapsed');
                $this.children ('a').addClass ('has-opener');
                $this.children ('ul').attr ('id', id + '-ul').addClass ('collapse');
            }
        });

        // Remove dangling links

        toc.find ('a').each (function () {
            var href = $ (this).attr ('href') || '';
            // jquery interprets #BK.123 as selector id=BK and class=123
            href = href.replace ('.', '\\.');
            href = href.replace (',', '\\,');
            href = href.replace (':', '\\:');
            if (href && $ (href).length === 0) {
                $ (this).parent ().parent ().css ('display', 'none');
            }
        });

        toc.css ('display', '');

        // Make sidebar sticky

        // FIXME: somehow extract this value from bootstrap files
        // if ($('body').css ('content') == 'sm')
        if (window.matchMedia ('(min-width: 768px)').matches) {
            var height = $ (window).height () + 'px';
            var sidebar = $ ('div.sidebar-toc');
            sidebar.css ('max-height', height);
            sidebar.closest ('li').css ('height', '100%');
            sidebar.closest ('ul').css ('height', '100%');
        }
    }

    $ (document).ready (function () {
        initSidebarToc ();
    });
} (jQuery));
