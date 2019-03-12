<?php
/**
 * Capitularia XSL Processor functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

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
        $options = get_option ('cap_xsl_options', array ());
    }
    return $options[$name] ? $options[$name] : $default;
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
 * Increment metadata counters for post.
 *
 * @param int    $post_id The post id.
 * @param string $meta    The metadata key.
 *
 * @return int The new value.
 */

function increment_metadata ($post_id, $meta)
{
    $n = get_metadata ('post', $post_id, $meta, true) or 0;
    $n++;
    update_post_meta ($post_id, $meta, $n);
    return $n;
}

/**
 * Turn off revision generation for save operations.
 *
 * Note: we cannot use the _wp_revisions_to_keep_ -filter and set it to 0
 * because that would delete all previous revisions.
 *
 * @return void
 *
 * @see https://core.trac.wordpress.org/browser/tags/4.3.1/src/wp-includes/revision.php#L150
 *
 * @SuppressWarnings(PHPMD.UnusedLocalVariable)
 */

function suppress_revisions ()
{
    // error_log ('on_the_content_early () revisions disabled');
    add_filter (
        'wp_save_post_revision_post_has_changed',
        function ($post_has_changed, $last_revision, $post) {
            return false;
        },
        10,
        3
    );
}

/**
 * Enqueue the frontpage scripts and styles
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    wp_register_style ('cap-xsl-front', plugins_url ('css/front.css', __FILE__));
    wp_enqueue_style  ('cap-xsl-front');
}

/**
 * Initialize the plugin.
 *
 * @return void
 */

function on_init ()
{
    load_plugin_textdomain ('cap-xsl-processor', false, basename (dirname ( __FILE__ )) . '/languages/');
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
    wp_register_style ('cap-xsl-admin', plugins_url ('css/admin.css', __FILE__));
    wp_enqueue_style  ('cap-xsl-admin');
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
        NAME . ' Options',
        NAME,
        'manage_options',
        'cap_xsl_options',
        array (new Settings_Page (), 'on_menu_options_page')
    );
}

/**
 * Add a cache flush button to the Wordpress admin toolbar.
 *
 * @param \WP_Admin_Bar $wp_admin_bar The \WP_Admin_Bar object
 *
 * @return void
 */

function on_admin_bar_menu ($wp_admin_bar)
{
    global $cap_xsl_processor, $cap_xsl_processor_stats;
    if (!is_admin () && current_user_can ('edit_pages') && $cap_xsl_processor->has_shortcode ()) {
        $page_id = intval (get_queried_object_id ());
        $args = array (
            'id'    => 'cap_xsl_cache_reload',
            'title' => 'XSL',
            'href'  => $_SERVER['REQUEST_URI'] . '?cap_xsl=reload',
            'meta'  => array ('class' => 'cap-xsl',
                              'title' => NAME . "\nRefresh the page cache\n" .
                              $cap_xsl_processor_stats->get_tooltip ($page_id))
        );
        $wp_admin_bar->add_node ($args);
    }
}

/**
 * Register _cap\_xsl_ as valid HTTP GET parameter
 *
 * If _cap\_xsl_ is 'reload' then we refresh the cache unconditionally.
 *
 * @param string[] $vars Already registered parameter names
 *
 * @return string[] Augmented registered parameter names.
 */

function on_query_vars ($vars)
{
    $vars[] = 'cap_xsl';
    return $vars;
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
