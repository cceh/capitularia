<?php
/**
 * Capitularia Collation global functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation_user;

/** @var string Wordpress ID of the dashboard page */
const DASHBOARD_PAGE_ID    = 'cap_collation_dashboard';

/** @var string AJAX security */
const NONCE_SPECIAL_STRING = 'cap_collation_nonce';

/** @var string AJAX security */
const NONCE_PARAM_NAME     = '_ajax_nonce';

/** @var string Where our Wordpress is in the filesystem */
const AFS_ROOT             = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';

/**
 * Add an AJAX action on both the admin and the front side.
 *
 * @return void
 */

function add_nopriv_action ($action)
{
    $action = 'on_cap_collation_user_' . $action;
    add_action ('wp_ajax_'        . $action, __NAMESPACE__ . '\\' . $action);
    add_action ('wp_ajax_nopriv_' . $action, __NAMESPACE__ . '\\' . $action);
}

/**
 * Enqueue the public pages scripts and styles
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    wp_register_style (
        'cap-collation-user-front',
        plugins_url ('css/front.css', __FILE__),
        array ('cap-jquery-ui-css')
    );
    wp_enqueue_style  ('cap-collation-user-front');

    wp_register_script (
        'cap-collation-user-front',
        plugins_url ('js/front.js', __FILE__),
        array ('cap-underscore', 'cap-vue', 'cap-jquery', 'jquery-ui-accordion', 'jquery-ui-sortable', 'cap-bs-dropdown-js')
    );
    wp_enqueue_script ('cap-collation-user-front');

    wp_localize_script (
        'cap-collation-user-front',
        'cap_collation_user_front_ajax_object',
        array (
            NONCE_PARAM_NAME => wp_create_nonce (NONCE_SPECIAL_STRING),
            'ajaxurl'        => admin_url ('admin-ajax.php')
        )
    );
}

/**
 * Register the translations.
 *
 * @return void
 */

function on_init ()
{
    load_plugin_textdomain ('cap-collation-user', false, basename (dirname ( __FILE__ )) . '/languages/');
}

function on_shortcode ($atts, $content = '')
{
    dashboard_page ();
}

/**
 * Sort strings with numbers
 *
 * Sort the numbers in the strings in a sensible way, eg. BK1, BK2, BK10.
 *
 * @param array $unsorted The return fron an SQL query
 *
 * @return string[] The sorted array of strings
 */

function sort_results ($unsorted)
{
    // Add a key to all objects in the array that allows for sensible
    // sorting of numeric substrings.
    foreach ($unsorted as $res) {
        $res->key = preg_replace_callback (
            '|\d+|',
            function ($match) {
                return 'zz' . strval (strlen ($match[0])) . $match[0];
            },
            $res->meta_value
        );
    }

    // Sort the array according to key.
    usort (
        $unsorted,
        function ($res1, $res2) {
            return strcoll ($res1->key, $res2->key);
        }
    );

    return array_map (
        function ($s) {
            return $s->meta_value;
        },
        $unsorted
    );
}

/**
 * Get a list of all capitulars
 *
 * @return string[] All capitulars
 */

function get_capitulars ()
{
    global $wpdb;

    $bk = "^(BK|Mordek)\.\d+(_|$)";

    $sql = $wpdb->prepare (
        'SELECT DISTINCT REGEXP_REPLACE (meta_value, \'_.*$\', \'\') as meta_value FROM wp_postmeta ' .
        'WHERE meta_key = \'corresp\' AND meta_value REGEXP \'%s\' ORDER BY meta_value;',
        $bk
    );

    return sort_results ($wpdb->get_results ($sql));
}

/**
 * Get a list of all corresps of a capitular
 *
 * @param string $bk The capitular
 *
 * @return string[] The corresps in the capitular
 */

function get_corresps ($bk)
{
    global $wpdb;

    $bk      = "{$bk}(_|$)";
    $exclude = "_inscriptio|_incipit|_explicit";
    if (get_current_user_id () != 0) {
        $exclude = "^$";
    }

    $sql = $wpdb->prepare (
        'SELECT DISTINCT meta_value FROM wp_postmeta ' .
        'WHERE meta_key = \'corresp\' AND meta_value REGEXP \'%s\' AND meta_value NOT REGEXP \'%s\' ORDER BY meta_value;',
        $bk, $exclude
    );

    return sort_results ($wpdb->get_results ($sql));
}

/**
 * Get all witnesses for a Corresp
 *
 * Take special care that we don't get duplicate ids !!! They fuck up the
 * collation layout.  Since the same file can be "mounted" at more than one
 * page, eg. below /mss/ and below /test/, we will get one random page_id
 * and slug among the valid ones.
 *
 * @param string  $corresp     The corresp eg. 'BK123_4'
 * @param boolean $later_hands Whether to synthetize manuscripts as edited by later hands
 * @param boolean $all         Include all if corresp is contained more than once,
 *                             else include first only.
 *
 * @return Witness[] The witnesses
 */

