<?php
/*
Plugin Name: Capitularia Dynamic Menu
Plugin URI:
Description: Builds menus from the page contents
Version:     0.1.0
Author:      Marcello Perathoner
Author URI:
License:     GPLv2 or later
Text Domain: cap-dynamic-menu
*/

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'class-dynamic-menu.php';

$i = \cceh\capitularia\dynamic_menu\Dynamic_Menu::getInstance ();

register_activation_hook   (__FILE__, array ($i, 'on_activation'));
register_deactivation_hook (__FILE__, array ($i, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($i, 'on_uninstall'));

$plugin_dir = basename (dirname (__FILE__));
load_plugin_textdomain ('cap-dynamic-menu', null, "$plugin_dir/i18n");
