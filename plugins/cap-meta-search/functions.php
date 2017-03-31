<?php
/**
 * Capitularia Meta Search.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

const NONCE_SPECIAL_STRING  = 'cap_meta_search_nonce';
const NONCE_PARAM_NAME      = '_ajax_nonce';
const OPTIONS_PAGE_ID       = 'cap_meta_search_options';
/** Default path to the project directory on AFS. */
const AFS_ROOT              = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';

/**
 * Add current namespace
 *
 * @param string $function_name The class or function name without namespace
 *
 * @return string Name with namespace
 */

function ns ($function_name)
{
    return __NAMESPACE__ . '\\' . $function_name;
}

/**
 * Init the plugin
 *
 * @return void
 */

function init ()
{
    /** @var string The name of the plugin */
    global $plugin_name;
    $plugin_name = __ ('Capitularia Meta Search', 'capitularia');

    add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));
    add_action ('admin_menu',            ns ('on_admin_menu'));
    add_action ('admin_enqueue_scripts', ns ('on_admin_enqueue_scripts'));
    add_action ('widgets_init',          ns ('on_widgets_init'));

    add_filter ('the_content',           ns ('on_the_content'));
    add_filter ('get_the_excerpt',       ns ('on_get_the_excerpt'));
    add_filter ('query_vars',            ns ('on_query_vars'));

    add_action ('cap_xsl_transformed',              ns ('on_cap_xsl_transformed'),              10, 2);
    add_filter ('cap_meta_search_extract_metadata', ns ('on_cap_meta_search_extract_metadata'), 10, 3);
}

/**
 * Sanitize a text filed.
 *
 * @param string $text The text to sanitize.
 *
 * @return The sanitized text.
 */

function sanitize ($text)
{
    return empty ($text) ? '' : strip_tags ($text);
}

/**
 * Register the widget with Wordpress.
 *
 * @return void
 */

function on_widgets_init ()
{
    register_widget (ns ('Widget'));
}

/**
 * Highlight the found strings on the page once the user has chose a search
 * result from the search results page.
 *
 * @param string $content The content to highlight.
 *
 * @return string The highlighted content.
 */

function on_the_content ($content)
{
    $highlighter = new Highlighter ();
    return $highlighter->on_the_content ($content);
}

/**
 * Highlight the found strings in the excerpt on the search results page.
 *
 * @param string $content The content to highlight.
 *
 * @return string The highlighted content.
 */

function on_get_the_excerpt ($content)
{
    $highlighter = new Highlighter ();
    return $highlighter->on_get_the_excerpt ($content);
}

/**
 * Hook to automatically extract metadata every time a TEI file gets
 * transformed.
 *
 * @param int    $post_id  The post id.
 * @param string $xml_path The path of the TEI file.
 *
 * @return array Array of messages.
 */

function on_cap_xsl_transformed ($post_id, $xml_path)
{
    $extractor = new Extractor ();
    return $extractor->extract_meta ($post_id, $xml_path);
}

/**
 * Hook to manually extract metadata from TEI files.
 *
 * @param array  $errors   Array of messages.
 * @param int    $post_id  The post id.
 * @param string $xml_path The path of the TEI file.
 *
 * @return array Augmented array of messages.
 */

function on_cap_meta_search_extract_metadata ($errors, $post_id, $xml_path)
{
    $extractor = new Extractor ();
    return array_merge ($errors, $extractor->extract_meta ($post_id, $xml_path));
}

/**
 * Add our custom HTTP query vars
 *
 * @param array $vars The stock query vars
 *
 * @return array The stock and custom query vars
 */

function on_query_vars ($vars)
{
    $vars[] = 'capit';
    $vars[] = 'place';
    $vars[] = 'notbefore';
    $vars[] = 'notafter';
    return $vars;
}

/**
 * Enqueue front side scripts and styles
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    wp_register_style  ('cap-meta-search-front', plugins_url ('css/front.css', __FILE__));
    wp_enqueue_style   ('cap-meta-search-front');

    wp_register_script (
        'cap-meta-search-front',
        plugins_url ('js/front.js', __FILE__),
        array ('cap-jquery', 'cap-jquery-ui')
    );
    wp_enqueue_script  ('cap-meta-search-front');
    wp_localize_script (
        'cap-meta-search-front',
        'ajax_object',
        array (
            'ajax_nonce' => wp_create_nonce (NONCE_SPECIAL_STRING),
            'ajax_nonce_param_name' => NONCE_PARAM_NAME,
        )
    );
}

/*
 * Incipit administration page stuff
 */

/**
 * Enqueue admin side scripts and styles
 *
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    wp_register_style ('cap-meta-search-admin', plugins_url ('css/admin.css', __FILE__));
    wp_enqueue_style  ('cap-meta-search-admin');
}

/**
 * Add our settings page to the admin menu
 *
 * @return void
 */

function on_admin_menu ()
{
    /** @var Settings_Page|null The settings page */
    global $settings_page;
    $settings_page = new Settings_Page ();
    global $plugin_name;

    // adds a menu entry to the settings menu
    add_options_page (
        $plugin_name . ' Options',
        $plugin_name,
        'manage_options',
        'cap_meta_search_options',
        array ($settings_page, 'display')
    );
}

/**
 * Things to do when an admin activates the plugin
 *
 * @return void
 */

function on_activation ()
{
}

/**
 * Things to do when an admin deactivates the plugin
 *
 * @return void
 */

function on_deactivation ()
{
}

/**
 * Things to do when an admin uninstalls the plugin
 *
 * @return void
 */

function on_uninstall ()
{
}
