<?php

/**
 * TEI Metadata Extraction and Search widget.
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
 *
 * Provides the search box on manuscript pages.  This search lets you filter by
 * metadata such as capitularies contained, dates, and locations.
 *
 * Also extracts the relevant metadata from TEI files and stores it in the
 * Wordpress database.  Retrieves geographic information from GIS providers.
 */

namespace cceh\capitularia\meta_search;

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

/** @var string The name of the plugin. */
const NAME                  = 'Capitularia Meta Search';

/** @var string Text Domain */
const LANG                 = 'cap-meta-search';

/** @var string Wordpress ID of the settings (option) page */
const OPTIONS              = 'cap_meta_search_options';

/** @var string AJAX security */
const NONCE_SPECIAL_STRING = 'cap_meta_search_nonce';

/** @var string AJAX security */
const NONCE_PARAM_NAME     = '_ajax_nonce';

/** @var string Default path to the project directory on AFS. */
const AFS_ROOT             = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';

/** @var Object URLs of GIS ontology systems */
const GEO_INFO = array (
    'viaf'     => 'http://viaf.org/viaf/',
    'geonames' => 'http://www.geonames.org/',
    'gnd'      => 'http://d-nb.info/gnd/',
);

/** @var string API Endpoint @ geonames.org */
const GEONAMES_API_ENDPOINT = 'http://api.geonames.org/hierarchyJSON';

/** @var string Our username @ geonames.org */
const GEONAMES_USER         = 'highlander'; // FIXME get an institutional user


require_once 'functions.php';
require_once 'class-extractor.php';
require_once 'class-highlighter.php';
require_once 'class-settings-page.php';
require_once 'class-meta-search-widget.php';

add_action ('init',                  ns ('on_init'));
add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));
add_action ('admin_menu',            ns ('on_admin_menu'));
add_action ('admin_enqueue_scripts', ns ('on_admin_enqueue_scripts'));
add_action ('widgets_init',          ns ('on_widgets_init'));

add_action ('wp_ajax_nopriv_on_cap_places',     ns ('on_ajax_cap_places'));
add_action ('wp_ajax_on_cap_places',            ns ('on_ajax_cap_places'));
add_action ('wp_ajax_on_cap_reload_places',     ns ('on_ajax_cap_reload_places'));

add_filter ('the_content',                      ns ('on_the_content'));
add_filter ('get_the_excerpt',                  ns ('on_get_the_excerpt'));
add_filter ('query_vars',                       ns ('on_query_vars'));
add_filter ('plugin_action_links_cap-meta-search/cap-meta-search.php',
            ns ('on_plugin_action_links'));

add_action ('cap_xsl_transformed',              ns ('on_cap_xsl_transformed'),              10, 2);
add_filter ('cap_meta_search_extract_metadata', ns ('on_cap_meta_search_extract_metadata'), 10, 3);


register_activation_hook   (__FILE__, ns ('on_activation'));
register_deactivation_hook (__FILE__, ns ('on_deactivation'));
register_uninstall_hook    (__FILE__, ns ('on_uninstall'));


// for side effect only: to get it in the .po file
__ ('Capitularia Meta Search');
__ ('Extracts metadata from TEI files and searches it.');
