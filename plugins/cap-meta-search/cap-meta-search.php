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
 * Text Domain: capitularia
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'class-meta-search-widget.php';
require_once 'class-meta-search.php';

$i = Meta_Search::get_instance ();

$class_name = 'cceh\capitularia\meta_search\Meta_Search';
register_activation_hook   (__FILE__, array ($class_name, 'on_activation'));
register_deactivation_hook (__FILE__, array ($class_name, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($class_name, 'on_uninstall'));

add_action (
    'widgets_init',
    function () {
        register_widget ('cceh\capitularia\meta_search\Widget');
    }
);
