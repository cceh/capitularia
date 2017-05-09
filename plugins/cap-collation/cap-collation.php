<?php

/**
 * Capitularia collation plugin.
 *
 * Plugin Name: Capitularia Collation
 * Plugin URI:
 * Description: Generate colllations from TEI files.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: capitularia
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

$cap_collation_name = __ ('Capitularia Collation', 'capitularia');

require_once 'functions.php';

add_action ('wp_enqueue_scripts',              __NAMESPACE__ . '\on_enqueue_scripts');
add_action ('admin_bar_menu',                  __NAMESPACE__ . '\on_admin_bar_menu', 200);

if (is_admin ()) {
    if (!class_exists ('\WP_List_Table')) {
        include_once ABSPATH . 'wp-admin/includes/class-wp-list-table.php';
    }

    include_once 'dashboard.php';
    include_once 'dashboard-ajax.php';
    include_once 'class-witness.php';
    include_once 'class-witness-list-table.php';
    include_once 'class-collatex.php';

    /**
     * The collation algorithms we support.  The Needleman-Wunsch-Gotoh alogorithm
     * is available only with our special patched version of CollateX.
     */

    $cap_collation_algorithms = array (
        'dekker'                 => _x ('Dekker',                 'Collation Algorithm', 'capitularia'),
        'gst'                    => _x ('Greedy String Tiling',   'Collation Algorithm', 'capitularia'),
        'medite'                 => _x ('MEDITE',                 'Collation Algorithm', 'capitularia'),
        'needleman-wunsch'       => _x ('Needleman-Wunsch',       'Collation Algorithm', 'capitularia'),
        'needleman-wunsch-gotoh' => _x ('Needleman-Wunsch-Gotoh', 'Collation Algorithm', 'capitularia'),
    );

    add_action ('admin_menu',                      __NAMESPACE__ . '\on_admin_menu');
    add_action ('admin_enqueue_scripts',           __NAMESPACE__ . '\on_admin_enqueue_scripts');
    add_action ('wp_ajax_on_cap_load_sections',    __NAMESPACE__ . '\on_cap_load_sections');
    add_action ('wp_ajax_on_cap_load_manuscripts', __NAMESPACE__ . '\on_cap_load_manuscripts');
    add_action ('wp_ajax_on_cap_load_collation',   __NAMESPACE__ . '\on_cap_load_collation');

    register_activation_hook   (__FILE__, __NAMESPACE__ . '\on_activation');
    register_deactivation_hook (__FILE__, __NAMESPACE__ . '\on_deactivation');
    register_uninstall_hook    (__FILE__, __NAMESPACE__ . '\on_uninstall');
}
