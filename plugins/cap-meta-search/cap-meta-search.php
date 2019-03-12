<?php

/**
 * TEI metadata extraction and search widget.
 *
 * Plugin Name: Capitularia Meta Search
 * Plugin URI:
 * Description: Extracts metadata from TEI files and searches it.
 * Version:     0.1.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-meta-search
 * Domain Path: /languages
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'functions.php';
require_once 'class-extractor.php';
require_once 'class-highlighter.php';
require_once 'class-settings-page.php';
require_once 'class-meta-search-widget.php';

init ();

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));
