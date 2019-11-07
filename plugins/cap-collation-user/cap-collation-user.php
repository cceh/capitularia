<?php

/**
 * Capitularia Collation Tool plugin.
 *
 * Plugin Name: Capitularia Collation Tool
 * Plugin URI:
 * Description: Collates TEI files.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-collation-user
 * Domain Path: /languages
 *
 * @package Capitularia
 *
 * Provides a workspace where the user can request collations of sections of
 * manuscripts.  Most of the workspace is implemented in javascript with Vue.js.
 *
 * The plugin extracts the relevant sections from the TEI files and
 * pre-processes them for collation.  All TEI tags are removed and only the
 * normalized text is kept.
 *
 * The actual collation is done on the Capitularia VM with CollateX.  A REST
 * request will be sent to the VM.
 */

namespace cceh\capitularia\collation_user;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

include_once ABSPATH . 'wp-admin/includes/template.php';
if (!class_exists ('\WP_List_Table')) {
    include_once ABSPATH . 'wp-admin/includes/class-wp-list-table.php';
}

/** @var string The name of the plugin. */
const NAME      = 'Capitularia Collation Tool';

/** @var string Text Domain */
const LANG      = 'cap-collation-user';

/** @var string Wordpress ID of the settings (option) page */
const OPTIONS   = 'cap_cu_options';

/** @var string Wordpress ID of the dashboard page */
const DASHBOARD = 'cap_collation_dashboard';

/** @var string AJAX security */
const NONCE_SPECIAL_STRING = 'cap_collation_nonce';

/** @var string AJAX security */
const NONCE_PARAM_NAME     = '_ajax_nonce';

/** @var string Where our Wordpress is in the filesystem */
const AFS_ROOT             = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';

/** The ID of the /mss/ page in our wordpress database. */
const MSS_PAGE_ID = 58;         //  /mss
const BKPARENT_PAGE_ID = 4890;  //  /internal/mss

const RE_PUBLISH = 'publish';
const RE_PRIVATE = 'publish|private';

/** @var string Sections we do not want to collate */
const RE_EXCLUDE = "_inscriptio|_incipit|_explicit";


include_once 'functions.php';
include_once 'dashboard.php';
include_once 'dashboard-ajax.php';
include_once 'class-witness.php';
include_once 'class-collatex.php';
require_once 'class-settings-page.php';

add_action ('init',                  ns ('on_init'));
add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));

add_action ('admin_init',            ns ('on_admin_init'));
add_action ('admin_enqueue_scripts', ns ('on_admin_enqueue_scripts'));
add_action ('admin_menu',            ns ('on_admin_menu'));

add_filter ('plugin_action_links_cap-collation-user/cap-collation-user.php',
            ns ('on_plugin_action_links'));

add_nopriv_action ('load_bks');
add_nopriv_action ('load_corresps');
add_nopriv_action ('load_witnesses');
add_nopriv_action ('load_collation');

add_shortcode ('cap_collation_dashboard', ns ('on_shortcode'));

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));


// for side effect only: to get it in the .po file
__ ('Capitularia Collation Tool');
__ ('Collates TEI files.');
