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
 * Put shortcodes and <pre> tags around the content.
 *
 * @param array  $atts    The shortcode attributes.
 * @param string $content The shortcode content.
 *
 * @return string The content surrounded by shortcodes and <pre> tags.
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
 * @return string The stripped content.
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
 * Initialize the plugin.
 *
 * @return void
 */

function on_init ()
{
    lib\load_plugin_textdomain (DOMAIN, __FILE__);
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
        __ (NAME, DOMAIN) . ' ' . __ ('Settings', DOMAIN),
        __ (NAME, DOMAIN),
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
        '<a href="options-general.php?page=' . OPTIONS . '">' . __ ('Settings', DOMAIN) . '</a>'
    );
    return $links;
}
