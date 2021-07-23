/** @module themes/capitularia */

/**
 * This file contains the Javascript for the Capitularia theme.
 *
 * @file
 */

import $ from 'jquery';
import { Tooltip } from 'bootstrap';
import panZoom from 'panzoom';

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
 * Initialize the footnote refs, ie. the '*', to open a popup on mouse hover.
 * The popup contains the footnote text.  The popup shall also stay open while
 * the user hovers over the content, so that the user may click on links in the
 * content.
 *
 * Footnotes are done with bootstrap 5.
 *
 * @memberof module:themes/capitularia
 */

function initFootnoteTooltips () {
    $ ('a.annotation-ref').each (function () {
        const tt = new Tooltip (this, {
            'trigger'   : 'manual',
            'placement' : 'top',
            'html'      : true,
            'title'     : function () {
                const href = $ (this).attr ('href');
                return $ (href).closest ('div.annotation-content').prop ('outerHTML');
            },
        });

        $ (this).on ('mouseenter', function () {
            tt.show ();
        }).on ('mouseleave', function () {
            // hack: are there any open tooltips hovered ?
            const hovers = $ ('.tooltip:hover');
            if (hovers.length) {
                // pointer went over the content
                // close when pointer leaves the content
                hovers.on ('mouseleave', function () {
                    tt.hide ();
                });
            } else {
                // close now
                tt.hide ();
            }
        });
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

function initPanZoom () {
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
            }

            // switch tags
            $ (img).replaceWith ($svg);

            // get original scene dimensions, reflows layout
            const sceneRect = svg.getBoundingClientRect ();

            const $container = $svg.closest ('div');
            function calcScale () {
                return $container[0].getBoundingClientRect ();
            }
            let containerRect = calcScale ();
            window.addEventListener ('resize', () => { containerRect = calcScale (); });

            // enable pan & zoom
            const p = panZoom (svg, {
                'onTouch' : function (ev) {
                    // enable click on links
                    return !(ev.type === 'touchstart' || ev.type === 'touchend');
                },
            });
            // do not scroll the whole screen, only the svg
            $container.on ('touchmove', (e) => { e.preventDefault (); });

            function zoom (scale) {
                p.smoothZoom (containerRect.width  / 2, containerRect.height / 2, scale);
            }

            function fit () {
                const sx = containerRect.width  / sceneRect.width;
                const sy = containerRect.height / sceneRect.height;
                const scale = Math.min (sx, sy);
                p.moveTo (0, 0);
                p.zoomAbs (0, 0, scale);
            }

            const $controls = $ ('<div class="pan-zoom-controls"></div>');
            $controls.appendTo ($container);

            $ ('<button>+</button>').appendTo ($controls).on ('click', () => { zoom (2); });
            $ ('<button>0</button>').appendTo ($controls).on ('click', () => { fit (); });
            $ ('<button>-</button>').appendTo ($controls).on ('click', () => { zoom (0.5); });
        }, 'xml');
    }
}

$ (document).ready (function () {
    initFootnoteTooltips ();
    setTimeout (initResetForm, 0);

    initPanZoom ();

    // FIXME: somehow extract this value from bootstrap files
    // if ($('body').css ('content') == 'sm')
    if (window.matchMedia ('(min-width: 768px)').matches) {
        initLegend ();
        initSidebarToc ();
    }
});
