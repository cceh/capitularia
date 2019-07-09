<?php

/**
 * Template Name: Blank Page (only header and footer)
 *
 * Capitularia Theme page_blank.php file
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

get_header ();

get_main_start ('page-php');

if (have_posts ()) {
    the_post ();

    $id = get_the_ID ();

    echo ("<article id='post-$id' class='page page-blank'>\n");
    echo ("  <header class='article-header cap-page-header'>\n");
    echo ('    <h2>' . get_the_title () . "</h2>\n");
    echo ("  </header>\n");

    echo ("  <div class='page'>\n");
    the_content ();
    echo ("  </div>\n");
    echo ("</article>\n");
}

get_main_end ();

get_footer ();
