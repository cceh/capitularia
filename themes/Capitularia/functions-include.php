<?php

/**
 * Capitularia Theme functions-include.php file
 *
 * This file only declares symbols (classes, functions, constants) in accordance
 * with PSR-2.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * Get the first path component of the slug.
 *
 * If a page has a slug of: "top/sub/current" this function returns "top".
 *
 * @param integer $page_id Wordpress Page ID.
 *
 * @return string The slug root.
 */

function get_slug_root ($page_id)
{
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
 * @param string $name  The name of the attribute.
 * @param string $value The value of the attribute.
 *
 * @return void
 */

function echo_attribute ($name, $value)
{
    // Echoes: name="value"
    $value = esc_attr ($value);
    echo (" $name=\"$value\"");
}

/**
 * Echo a src="img" pair.
 *
 * The src will be pointing to the theme images directory.
 *
 * @param string $img The image filename.
 *
 * @return void
 */

function echo_theme_image ($img)
{
    echo ('src="' . get_bloginfo ('template_directory') . "/img/$img\"");
}

/**
 * Returns an opening <a> containing a permalink to the current page.
 *
 * It is the responsibilty of the caller to close the <a> tag.
 *
 * @return string An opening <a> tag.
 */

function get_permalink_a ()
{
    return (
        '<a href="' .
        get_the_permalink () .
        '" title="' .
        esc_attr (sprintf (__ ('Permalink to %s', 'capitularia'), the_title_attribute ('echo=0'))) .
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
 * @return void
 */

function register_jquery ()
{
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
 * @return void
 */

function on_enqueue_scripts ()
{
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
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    $styles = array ();
    $styles['cap-admin']       = '/css/admin.css';

    foreach ($styles as $key => $file) {
        wp_enqueue_style (
            $key,
            get_template_directory_uri () . $file,
            array () // no deps for now
        );
    };

    // NOTE: Wordpress' own jquery-ui does not include jquery-ui.css.
    register_jquery ();
    wp_enqueue_script ('cap-jquery-ui');
}

/**
 * Customize <head> <title>
 *
 * Customize the title displayed in the browser window caption and used if you
 * bookmark the page.
 *
 * if root: "Capitularia | Edition der fränkischen Herrschererlasse"
 * else:    "[Name of page] | Capitularia"
 *
 * @param string $title Default title text for current view.
 * @param string $sep   Optional separator.
 *
 * @return string  The customized title.
 */

function on_wp_title ($title, $sep)
{
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

/**
 * Add a <body> class.
 *
 * Add a class to the HTML <body> tag depending on which section of the website
 * we are in.  Eg.: adds class="cap-slug-mss" in the /mss/ section of the site.
 *
 * @param array $classes Old classes added by Wordpress or other plugins.
 *
 * @return array New classes
 */

function on_body_class ($classes)
{
    if (is_page ()) {
        $classes[] = esc_attr ('cap-slug-' . get_slug_root (get_the_ID ()));
    }
    return $classes;
}

/**
 * Initialize the plugin.
 *
 * @return void
 */

function on_init ()
{
    /**
     * Add excerpt support to pages.
     *
     * Most of our site is pages and not posts, so we need excerpts there.  An
     * excerpt is a quick summary that may be displayed in places where the full
     * content is not appropriate.
     */

    add_post_type_support ('page', 'excerpt');

    /**
     * Register our 2 horizontal navigation menus.
     *
     * The first one is above the logo, the second one below the logo.
     */

    register_nav_menus (
        array (
            'navtop'    => __ ('Top horizontal navigation bar', 'capitularia'),
            'navbottom' => __ ('Bottom horizontal navigation bar', 'capitularia')
        )
    );

    /**
     * Register a custom taxonomy for sidebar selection.
     *
     * Using this taxonomy you can add arbitrary sidebars to arbitrary pages.
     */

    register_taxonomy (
        'cap-sidebar',
        'page',
        array (
            'label' => __ ('Capitularia Sidebar', 'capitularia'),
            'public' => false,
            'show_ui' => true,
            'rewrite' => false,
            'hierarchical' => false,
        )
    );
    register_taxonomy_for_object_type ('cap-sidebar', 'page');
}


/**
 * Add private/draft/future/pending pages to page parent dropdown.
 *
 * Only public pages are eligible for parenting in vanilla Wordpress.  We want
 * other pages also.
 *
 * @param array $dropdown_args The previous args.
 * @param int   $dummy_post    (unused) The post ID .
 *
 * @return array The new args.
 */

function on_dropdown_pages_args ($dropdown_args, $dummy_post = null)
{
    $dropdown_args['post_status'] = array ('publish', 'draft', 'pending', 'future', 'private');
    return $dropdown_args;
}


/**
 * Translate the archive widget month names
 *
 * @param string $month_year Link containing untranslated MMMMMMM YYYY
 *
 * @return string Link containing translated MMMMMMM YYYY
 */

function translate_month_year ($month_year)
{
    return preg_replace_callback (
        '/^(.*?)(\w+)( \d{4}.*)$/',
        function ($matches) {
            return $matches[1] . __ ($matches[2], 'capitularia') . $matches[3];
        },
        $month_year
    );
}

/*
 * Redirect user to current page after login
 */

function on_login_redirect ($redirect_to, $requested_redirect_to, $user)
{
    return $requested_redirect_to;
}
