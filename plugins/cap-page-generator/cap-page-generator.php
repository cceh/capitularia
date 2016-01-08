<?php

/**
 * Capitularia page generator plugin.
 *
 * Plugin Name: Capitularia Page Generator
 * Plugin URI:
 * Description: Generate pages from TEI files.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: capitularia
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

if (!class_exists ('\WP_List_Table')) {
    include_once ABSPATH . 'wp-admin/includes/class-wp-list-table.php';
}

require_once 'functions.php';
require_once 'class-config.php';
require_once 'class-manuscript.php';
require_once 'class-file-list-table.php';
require_once 'class-dashboard-page.php';
require_once 'class-settings-page.php';
require_once 'class-page-generator.php';

$config = new Config ();
$i = Page_Generator::get_instance ($config);

register_activation_hook   (__FILE__, __NAMESPACE__ . '\on_activation');
register_deactivation_hook (__FILE__, __NAMESPACE__ . '\on_deactivation');
register_uninstall_hook    (__FILE__, __NAMESPACE__ . '\on_uninstall');
