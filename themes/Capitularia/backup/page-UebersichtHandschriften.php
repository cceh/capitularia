<?php
/**
 * Template Name: UebersichtHandschriften
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
    <h4>&Uuml;bersicht Handschriften</h4>

    <!-- menu_class orientiert sich an Korthals-Design -->
    <?php wp_nav_menu( array( 'theme_location' => 'uebersichthandschriften-menu',
			      'menu_class' => 'transkription-uebersicht' ) ); ?>

    <div class="filter-box">

      <h4>Filter: Hss. nach Kriterien</h4>
      <form class="filter-form" action="#">

	<label for="filter-kapitularien">Kapitularien</label>
	<select id="filter-kapitularien" name="kapitularien">
	  <option value="alle"> - Alle - </option>
	  <option value="1"> Option 1</option>
	  <option value="2"> Option 2</option>
	  <option value="3"> Option 3</option>
	</select>

	<label for="filter-datierung">Datierung</label>
	<select id="filter-datierung" name="datierung">
	  <option value="alle"> - Alle - </option>
	  <option value="1"> Option 1</option>
	  <option value="2"> Option 2</option>
	  <option value="3"> Option 3</option>
	</select>

	<label for="filter-herkunft">Herkunft</label>
	<select id="filter-herkunft" name="herkunft">
	  <option value="alle"> - Alle - </option>
	  <option value="1"> Option 1</option>
	  <option value="2"> Option 2</option>
	  <option value="3"> Option 3</option>
	</select>

	<label for="filter-institution">Institution</label>
	<select id="filter-institution" name="institution">
	  <option value="alle"> - Alle - </option>
	  <option value="1"> Option 1</option>
	  <option value="2"> Option 2</option>
	  <option value="3"> Option 3</option>
	</select>

	<label for="filter-undoder1">und/oder</label>
	<input type="text" id="filter-undoder1" name="undoder1">

	<label for="filter-undoder2">und/oder</label>
	<input type="text" id="filter-undoder2" name="undoder2">

	<input type="submit" value="Absenden"/>
	<a href="javascript:void(0)" class="reset-form">Suche zur&uuml;rcksetzen</a>
      </form>

    </div>

    <div class="filter-box">

      <h4>Filter: Hss. nach Kriterien</h4>
      <form class="filter-form" action="#">

	<label for="filter-kapitularien">Kapitularien</label>
	<select id="filter-kapitularien" name="kapitularien">
	  <option value="alle"> - Alle - </option>
	  <option value="1"> Option 1</option>
	  <option value="2"> Option 2</option>
	  <option value="3"> Option 3</option>
	</select>

	<label for="filter-datierung">Datierung</label>
	<select id="filter-datierung" name="datierung">
	  <option value="alle"> - Alle - </option>
	  <option value="1"> Option 1</option>
	  <option value="2"> Option 2</option>
	  <option value="3"> Option 3</option>
	</select>

	<label for="filter-herkunft">Herkunft</label>
	<select id="filter-herkunft" name="herkunft">
	  <option value="alle"> - Alle - </option>
	  <option value="1"> Option 1</option>
	  <option value="2"> Option 2</option>
	  <option value="3"> Option 3</option>
	</select>

	<label for="filter-institution">Institution</label>
	<select id="filter-institution" name="institution">
	  <option value="alle"> - Alle - </option>
	  <option value="1"> Option 1</option>
	  <option value="2"> Option 2</option>
	  <option value="3"> Option 3</option>
	</select>

	<label for="filter-undoder1">und/oder</label>
	<input type="text" id="filter-undoder1" name="undoder1">

	<label for="filter-undoder2">und/oder</label>
	<input type="text" id="filter-undoder2" name="undoder2">

	<input type="submit" value="Absenden"/>
	<a href="javascript:void(0)" class="reset-form">Suche zur&uuml;rcksetzen</a>
      </form>

    </div>
  </div>

</main>

<?php get_footer(); ?>
