<?php get_header();

function print_link () {
  echo (
    '<a href="' .
    get_the_permalink () .
    '" title="' .
    esc_attr (sprintf (__('Permalink to %s', 'capitularia'), the_title_attribute ('echo=0'))) .
    '" rel="bookmark">'
  );
}

?>

<main id="main">

  <div class="content-col">
    <?php while (have_posts()) : the_post(); ?>

      <article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
        <div class="page-header">
          <h2><?php print_link (); the_title (); echo ('</a>'); ?></h2>
        </div>

        <div class="entry-summary">
          <?php
if (has_post_thumbnail ()) {
  print_link ();
  the_post_thumbnail ('featured-slider');
  echo ('</a>');
}
the_excerpt();
?>
        </div>
      </article>

    <?php endwhile; ?>
  </div>

  <div class="sidebar-col">
    <ul>
      <?php
        // This sidebar gets displayed on all posts.
        dynamic_sidebar ('Post-Sidebar');
        // This sidebar gets displayed on all posts and pages.
        dynamic_sidebar ('Sidebar');
      ?>
    </ul>
  </div>

</main>

<?php get_footer(); ?>

				<?php /*
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
				*/ ?>

<?php get_footer(); ?>