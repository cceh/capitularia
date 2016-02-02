<?php

/**
 * Template for single posts or multiple excerpts.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

get_header ();

echo ("<main id='main' class='index-php'>\n");
echo ("<div class='content-col'>\n");

while (have_posts ()) {
    the_post ();
    $id = get_the_ID ();
    $class = is_single () ? 'post' : 'excerpt';
    $classes = implode (' ', get_post_class ($class));
    $title = get_the_title ($id);
    if (!is_single ()) {
        $title = get_permalink_a () . $title . '</a>';
    }
    echo ("<article id='post-$id' class='$classes'>\n");
    echo ("  <header class='article-header $class-header'>\n");
    echo ("    <h2>$title</h2>\n");
    echo ("  </header>\n");
    echo ("  <div class='$class'>\n");
    if (is_single ()) {
        the_content ();
    } else {
        if (has_post_thumbnail ()) {
            echo (get_permalink_a ());
            the_post_thumbnail ('featured-slider');
            echo ('</a>');
        }
        the_excerpt ();
    }
    echo ("  </div>\n");
    echo ("</article>\n");
}
echo ("</div>\n");

echo ("<div class='sidebar-col'>\n");
echo ("<ul>\n");

// This sidebar gets displayed on all posts.
dynamic_sidebar ('Post-Sidebar');
// This sidebar gets displayed on all posts and pages.
dynamic_sidebar ('Sidebar');

echo ("</ul>\n");
echo ("</div>\n");

echo ("</main>\n");

get_footer ();
