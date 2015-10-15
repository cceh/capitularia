<?php get_header(); ?>
<main id="main" class="home">

				<?php /*

					//letzte 3 Posts anzeigen:
					$latest_blog_posts = new WP_Query( array( 'posts_per_page' => 3 ) );

					if ( $latest_blog_posts->have_posts() ) : while ( $latest_blog_posts->have_posts() ) : $latest_blog_posts->the_post();
					    // Loop output goes here

						//the_content();
						//the_content("Continue reading " . get_the_title());

					endwhile; endif;

					*/

				?>


				<?php
				if ( have_posts() ) {


					$showPosts = 3;

					echo '<table class="handschriften-table">';
					echo '<thead>';
					echo 'Die letzten ' . $showPosts . ' Blogeinträge:';
					echo '</thead>';
					echo '<tbody>';

					$latest_blog_posts = new WP_Query( array( 'posts_per_page' => $showPosts ) );

					if ( $latest_blog_posts->have_posts() ) : while ( $latest_blog_posts->have_posts() ) : $latest_blog_posts->the_post();
					    // Loop output goes here

						//the_content();
						//the_content("Continue reading " . get_the_title());

						//the_post();
						echo '<tr>';
						echo '<td>';
						echo '<h4>';
						the_title();
						echo '</h4>';
						echo '<p>';

						echo '</p>';
						echo '<a class="ssdone" href="' . get_permalink() . '">';
						echo 'zum Blogeintrag';
						echo '</a>';
						echo '<br/>';
						echo '</td>';
						echo '</tr>';

						//the_content();

					endwhile; endif;

					echo '</tbody>';
					echo '</table>';

				}
				?>


			</main>

<?php get_footer(); ?>