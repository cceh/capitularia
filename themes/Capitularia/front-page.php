<?php

/**
 * Capitularia Theme front-page.php file
 *
 * @package Capitularia
 */

get_header (); ?>

<main id="main" class="home front-page-php">

  <div class="front-splash ui-helper-clearfix">
    <h1><?php bloginfo ('description', 'display'); ?></h1>
    <ul>
        <?php dynamic_sidebar ('frontpage-image') ?>
    </ul>
  </div>

  <div class="teaser-bar teaser-bar-1 ui-helper-clearfix">
    <ul>
        <?php dynamic_sidebar ('frontpage-teaser-1') ?>
    </ul>
  </div>

  <div class="teaser-bar teaser-bar-2 ui-helper-clearfix">
    <ul>
        <?php dynamic_sidebar ('frontpage-teaser-2') ?>
    </ul>
  </div>

</main>

<?php get_footer ();
