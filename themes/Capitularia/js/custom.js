var inPrintMode = false;

(function ($) {

    function initBackToTop(){
        $('.back-to-top').click(function(){
            $('body,html').animate({'scroll-top':0},600);
            return false;
        });
    }

    function initResetForm(){
        $('.reset-form').click(function(){
            $(this).closest('form').find('input[type="text"]').val('');
            $(this).closest('form').find('select').each(function(){
                var v = $(this).children().first().val();
                $(this).val(v);
            });
        });
    }

    function initSmoothScrollLinks(){
        $('a').each (function () {
            if ($(this).hasClass ('ssdone')) {
                return;
            }
            $(this).addClass ('ssdone');

            var href = $(this).attr ('href');
            if (href === undefined) {
                return;
            }
            href = href.replace ('.', '\\.');
            var io = href.indexOf ('#');
            // only act on page-internal links
            if (io !== 0) {
                return;
            }
            $(this).addClass ('sscontrolled');

            $(this).click (function () {
                var target = $(href);
                if (target.length > 0) {
                    var off = target.first ().offset ().top;
                    $('body,html').animate ({'scroll-top': off}, 600);
                    return false;
                }
            });
        });
    }

    function detectPrintMode () {
        // sets inPrintMode as side effect
        if (window.matchMedia) {
            // modern browers
            var mql = window.matchMedia ('print');
            if (mql.matches) {
                inPrintMode = true;
            }
        } else {
            // IE < 10
            window.onbeforeprint = function () {
                inPrintMode = true;
            };
        }
    }

    function initFootnoteTooltips () {
        $("a.annotation-ref").cap_tooltip ({
            items: "a",
            content: function () {
                var href = $(this).attr ('href');
                // jquery appends the content to a 'log file' div.  Printing
                // footnotes would not work any more after that.  We let jquery
                // grab a clone instead so we still have the footnotes where we
                // want to print them.
                return $(href).closest ('div.annotation-content').clone ();
            },
            show: false,
            hide: true,
            tooltipClass: 'ui-tooltip-footnote',
            position: {
                my: "center bottom-10",
                at: "center top",
                collision: "fit"
            }
        });
    }

    function initLegend () {
        // the Legend slide-out
        var legend = $('#legend');
        if (legend.length) {
            var wrapper = $(
                '<div class="slideout screen-only"><div class="slideout-tab"></div><div class="slideout-inner"></div></div>');
            $('body').append (wrapper);
            var legend_copy = legend.clone ();
            legend.addClass ('print-only');
            $('div.slideout-inner').append (legend_copy);
            $('div.slideout-tab').append ($('div.slideout-inner h5'));
            $('div.slideout-tab, div.slideout-inner').click (function () {
                $(this).parent ().toggleClass ('slideout-active');
            });
        }
    }

    detectPrintMode ();

    //
    // a custom tooltip jquery widget that stays open while the user is hovering
    // on the popup, allowing her to click on links in the popup
    //

    $.widget ("custom.cap_tooltip", $.ui.tooltip, {
        open: function (event) {
            var that = this;
            var ret = this._super (event);
            var target = $(event ? event.currentTarget : this.element);
            this._off (target, "mouseleave");
            this.capTimeoutId = 0;

            target.off ("mouseleave");
            target.on ("mouseleave", function () {
                var id = setTimeout (function () {
                    // console.log ("a mouseleave timeout");
                    that.close ();
                }, 500);
                target.data ('capTimeoutId', id);
                // console.log ("a mouseleave id=" + id);
            });

            var tooltipData = this._find (target);
            if (tooltipData) {
                var tt = $(tooltipData.tooltip);
                tt.off ("mouseenter mouseleave");
                tt.on ("mouseenter", function (event) {
                    var id = target.data ('capTimeoutId');
                    clearTimeout (id);
                    // console.log ("div mouseenter id=" + id);
                });
                tt.on ("mouseleave", function (event) {
                    // console.log ("div mouseleave");
                    that.close ();
                });
            }
            return ret;
        }
    });

    $(document).ready (function () {
        setTimeout (initBackToTop,0);
        setTimeout (initSmoothScrollLinks,0);
        setTimeout (initResetForm,0);
        initFootnoteTooltips ();
        initLegend ();
    });

})(jQuery);
