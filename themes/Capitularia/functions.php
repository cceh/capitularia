<?php

define('CAPITULARIA_PARENT_DIR', get_template_directory());
define('CAPITULARIA_JS_DIR', CAPITULARIA_PARENT_DIR . '/js');

define('CAPITULARIA_PARENT_URL', get_template_directory_uri());
define('CAPITULARIA_CSS_URL', CAPITULARIA_PARENT_DIR . '/css');


/**
 * Some utility functions
 *
 */

function cap_the_slug () {
    echo (basename (get_permalink ()));
}

function cap_get_slug_root () {
    // get the first path component of the slug
    $path = parse_url (get_permalink (), PHP_URL_PATH);
    $a = explode ('/', $path);
    if (count ($a) >= 1) {
        return $a[1];
    }
    return '';
}

function cap_theme_image ($img) {
    // Echoes image url pointing to the theme images directory
    echo ('src="' . get_bloginfo ('template_directory') . "/img/$img\"");
}

function get_id_by_slug($page_slug)
{
    $page = get_page_by_path($page_slug);
    return $page ? $page->ID : NULL;
}


/**
 * Enqueue scripts and CSS
 *
 * Adds all our JS and CSS the wordpress way.
 */

function cap_enqueue_scripts () {
    wp_enqueue_style (
        'cap-reset',
        get_template_directory_uri () . "/css/reset.css",
        array ()
    );

    $styles = array ();
    $styles['cap-base']        = '/css/base.css';
    $styles['cap-fonts']       = '/ttf/fonts.css';
    $styles['cap-style']       = '/css/style.css';
    $styles['cap-bg-data-uri'] = '/css/bg_data_uri.css';
    $styles['cap-bg-img-ie7']  = '/css/bg_img.css';
    $styles['cap-navigation']  = '/css/navigation.css';
    $styles['cap-content']     = '/css/content.css';
    $styles['cap-mobile']      = '/css/mobile.css';
    $styles['cap-qtranslate']  = '/css/qtranslate-x.css';

    foreach ($styles as $key => $file) {
        wp_enqueue_style (
            $key,
            get_template_directory_uri () . $file,
            array ('cap-reset')
        );
    };
    wp_enqueue_style ('dashicons');

    $scripts = array ();
    $scripts['cap-html5-ie9']   = '/js/html5.js';
    $scripts['cap-mobile']      = '/js/mobile.js';

    foreach ($scripts as $key => $file) {
        wp_enqueue_script (
            $key,
            get_template_directory_uri () . $file,
            array ()
        );
    };

    // make some stuff IE-conditional
    global $wp_styles, $wp_scripts;
    $wp_styles->add_data ('cap-bg-img-ie7', 'conditional', 'lte IE 7');
    $wp_scripts->add_data ('cap-html5-ie9', 'conditional', 'lt IE 9');

    wp_register_style (
        'jquery-ui-css',
        get_template_directory_uri () . '/js/jquery-ui-1.11.4/jquery-ui.css',
        array ()
    );
    wp_register_style (
        'cap-jquery-ui-custom',
        get_template_directory_uri () . '/css/jquery-ui-custom.css',
        array ('jquery-ui-css')
    );
    wp_enqueue_style ('cap-jquery-ui-custom');

    wp_enqueue_script (
        'jquery-plugin-sticky',
        get_template_directory_uri () . '/js/jquery.sticky.js',
        array ('jquery')
    );
    wp_enqueue_script (
        'cap-custom-js',
        get_template_directory_uri () . '/js/custom.js',
        array ('jquery', 'jquery-ui-core', 'jquery-ui-accordion')
    );
}

add_action ('wp_enqueue_scripts', 'cap_enqueue_scripts');


/**
 * Customize title
 *
 * Anpassung nach Muster:
 *
 * if root: "Capitularia | Edition der fränkischen Herrschererlasse"
 * else:    "[Name der Unterseite] | Capitularia"
 *
 *
 * @param string $title Default title text for current view.
 * @param string $sep Optional separator.
 * @return string The filtered title.
 */

