<?php
/**
 * Capitularia Collation Tool global functions.
 *
 * @package Capitularia Collation Tool
 */

namespace cceh\capitularia\collation_user;

use cceh\capitularia\lib;

/**
 * Add current namespace
 *
 * @param string $function_name The class or function name without namespace
 *
 * @return string The name with namespace
 */

function ns ($function_name)
{
    return __NAMESPACE__ . '\\' . $function_name;
}

/**
 * Enqueue the front page script and localize it.
 *
 * The script is a webpacked Vue.js application containing its own css.
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    wp_register_script (
        'cap-collation',
        plugins_url ('js/front.js', __FILE__),
        array (
            'wp-i18n',
            'cap-lib-front',
            'cap-underscore',
            'cap-vue',
            'cap-bootstrap-vue',
            'cap-jquery',
            'jquery-ui-sortable'
        )
    );

    load_plugin_textdomain (LANG, false, basename (dirname (__FILE__)) . '/languages/');

    // Actually we use this to pass some status information to JS
    wp_localize_script (
        'cap-collation',
        'cap_collation_user_front_ajax_object',
        array (
            'api_url'  => lib\get_opt ('api'),
            'status'   => current_user_can ('read_private_pages') ? 'private' : 'publish',
        )
    );

    // See: https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/
    wp_set_script_translations (
        'cap-collation',
        LANG,
        plugin_dir_path (__FILE__) . 'languages'
    );
}

/**
 * Replace the shortcode with the collation dashboard.
 *
 * Insert a Vue.js component.  Vue.js takes over from that and builds the
 * collation dashboard.
 *
 * @param array $dummy_atts    (unused) The shortcode attributes
 * @param array $dummy_content (unused) The shortcode content (should be empty)
 *
 * @return string The Vue.js component as HTML.
 */

function on_shortcode ($dummy_atts, $dummy_content) // phpcs:ignore
{
    // Include the <script> only if the shortcode is actually on the page.
    // Makes the script show up in the footer.
    wp_enqueue_script ('cap-collation');

    return '<cap-collation-app id="cap-collation-app"></cap-collation-app>';
}
