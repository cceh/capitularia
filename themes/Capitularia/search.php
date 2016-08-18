<?php

/**
 * The template for displaying Search Results pages.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

get_header ();

// $args['nopaging'] = true;
// $the_query = new \WP_Query ($args);

$the_query = $wp_query;

echo ("<main id='main' class='search-php'>\n");
echo ("<div class='content-col'>\n");

$your_search = apply_filters ('cap_meta_search_your_search', '');
$n_results = $the_query->found_posts;

if ($n_results) {
    $your_search = sprintf (
        _n (
            'Your search for: %1$s gave one result.',
            'Your search for: %1$s gave %2$d results.',
            $n_results,
            'capitularia'
        ),
        $your_search,
        $n_results
    );
} else {
    $your_search = sprintf (
        __ (
            'Your search for %1$s gave no results.',
            'capitularia'
        ),
        $your_search
    );
}


$page_msg = __ ('Page:', 'capitularia');
$pagination = paginate_links (
    array (
        'current' => max (1, get_query_var ('paged')),
        'total' => $the_query->max_num_pages,
        'before_page_number' => "<span class='screen-reader-text'>$page_msg </span>"
    )
);

echo (
    "<header class='search-header page-header'>\n  <h2>" .
    __ ('Search Results', 'capitularia') . "</h2>\n" .
    "  <div class='search-your-search'>$your_search</div>\n" .
    "  <div class='search-pagination-nav search-pagination-nav-top'>$pagination</div>\n" .
    "</header>\n"
);

if ($the_query->have_posts ()) {
    echo ("<div class='search-results'>\n");
    while ($the_query->have_posts ()) {
        $the_query->the_post ();
        $id = get_the_ID ();

        echo ("<article id='post-$id' class='search-results-excerpt'>\n");
        echo ("  <header class='article-header excerpt-header search-excerpt-header'>\n");
        echo ('    <h2><a href="' . get_the_permalink () .'">' . get_the_title () . "</a></h2>\n");
        echo ("  </header>\n");
        echo ("  <div class='excerpt'>\n");
        echo (get_the_excerpt ());
        echo ("  </div>\n");
        echo ("</article>\n");
    }
    echo ("</div>\n");

    echo ("<footer class='search-footer'>\n");
    echo ("<div class='search-pagination-nav search-pagination-nav-bottom'>\n$pagination\n</div>\n");
    echo ("</footer>\n");
}
echo ("</div>\n");

echo ("<div class='sidebar-col'>\n<ul>\n");
dynamic_sidebar ('search');
echo ("</ul>\n</div>\n");

echo ("</main>\n");

get_footer ();
