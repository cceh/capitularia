<?php
/**
 * Capitularia File Includer functions.
 *
 * The main difficulty here is to get around the wpautop and wptexturizer
 * filters that were implemented with boundless incompetence.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

use cceh\capitularia\lib;

/**
 * Clean up the <pre> tags we inserted solely to protect against the dumb
 * wpautop and wptexturizer filters.
 *
 * @param array  $dummy_atts (unused) The shortcode attributes.
 * @param string $content    The shortcode content.
 *
 * @return The content with <pre> tags stripped.
 */

function on_shortcode ($dummy_atts, $content) // phpcs:ignore
{
    return \do_shortcode (strip_pre ($content));
}

/**
 * Put shortcodes and <pre> tags around the content.
 *
 * @param array  $atts    The shortcode attributes.
 * @param string $content The shortcode content.
 *
 * @return The content surrounded by shortcodes and <pre> tags.
 */

function make_shortcode_around ($atts, $content)
{
    $short = get_opt ('shortcode');

    $attributes = "path=\"{$atts['path']}\"";
    if ($atts['post']) {
        $attributes .= ' post="true"';
    }
    return "[{$short} {$attributes}]<pre><pre>{$content}</pre></pre>[/{$short}]";
}

/**
 * Strip <pre> tags from around the content.
 *
 * @param string $content The content to strip.
 *
 * @return The stripped content.
 */

function strip_pre ($content)
{
    $content = preg_replace ('!<pre><pre>!s',   '', $content);
    $content = preg_replace ('!</pre></pre>!s', '', $content);
    return $content;
}

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
 * Get an option from Wordpress.
 *
 * @param string $name    The name of the option.
 * @param string $default The default value.
 *
 * @return string The option value
 */

function get_opt ($name, $default = '')
{
    static $options = null;

    if ($options === null) {
        $options = get_option (OPTIONS, array ());
    }
    return isset ($options[$name]) ? $options[$name] : $default;
}

/**
 * Get the configured root directory.
 *
 * @return string The root directory
 */

function get_root ()
{
    return lib\urljoin (lib\get_opt ('afs'), get_opt ('root'));
}

/**
 * Enqueue the frontpage scripts and styles
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    wp_register_style ('cap-fi-front', plugins_url ('css/front.css', __FILE__));
    wp_enqueue_style  ('cap-fi-front');
}

/**
 * Initialize the plugin.
 *
 * @return void
 */

function on_init ()
{
    load_plugin_textdomain (LANG, false, basename (dirname (__FILE__)) . '/languages/');
}

/**
 * Initialize the settings page.
 *
 * First hook called on every admin page.
 *
 * @return void
 */

function on_admin_init ()
{
}

/**
 * Enqueue the admin page scripts and styles
 *
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    wp_register_style ('cap-fi-admin', plugins_url ('css/admin.css', __FILE__));
    wp_enqueue_style  ('cap-fi-admin');
}

/**
 * Add menu entry to the Wordpress admin menu.
 *
 * Add a menu entry for the settings (options) page to the Wordpress
 * settings menu.
 *
 * @return void
 */

function on_admin_menu ()
{
    add_options_page (
        __ (NAME, LANG) . ' ' . __ ('Settings', LANG),
        __ (NAME, LANG),
        'manage_options',
        OPTIONS,
        array (new Settings_Page (), 'display')
    );
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
        '<a href="options-general.php?page=' . OPTIONS . '">' . __ ('Settings', LANG) . '</a>'
    );
    return $links;
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