function cap_wp_title ($title, $sep) {
    if (is_feed ()) {
        return $title;
    }

    global $page, $paged;

    // Add the blog name
    $blog_name = get_bloginfo ('name', 'display');
    $blog_description = get_bloginfo ('description', 'display');

    if (is_home () || is_front_page ()) {
        return "$blog_name $sep $blog_description";
        // return "Capitularia | Edition der fränkischen Herrschererlasse";
    }
    $title .= $blog_name;

    // Add a page number if necessary:
    if ( ( $paged >= 2 || $page >= 2 ) && ! is_404() ) {
        $title .= " $sep " . sprintf( __( 'Page %s', '_s' ), max( $paged, $page ) );
    }

    return $title;
}

add_filter ('wp_title', 'cap_wp_title', 10, 2);


/**
 * Add excerpt support to pages
 *
 */

function cap_add_excerpts_to_pages () {
    add_post_type_support ('page', 'excerpt');
}

add_action ('init', 'cap_add_excerpts_to_pages');


/**
 * Add <body> classes depending on which website section we are in
 *
 * eg.: adds class="cap-slug-mss" in the /mss/ section of the site.
 */

function cap_on_body_class ($classes) {
    if (is_page ()) {
        $classes[] = esc_attr ('cap-slug-' . cap_get_slug_root ());
    }
    return $classes;
}

add_filter ('body_class', 'cap_on_body_class');


/**
 * Register our 2 horizontal navigation menus
 *
 */

function cap_register_nav_menus () {
    register_nav_menus (
        array (
            'navtop'    => __('Top horizontal navigation bar'),
            'navbottom' => __('Bottom horizontal navigation bar')
        )
    );
}

add_action ('init', 'cap_register_nav_menus');


/**
 * Register sidebars
 *
 */

$sidebars = array ();
$sidebars[] = array ('frontpage-teaser-1',  'Frontpage Teaser Bar 1',
                     'The top teaser bar on the front page.');
$sidebars[] = array ('frontpage-teaser-2',  'Frontpage Teaser Bar 2',
                     'The bottom teaser bar on the front page.');
$sidebars[] = array ('logobar',        'Logo Bar',
                     'The logo bar in the footer of every page.');

foreach ($sidebars as $a) {
    register_sidebar (array (
        'id' => $a[0],
        'name' => $a[1],
        'description' => $a[2],
    ));
};

$sidebars = array ();
$sidebars[] = array ('sidebar',        'Sidebar',
                     'The sidebar on most pages. This starts below the more specialized sidebars.');

$sidebars[] = array ('capit',          'Capitularies Sidebar',
                     'The sidebar on /capit/ pages.');
$sidebars[] = array ('mss',            'Manuscripts Sidebar',
                     'The sidebar on /mss/ pages.');
$sidebars[] = array ('resources',      'Resources Sidebar',
                     'The sidebar on /resources/ pages.');
$sidebars[] = array ('project',        'Project Sidebar',
                     'The sidebar on /project/ pages.');
$sidebars[] = array ('internal',       'Internal Sidebar',
                     'The sidebar on /internal/ pages.');
$sidebars[] = array ('transcription',  'Transcription Sidebar',
                     'The sidebar on transcription pages');

foreach ($sidebars as $a) {
    register_sidebar (array (
        'id' => $a[0],
        'name' => $a[1],
        'description' => $a[2],
    ));
};


/**
 * Register a custom taxonony for sidebar selection
 *
 */

function cap_create_page_taxonomy () {
    register_taxonomy (
        'cap-sidebar',
        'page',
        array (
            'label' => __('Capitularia Sidebar'),
            'public' => false,
            'show_ui' => true,
            'rewrite' => false,
            'hierarchical' => false,
        )
    );
    register_taxonomy_for_object_type ('cap-sidebar', 'page');
}

add_action ('init', 'cap_create_page_taxonomy');


/**
 * Add private/draft/future/pending pages to page parent dropdown.
 */

function cap_on_dropdown_pages_args ($dropdown_args, $post = NULL) {
    $dropdown_args['post_status'] = array ('publish', 'draft', 'pending', 'future', 'private');
    return $dropdown_args;
}

add_filter ('page_attributes_dropdown_pages_args', 'cap_on_dropdown_pages_args');
add_filter ('quick_edit_dropdown_pages_args',      'cap_on_dropdown_pages_args');


/**
 * Widgets
 *
 */

require ('widgets/cap-widgets.php');
require ('widgets/cap-widget-search-box.php');
require ('widgets/cap-widget-transcription-navigation.php');

?>
