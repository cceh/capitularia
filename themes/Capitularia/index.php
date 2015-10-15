<?php get_header(); ?>

<main id="main">
  <?php while (have_posts()) : the_post(); ?>

  <div class="page-header">
    <h2><?php the_title(); ?></h2>
  </div>

  <div class="entry">
    <?php the_content(); ?>
  </div>

  <?php endwhile; ?>
</main>

<?php get_footer(); ?>
