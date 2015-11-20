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
            $(this).click (function () {
                var href = $(this).attr ('href');
                if (href === undefined) {
                    return;
                }
                href = href.replace ('.', '\\.');
                var io = href.indexOf ('#');
                if (io == -1) {
                    return;
                }
                href = href.substr (io);
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
        $("div.content-col").tooltip ({
            items: "a.annotation-ref",
            content: function () {
                var href = $(this).attr ('href');
                // clone because jquery appendsTo a 'log file'
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

    detectPrintMode ();

    $(document).ready (function () {
        setTimeout (initBackToTop,0);
        setTimeout (initSmoothScrollLinks,0);
        setTimeout (initResetForm,0);
        initFootnoteTooltips ();
    });

})(jQuery);
