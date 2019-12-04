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

    wp_register_script (
        'cap-collation-user-front',
        plugins_url ('js/front.js', __FILE__),
        array (
            'cap-lib-front',
            'cap-underscore',
            'cap-vue',
            'cap-jquery',
            'jquery-ui-sortable',
            'cap-bs-dropdown-js'
        )
    );

    load_plugin_textdomain (LANG, false, basename (dirname (__FILE__)) . '/languages/');

    wp_localize_script (
        'cap-collation-user-front',
        'cap_collation_user_front_ajax_object',
        array (
            'api_url'  => lib\get_opt ('api'),
            'status'   => current_user_can ('read_private_pages') ? 'private' : 'publish',
            'copy_msg' => _x (' ($1. copy)',  '2., 3., etc. copy of capitularies', LANG),
            'corr_msg' => _x (' (corrected)', 'corrected version of capitularies', LANG),
            'bktz_msg' => _x ('Edition by Boretius/Krause', 'title of the edition', LANG)
        )
    );
}

/**
 * Replace the shortcode with the collation dashboard code.
 *
 * @param array $dummy_atts    (unused) The shortcode attributes
 * @param array $dummy_content (unused) The shortcode content (should be empty)
 *
 * @return string The collation dashboard page as HTML.
 */

function on_shortcode ($dummy_atts, $dummy_content) // phpcs:ignore
{
    // send these only if the shortcode is on the page
    wp_enqueue_style  ('cap-collation-user-front');
    wp_enqueue_script ('cap-collation-user-front');

    require_once 'dashboard.php';

    return dashboard_page ();
}
