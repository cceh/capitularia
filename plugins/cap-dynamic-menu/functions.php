<?php
/**
 * Capitularia Dynamic Menu global functions.
 *
 * @package Capitularia Dynamic Menu
 */

namespace cceh\capitularia\dynamic_menu;

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
 * Load the content DOM.
 *
 * Load the DOM of the current page.
 *
 * @return \DomDocument The DOM of the current page
 */

function load_html ()
{
    $content = apply_filters ('the_content', get_the_content ());

    $doc = new \DomDocument ();

    // keep server error log small (seems to be a problem at uni-koeln.de)
    libxml_use_internal_errors (true);

    // phpcs:disable Squiz.NamingConventions.ValidVariableName.NotSnakeCase

    // Hack to load HTML with utf-8 encoding
    $doc->loadHTML ("<?xml encoding='UTF-8'>\n" . $content, LIBXML_NONET);
    foreach ($doc->childNodes as $item) {
        if ($item->nodeType == XML_PI_NODE) {
            $doc->removeChild ($item); // remove xml declaration
        }
    }
    $doc->encoding = 'UTF-8'; // insert proper encoding
    return $doc;
    // phpcs:enable
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
        array ('cap-jquery')
    );
    wp_enqueue_script  ('cap-dynamic-menu-front');
}

/**
 * Add dynamic items to the menu.
 *
 * This just outputs a placeholder that will be processed by javascript.
 *
 * @see src/js/front.js for more information.
 *
 * @param array  $items      Old items.
 * @param string $dummy_menu (unused) Menu.
 * @param array  $dummy_args (unused) Menu args.
 *
 * @return array Updated menu.
 */

function on_wp_get_nav_menu_items ($items, $dummy_menu, $dummy_args) // phpcs:ignore
{
    // Only do this on front pages.
    if (is_admin ()) {
        return $items;
    }

    foreach ($items as $key => $item) {
        if (isset ($item->url)) {
            if (strcmp ($item->url, '#cap_dynamic_menu#') === 0) {
                // the menu will be post-processed by javascript
                // put the description somewhere in the html so
                // the javascript can find it
                $item->target = $item->description;
            }
            if (strcmp ($item->url, '#cap_login_menu#') === 0) {
                $item->url = wp_login_url (get_permalink ());
            }
        }
    }

    return $items;
}
