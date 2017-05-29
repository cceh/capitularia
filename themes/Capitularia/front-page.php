<?php

/**
 * Capitularia Theme front-page.php file
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

get_header ();

?>

<div class="front-splash">
  <div class="front-splash-caption">
    <h1><span><?php bloginfo ('description', 'display'); ?></span></h1>
  </div>
  <ul class="front-splash-image">
    <?php dynamic_sidebar ('frontpage-image') ?>
  </ul>
</div>

<ul class="teaser-bar teaser-bar-1">
  <?php dynamic_sidebar ('frontpage-teaser-1') ?>
</ul>

<ul class="teaser-bar teaser-bar-2">
  <?php dynamic_sidebar ('frontpage-teaser-2') ?>
</ul>

<?php

get_footer ();
