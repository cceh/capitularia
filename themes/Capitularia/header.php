<?php

/**
 * The HTML header.
 *
 * This is the HTML header that is output on every page.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

use cceh\capitularia\lib;

?><!DOCTYPE html>

<html <?php language_attributes (); ?>>
  <head>
    <meta charset="<?php bloginfo ('charset'); ?>" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

    <link rel="pingback" href="<?php bloginfo ('pingback_url'); ?>" />

    <title><?php wp_title ('|', true, 'right'); ?></title>

    <script type="text/javascript">
        var _paq = window._paq || [];
        _paq.push (['trackPageView']);
        _paq.push (['enableLinkTracking']);

        (function () {
            var u = '//webstats.cceh.uni-koeln.de/';
            _paq.push (['setTrackerUrl', u + 'matomo.php']);
            _paq.push (['setSiteId', 14]);

            var d = document;
            var g = d.createElement ('script');
            var s = d.getElementsByTagName ('script')[0];
            g.type = 'text/javascript';
            g.async = true;
            g.defer = true;
            g.src = u + 'matomo.js';
            s.parentNode.insertBefore (g, s);
        } ());
    </script>

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
    <div class="container"> <!-- bootstrap container -->
      <div id="top"></div>
      <header id="header">
        <nav id="top-nav" class="top-nav horiz-nav">
            <?php wp_nav_menu (array ('theme_location' => 'navtop')); ?>
        </nav>
      </header>

      <header id="header2">
        <div class="cap-left-col">
          <h1>
            <a href="/" class="homelink"><img
                <?php echo_attribute ('src', lib\get_image_uri ('logo-capitularia.png'));
                      echo_attribute ('alt', get_bloginfo ('name') . ' - ' . get_bloginfo ('description')); ?>
            /></a>
          </h1>
        </div>

        <div class="cap-right-col">
          <nav class="search-nav">
            <form id="searchform" class="searchform" action="/" method="get">
              <table>
                <tr>
                  <td>
                    <input id="searchinput" class="sword" type="text" name="s"
                        <?php
                            echo_attribute ('value', $_GET['s']);
                            echo_attribute ('placeholder', __ ('Search', 'capitularia')); ?>
                        />
                  </td>
                  <td class="submit-cell">
                    <button id="searchsubmit" class="submit" type="submit" name="submit"></button>
                  </td>
                </tr>
              </table>
            </form>
          </nav>
        </div>
      </header>

      <header id="header3">
        <nav id="bottom-nav" class="bottom-nav horiz-nav">
            <?php wp_nav_menu (array ('theme_location' => 'navbottom')); ?>
        </nav>
      </header>
