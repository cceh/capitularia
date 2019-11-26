<?php

/**
 * Capitularia Collation Tool plugin.
 *
 * Plugin Name: Capitularia Collation Tool
 * Plugin URI:
 * Description: Collates TEI files.
 * Version:     0.2.1
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
 * The actual collation is done on the Capitularia API Server with a customized
 * version of CollateX for Java.
 *
 * A big Makefile, run by cron on the API server, uses XSLT and Saxon to extract
 * the relevant sections from the TEI files and pre-processes them for
 * collation.  In the end all TEI tags are removed and only the normalized text
 * is stored into the Postgres database.  On an incoming collation request the
 * API server reads the pre-processed texts from the database and sends them to
 * CollateX.  See: collatex_server.py.
 */

namespace cceh\capitularia\collation_user;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** @var string The name of the plugin. */
const NAME      = 'Capitularia Collation Tool';

/** @var string Text Domain */
const LANG      = 'cap-collation-user';

/** @var string AJAX security */
// const NONCE_SPECIAL_STRING = 'cap_collation_nonce';

/** @var string AJAX security */
// const NONCE_PARAM_NAME     = '_ajax_nonce';


require_once 'functions.php';
require_once 'dashboard.php';

add_action ('init',                  ns ('on_init'));
add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));

add_action ('admin_enqueue_scripts', ns ('on_admin_enqueue_scripts'));

add_shortcode ('cap_collation_dashboard', ns ('on_shortcode'));

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));


// for side effect only: to get it in the .po file
__ ('Capitularia Collation Tool');
__ ('Collates TEI files.');
