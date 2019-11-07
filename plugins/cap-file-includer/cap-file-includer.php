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
 * @package Capitularia
 *
 * The TEI files are transformed into HTML on the Capitularia VM.  On that
 * server we maintain up-to-date python and java installations.  A web project
 * does not include those or includes outdated versions of them.
 *
 * Then we use this plugin to include the HTML files we generated into our
 * Wordpress pages.
 *
 * The format of the shortcode is:
 *
 *   [cap_include path="/path/to/file.html" post="true"]
 *
 * @param path - Path of the file to include, relative to the root
 *               on the settings page.
 *
 * @param post - Optional. If the included file should be post-processes
 *               by the footnotes-post-processor set this param to true.
 *
 * See also: the Page Generator plugin, which generates batches of page stubs
 * from directories of TEI files.  Those stubs usually contain the shortcodes
 * for this plugin.
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

/** @var string Where our Wordpress is in the filesystem */
const AFS_ROOT = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia';

require_once 'functions.php';
require_once 'footnotes-post-processor-include.php';
require_once 'class-settings-page.php';


add_action ('init',                  ns ('on_init'));
add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));

add_action ('admin_init',            ns ('on_admin_init'));
add_action ('admin_enqueue_scripts', ns ('on_admin_enqueue_scripts'));
add_action ('admin_menu',            ns ('on_admin_menu'));

add_shortcode (get_opt ('shortcode', 'cap_include'), ns ('on_shortcode'));

add_filter ('plugin_action_links_cap-file-includer/cap-file-includer.php',
            ns ('on_plugin_action_links'));

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));
