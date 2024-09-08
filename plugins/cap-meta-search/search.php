<?php

/**
 * The template for displaying Search Results pages.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

use cceh\capitularia\theme as theme;

get_header ();

theme\get_main_start ('search-php');

/*
 * Add the 'search' sidebar.
 */

theme\get_sidebar_start ();
dynamic_sidebar ('search');
theme\get_sidebar_end ();

/*
 * Page Content
 */

theme\get_content_start ();

echo "<header class='search-header cap-page-header'>\n  <h2>" .
    __ ('Search Results', 'capitularia') . "</h2>\n";

echo '<div id="cap-meta-search-app"></div>';

echo "</header>\n";

enqueue_scripts ();

theme\get_content_end ();

theme\get_main_end ();

get_footer ();
