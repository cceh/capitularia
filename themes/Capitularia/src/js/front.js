/** @module themes/capitularia */

/**
 * This file contains the Javascript for the Capitularia theme.
 *
 * @file
 */

import $ from 'jquery';

/**
 * Initialize the back to top link: on click do a smooth scroll to the top
 * of the page.
 *
 * @memberof module:themes/capitularia
 */

function initBackToTop () {
    $ ('.back-to-top').click (function () {
        $ ('body,html').animate ({ 'scroll-top' : 0 }, 600);
        return false;
    });
}

/**
 * Initialize all links on the page to do a smooth scroll to their
 * respective targets.
 *
 * @memberof module:themes/capitularia
 */

function initSmoothScrollLinks () {
    $ ('a').each (function () {
        if ($ (this).hasClass ('ssdone')) {
            return;
        }
        $ (this).addClass ('ssdone');

        let href = $ (this).attr ('href');
        if (href === undefined) {
            return;
        }
        href = href.replace ('.', '\\.');

        // only act on page-internal links
        if (href.indexOf ('#') !== 0) {
            return;
        }

        // only act on existing targets
        let target = null;
        try {
            target = $ (href);
        } catch (e) {
            return;
        }
        if (target.length === 0) {
            return;
        }

        $ (this).addClass ('sscontrolled');
        $ (this).on ('click', function (event) {
            const off = target.first ().offset ().top;
            $ ('body,html').animate ({ 'scroll-top' : off }, 600);
            event.preventDefault ();
            return true;
        });
    });
}

/**
 * Initialize reset buttons to reset input and select controls on the parent
 * form.
 *
 * @memberof module:themes/capitularia
 */

function initResetForm () {
    $ ('.reset-form').click (function () {
        $ (this).closest ('form').find ('input[type="text"]').val ('');
        $ (this).closest ('form').find ('select').each (function () {
            const v = $ (this).children ().first ().val ();
            $ (this).val (v);
        });
    });
}

/**
 * Initialize the footnote refs, ie. the '*', to open a popup on mouse
 * hover.  The popup contains the footnote text.
 *
 * @memberof module:themes/capitularia
 */

function initFootnoteTooltips () {
    $ ('a.annotation-ref').tooltip ({
        'placement' : 'top',
        'title'     : function () {
            const href = $ (this).attr ('href');
            return $ (href).closest ('div.annotation-content').prop ('outerHTML');
        },
        'html'    : true,
        'trigger' : 'manual',
        // 'boundary'   : 'window',
    }).on ('mouseenter', function () {
        // keeps the tooltip open as long as the user hovers over it,
        // the user may click on links
        const that = this;
        $ (this).tooltip ('show');
        $ ('.tooltip').on ('mouseleave', function () {
            $ (that).tooltip ('hide');
        });
    }).on ('mouseleave', function () {
        const that = this;
        setTimeout (function () {
            if (!$ ('.tooltip:hover').length) {
                $ (that).tooltip ('hide');
            }
        }, 300);
    });
}

/**
 * Initialize the legend slide-out.  Make the legend slide out (and back in)
 * if the user clicks on the respective tab.
 *
 * @memberof module:themes/capitularia
 */

function initLegend () {
    // the Key (Legend) slide-out
    const legend = $ ('#legend');
    if (legend.length) {
        const wrapper = $ ('<div class="slideout screen-only"><div class="slideout-tab"></div>'
                         + '<div class="slideout-inner"></div></div>');
        $ ('body').append (wrapper);
        const legend_copy = legend.clone ();
        legend.addClass ('print-only');
        $ ('div.slideout-inner').append (legend_copy);
        $ ('div.slideout-tab').append ($ ('div.slideout-inner h5'));
        $ ('div.slideout-tab, div.slideout-inner').click (function () {
            $ (this).parent ().toggleClass ('slideout-active');
        });
    }
}

function initSidebarToc () {
    var sidebar = $ ('div.sidebar-toc');
    var top = parseInt (sidebar.css ('top'), 10);
    var height = $ (window).height () - (2 * top) + 'px';
    sidebar.css ('max-height', height);
    sidebar.closest ('li').css ('height', '100%');
    sidebar.closest ('ul').css ('height', '100%');
}

$ (document).ready (function () {
    initFootnoteTooltips ();
    setTimeout (initBackToTop, 0);
    setTimeout (initSmoothScrollLinks, 0);
    setTimeout (initResetForm, 0);

    // FIXME: somehow extract this value from bootstrap files
    // if ($('body').css ('content') == 'sm')
    if (window.matchMedia ('(min-width: 768px)').matches) {
        initLegend ();
        initSidebarToc ();
    }
});
