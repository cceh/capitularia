<?php

/**
 * The HTML footer on every page.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

?>

<footer id="footer">
  <div id="footer-wrapper" class="ui-helper-clearfix">

    <ul class="footer-text ui-helper-clearfix"></ul>

    <div class="logo-bar logo-bar-1">
      <ul>
        <?php dynamic_sidebar ('logobar') ?>
      </ul>
    </div>
  </div>
</footer>

<?php
          /* Always have wp_footer() just before the closing </body>
           * tag of your theme, or you will break many plugins, which
           * generally use this hook to reference JavaScript files.
           *
           * See: https://codex.wordpress.org/Function_Reference/wp_footer
           */
          wp_footer();
?>

<noscript><img src="//projects.cceh.uni-koeln.de/piwik/piwik.php?idsite=14" style="border:0;" alt="" /></noscript>

</body>
</html>
