<?php
/*
Plugin Name: Capitularia Meta Search
Plugin URI:
Description: Extracts metadata from TEI files and searches it.
Version:     0.1.0
Author:      Marcello Perathoner
Author URI:
License:     GPLv2 or later
Text Domain: cap-meta-search
*/

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'class-meta-search-widget.php';
require_once 'class-meta-search.php';

$i = \cceh\capitularia\meta_search\Meta_Search::getInstance ();

register_activation_hook   (__FILE__, array ($i, 'on_activation'));
register_deactivation_hook (__FILE__, array ($i, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($i, 'on_uninstall'));

// $w = \cceh\capitularia\meta_search\Widget::getInstance ();

add_action (
    'widgets_init',
    function () {
        register_widget ('cceh\capitularia\meta_search\Widget');
    }
);

$plugin_dir = basename (dirname (__FILE__));
load_plugin_textdomain ('cap-meta-search', null, "$plugin_dir/i18n");
