<?php

/**
 * Capitularia dynamic menu plugin.
 *
 * Plugin Name: Capitularia Dynamic Menu
 * Plugin URI:
 * Description: Builds menus from the page contents
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: capitularia
 *
 * @package Capitularia
 */

namespace cceh\capitularia\dynamic_menu;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'class-dynamic-menu.php';

$i = Dynamic_Menu::get_instance ();

$class_name = 'cceh\capitularia\dynamic_menu\Dynamic_Menu';
register_activation_hook   (__FILE__, array ($class_name, 'on_activation'));
register_deactivation_hook (__FILE__, array ($class_name, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($class_name, 'on_uninstall'));
