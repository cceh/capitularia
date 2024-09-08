<?php

/**
 * Plugin Name: Capitularia Page Generator
 * Plugin URI:
 * Description: Generate Wordpress pages for our TEI files.
 * Version:     0.1.1
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-page-generator
 * Domain Path: /languages
 *
 * Capitularia Page Generator plugin.
 *
 * The *Page Generator* plugin helps managing the publication of manuscript pages.
 * Whenever a new manuscript is transcribed and its file is put into the file
 * repository, a new Wordpress page needs to be made for the manuscript to actually
 * appear in Wordpress.
 *
 * This plugin lets you choose among a configurable set of source directories.
 * Then it displays a list of the TEI files in that directory and lets you
 * create and manage the page for each file.  Bulk actions allow you to manage
 * the pages in batches.
 *
 * The plugin can be configured to automatically put some text on newly created
 * pages.  Usually this text consists in one or more shortcodes for the
 * :ref:`Capitularia File Includer plugin <file-includer>`.  It is the File
 * Includer plugin that actually puts the content onto the page.
 *
 * Note that this plugin does nothing on the public pages (except displaying a
 * button on the admin toolbar).
 *
 * How do the TEI files get to the user?
 *
 * A cron process on the API server converts all the TEI files into HTML files
 * and stores them in the filesystem.  See also: :ref:`makefile`.
 *
 * The :ref:`Capitularia File Includer plugin <file-includer>` then includes
 * those files from the filesystem when outputting a Wordpress page to the
 * user.
 *
 * @package Capitularia_Page_Generator
 */

namespace cceh\capitularia\page_generator;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** The name of the plugin. */
const NAME                 = 'Capitularia Page Generator';

/** The Text Domain ofthe plugin. */
const DOMAIN                 = 'cap-page-generator';

/** The Wordpress ID of the settings (option) page. */
const OPTIONS              = 'cap_page_gen_options';

/** The Wordpress ID of the dashboard page. */
const DASHBOARD            = 'cap_page_gen_dashboard';

if (!class_exists ('\WP_List_Table')) {
    include_once ABSPATH . 'wp-admin/includes/class-wp-list-table.php';
}

require_once 'functions.php';
require_once 'class-config.php';
require_once 'class-manuscript.php';
require_once 'class-file-list-table.php';
require_once 'class-dashboard-page.php';
require_once 'class-settings-page.php';

$config = null;

add_action ('init',                        ns ('on_init'));
add_action ('wp_enqueue_scripts',          ns ('on_enqueue_scripts'));
add_action ('admin_menu',                  ns ('on_admin_menu'));
add_action ('admin_bar_menu',              ns ('on_admin_bar_menu'), 200);
add_action ('admin_enqueue_scripts',       ns ('on_admin_enqueue_scripts'));
add_action ('wp_ajax_on_cap_action_file',  ns ('on_cap_action_file'));
add_action ('wp_ajax_on_cap_load_section', ns ('on_cap_load_section'));
add_filter ('query_vars',                  ns ('on_query_vars'));

add_filter (
    'plugin_action_links_cap-page-generator/cap-page-generator.php',
    ns ('on_plugin_action_links')
);

// for side effect only: to get it in the .po file
__ ('Capitularia Page Generator');
__ ('Generate Wordpress pages for our TEI files.');
