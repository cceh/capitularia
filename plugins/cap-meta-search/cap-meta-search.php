<?php
/*
Plugin Name: Capitularia Meta Search
Plugin URI:
Description: An xsl processor that caches its output in the wordpress database.
Version:     0.1.0
Author:      Marcello Perathoner
Author URI:
License:     GPLv2 or later
Text Domain: cap-xsl
*/

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'class-meta-search.php';

$i = \cceh\capitularia\meta_search\Meta_Search::getInstance ();

register_activation_hook   (__FILE__, array ($i, 'on_activation'));
register_deactivation_hook (__FILE__, array ($i, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($i, 'on_uninstall'));
