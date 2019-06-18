<?php

/**
 * Capitularia user collation plugin.
 *
 * Plugin Name: Capitularia Collation for Users
 * Plugin URI:
 * Description: Generate colllations from TEI files.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-collation-user
 * Domain Path: /languages
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation_user;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

$cap_collation_name = __ ('Capitularia Collation', 'cap-collation-user');

include_once ABSPATH . 'wp-admin/includes/template.php';
if (!class_exists ('\WP_List_Table')) {
    include_once ABSPATH . 'wp-admin/includes/class-wp-list-table.php';
}

include_once 'functions.php';
include_once 'dashboard.php';
include_once 'dashboard-ajax.php';
include_once 'class-witness.php';
include_once 'class-collatex.php';

add_action ('init',                            __NAMESPACE__ . '\on_init');
add_action ('wp_enqueue_scripts',              __NAMESPACE__ . '\on_enqueue_scripts');

add_nopriv_action ('load_bks');
add_nopriv_action ('load_corresps');
add_nopriv_action ('load_manuscripts');
add_nopriv_action ('load_collation');

add_shortcode ('cap_collation_dashboard', __NAMESPACE__ . '\on_shortcode');

register_activation_hook   (__FILE__, __NAMESPACE__ . '\on_activation');
register_deactivation_hook (__FILE__, __NAMESPACE__ . '\on_deactivation');
register_uninstall_hook    (__FILE__, __NAMESPACE__ . '\on_uninstall');
