<?php

/**
 * Capitularia Page Generator plugin.
 *
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
 * @package Capitularia
 *
 * The _Capitularia Page Generator_ plugin helps create the Wordpress pages that
 * display our TEI files.  It lists the TEI files in a directory and lets the
 * admin user create and manage the page for each file.  Bulk actions allow the
 * admin user to manage the pages in batches.
 *
 * When a page is created, text can automatically be written to it.  Usually
 * this text consists in one or more shortcodes for the _Capitularia File
 * Includer_ plugin.
 *
 * Note that this plugin does nothing on the public pages (except displaying a
 * button on the admin toolbar).
 *
 * How do the TEI files get to the user?
 *
 * A cron process on the API server converts all the TEI files into HTML files
 * and stores them in the AFS filesystem.  See also: the Makefile in the xslt
 * directory on the API server.
 *
 * The _Capitularia File Includer_ plugin then includes those files from the AFS
 * filesystem when outputting a Wordpress page to the user.
 */

namespace cceh\capitularia\page_generator;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** @var string The name of the plugin. */
const NAME                 = 'Capitularia Page Generator';

/** @var string Text Domain */
const LANG                 = 'cap-page-generator';

/** @var string Wordpress ID of the settings (option) page */
const OPTIONS              = 'cap_page_gen_options';

/** @var string Wordpress ID of the dashboard page */
const DASHBOARD            = 'cap_page_gen_dashboard';

/** @var string AJAX security */
const NONCE_SPECIAL_STRING = 'cap_page_gen_nonce';

/** @var string AJAX security */
const NONCE_PARAM_NAME     = '_ajax_nonce';

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

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));

// for side effect only: to get it in the .po file
__ ('Capitularia Page Generator');
__ ('Generate Wordpress pages for our TEI files.');
