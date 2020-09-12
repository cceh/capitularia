<?php
/**
 * Capitularia Collation Tool global functions.
 *
 * @package Capitularia_Collation_Tool
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

function enqueue_scripts ()
{
    $handle = 'cap-collation-front.js';

    lib\enqueue_from_manifest ($handle, ['cap-theme-front.js', 'wp-i18n']);

    // See: https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/
    lib\wp_set_script_translations ($handle, DOMAIN, __FILE__);
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
    enqueue_scripts ();

    return '<div id="cap-collation-app"></div>';
}
