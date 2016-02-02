<?php
/**
 * Template Name: Startseite
 *
 * @package Capitularia
 */

////////////////////////////////////////////////////////////
// Warning: this is a test page, not the real front page! //
////////////////////////////////////////////////////////////

namespace cceh\capitularia\theme;

get_header ();

?>

<main id="main" class="home page-startseite-php">

  <div class="front-splash ui-helper-clearfix">
    <h1><?php bloginfo ('description', 'display'); ?></h1>
    <?php dynamic_sidebar ('frontpage-image') ?>
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
