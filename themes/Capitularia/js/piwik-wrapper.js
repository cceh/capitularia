var _paq = _paq || [];
_paq.push (['trackPageView']);
_paq.push (['enableLinkTracking']);

(function () {
    var u = "//projects.cceh.uni-koeln.de/piwik/";
    _paq.push (['setTrackerUrl', u + 'piwik.php']);
    _paq.push (['setSiteId', 14]);
    var d = document,
        g = d.createElement ('script'),
        s = d.getElementsByTagName ('script')[0];
    g.type = 'text/javascript';
    g.async = true;
    g.defer = true;
    g.src = u + 'piwik.js';
    s.parentNode.insertBefore (g, s);
}) ();
