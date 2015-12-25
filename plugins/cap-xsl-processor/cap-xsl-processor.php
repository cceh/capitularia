<?php

/**
 * Capitularia XSL processor plugin.
 *
 * @package Capitularia
 *
 * Plugin Name: Capitularia XSL Processor
 * Plugin URI:
 * Description: An xsl processor that caches its output in the wordpress database.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: capitularia
 */

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'class-stats.php';
require_once 'class-xsl-processor.php';

$i = \cceh\capitularia\xsl_processor\XSL_Processor::get_instance ();

register_activation_hook   (__FILE__, array ($i, 'on_activation'));
register_deactivation_hook (__FILE__, array ($i, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($i, 'on_uninstall'));
