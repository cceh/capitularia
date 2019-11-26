<?php

/**
 * TEI Metadata Search widget.
 *
 * Plugin Name: Capitularia Meta Search
 * Plugin URI:
 * Description: Perform metadata-aware searches for and in TEI files.
 * Version:     0.2.0
 * Author:      Marcello Perathoner
 * Author URI:
 * License:     GPLv2 or later
 * Text Domain: cap-meta-search
 * Domain Path: /languages
 *
 * @package Capitularia
 *
 * Implements the metadata search box on manuscript pages.
 *
 * The meta search uses a different approach than the built-in Wordpress search.
 * This search is done on the VM server and the unit of search is the capitulary
 * chapter.  It lets you filter by metadata such as capitularies contained,
 * dates, and place of origin.
 *
 * The plugin also provides a snippet and highlighter class for the built-in
 * Wordpress search, that displays snippets of text around the found terms
 * instead of the page excerpt.
 */

namespace cceh\capitularia\meta_search;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** @var string The name of the plugin. */
const NAME                  = 'Capitularia Meta Search';

/** @var string Text Domain */
const LANG                 = 'cap-meta-search';

/** @var string AJAX security */
const NONCE_SPECIAL_STRING = 'cap_meta_search_nonce';

/** @var string AJAX security */
const NONCE_PARAM_NAME     = '_ajax_nonce';

/** @var string The highlight parameter */
const HIGHLIGHT            = 'cap_highlight_words';

require_once 'functions.php';
require_once 'class-highlighter.php';
require_once 'class-meta-search.php';
require_once 'class-meta-search-widget.php';

add_action ('init',                  ns ('on_init'));
add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));
add_action ('admin_enqueue_scripts', ns ('on_admin_enqueue_scripts'));
add_action ('widgets_init',          ns ('on_widgets_init'));

if (!is_admin ()) {
    add_filter ('query_vars',                    ns ('on_query_vars'));
    add_filter ('cap_meta_search_the_permalink', ns ('on_cap_meta_search_the_permalink'));

    $cap_meta_search = null;

    if (is_meta_search ()) {
        $cap_meta_search = new MetaSearch ();
        add_action ('pre_get_posts',    array ($cap_meta_search, 'on_pre_get_posts'));
        add_filter ('get_the_excerpt',  array ($cap_meta_search, 'on_get_the_excerpt'));
        add_filter ('get_search_query', array ($cap_meta_search, 'on_get_search_query'));
    } elseif (is_highlight ()) {
        $cap_meta_search = new Highlighter ();
        add_filter ('get_the_excerpt',  array ($cap_meta_search, 'on_get_the_excerpt'));
        add_filter ('the_content',      array ($cap_meta_search, 'on_the_content'));
    }
}

register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));


// for side effect only: to get it in the .po file
__ ('Capitularia Meta Search');
__ ('Perform metadata-aware searches for and in TEI files.');
