<?php
/**
 * Capitularia Collation global functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation_user;

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
 * Register the translations.
 *
 * @return void
 */

function on_init ()
{
    load_plugin_textdomain (LANG, false, basename (dirname (__FILE__)) . '/languages/');
}

/**
 * Enqueue the front page scripts and styles
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    wp_register_style (
        'cap-collation-user-front',
        plugins_url ('css/front.css', __FILE__),
        array ('cap-jquery-ui-css')
    );
    wp_enqueue_style  ('cap-collation-user-front');

    wp_register_script (
        'cap-collation-user-front',
        plugins_url ('js/front.js', __FILE__),
        array (
            'cap-lib-front',
            'cap-underscore',
            'cap-vue',
            'cap-jquery',
            'jquery-ui-accordion',
            'jquery-ui-sortable',
            'cap-bs-dropdown-js'
        )
    );

    wp_localize_script (
        'cap-collation-user-front',
        'cap_collation_user_front_ajax_object',
        array (
            // NONCE_PARAM_NAME => wp_create_nonce (NONCE_SPECIAL_STRING),
            // 'ajaxurl'        => admin_url ('admin-ajax.php'),
            'api_url'        => lib\get_opt ('api'),
            'status'         => current_user_can ('read_private_pages') ? 'private' : 'publish',
            'copy_msg'       => _x (' ($1. copy)',   '2., 3., etc. copy of capitularies', 'cap-collation-user'),
            'corr_msg'       => _x (' (corrected)',  'corrected version of capitularies', 'cap-collation-user'),
            'bktz_msg'       => _x ('Edition by Boretius/Krause', 'title of the edition', 'cap-collation-user')
        )
    );
}

/**
 * Enqueue the admin page scripts and styles
 *
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    wp_register_style ('cap-collation-user-admin', plugins_url ('css/admin.css', __FILE__));
    wp_enqueue_style  ('cap-collation-user-admin');
}

/**
 * The shortcode that adds the whole shebang.
 *
 * @param array $dummy_atts    (unused) The shortcode attributes
 * @param array $dummy_content (unused) The shortcode content (should be empty)
 *
 * @return void The collation dashboard page HTML
 */

function on_shortcode ($dummy_atts, $dummy_content) // phpcs:ignore
{
    // include vue.js, underscore.js, front.js only if needed
    wp_enqueue_script ('cap-collation-user-front');
    return dashboard_page ();
}

/**
 * Things to do when a admin activates the plugin
 *
 * @return void
 */

function on_activation ()
{
}

/**
 * Things to do when a admin deactivates the plugin
 *
 * @return void
 */

function on_deactivation ()
{
}

/**
 * Things to do when a admin uninstalls the plugin
 *
 * @return void
 */

function on_uninstall ()
{
}
