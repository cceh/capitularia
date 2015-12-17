<?php

/**
 * Capitularia Theme functions.php file
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/*
 * Load the translation files.
 *
 * Translation files are *.mo files in the themes/Capitularia/languages/
 * directory.
 */

load_theme_textdomain ('capitularia', get_template_directory () . '/languages/');

/*
 * Some utility functions
 */

function cap_the_slug () {
    echo (basename (get_permalink ()));
}

function cap_get_slug_root ($page) {
    // get the first path component of the slug
    $path = parse_url (get_page_uri ($page), PHP_URL_PATH);
    $a = explode ('/', $path);
    if ($a) {
        return $a[0];
    }
    return '';
}

function cap_attribute ($name, $value) {
    // Echoes: name="value"
    echo ($name . '="' . esc_attr ($value) . '" ');
}

function cap_theme_image ($img) {
    // Echoes image url pointing to the theme images directory
    echo ('src="' . get_bloginfo ('template_directory') . "/img/$img\"");
}

function get_id_by_slug ($page_slug) {
    $page = get_page_by_path ($page_slug);
    return $page ? $page->ID : null;
}

function get_permalink_a () {
    return (
        '<a href="' .
        get_the_permalink () .
        '" title="' .
        esc_attr (sprintf (__('Permalink to %s', 'capitularia'), the_title_attribute ('echo=0'))) .
        '" rel="bookmark">'
    );
}

/**
 * Register jquery and jquery-ui scripts and CSS
 *
 * Quandary: Wordpress (as of 4.3) comes with a version of jquery and jquery-ui
 * but lacks the jquery-ui css styles.  If we provide just our own jquery-ui css
 * styles, we may get out of sync with the jquery-ui javascript provided by
 * Wordpress.  But if we provide the whole jquery-ui of our own we may get out
 * of sync with Wordpress' assumptions of the actual jquery-ui version.
 *
 * For now we provide our own jquery / jquery-ui.
 */

function cap_register_jquery () {
    wp_register_script (
        'cap-jquery',
        get_template_directory_uri () . '/bower_components/jquery/dist/jquery.js'
    );
    wp_register_script (
        'cap-jquery-ui',
        get_template_directory_uri () . '/bower_components/jquery-ui/jquery-ui.js',
        array ('cap-jquery')
    );
    wp_register_script (
        'cap-jquery-sticky',
        get_template_directory_uri () . '/bower_components/jquery-sticky/jquery.sticky.js',
        array ('cap-jquery-ui')
    );
    wp_register_style (
        'cap-jquery-ui-css',
        get_template_directory_uri () . '/bower_components/jquery-ui/themes/cupertino/jquery-ui.css',
        array ()
    );
}

/**
 * Enqueue scripts and CSS
 *
 * Add JS and CSS the wordpress way.
 */

function cap_enqueue_scripts () {
    cap_register_jquery ();

    wp_enqueue_style (
        'cap-reset',
        get_template_directory_uri () . '/css/reset.css',
        array ()
    );

    $styles = array ();
    $styles['cap-webfonts']    = '/webfonts/webfonts.css';
    $styles['cap-fonts']       = '/css/fonts.css';
    $styles['cap-content']     = '/css/content.css';
    $styles['cap-navigation']  = '/css/navigation.css';
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
    $scripts['cap-piwik']       = '/js/piwik-wrapper.js';
    $scripts['cap-html5shiv']   = '/bower_components/html5shiv/dist/html5shiv.js';

    foreach ($scripts as $key => $file) {
        wp_enqueue_script (
            $key,
            get_template_directory_uri () . $file,
            array ()
        );
    };

    // make html5shiv IE-conditional
    global $wp_scripts;
    $wp_scripts->add_data ('cap-html5shiv', 'conditional', 'lt IE 9');

    wp_enqueue_style (
        'cap-jquery-ui-custom-css',
        get_template_directory_uri () . '/css/jquery-ui-custom.css',
        array ('cap-jquery-ui-css')
    );
    wp_enqueue_script (
        'cap-custom-js',
        get_template_directory_uri () . '/js/custom.js',
        array ('cap-jquery', 'cap-jquery-ui', 'cap-jquery-sticky')
    );
}

function cap_admin_enqueue_scripts () {
    // NOTE: Wordpress' own jquery-ui does not include jquery-ui.css.
    cap_register_jquery ();
    wp_enqueue_script ('cap-jquery-ui');
}

add_action ('wp_enqueue_scripts',    'cceh\capitularia\theme\cap_enqueue_scripts');
add_action ('admin_enqueue_scripts', 'cceh\capitularia\theme\cap_admin_enqueue_scripts');


