<?php
/**
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
 * TEI Metadata Search plugin.
 *
 * The *Meta Search plugin* offers metadata-aware and fuzzy fulltext search.  A
 * search form widget is part of the plugin.  This search box is used on all
 * manuscript pages.
 *
 * The meta search uses a different approach than the built-in Wordpress search.
 * This search is done on the VM server and the unit of search is the capitulary
 * chapter.  It lets you filter by metadata such as capitularies contained,
 * dates, and place of origin.
 *
 * The plugin also provides a snippet and highlighter class for the built-in
 * Wordpress search, that displays snippets of text around the found terms
 * instead of the page excerpt.  The highlighter may be used on any Wordpress
 * page.
 *
 * See: :mod:`data_server`, :ref:`metadata search overview<meta-search-overview>`.
 *
 * @package Capitularia_Meta_Search
 */

namespace cceh\capitularia\meta_search;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** The name of the plugin. */
const NAME                 = 'Capitularia Meta Search';

/** The text domain of the plugin. */
const LANG                 = 'cap-meta-search';

/** AJAX security */
const NONCE_SPECIAL_STRING = 'cap_meta_search_nonce';

/** AJAX security */
const NONCE_PARAM_NAME     = '_ajax_nonce';

/** The URL query parameter to request word highlighting. */
const HIGHLIGHT            = 'cap_highlight_words';

require_once 'functions.php';
require_once 'class-highlighter.php';
require_once 'class-meta-search.php';
require_once 'class-meta-search-widget.php';

add_action ('init',                  ns ('on_init'));
add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));
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
        add_filter ('the_content',      array ($cap_meta_search, 'on_the_content'), 99);
    }
}

// for side effect only: to get it in the .po file
__ ('Capitularia Meta Search');
__ ('Perform metadata-aware searches for and in TEI files.');
