<?php

/**
 * Capitularia Theme functions.php file
 *
 * This file executes only logic with side-effects in accordance with PSR-2.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

require 'functions-include.php';
require 'sidebars.php';
require 'shortcodes.php';
require 'widgets/cap-widgets.php';


/*
 * Load the site translation files.
 *
 * Translation files are needed to show the site in different languages.  They
 * contain translations for all strings in the PHP sources.  Translation files
 * have the extension .mo and are found the themes/Capitularia/languages/
 * directory, one file per supported language.
 *
 * N.B. Translation of content (user generated and XSL-transformed) that is
 * stored in the Wordpress database is done in a completely different way by a
 * plugin.
 */

load_theme_textdomain ('capitularia', get_template_directory () . '/languages/');

/*
 * These strings are defined somewhere inside Wordpress.  Because we want to
 * translate them, we must include them in the translation source file (.pot).
 * These are dummy calls to the translation function just to make the xgettext
 * program collect the month names into the translation source file.
 */

if (0 === 1) { // phpcs complains on false
    __ ('January',   'capitularia');
    __ ('February',  'capitularia');
    __ ('March',     'capitularia');
    __ ('April',     'capitularia');
    __ ('May',       'capitularia');
    __ ('June',      'capitularia');
    __ ('July',      'capitularia');
    __ ('August',    'capitularia');
    __ ('September', 'capitularia');
    __ ('October',   'capitularia');
    __ ('November',  'capitularia');
    __ ('December',  'capitularia');
}

/*
 * Wordpress Actions
 */

add_action ('init',                                'cceh\capitularia\theme\on_init');
add_action ('wp_enqueue_scripts',                  'cceh\capitularia\theme\on_enqueue_scripts');
add_action ('admin_enqueue_scripts',               'cceh\capitularia\theme\on_admin_enqueue_scripts');
add_action ('registered_post_type',                ns ('on_registered_post_type'), 10, 2);
add_action ('pre_get_posts',                       ns ('on_pre_get_posts'));

/*
 * Wordpress Filters
 */

/* redirects the user to the current page after she logged in */
add_filter ('login_redirect',                      'cceh\capitularia\theme\on_login_redirect', 10, 3);

/* our custom page titles */
add_filter ('wp_title',                            'cceh\capitularia\theme\on_wp_title', 10, 2);

/* change post title for wiki posts */
add_filter ('the_title',                           ns ('on_the_title'), 10, 2);

/* our custom <body> classes */
add_filter ('body_class',                          'cceh\capitularia\theme\on_body_class');

/* add private pages to the 'parent page' dropdown menu on the admin pages */
add_filter ('page_attributes_dropdown_pages_args', 'cceh\capitularia\theme\on_dropdown_pages_args');
add_filter ('quick_edit_dropdown_pages_args',      'cceh\capitularia\theme\on_dropdown_pages_args');

/* translate month names in archives links */
add_filter ('get_archives_link',                   'cceh\capitularia\theme\translate_month_year');

/* add an url redirector for urls like /bk/42 */
add_filter ('do_parse_request',                    'cceh\capitularia\theme\on_do_parse_request', 10, 3);

/*
 * The shortcodes provided by our theme.  For the implementation see:
 * shortcodes.php.
 */

/* if the user is logged in */
add_shortcode ('logged_in',        'cceh\capitularia\theme\on_shortcode_logged_in');
add_shortcode ('logged_out',       'cceh\capitularia\theme\on_shortcode_logged_out');

/* if the status of a page is public, private or delete */
add_shortcode ('if_status',        'cceh\capitularia\theme\on_shortcode_if_status');
add_shortcode ('if_not_status',    'cceh\capitularia\theme\on_shortcode_if_not_status');

/* if the page is visible to the user */
add_shortcode ('if_visible',       'cceh\capitularia\theme\on_shortcode_if_visible');
add_shortcode ('if_not_visible',   'cceh\capitularia\theme\on_shortcode_if_not_visible');

/* if a capitular in a manuscript has already been transcribed */
add_shortcode ('if_transcribed',   'cceh\capitularia\theme\on_shortcode_if_transcribed');

/* build a link to the image server */
add_shortcode ('cap_image_server', 'cceh\capitularia\theme\on_shortcode_cap_image_server');

/* output the current date */
add_shortcode ('current_date',     'cceh\capitularia\theme\on_shortcode_current_date');

/* output a short description of how to cite the article */
add_shortcode ('cite_as',          'cceh\capitularia\theme\on_shortcode_cite_as');

/* output a table of the tei:change elements in all mss. */
add_shortcode ('cap_changes',      'cceh\capitularia\theme\on_shortcode_cap_changes');

/* output a table of downloadable TEI files */
add_shortcode ('cap_downloads',    'cceh\capitularia\theme\on_shortcode_cap_downloads');
