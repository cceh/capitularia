<?php

/**
 * Capitularia File Includer plugin.
 *
 * Plugin Name: Capitularia File Includer
 * Plugin URI:
 * Description: Includes external HTML files in Wordpress pages.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-file-includer
 * Domain Path: /languages
 *
 * This plugin implements a shortcode to include external files.  It also stores
 * a copy of the file in the Wordpress database so that the built-in
 * search function can find it.
 *
 * The TEI files are transformed into HTML on the Capitularia VM.  On that
 * server we maintain up-to-date python and java installations.  A customary web
 * project at uni-koeln.de does not include those or includes outdated versions
 * of them.
 *
 * We then use this plugin to include into our Wordpress pages the HTML files we
 * generated on the VM.
 *
 * The format of the shortcode is:
 *
 *   [cap_include path="/path/to/file.html" post="true"]
 *
 * @param path - Path of the file to include, relative to the root on the
 *               settings page.
 * @param post - Optional. If the included file should be post-processed by the
 *               footnotes-post-processor then set this parameter to true.
 *
 * See also: the Page Generator plugin, which generates batches of page stubs
 * from directories of TEI files.  Those stubs usually contain the shortcodes
 * for this plugin.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

// for side effect only: to get it in the .po file
__ ('Capitularia File Includer');
__ ('Includes external HTML files in Wordpress pages.');

/** @var string The name of the plugin. */
const NAME     = 'Capitularia File Includer';

/** @var string Text Domain */
const LANG     = 'cap-file-includer';

/** @var string Wordpress ID of the settings (option) page */
const OPTIONS  = 'cap_fi_options';

require_once 'functions.php';
require_once 'footnotes-post-processor-include.php';
require_once 'class-file-includer.php';
require_once 'class-settings-page.php';

$cap_file_includer = new FileIncluderEngine ();

add_action ('init',                    ns ('on_init'));
add_action ('wp_enqueue_scripts',      ns ('on_enqueue_scripts'));

add_action ('admin_init',              ns ('on_admin_init'));
add_action ('admin_enqueue_scripts',   ns ('on_admin_enqueue_scripts'));
add_action ('admin_menu',              ns ('on_admin_menu'));

add_filter ('the_content',             array ($cap_file_includer, 'on_the_content_early'), 9);
add_filter ('wp_revisions_to_keep',    array ($cap_file_includer, 'on_wp_revisions_to_keep'));

// Our shortcode needs to be registered or else the incredibly stupid
// wptexturizer will texturize the quotes around our parameters !!!
add_shortcode (get_opt ('shortcode', 'cap_include'), ns ('on_shortcode'));

add_filter (
    'plugin_action_links_cap-file-includer/cap-file-includer.php',
    ns ('on_plugin_action_links')
);

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));
