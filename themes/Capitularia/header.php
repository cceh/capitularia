<?php

/**
 * The HTML header.
 *
 * This is the HTML header that is output on every page.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

?><!DOCTYPE html>

<html <?php language_attributes (); ?>>
  <head>
    <meta charset="<?php bloginfo ('charset'); ?>" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

    <link rel="pingback" href="<?php bloginfo ('pingback_url'); ?>" />

    <title><?php wp_title ('|', true, 'right'); ?></title>

    <?php
        /*
         * Always have wp_head() just before the closing </head>
         * tag of your theme, or you will break many plugins, which
         * generally use this hook to add elements to <head> such
         * as styles, scripts, and meta tags.
         */
        wp_head ();
        ?>
  </head>

  <body <?php body_class (); ?>>
    <header id="header">

      <div id="top"></div>

      <nav id="top-nav" class="top-nav horiz-nav ui-helper-clearfix">
        <?php wp_nav_menu (array ('theme_location' => 'navtop')); ?>
      </nav>

      <div id="bottom-header-wrapper">

        <nav class="search-nav">
          <form id="searchform" class="searchform" action="/" method="get">
            <input id="searchinput" class="sword" type="text" name="s"
                <?php echo_attribute ('placeholder', __ ('Search', 'capitularia')); ?> />
            <button id="searchsubmit" class="submit" type="submit" name="submit"></button>
          </form>
        </nav>

        <h1>
          <a href="/" class="homelink"><img
            <?php echo_theme_image ('Capitularia_Logo.png');
                  echo_attribute ('alt', get_bloginfo ('name') . ' - ' . get_bloginfo ('description')); ?>
          /></a>
        </h1>

        <nav id="bottom-nav" class="bottom-nav horiz-nav ui-helper-clearfix">
            <?php wp_nav_menu (array ('theme_location' => 'navbottom')); ?>
        </nav>

      </div>

    </header>
