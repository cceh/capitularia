<?php
/**
 * Capitularia File Includer functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

/**
 * Include the file.
 *
 * @param array  $atts    The shortcode attributes.
 * @param string $content Should be empty.
 *
 * @return The page content to insert.
 */

function on_shortcode ($atts, $content = '')
{
    global $post;

    $atts = shortcode_atts (
        array (
            'path' => '',
            'post' => false,
        ),
        $atts
    );

    # replace {slug} with the page slug
    $path = preg_replace ('/\{slug\}/', $post->post_name, $atts['path']);

    $root = realpath (get_opt ('root'));
    $path = realpath ("$root/$path");

    if (strncmp ($root, $path, strlen ($root)) !== 0) {
        return sprintf (_x ('%s: Illegal path.', 'Plugin name', LANG), NAME);
    }

    $do_postprocessing = wp_parse_args ($atts['post']);

    if (!is_readable ($path)) {
        return '<div class="error">' . sprintf (__ ("File not found: %s", 'cap-file-includer'), $path) . '</div>';
    }

    $doc = load_xml_or_html (file_get_contents ($path));

    if ($do_postprocessing) {
        $doc = post_process ($doc);
    }

    $output = explode ("\n", save_html ($doc));

    if (strncmp ($output[0], '<?xml ', 6) == 0) {
        array_shift ($output);
    }
    array_unshift ($output, '<div class="xsl-output">');
    $output[] = '</div>';

    // run shortcode parser recursively
    return do_shortcode (join ("\n", $output));
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
 * Output a localized 'save changes' button
 *
 * @return
 */

function save_button () {
    submit_button (
        _x ('Save Changes', 'Button: Save Changes in setting page', LANG)
    );
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
 * Join two paths with exactly one slash.
 *
 * @param string $url1 The first path.
 * @param string $url2 The second path.
 *
 * @return url1 and url2 joined by exactly one slash.
 */

function urljoin ($url1, $url2)
{
    return rtrim ($url1, '/') . '/' . $url2;
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
    load_plugin_textdomain (LANG, false, basename (dirname ( __FILE__ )) . '/languages/');
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
 * @return array
 */

function on_plugin_action_links ($links) {
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
