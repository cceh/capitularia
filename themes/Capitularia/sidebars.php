<?php

/**
 * Capitularia Theme sidebars.php file
 *
 * Register the sidebars for various page types.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

$sidebars = array ();

/*
 * The sidebars on the front page.  On the front page they look more like
 * ribbons than sidebars.  We use them mainly as docking place for widgets.
 */

$sidebars[] = array (
    'frontpage-image',
    __ ('Frontpage Image', 'capitularia'),
    __ ('The big splash image on the front page. Takes one Capitularia Logo Widget.', 'capitularia')
);
$sidebars[] = array (
    'frontpage-teaser-1',
    __ ('Frontpage Teaser Bar 1', 'capitularia'),
    __ ('The top teaser bar on the front page. Normally takes 3 Capitularia Text Widgets.', 'capitularia')
);
$sidebars[] = array (
    'frontpage-teaser-2',
    __ ('Frontpage Teaser Bar 2', 'capitularia'),
    __ ('The bottom teaser bar on the front page. Normally takes 2 Capitularia Image Widgets.', 'capitularia')
);
$sidebars[] = array (
    'logobar',
    __ ('Logo Bar', 'capitularia'),
    __ ('The logo bar in the footer of every page. Takes one or more Capitularia Logo Widgets.', 'capitularia')
);

/*
 * The sidebars on posts and pages.  These are displayed on all posts and/or
 * pages.
 */

$sidebars[] = array (
    'post-sidebar',
    __ ('Post Sidebar', 'capitularia'),
    __ ('The sidebar on posts.', 'capitularia')
);
$sidebars[] = array (
    'page-sidebar',
    __ ('Page Sidebar', 'capitularia'),
    __ ('The sidebar on pages. Output below the more specialized page sidebars.', 'capitularia')
);
$sidebars[] = array (
    'sidebar',
    __ ('Post and Page Sidebar', 'capitularia'),
    __ ('The sidebar on posts and pages. Output below the other sidebars.', 'capitularia')
);

/*
 * The more specialized sidebars.  These are displayed on all pages that belong
 * to a section of the site, as expressed by the first path component of the
 * url.
 */

$sidebars[] = array (
    'capit',
    __ ('Capitularies Sidebar', 'capitularia'),
    __ ('The sidebar on /capit/ pages.', 'capitularia')
);
$sidebars[] = array (
    'mss',
    __ ('Manuscripts Sidebar', 'capitularia'),
    __ ('The sidebar on /mss/ pages.', 'capitularia')
);
$sidebars[] = array (
    'resources',
    __ ('Resources Sidebar', 'capitularia'),
    __ ('The sidebar on /resources/ pages.', 'capitularia')
);
$sidebars[] = array (
    'project',
    __ ('Project Sidebar', 'capitularia'),
    __ ('The sidebar on /project/ pages.', 'capitularia')
);
$sidebars[] = array (
    'tools',
    __ ('Tools Sidebar', 'capitularia'),
    __ ('The sidebar on /tools/ pages.', 'capitularia')
);
$sidebars[] = array (
    'internal',
    __ ('Internal Sidebar', 'capitularia'),
    __ ('The sidebar on /internal/ pages.', 'capitularia')
);
$sidebars[] = array (
    'capitular',
    __ ('Capitular Sidebar', 'capitularia'),
    __ ('The sidebar on single capitular pages', 'capitularia')
);
$sidebars[] = array (
    'transcription',
    __ ('Transcription Sidebar', 'capitularia'),
    __ ('The sidebar on transcription pages', 'capitularia')
);
$sidebars[] = array (
    'search',
    __ ('Search Page Sidebar', 'capitularia'),
    __ ('The sidebar on the search page', 'capitularia')
);

foreach ($sidebars as $a) {
    register_sidebar (
        array (
            'id' => $a[0],
            'name' => $a[1],
            'description' => $a[2],
        )
    );
};
