<?php

/**
 * The template for displaying Search Results pages.
 *
 * @package Capitularia
 */

get_header ();

echo ("<main id='main'>\n");
echo ("<div class='content-col'>\n");

echo ("<header class='article-header page-header'>\n<h2>" . __('Search Results', 'capitularia') . "</h2>\n</header>\n");

$your_search = apply_filters ('cap_meta_search_your_search', '');
$n_results = $wp_query->post_count;

if ($n_results) {
    $your_search = sprintf (
        _n (
            'Your search for: %1$s gave one result.',
            'Your search for: %1$s gave %2$d results.',
            $n_results,
            'capitularia'
        ), $your_search, $n_results
    );
} else {
    $your_search = sprintf (
        __(
            'Your search for %1$s gave no results.',
            'capitularia'
        ), $your_search
    );
}

echo ("<div class='search-pager'>$your_search</div>\n");

if (have_posts ()) {
    echo ("<div class='search-results'>\n");

    while (have_posts ()) {
        the_post ();

        echo ("<div class='search-results-excerpt'>\n");
        echo ('<h2><a href="' . get_the_permalink () .'">' . get_the_title () . "</a></h2>\n");
        echo (get_the_excerpt ());
        echo ("</div>\n");

    }
    echo ("</div>\n");
}

echo ("</div>\n");

echo ("<div class='sidebar-col'>\n<ul>\n");
dynamic_sidebar ('search');
echo ("</ul>\n</div>\n");

echo ("</main>\n");

get_footer ();
