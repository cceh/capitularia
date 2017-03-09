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

require_once 'functions.php';
require_once 'class-dynamic-menu.php';

$cap_dynamic_menu = new Dynamic_Menu ();

add_action ('wp_enqueue_scripts',    __NAMESPACE__ . '\on_enqueue_scripts');

register_activation_hook   (__FILE__, __NAMESPACE__ . '\on_activation');
register_deactivation_hook (__FILE__, __NAMESPACE__ . '\on_deactivation');
register_uninstall_hook    (__FILE__, __NAMESPACE__ . '\on_uninstall');
