<?php

/**
 * Template Name: Page Without Sidebar
 *
 * Capitularia Theme page_no-sidebar.php file
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

get_header ();

get_main_start ('page-php');

if (have_posts ()) {
    the_post ();

    echo ("  <div class='content-col no-sidebar'>\n");

    $id = get_the_ID ();

    echo ("<article id='post-$id' class='page'>\n");
    echo ("  <header class='article-header cap-page-header'>\n");
    echo ('    <h2>' . get_the_title () . "</h2>\n");
    echo ("  </header>\n");

    echo ("  <div class='page'>\n");
    the_content ();
    echo ("  </div>\n");
    echo ("</article>\n");

    echo ("  </div>\n");
}

get_main_end ();

get_footer ();