/**
 * Customize <head> <title>
 *
 * Customize the title displayed in the browser window caption and used if you
 * bookmark the page.
 *
 * if root: "Capitularia | Edition der fränkischen Herrschererlasse"
 * else:    "[Name of page] | Capitularia"
 *
 * @param string $title  Default title text for current view.
 * @param string $sep    Optional separator.
 *
 * @return string  The customized title.
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
    }
    $title .= $blog_name;

    // Add a page number if necessary:
    if (($paged >= 2 || $page >= 2) && ! is_404 ()) {
        $title .= " $sep " . sprintf (__ ('Page %s', 'capitularia'), max ($paged, $page));
    }

    return $title;
}

add_filter ('wp_title', 'cceh\capitularia\theme\cap_wp_title', 10, 2);


/**
 * Add excerpt support to pages.
 */

function cap_add_excerpts_to_pages () {
    add_post_type_support ('page', 'excerpt');
}

add_action ('init', 'cceh\capitularia\theme\cap_add_excerpts_to_pages');


/**
 * Add <body> classes depending on which website section we are in
 *
 * Eg.: adds class="cap-slug-mss" in the /mss/ section of the site.
 */

function cap_on_body_class ($classes) {
    if (is_page ()) {
        $classes[] = esc_attr ('cap-slug-' . cap_get_slug_root (get_the_ID ()));
    }
    return $classes;
}

add_filter ('body_class', 'cceh\capitularia\theme\cap_on_body_class');


/**
 * Register our 2 horizontal navigation menus
 */

function cap_register_nav_menus () {
    register_nav_menus (
        array (
            'navtop'    => __('Top horizontal navigation bar', 'capitularia'),
            'navbottom' => __('Bottom horizontal navigation bar', 'capitularia')
        )
    );
}

add_action ('init', 'cceh\capitularia\theme\cap_register_nav_menus');


/*
 * Register sidebars
 */

$sidebars = array ();
$sidebars[] = array ('frontpage-image',     'Frontpage Image',
                     'The big splash image on the front page. Takes one Capitularia Logo Widget.');
$sidebars[] = array ('frontpage-teaser-1',  'Frontpage Teaser Bar 1',
                     'The top teaser bar on the front page. Normally takes 3 Capitularia Text Widgets.');
$sidebars[] = array ('frontpage-teaser-2',  'Frontpage Teaser Bar 2',
                     'The bottom teaser bar on the front page. Normally takes 2 Capitularia Image Widgets.');
$sidebars[] = array ('logobar',             'Logo Bar',
                     'The logo bar in the footer of every page. Takes one or more Capitularia Logo Widgets.');

foreach ($sidebars as $a) {
    register_sidebar (
        array (
            'id' => $a[0],
            'name' => $a[1],
            'description' => $a[2],
        )
    );
};

$sidebars = array ();
$sidebars[] = array ('post-sidebar',   'Post Sidebar',
                     'The sidebar on posts.');
$sidebars[] = array ('page-sidebar',   'Page Sidebar',
                     'The sidebar on pages. Output below the more specialized page sidebars.');
$sidebars[] = array ('sidebar',        'Post and Page Sidebar',
                     'The sidebar on posts and pages. Output below the other sidebars.');

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
$sidebars[] = array ('search',  'Search Page Sidebar',
                     'The sidebar on the search page');

foreach ($sidebars as $a) {
    register_sidebar (
        array (
            'id' => $a[0],
            'name' => $a[1],
            'description' => $a[2],
        )
    );
};


/**
 * Register a custom taxonony for sidebar selection
 */

function cap_create_page_taxonomy () {
    register_taxonomy (
        'cap-sidebar',
        'page',
        array (
            'label' => __('Capitularia Sidebar', 'capitularia'),
            'public' => false,
            'show_ui' => true,
            'rewrite' => false,
            'hierarchical' => false,
        )
    );
    register_taxonomy_for_object_type ('cap-sidebar', 'page');
}

add_action ('init', 'cceh\capitularia\theme\cap_create_page_taxonomy');


/**
 * Add private/draft/future/pending pages to page parent dropdown.
 */

function cap_on_dropdown_pages_args ($dropdown_args, $post = null) {
    $dropdown_args['post_status'] = array ('publish', 'draft', 'pending', 'future', 'private');
    return $dropdown_args;
}

add_filter ('page_attributes_dropdown_pages_args', 'cceh\capitularia\theme\cap_on_dropdown_pages_args');
add_filter ('quick_edit_dropdown_pages_args',      'cceh\capitularia\theme\cap_on_dropdown_pages_args');


/*
 * Shortcodes
 */

function on_cap_shortcode_logged_in ($atts, $content) {
    if (is_user_logged_in ()) {
        return do_shortcode ($content);
    }
    return '';
}

function on_cap_shortcode_logged_out ($atts, $content) {
    if (!is_user_logged_in ()) {
        return do_shortcode ($content);
    }
    return '';
}

add_shortcode ('logged_in',  'cceh\capitularia\theme\on_cap_shortcode_logged_in');
add_shortcode ('logged_out', 'cceh\capitularia\theme\on_cap_shortcode_logged_out');

/*
 * Widgets
 */

require 'widgets/cap-widgets.php';
