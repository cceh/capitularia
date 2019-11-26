<?php

/**
 * Capitularia Library plugin.
 *
 * Plugin Name: Capitularia Library
 * Plugin URI:
 * Description: Library of functions for Capitularia plugins. (REQUIRED)
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-lib
 * Domain Path: /languages
 *
 * This plugin is required by the other Capitularia plugins.  This plugin
 * bundles all functions that don't quite fit elsewhere or would be excessively
 * duplicated.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\lib;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** @var string The name of the plugin. */
const NAME    = 'Capitularia Library';

/** @var string Text Domain */
const LANG    = 'cap-lib';

/** @var string Wordpress ID of the settings (option) page */
const OPTIONS = 'cap_lib_options';

require_once 'functions.php';
require_once 'class-settings-page.php';


add_action ('init',                  ns ('on_init'));
add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));

add_action ('admin_init',            ns ('on_admin_init'));
add_action ('admin_enqueue_scripts', ns ('on_admin_enqueue_scripts'));
add_action ('admin_menu',            ns ('on_admin_menu'));

add_filter (
    'plugin_action_links_cap-lib/cap-lib.php',
    ns ('on_plugin_action_links')
);

add_nopriv_action ('get_api_endpoint');
add_nopriv_action ('current_user_can');
add_nopriv_action ('get_published_ids');

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));


// for side effect only: to get it in the .po file
__ ('Capitularia Library');
__ ('Library of functions for Capitularia plugins. (REQUIRED)');
