<?php
/*
 * Plugin Name: Capitularia Dynamic Menu
 * Plugin URI:
 * Description: Build navigation menus from user-specified HTML-tags.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-dynamic-menu
 * Domain Path: /languages
 */

/**
 * Capitularia Dynamic Menu plugin.
 *
 * The *Dynamic Menu plugin* provides a navigation menu for the sidebar.  The
 * menu entries are collected from DOM elements and attributes of the HTML page
 * and allow the user to navigate to portions of the document.  The menu entries
 * may be nested.
 *
 * You may configure the menu with xpath expressions, eg.to build a menu from
 * all <h3>, <h4>, and <h5> tags on the page.  The menu entries will be properly
 * nested.
 *
 * The PHP code only outputs a placeholder tag.  The Javascript code will build
 * the actual menu using the DOM of the page.
 *
 * @see src/js/front.js
 *
 * @package Capitularia Dynamic Menu
 */

namespace cceh\capitularia\dynamic_menu;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** The Text Domain */
const LANG = 'cap-dynamic-menu';

require_once 'functions.php';

add_action ('wp_enqueue_scripts', ns ('on_enqueue_scripts'));

if (!is_admin ()) {
    add_filter ('nav_menu_link_attributes', ns ('on_nav_menu_link_attributes'), 20, 4);
}

// for side effect only: to get it in the .po file
__ ('Capitularia Dynamic Menu');
__ ('Build navigation menus from user-specified HTML-tags.');
