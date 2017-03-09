<?php

/**
 * Capitularia XSL processor plugin.
 *
 * Plugin Name: Capitularia XSL Processor
 * Plugin URI:
 * Description: An xsl processor that caches its output in the wordpress database.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: capitularia
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

const NAME = 'Capitularia XSL Processor';

require_once 'functions.php';
require_once 'class-stats.php';
require_once 'class-settings-page.php';
require_once 'class-xsl-processor.php';

$cap_xsl_processor = new XSL_Processor ();
$cap_xsl_processor_stats = new Stats ();

add_action ('init',                  __NAMESPACE__ . '\on_init');
add_action ('admin_init',            __NAMESPACE__ . '\on_admin_init');
add_action ('wp_enqueue_scripts',    __NAMESPACE__ . '\on_enqueue_scripts');
add_action ('admin_enqueue_scripts', __NAMESPACE__ . '\on_admin_enqueue_scripts');
add_action ('admin_menu',            __NAMESPACE__ . '\on_admin_menu');
add_action ('admin_bar_menu',        __NAMESPACE__ . '\on_admin_bar_menu', 200);
add_filter ('query_vars',            __NAMESPACE__ . '\on_query_vars');

register_activation_hook   (__FILE__, __NAMESPACE__ . '\on_activation');
register_deactivation_hook (__FILE__, __NAMESPACE__ . '\on_deactivation');
register_uninstall_hook    (__FILE__, __NAMESPACE__ . '\on_uninstall');
