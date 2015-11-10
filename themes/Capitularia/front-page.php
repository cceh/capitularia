<?php get_header (); ?>

<main id="main" class="home">

  <div class="header-block ui-helper-clearfix">
    <h1><?php bloginfo ('description', 'display'); ?></h1>
    <img <?php cap_theme_image ('img-home-4.png'); ?> title="Modena BC O.I.2, fol. 154v/155r. ©Archivio Storico Diocesano, Modena" />
  </div>

  <div class="teaser-bar teaser-bar-1 ui-helper-clearfix">
    <ul>
      <?php dynamic_sidebar ('frontpage-teaser-1') ?>
    </ul>
  </div>

  <div class="teaser-bar teaser-bar-2 ui-helper-clearfix">
    <ul>
      <?php dynamic_sidebar ('frontpage-teaser-2') ?>
    </ul>
  </div>

</main>

<?php get_footer (); ?>
