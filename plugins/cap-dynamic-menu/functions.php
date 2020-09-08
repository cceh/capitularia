<?php
/**
 * Capitularia Dynamic Menu global functions.
 *
 * @package Capitularia Dynamic Menu
 */

namespace cceh\capitularia\dynamic_menu;

const MAGIC_MENU  = '#cap_dynamic_menu#';
const MAGIC_LOGIN = '#cap_login_menu#';

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
 * Enqueue Javascript and CSS for the front page.
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    wp_register_style  ('cap-dynamic-menu-front', plugins_url ('css/front.css', __FILE__));
    wp_register_script (
        'cap-dynamic-menu-front',
        plugins_url ('js/front.js', __FILE__),
        array ('cap-front-js')
    );

    load_plugin_textdomain (LANG, false, basename (dirname (__FILE__)) . '/languages/');
}

/**
 * Add attribute data-cap-dynamic-menu and dynamic url to login menu.
 *
 * Puts the item description into the HTML attribute
 * data-cap-dynamic-menu.  Otherwise it would get lost.
 *
 * @see src/js/front.js for more information.
 *
 * @param array    $atts   The old HTML attributes.
 * @param WP_Post  $item   The current menu item.
 * @param stdClass $args   An object of wp_nav_menu() arguments.
 * @param int      $depth  Depth of menu item. Used for padding.
 *
 * @return array  The updated HTML attributes.
 */

function on_nav_menu_link_attributes ($atts, $item, $args, $depth) // phpcs:ignore
{
    if (isset ($item->url)) {
        if (strcmp ($item->url, MAGIC_MENU) === 0) {
            $atts['data-cap-dynamic-menu'] = $item->description;
            // enqueue only if a dynamic menu is on the page
            wp_enqueue_script  ('cap-dynamic-menu-front');
        }
        if (strcmp ($item->url, MAGIC_LOGIN) === 0) {
            $atts['href'] = wp_login_url (get_permalink ());
        }
    }
    return $atts;
}
