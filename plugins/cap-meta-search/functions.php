<?php
/**
 * Capitularia Meta Search.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

const NONCE_SPECIAL_STRING  = 'cap_meta_search_nonce';
const NONCE_PARAM_NAME      = '_ajax_nonce';
const AFS_ROOT              = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';
const OPTIONS_PAGE_ID       = 'cap_meta_search_options';

/**
 * Add current namespace
 *
 * @param string $function_name The class or function name without namespace
 *
 * @return string Name with namespace
 */

function ns ($function_name)
{
    return __NAMESPACE__ . '\\' . $function_name;
}

/**
 * Init the plugin
 *
 * @return void
 */

function init ()
{
    /** @var string The name of the plugin */
    global $plugin_name;
    $plugin_name = __ ('Capitularia Meta Search', 'capitularia');

    add_action ('init',                  ns ('on_init'));
    add_action ('wp_enqueue_scripts',    ns ('on_enqueue_scripts'));
    add_action ('admin_menu',            ns ('on_admin_menu'));
    add_action ('admin_bar_menu',        ns ('on_admin_bar_menu'), 200);
    add_action ('admin_enqueue_scripts', ns ('on_admin_enqueue_scripts'));
    add_filter ('the_content',           ns ('on_the_content'));
    add_filter ('get_the_excerpt',       ns ('on_get_the_excerpt'));
    add_action ('widgets_init',          ns ('on_widgets_init'));
}

function on_init ()
{
    add_action ('cap_xsl_transformed',              ns ('on_cap_xsl_transformed'),              10, 2);
    add_filter ('cap_meta_search_extract_metadata', ns ('on_cap_meta_search_extract_metadata'), 10, 3);
}

function on_widgets_init ()
{
    register_widget (ns ('Widget'));
}

function on_the_content ($content)
{
    $highlighter = new Highlighter ();
    return $highlighter->on_the_content ($content);
}

function on_get_the_excerpt ($content)
{
    $highlighter = new Highlighter ();
    return $highlighter->on_get_the_excerpt ($content);
}

function on_cap_xsl_transformed ($post_id, $xml_path)
{
    $extractor = new Extractor ();
    return $extractor->extract_meta ($post_id, $xml_path);
}

function on_cap_meta_search_extract_metadata ($errors, $post_id, $xml_path)
{
    $extractor = new Extractor ();
    return array_merge ($errors, $extractor->extract_meta ($post_id, $xml_path));
}

/**
 * Enqueue front side scripts and styles
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    wp_register_style  ('cap-meta-search-front', plugins_url ('css/front.css', __FILE__));
    wp_enqueue_style   ('cap-meta-search-front');
    wp_register_script (
        'cap-meta-search-front',
        plugins_url ('js/front.js', __FILE__),
        array ('cap-jquery', 'cap-jquery-ui')
    );
}

/*
 * Incipit administration page stuff
 */

/**
 * Enqueue admin side scripts and styles
 *
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    wp_register_style ('cap-meta-search-admin', plugins_url ('css/admin.css', __FILE__));
    wp_enqueue_style  ('cap-meta-search-admin');
}

/**
 * Add our settings page to the admin menu
 *
 * @return void
 */

function on_admin_menu ()
{
    /** @var Settings_Page|null The settings page */
    global $settings_page;
    $settings_page = new Settings_Page ();
    global $plugin_name;

    // adds a menu entry to the settings menu
    add_options_page (
        $plugin_name . ' Options',
        $plugin_name,
        'manage_options',
        'cap_meta_search_options',
        array ($settings_page, 'display')
    );
}

/**
 * Add a metadata extract button to the admin bar.
 *
 * Ask the xsl processor plugin if this page contains any xsl transformations.
 * If it does, add a button to extract metadata to the Wordpress admin bar.
 * This works because admin_bar_menu is one of the last hooks called and the
 * shortcode filter has already run.
 *
 * @param object $wp_admin_bar The Wordpress admin bar.
 *
 * @return void
 */

function on_admin_bar_menu ($wp_admin_bar)
{
    $xmlfiles = do_action ('cap_xsl_get_xmlfiles');

    if (count ($xmlfiles) > 0) {
        wp_enqueue_script  ('cap-meta-search-front');
        wp_localize_script (
            'cap-meta-search-front',
            'ajax_object',
            array (
                'ajax_nonce' => wp_create_nonce (NONCE_SPECIAL_STRING),
                'ajax_nonce_param_name' => NONCE_PARAM_NAME,
            )
        );

        $xmlfile = esc_attr ($xmlfiles[0]);
        $post_id = get_the_ID ();
        $args = array (
            'id'      => 'cap_meta_search_extract_metadata',
            'title'   => 'Metadata',
            'onclick' => "on_cap_meta_search_extract_metadata ($post_id, $xmlfile);",
            'meta'    => array ('class' => 'cap-meta-search-reload',
                                'title' => __ ('Extract metadata from TEI file.', 'capitularia')),
        );
        $wp_admin_bar->add_node ($args);
    }
}

/**
 * Things to do when a admin activates the plugin
 *
 * @return void
 */

function on_activation ()
{
}

/**
 * Things to do when a admin deactivates the plugin
 *
 * @return void
 */

function on_deactivation ()
{
}

/**
 * Things to do when a admin uninstalls the plugin
 *
 * @return void
 */

function on_uninstall ()
{
}
