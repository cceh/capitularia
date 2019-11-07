<?php

/**
 * The template for displaying Search Results pages.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

get_header ();

get_main_start ('search-php');

/*
 * Build Messages
 */

// retrieve the 'You searched for: X' message
$your_search = apply_filters ('cap_meta_search_your_search', '');

// build the 'how many results' message
$n_results = $wp_query->found_posts;
$your_search = sprintf (
    _n (
        'Your search for: %1$s gave %2$d result.',
        'Your search for: %1$s gave %2$d results.',
        $n_results,
        'capitularia'
    ),
    $your_search,
    $n_results
);

// initialize pagination
$page_msg = __ ('Page:', 'capitularia');
$pagination = paginate_links (
    array (
        'current'            => max (1, get_query_var ('paged')),
        'total'              => $wp_query->max_num_pages,
        'before_page_number' => "<span class='screen-reader-text'>$page_msg </span>",
        'prev_text'          => __ ('« Previous', 'capitularia'),
        'next_text'          => __ ('Next »', 'capitularia'),
    )
);

/*
 * Add the 'search' sidebar.
 */

get_sidebar_start ();
dynamic_sidebar ('search');
get_sidebar_end ();

/*
 * Page Content
 */

get_content_start ();

echo (
    "<header class='search-header cap-page-header'>\n  <h2>" .
    __ ('Search Results', 'capitularia') . "</h2>\n" .
    "  <div class='search-your-search'>$your_search</div>\n"
);
if ($pagination) {
    echo ("  <div class='pagination-nav search-pagination-nav pagination-nav-top'>$pagination</div>\n");
}
echo ("</header>\n");

if (have_posts ()) {
    echo ("<div class='search-results'>\n");
    while (have_posts ()) {
        the_post ();
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
    if ($pagination) {
        echo ("<div class='pagination-nav search-pagination-nav pagination-nav-bottom'>\n$pagination\n</div>\n");
    }
    echo ("</footer>\n");
}

get_content_end ();

get_main_end ();

get_footer ();
