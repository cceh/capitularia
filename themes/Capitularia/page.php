<?php

/**
 * Capitularia Theme page.php file
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

get_header ();

get_main_start ('page-php');

// We need the_content for the sidebar menu.
if (have_posts ()) {
    the_post ();

    get_sidebar_start ();

    // Code to choose the sidebar depending on page slug or taxonomy.

    $cap_templates = array ();
    $cap_templates[] = get_slug_root ($post->ID);

    // You can override the default selection by slug if you assign terms in the
    // cap-sidebar taxonomy.  These are the sidebars you can choose from.  (Only one
    // of each gets displayed).
    $cap_sidebars = array ('capit', 'mss', 'resources', 'project', 'internal', 'transcription', 'capitular');

    $terms = get_the_terms ($post->ID, 'cap-sidebar');
    if ($terms && !is_wp_error ($terms)) {
        $cap_templates = array ();
        foreach ($terms as $term) {
            if (in_array ($term->name, $cap_sidebars)) {
                $cap_templates[] = $term->name;
            }
        }
    }

    $cap_templates = array_unique ($cap_templates);

    // Display the chosen sidebars.
    foreach ($cap_templates as $template) {
        dynamic_sidebar ($template);
    }

    // This sidebar gets displayed on all pages.
    dynamic_sidebar ('Page-Sidebar');
    // This sidebar gets displayed on all posts and pages.
    dynamic_sidebar ('Sidebar');

    get_sidebar_end ();

    get_content_start ();

    $id = get_the_ID ();

    echo ("<article id='post-$id' class='page'>\n");
    echo ("  <header class='article-header cap-page-header'>\n");
    echo ('    <h2>' . get_the_title () . "</h2>\n");
    echo ("  </header>\n");

    echo ("  <div class='page'>\n");
    the_content ();
    echo ("  </div>\n");
    echo ("</article>\n");
}

get_content_end ();

get_main_end ();

get_footer ();
