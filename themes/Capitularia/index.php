<?php get_header(); ?>

<main id="main">

  <div class="content-col">
    <?php while (have_posts ()) : the_post (); ?>

      <div class="page-header">
        <h2><?php the_title (); ?></h2>
      </div>

      <div class="entry">
        <?php the_content (); ?>
      </div>

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
