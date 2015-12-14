<?php

/**
 * Capitularia Theme home.php file
 *
 * @package Capitularia
 */

get_header();

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
    <?php while (have_posts ()) : the_post(); ?>

    <article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
      <div class="page-header">
        <h2><?php print_link ();
                  the_title ();
                  echo ('</a>');
            ?></h2>
      </div>

      <div class="entry-summary">
        <?php
        if (has_post_thumbnail ()) {
            print_link ();
            the_post_thumbnail ('featured-slider');
            echo ('</a>');
        }
        the_excerpt ();
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

<?php get_footer ();
