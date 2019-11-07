<?php

/**
 * Capitularia Dynamic Menu plugin.
 *
 * Plugin Name: Capitularia Dynamic Menu
 * Plugin URI:
 * Description: Build navigation menus from user-specified HTML-tags.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-dynamic-menu
 * Domain Path: /languages
 *
 * @package Capitularia
 *
 * This plugin walks through the content of the Wordpress page and builds a
 * navigation menu from user-specified tags.  You may eg. build a menu from all
 * <h3>, <h4>, and <h5> tags on the page.  The menu entries will be properly
 * nested.
 *
 * See also: src/js/front.js
 */

namespace cceh\capitularia\dynamic_menu;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** @var string Text Domain */
const LANG = 'cap-dynamic-menu';

require_once 'functions.php';

add_action ('init',                   ns ('on_init'));
add_action ('wp_enqueue_scripts',     ns ('on_enqueue_scripts'));

add_filter ('wp_get_nav_menu_items',  ns ('on_wp_get_nav_menu_items'), 20, 3);

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));

// for side effect only: to get it in the .po file
__ ('Capitularia Dynamic Menu');
__ ('Build navigation menus from user-specified HTML-tags.');
