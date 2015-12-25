<?php

/**
 * Capitularia dynamic menu plugin.
 *
 * @package Capitularia
 *
 * Plugin Name: Capitularia Dynamic Menu
 * Plugin URI:
 * Description: Builds menus from the page contents
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: capitularia
 */

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'class-dynamic-menu.php';

$i = \cceh\capitularia\dynamic_menu\Dynamic_Menu::get_instance ();

register_activation_hook   (__FILE__, array ($i, 'on_activation'));
register_deactivation_hook (__FILE__, array ($i, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($i, 'on_uninstall'));
