<?php
/**
 * Template Name: UebersichtKapitularien
 *
 * @package WordPress
 * @subpackage Capitularia
 * @since Capitularia 0.1
 */
   ?>

<?php get_header(); ?>

<main id="main">

  <div class="content-col">
    <?php if (have_posts()) : while (have_posts()) : the_post(); ?>

    <!-- Titel der Seite anzeigen -->
    <div class="page-header">
      <h2>
	<?php the_title(); ?>
      </h2>
    </div>

    <!-- Inhalt der Seite anzeigen -->
    <div class="entry">
      <?php the_content(); ?>
    </div>

    <?php endwhile; ?>
    <?php endif; ?>
  </div>

  <div class="sidebar-col">
    <h4>&Uuml;bersicht Kapitularien</h4>

    <?php wp_nav_menu( array( 'theme_location' => 'uebersichtkapitularien-menu',
			      'menu_class' => 'transkription-uebersicht' ) ); ?>
  </div>

</main>

<?php get_footer(); ?>
