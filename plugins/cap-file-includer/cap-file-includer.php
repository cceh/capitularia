<?php
/*
 * Plugin Name: Capitularia File Includer
 * Plugin URI:
 * Description: Includes external HTML files in Wordpress pages.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-file-includer
 * Domain Path: /languages
 */

/**
 * Capitularia File Includer plugin.
 *
 * The *File Includer plugin* registers a Wordpress shortcode that allows to
 * include any external HTML file in a Worpdress page.  We use this shortcode to
 * put the transcribed manuscripts into Wordpress.
 *
 * The TEI files are :ref:`transformed into HTML files <html-generation>` on the
 * Capitularia VM.  On that server we maintain up-to-date python and java
 * installations.  A customary Web Projekt at uni-koeln.de does not include
 * those or includes outdated versions of them.
 *
 * This plugin also stores the included text into the Wordpress database.  This
 * makes the built-in Wordpress search function work with the included material.
 *
 * .. note:: Currently (Nov. 2019) the plugin also does some post-processing of
 *    the HTML files.  This code will also be rewritten and moved to the VM.
 *
 * The format of the shortcode is:
 *
 * .. code::
 *
 *    [cap_include path="path/to/file.html" post="true"]
 *
 * :param str path: Path of the file to include, relative to the root on the
 *                  settings page.
 * :param str post: Optional. If the included file should be post-processed by the
 *                  footnotes-post-processor then set this parameter to true.
 *
 * See also: the :ref:`Page Generator plugin <page-generator>`, which generates
 * batches of page stubs from directories of TEI files.  Those stubs usually
 * contain the shortcodes for this plugin.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

// for side effect only: to get it in the .po file
__ ('Capitularia File Includer');
__ ('Includes external HTML files in Wordpress pages.');

/** The name of the plugin. */
const NAME    = 'Capitularia File Includer';

/** The Text Domain of the plugin. */
const LANG    = 'cap-file-includer';

/** The Wordpress ID of the settings (option) page. */
const OPTIONS = 'cap_fi_options';

require_once 'functions.php';
require_once 'footnotes-post-processor-include.php';
require_once 'class-file-includer.php';
require_once 'class-settings-page.php';

$cap_file_includer = new FileIncluderEngine ();

add_action ('init',                    ns ('on_init'));
add_action ('wp_enqueue_scripts',      ns ('on_enqueue_scripts'));

add_action ('admin_enqueue_scripts',   ns ('on_admin_enqueue_scripts'));
add_action ('admin_menu',              ns ('on_admin_menu'));

add_filter ('the_content',             array ($cap_file_includer, 'on_the_content_early'), 9);

// The shortcode needs to be alwqays registered or else the incredibly stupid
// wptexturizer will texturize the quotes around our parameters !!!
add_shortcode (
    get_opt ('shortcode', 'cap_include'),
    array ($cap_file_includer, 'on_shortcode')
);

add_filter (
    'plugin_action_links_cap-file-includer/cap-file-includer.php',
    ns ('on_plugin_action_links')
);
