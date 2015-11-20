<?php
/**
 * Template Name: Startseite
 *
 * @package WordPress
 * @subpackage Capitularia
 * @since Capitularia 0.1
 */
?>

/*** Warning: this is a test page, not the real front page! ****/

<?php get_header (); ?>

<main id="main" class="home">

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

<?php get_footer (); ?>
