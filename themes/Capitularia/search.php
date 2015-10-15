<?php
/**
 * The template for displaying Search Results pages.
 *
 * @package WordPress
 * @subpackage Capitularia
 */
?>

<?php get_header(); ?>

			<main id="main">

				<div class="content-col">

					<div class="page-header">
						<h2>Kapitulariensuche</h2>
					</div>

					<div class="search-pager">
						<?php
						/*if ( ! $_GET["cat"] == '' ) { $filter_cat = '&cat='.$_GET["cat"]; }
$allsearch = &new WP_Query('s='.str_replace(' ', '+', get_search_query()).'&showposts=-1'.$filter_cat);
$count = $allsearch->post_count;
wp_reset_query();

if( have_posts () ) :
$have_post = '1';
$actual_url = currentURL();
$constructed_url = get_bloginfo(url).'/search/'.str_replace(' ', '+', get_search_query()).'/';
$replace = str_replace('page', '', str_replace('/', '', str_replace($constructed_url, '', $actual_url)));
$count_max = $replace*10;
if ( $count_max < $count ) { $the_max = $count_max; } elseif ( $count_max >= $count ) { $the_max = $count; }
$the_min = $replace*10-9;
$display_count = 'Results '.$the_min.' - '.$the_max.' of '.$count;
$display_count = str_replace('Results -9 - 0 of', 'Results 1 - 10 of', $display_count);
*/?>


						<?php if ( have_posts() ) : ?>
						<p>
						<?php echo $wp_query->post_count; ?>

							Ergebnisse
						</p>

						<!--
						<ul>
							<li class="active"><a href="javascript:void(0)">Seite 1</a></li>
							<li><a href="javascript:void(0)">Seite 2</a></li>
						</ul>
						-->

						<?php endif; ?>
					</div>

					<div class="search-results">
						<?php if ( have_posts() ) : ?>



							<?php while ( have_posts() ) : the_post(); ?>

								<?php get_template_part( 'content', get_post_format() ); ?>
								
								<a href="<?php the_permalink(); ?>">
								<h2><?php the_title(); ?></h2>
								</a>
								<p><?php the_excerpt(); ?></p>

							<?php endwhile; ?>

						<?php else : ?>
							
							<?php echo wpautop('Nichts gefunden...'); ?>

						<?php endif; ?>
					</div>

				</div>

				<div class="sidebar-col">

				</div>




			</main>

<?php get_footer(); ?>