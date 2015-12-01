(function ($) {

    function initAccordions () {
        // Initializes the menu accordions
        $("li.dynamic-menu-item").each (function () {
            if ($(this).children ("ul").length > 0 ) {
                $(this).accordion ({ collapsible: true, active: "false", heightStyle: "content" });
                $(this).addClass ("big-accordion");
            }
        });
    }

    $(document).ready (function () {
        initAccordions ();
    });

})(jQuery);
