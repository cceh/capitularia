<?php
/**
 * Capitularia Page Generator global functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

use cceh\capitularia\lib;

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
 * Get ID of the parent page of a section
 *
 * Returns the ID of the parent page of a section.
 *
 * @param string $section_id The section id
 *
 * @return mixed The parent page ID or false
 */

function cap_get_parent_id ($section_id)
{
    global $config;

    $page = get_page_by_path ($config->get_opt ($section_id, 'slug_path'));
    return $page ? $page->ID : false;
}

/**
 * Get the current status of a page.
 *
 * @param int $page_id The Wordpress page id
 *
 * @return string The current status
 */

function cap_get_status ($page_id)
{
    if ($page_id !== false) {
        return get_post_status ($page_id);
    }
    return 'delete';
}

/**
 * Get the current status of a section's parent page.
 *
 * We need to check this so as not to make public children of private pages.
 *
 * @param string $section_id The section id
 *
 * @return string The current status
 */

function cap_get_section_page_status ($section_id)
{
    $page_id = cap_get_parent_id ($section_id);
    if ($page_id !== false) {
        return get_post_status ($page_id);
    }
    return 'delete';
}

/**
 * Returns a path relative to base
 *
 * @param string $path The path
 * @param string $base The base
 *
 * @return string The path relative to base
 */

function cap_make_path_relative_to ($path, $base)
{
    $base = rtrim ($base, '/') . '/';
    if (strncmp ($path, $base, strlen ($base)) == 0) {
        return substr ($path, strlen ($base));
    }
    return $path;
}

/**
 * Do nothing
 *
 * @param string $s The string to do nothing with
 *
 * @return string The same string
 */

function cap_sanitize_nothing ($s)
{
    return $s;
}

/**
 * Sanitize a caption
 *
 * @param string $caption The caption to sanitize
 *
 * @return string The sanitized caption
 */

function cap_sanitize_caption ($caption)
{
    return sanitize_text_field ($caption);
}

/**
 * Sanitize a path
 *
 * @param string $path The path to sanitize
 *
 * @return string The sanitized path
 */

function cap_sanitize_path ($path)
{
    return rtrim (sanitize_text_field ($path), '/');
}

/**
 * Sanitize a space-separated list of paths
 *
 * @param string $path_list The space-separated list of paths to sanitize
 *
 * @return string The space-separated list of sanitized paths
 */

function cap_sanitize_path_list ($path_list)
{
    $paths = explode (' ', $path_list);
    $result = array ();
    foreach ($paths as $path) {
        $result[] = cap_sanitize_path ($path);
    }
    return implode (' ', $result);
}

/**
 * Sanitize a key
 *
 * @param string $key The key to sanitize
 *
 * @return string The sanitized key
 */

function cap_sanitize_key ($key)
{
    return trim (sanitize_key ($key));
}

/**
 * Sanitize a space-separated list of keys
 *
 * @param string $key_list The space-separated list of keys to sanitize
 *
 * @return string The space-separated list of sanitized keys
 */

function cap_sanitize_key_list ($key_list)
{
    $keys = explode (' ', $key_list);
    $result = array ();
    foreach ($keys as $key) {
        $result[] = cap_sanitize_key ($key);
    }
    return implode (' ', $result);
}

/**
 * Initialize the plugin.
 *
 * @return void
 */

function on_init ()
{
    lib\load_plugin_textdomain (DOMAIN, __FILE__);

    global $config;
    $config = new Config ();
    $config->init ();
}

/**
 * AJAX hook
 *
 * @return void
 */

function on_cap_action_file ()
{
    lib\check_ajax_referrer ();
    if (!current_user_can ('edit_posts')) {
        wp_send_json_error (
            array ('message' => __ ('You have no permission to edit posts.', DOMAIN))
        );
        exit ();
    }
    $dashboard_page = new Dashboard_Page ();
    $dashboard_page->on_cap_action_file ();
}

/**
 * AJAX hook
 *
 * @return void
 */

function on_cap_load_section ()
{
    // we do no user permission checks because we are just reading
    $dashboard_page = new Dashboard_Page ();
    $dashboard_page->on_cap_load_section ();
}

/**
 * Enqueue the public pages scripts and styles
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    lib\enqueue_from_manifest ('cap-page-generator-front.js', ['cap-theme-front.js']);
}

/**
 * Register *cap_page_gen* as valid HTTP GET parameter
 *
 * We use the *cap_page_gen* parameter to call the dashboard from the
 * :guilabel:`Page Generator` button on the user's tool bar on the public pages.
 *
 * @param string[] $vars Already registered parameter names
 *
 * @return string[] Augmented registered parameter names.
 */

function on_query_vars ($vars)
{
    $vars[] = 'cap_page_gen';
    return $vars;
}

/*
 * Administration page stuff
 */

/**
 * Enqueue the admin page scripts and styles
 *
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    lib\enqueue_from_manifest (
        'cap-page-generator-admin.js',
        ['cap-theme-admin.js', 'jquery-ui-tabs', 'jquery-ui-progressbar']
    );
}

/**
 * Add menu entries to the Wordpress admin menu.
 *
 * Adds menu entries for the settings (options) and the dashboard pages to
 * the Wordpress settings and dashboard admin page menus respectively.
 *
 * @return void
 */

function on_admin_menu ()
{
    // adds a menu entry to the settings menu
    add_options_page (
        __ (NAME, DOMAIN) . ' ' . __ ('Settings', DOMAIN),
        __ (NAME, DOMAIN),
        'manage_options',
        OPTIONS,
        array (new Settings_Page (), 'display')
    );

    // adds a menu entry to the dashboard menu
    add_submenu_page (
        'index.php',
        __ (NAME, DOMAIN) . ' ' . __ ('Dashboard', DOMAIN),
        __ (NAME, DOMAIN),
        'edit_pages',
        DASHBOARD,
        array (new Dashboard_Page (), 'display')
    );
}

/**
 * Add a dashboard button to the Wordpress toolbar.
 *
 * @param \WP_Admin_Bar $wp_admin_bar The \WP_Admin_Bar object
 *
 * @return void
 */

function on_admin_bar_menu ($wp_admin_bar)
{
    if (!is_admin () && current_user_can ('edit_pages')) {
        $args = array (
            'id'    => 'cap_page_gen_open',
            'title' => __ ('Page Generator', DOMAIN),
            'href'  => '/wp-admin/index.php?page=' . DASHBOARD,
            'meta'  => array (
                'class' => 'cap-page-gen',
                'title' => __ (NAME, DOMAIN)
            )
        );
        $wp_admin_bar->add_node ($args);
    }
}

/**
 * Add a link to our settings page to the plugins admin dashboard.
 *
 * Adds hack value.
 *
 * @param array $links The old links
 *
 * @return array The augmented links
 */

function on_plugin_action_links ($links)
{
    array_push (
        $links,
        '<a href="options-general.php?page=' . OPTIONS . '">' . __ ('Settings', DOMAIN) . '</a>',
        '<a href="index.php?page=' . DASHBOARD . '">' . __ ('Dashboard', DOMAIN) . '</a>'
    );
    return $links;
}
