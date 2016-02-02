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

require_once 'functions.php';
require_once 'class-collation.php';
require_once 'class-dashboard-page.php';
require_once 'class-witness.php';
require_once 'class-collatex.php';

$collation = new Collation ();

register_activation_hook   (__FILE__, __NAMESPACE__ . '\on_activation');
register_deactivation_hook (__FILE__, __NAMESPACE__ . '\on_deactivation');
register_uninstall_hook    (__FILE__, __NAMESPACE__ . '\on_uninstall');
