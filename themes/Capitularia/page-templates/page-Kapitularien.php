<?php
/**
 * Template Name: Kapitularien
 *
 * @package WordPress
 * @subpackage Capitularia
 * @since Capitularia 0.1
 */
?>

<?php get_header(); ?>

			<main id="main">

				<div class="content-col">

					<div class="page-header">
						<h2>Kapitularien</h2>
					</div>

					<p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet,</p>



				</div>

				<div class="sidebar-col">
					<h4>&Uuml;bersicht Kapitularien</h4>

					<?php wp_nav_menu( array( 'theme_location' => 'uebersichtkapitularien-menu',
                          'menu_class' => 'kapitularien-uebersicht' ) ); ?>


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