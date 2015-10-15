<?php
/**
 * Template Name: UebersichtMaterialien
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
    <h4>&Uuml;bersicht Materialien</h4>

    <!-- menu_class orientiert sich an Korthals-Design -->
    <?php wp_nav_menu( array( 'theme_location' => 'uebersichtmaterialien-menu',
			      'menu_class' => 'transkription-uebersicht' ) ); ?>


    <?php /*

<h4>&Uuml;bersicht Kapitularien</h4>
<?php if( !function_exists('dynamic_sidebar')
|| !dynamic_sidebar('UebersichtKapitularien') ) : ?>
<ul class="kapitularien-uebersicht">
  <li><a href="<?php echo get_site_url() . '/?page_id=52'; ?>">Gesamtliste</a></li>
  <li><a href="javascript:void(0)">Kapitularien vor 814</a></li>
  <li><a href="javascript:void(0)">Kapitularien Ludwigs des Frommen</a></li>
  <li><a href="javascript:void(0)">Kapitularien navh 840</a></li>
  <li><a href="javascript:void(0)">Undatierte Kapitularien</a></li>
</ul>
<?php endif; ?>

*/
?>

  </div>



</main>

<?php get_footer(); ?>
