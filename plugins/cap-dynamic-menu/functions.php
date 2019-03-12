<?php
/**
 * Capitularia Dynamic Menu global functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\dynamic_menu;

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

    // Hack to load HTML with utf-8 encoding
    $doc->loadHTML ("<?xml encoding='UTF-8'>\n" . $content, LIBXML_NONET);
    foreach ($doc->childNodes as $item) {
        if ($item->nodeType == XML_PI_NODE) {
            $doc->removeChild ($item); // remove xml declaration
        }
    }
    $doc->encoding = 'UTF-8'; // insert proper encoding
    return $doc;
}

/**
 * Register the translations.
 *
 * @return void
 */

function on_init ()
{
    load_plugin_textdomain ('cap-dynamic-menu', false, basename (dirname ( __FILE__ )) . '/languages/');
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
    // wp_enqueue_style   ('cap-dynamic-menu-front');
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
