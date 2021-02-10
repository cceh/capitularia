/** @module themes/capitularia */

/**
 * This file contains the Javascript for the Capitularia theme.
 *
 * @file
 */

import $ from 'jquery';
import svgPanZoom from 'svg-pan-zoom';

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

function initSVGPanZoom () {
    // first replace the <img> with the inline SVG

    for (const img of document.querySelectorAll ('img.svg-pan-zoom[src]')) {

        // retrieve the SVG
        $.get (img.getAttribute ('src'), function (data) {

            // only the SVG tag
            const $svg = $ (data).find ('svg');
            const svg  = $svg[0];
            for (const name of ['width', 'height', 'content']) {
                svg.removeAttribute (name); // clean up
            }

            // copy all attributes from <img> to <svg>
            for (const attr of img.attributes) {
                svg.setAttribute (attr.name, attr.value);
            };

            // switch tags
            $ (img).replaceWith ($svg);

            // enable pan & zoom
            const p = svgPanZoom (svg, {
                fit : false,
                controlIconsEnabled : true,
                zoomScaleSensitivity: 0.5,
            });

            const sizes = p.getSizes ();
            p.resize (); // update SVG cached size and controls positions
            p.fit ();
            p.center ();

        }, 'xml');
    };
}

$ (document).ready (function () {
    initFootnoteTooltips ();
    setTimeout (initBackToTop, 0);
    setTimeout (initResetForm, 0);

    // FIXME: somehow extract this value from bootstrap files
    // if ($('body').css ('content') == 'sm')
    if (window.matchMedia ('(min-width: 768px)').matches) {
        initLegend ();
        initSidebarToc ();
        initSVGPanZoom ();
    }
});
