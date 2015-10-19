<?php
/*
Plugin Name: Capitularia Page Generator
Plugin URI:
Description: Generate page stubs from files in a directory.
Version:     0.1.0
Author:      Marcello Perathoner
Author URI:
License:     GPLv2 or later
Text Domain: cap-page-gen
*/

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

if (!class_exists ('WP_List_Table')) {
    include_once ABSPATH . 'wp-admin/includes/class-wp-list-table.php';
}

require_once 'class-file-list-table.php';
require_once 'class-page-generator.php';

$i = \cceh\capitularia\page_generator\Page_Generator::getInstance ();

register_activation_hook   (__FILE__, array ($i, 'on_activation'));
register_deactivation_hook (__FILE__, array ($i, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($i, 'on_uninstall'));