function get_witnesses ($corresp, $later_hands = false, $all_copies = false)
{
    global $wpdb;
    $items = array ();

    $sql = $wpdb->prepare (
        'SELECT DISTINCT meta_value AS xml_id ' .
        'FROM wp_postmeta ' .
        'WHERE meta_key = \'tei-xml-id\' AND post_id IN (' .
        '  SELECT post_id FROM wp_postmeta ' .
        '  WHERE meta_key = \'corresp\' AND meta_value = %s)',
        $corresp
    );

    foreach ($wpdb->get_results ($sql) as $row) {
        $post_id = $wpdb->get_var (
            $wpdb->prepare (
                'SELECT post_id FROM wp_postmeta ' .
                "WHERE meta_key = 'tei-xml-id' AND meta_value = %s ORDER BY post_id",
                $row->xml_id
            )
        );
        $filename = $wpdb->get_var (
            $wpdb->prepare (
                'SELECT meta_value FROM wp_postmeta ' .
                "WHERE meta_key = 'tei-filename' AND post_id = %d ORDER BY meta_value",
                $post_id
            )
        );
        if (!is_readable ($filename)) {
            // orphaned page without file
            continue;
        }
        $slug = get_page_uri ($post_id);

        $items[] = $witness = new Witness ($corresp, $row->xml_id, $filename, $slug);

        $do_hands = $later_hands && $witness->has_later_hands ();
        if ($do_hands) {
            $items[] = $witness->clone_witness (1, true);
        }

        $n_corresps = $witness->count_corresps ($corresp);
        if ($all_copies && $n_corresps > 1) {
            for ($n = 2; $n <= $n_corresps; $n++) {
                $items[] = $witness->clone_witness ($n, false);
                if ($do_hands) {
                    $items[] = $witness->clone_witness ($n, true);
                }
            }
        }
    }

    // sort Witnesses according to xml_id
    usort (
        $items,
        function ($item1, $item2) {
            return strcoll ($item1->sort_key, $item2->sort_key);
        }
    );

    return $items;
}


/**
 * Returns a path relative to base
 *
 * @param string $path The path
 * @param string $base The base
 *
 * @return string The path relative to base
 */

function cap_make_path_relative_to ($path, $base)
{
    $base = rtrim ($base, '/') . '/';
    if (strncmp ($path, $base, strlen ($base)) == 0) {
        return substr ($path, strlen ($base));
    }
    return $path;
}

/**
 * Sanitize a caption
 *
 * @param string $caption The caption to sanitize
 *
 * @return string The sanitized caption
 */

function cap_sanitize_caption ($caption)
{
    return sanitize_text_field ($caption);
}

/**
 * Sanitize a path
 *
 * @param string $path The path to sanitize
 *
 * @return string The sanitized path
 */

function cap_sanitize_path ($path)
{
    return rtrim (sanitize_text_field ($path), '/');
}

/**
 * Sanitize a space-separated list of paths
 *
 * @param string $path_list The space-separated list of paths to sanitize
 *
 * @return string The space-separated list of sanitized paths
 */

function cap_sanitize_path_list ($path_list)
{
    $paths = explode (' ', $path_list);
    $result = array ();
    foreach ($paths as $path) {
        $result[] = cap_sanitize_path ($path);
    }
    return implode (' ', $result);
}

/**
 * Sanitize a key
 *
 * @param string $key The key to sanitize
 *
 * @return string The sanitized key
 */

function cap_sanitize_key ($key)
{
    return trim (sanitize_key ($key));
}

/**
 * Sanitize a space-separated list of keys
 *
 * @param string $key_list The space-separated list of keys to sanitize
 *
 * @return string The space-separated list of sanitized keys
 */

function cap_sanitize_key_list ($key_list)
{
    $keys = explode (' ', $key_list);
    $result = array ();
    foreach ($keys as $key) {
        $result[] = cap_sanitize_key ($key);
    }
    return implode (' ', $result);
}

/**
 * Return localized message for 'on' or 'off'
 *
 * @param boolean $bool The status
 *
 * @return string The localized message
 */

function on_off ($bool)
{
    return $bool ? __ ('on', 'cap-collation-user') : __ ('off', 'cap-collation-user');
}

/**
 * The missing mb_trim function
 *
 * @param string $s The string to trim
 *
 * @return The trimmed string
 */

function mb_trim ($s)
{
    return preg_replace ('/^\s+/u', '', preg_replace ('/\s+$/u', '', $s));
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
