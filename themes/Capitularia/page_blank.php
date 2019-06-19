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
    the_content ();
}

get_main_end ();

get_footer ();
