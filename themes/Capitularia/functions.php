<?php

/**
 * Capitularia Theme functions.php file
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/** The URL to the Capitularia image server. */
const IMAGE_SERVER_URL = 'http://images.cceh.uni-koeln.de/capitularia/';

/*
 * Load the translation files.
 *
 * Translation files are *.mo files in the themes/Capitularia/languages/
 * directory.
 */

load_theme_textdomain ('capitularia', get_template_directory () . '/languages/');

/**
 * Get the first path component of the slug.
 *
 * If a page has a slug of: "top/sub/current" this function returns "top".
 *
 * @param integer $page_id Wordpress Page ID.
 *
 * @return string The slug root.
 */

function get_slug_root ($page_id) {
    $path = parse_url (get_page_uri ($page_id), PHP_URL_PATH);
    $a = explode ('/', $path);
    if ($a) {
        return $a[0];
    }
    return '';
}

/**
 * Echo a name="value" pair.
 *
 * @param string $name
 * @param string $value
 *
 * @return nothing
 */

function echo_attribute ($name, $value) {
    // Echoes: name="value"
    echo ($name . '="' . esc_attr ($value) . '" ');
}

/**
 * Echo a src="img" pair.
 *
 * The src will be pointing to the theme images directory.
 *
 * @param string $img  The image filename.
 *
 * @return nothing
 */

function echo_theme_image ($img) {
    echo ('src="' . get_bloginfo ('template_directory') . "/img/$img\"");
}

/**
 * Returns an opening <a> containing a permalink to the current page.
 *
 * It is the responsibilty of the caller to close the <a> tag.
 *
 * @return string An opening <a> tag.
 */

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
 *
 * @return nothing
 */

function register_jquery () {
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
 *
 * @return nothing
 */

function on_enqueue_scripts () {
    register_jquery ();

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

/**
 * Enqueue admin scripts and CSS
 *
 * @return nothing
 */

function on_admin_enqueue_scripts () {
    // NOTE: Wordpress' own jquery-ui does not include jquery-ui.css.
    register_jquery ();
    wp_enqueue_script ('cap-jquery-ui');
}

add_action ('wp_enqueue_scripts',    'cceh\capitularia\theme\on_enqueue_scripts');
add_action ('admin_enqueue_scripts', 'cceh\capitularia\theme\on_admin_enqueue_scripts');


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

function wp_title ($title, $sep) {
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

add_filter ('wp_title', 'cceh\capitularia\theme\wp_title', 10, 2);


/**
 * Add excerpt support to pages.
 */

function add_excerpts_to_pages () {
    add_post_type_support ('page', 'excerpt');
}

add_action ('init', 'cceh\capitularia\theme\add_excerpts_to_pages');


/**
 * Add <body> classes depending on which website section we are in
 *
 * Eg.: adds class="cap-slug-mss" in the /mss/ section of the site.
 */

function on_body_class ($classes) {
    if (is_page ()) {
        $classes[] = esc_attr ('cap-slug-' . get_slug_root (get_the_ID ()));
    }
    return $classes;
}

add_filter ('body_class', 'cceh\capitularia\theme\on_body_class');


/**
 * Register our 2 horizontal navigation menus
 */

function register_nav_menus () {
    \register_nav_menus (
        array (
            'navtop'    => __('Top horizontal navigation bar', 'capitularia'),
            'navbottom' => __('Bottom horizontal navigation bar', 'capitularia')
        )
    );
}

add_action ('init', 'cceh\capitularia\theme\register_nav_menus');


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

function create_page_taxonomy () {
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

add_action ('init', 'cceh\capitularia\theme\create_page_taxonomy');


/**
 * Add private/draft/future/pending pages to page parent dropdown.
 */

function on_dropdown_pages_args ($dropdown_args, $post = null) {
    $dropdown_args['post_status'] = array ('publish', 'draft', 'pending', 'future', 'private');
    return $dropdown_args;
}

add_filter ('page_attributes_dropdown_pages_args', 'cceh\capitularia\theme\on_dropdown_pages_args');
add_filter ('quick_edit_dropdown_pages_args',      'cceh\capitularia\theme\on_dropdown_pages_args');


/*
 * Shortcodes
 */

/**
 * Add the logged_in shortcode.
 *
 * This shortcode outputs its content only to logged-in users.
 *
 * @param array  atts
 * @param string content
 *
 * @return string The new content
 */

function on_shortcode_logged_in ($atts, $content) {
    if (is_user_logged_in ()) {
        return do_shortcode ($content);
    }
    return '';
}

/**
 * Add the logged_out shortcode.
 *
 * This shortcode outputs its content only to logged-out users.
 *
 * @param array  atts
 * @param string content
 *
 * @return string The new content
 */

function on_shortcode_logged_out ($atts, $content) {
    if (!is_user_logged_in ()) {
        return do_shortcode ($content);
    }
    return '';
}

/**
 * Add the cap_image_server shortcode.
 *
 * This shortcode wraps the content in a link to the image server if the user is
 * logged in.
 *
 * @param array  atts
 * @param string content
 *
 * @return string The new content
 */

function on_shortcode_cap_image_server ($atts, $content) {
    if (is_user_logged_in () && isset ($atts['id']) && isset ($atts['n'])) {
        // build url out of attributes
        $id = $atts['id'];
        $n = $atts['n'];

        $matches = array ();
        if (preg_match ('/(\d+)(.+)/', $n, $matches)) {
            $num = str_pad ($matches[1], 4, '0', STR_PAD_LEFT);
            $num .= $matches[2];
            return '<a href="' . IMAGE_SERVER_URL . "$id/{$id}_{$num}.jpg\">$content</a>";
        }
    }
    return $content;
}

add_shortcode ('logged_in',        'cceh\capitularia\theme\on_shortcode_logged_in');
add_shortcode ('logged_out',       'cceh\capitularia\theme\on_shortcode_logged_out');
add_shortcode ('cap_image_server', 'cceh\capitularia\theme\on_shortcode_cap_image_server');

/*
 * Widgets
 */

require 'widgets/cap-widgets.php';
