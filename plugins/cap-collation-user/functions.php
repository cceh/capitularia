<?php
/**
 * Capitularia Collation global functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation_user;


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
 * Output a localized 'save changes' button
 *
 * @return
 */

function save_button () {
    submit_button (
        _x ('Save Changes', 'Button: Save Changes in setting page', LANG)
    );
}

/**
 * Add an AJAX action on both the admin and the front side.
 *
 * @return void
 */

function add_nopriv_action ($action)
{
    $action = 'on_cap_collation_user_' . $action;
    add_action ('wp_ajax_'        . $action, ns ($action));
    add_action ('wp_ajax_nopriv_' . $action, ns ($action));
}

/**
 * Get an option from Wordpress.
 *
 * @param string $name    The name of the option.
 * @param string $default The default value.
 *
 * @return string The option value
 */

function get_opt ($name, $default = '')
{
    static $options = null;

    if ($options === null) {
        $options = get_option (OPTIONS, array ());
    }
    return isset ($options[$name]) ? $options[$name] : $default;
}

/**
 * Register the translations.
 *
 * @return void
 */

function on_init ()
{
    load_plugin_textdomain (LANG, false, basename (dirname ( __FILE__ )) . '/languages/');
}


/**
 * Enqueue the front page scripts and styles
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
 * Initialize the settings page.
 *
 * First hook called on every admin page.
 *
 * @return void
 */

function on_admin_init ()
{
}

/**
 * Enqueue the admin page scripts and styles
 *
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    wp_register_style ('cap-collation-user-admin', plugins_url ('css/admin.css', __FILE__));
    wp_enqueue_style  ('cap-collation-user-admin');
}

/**
 * Add menu entry to the Wordpress admin menu.
 *
 * Add a menu entry for the settings (options) page to the Wordpress
 * settings menu.
 *
 * @return void
 */

function on_admin_menu ()
{
    add_options_page (
        __ ('Capitularia Collation Tool Settings', LANG),
        __ ('Capitularia Collation Tool', LANG),
        'manage_options',
        OPTIONS,
        array (new Settings_Page (), 'display')
    );
}

function on_shortcode ($atts, $content = '')
{
    // include vue.js, underscore.js, front.js only if needed
    wp_enqueue_script ('cap-collation-user-front');
    return dashboard_page ();
}

/**
 * Add a link to our settings page to the plugins admin dashboard.
 *
 * Adds hack value.
 *
 * @return array
 */

function on_plugin_action_links ($links)
{
	array_push (
		$links,
		'<a href="options-general.php?page=' . OPTIONS . '">' . __ ('Settings', LANG) . '</a>'
	);
	return $links;
}

/**
 * Get a list of the xml:ids of all published or privately published
 * manuscripts.
 *
 * If $status == 'publish' return all published manuscripts, if $status ==
 * 'private' return all privately published manuscripts.  These two sets are
 * distinct.
 *
 * @param string $status - Include all manuscripts with at least this
 *                         visibility.
 *
 * @return string[]
 */

function get_published_ids ($status)
{
    global $wpdb;

    $status = ($status === 'private') ? 'private' : 'publish';
    $parent_page = get_page_by_path ('mss');

    $sql = $wpdb->prepare (
        "SELECT pm.meta_value
         FROM {$wpdb->posts} p
           INNER JOIN {$wpdb->postmeta} pm ON p.ID = pm.post_id
         WHERE p.post_status = %s AND p.post_parent = %d AND pm.meta_key = 'tei-xml-id'",
        $status,
        $parent_page->ID
    );
    return $wpdb->get_col ($sql, 0);
}

/**
 * Make a key that sorts in a sensible way.
 *
 * Make a key that sorts the numbers in strings in a sensible way, eg. (BK1, BK2,
 * BK10), or (paris-bn-lat-4626, paris-bn-lat-18238).
 *
 * @param string s Any string
 *
 * @return string The key to sort with
 */

function make_sort_key ($s)
{
    return preg_replace_callback (
        '|\d+|',
        function ($match) {
            return 'zz' . strval (strlen ($match[0])) . $match[0];
        },
        $s
    );
}

/**
 * Make a json request to the configured API.
 *
 * @param string endpoint Endpoint relative to configured root.
 * @param array params    URL parameters to send.
 *
 * @return string The decoded JSON response.
 */

function api_json_request ($endpoint, $params = array ())
{
    $request = new \WP_Http ();
    error_log (get_opt ('api') . $endpoint);
    $result = $request->request (
        add_query_arg ($params, get_opt ('api') . $endpoint)
    );
    $body = $result['body'];
    if ($result['response'] !== 200) {
        // error_log ($body);
    }
    return json_decode ($body, true);
}

/**
 * Get a list of all capitulars
 *
 * @return string[] All capitulars
 */

function get_capitulars ()
{
    $params = array (
        'status' => current_user_can ('read_private_pages') ? 'private' : 'publish'
    );
    $res = [];
    foreach (api_json_request ('/data/capitularies.json/', $params) as $r) {
        $cap_id = $r['cap_id'];
        $transcriptions = $r['transcriptions'];
        if ($transcriptions > 1 && preg_match ('/^BK|^Mordek/', $cap_id)) {
            $res[] = $cap_id;
        }
    }
    return $res;
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
    $params = array (
        'status' => current_user_can ('read_private_pages') ? 'private' : 'publish'
    );
    $res = [];
    foreach (api_json_request ("/data/capitulary/$bk/chapters.json/", $params) as $r) {
        $chap = $r['chapter'];
        $res[] = $bk . ($chap ? "_{$chap}" : '');
    }
    return $res;
}

/**
 * Get all witnesses for a Corresp
 *
 * @param string  $corresp     The corresp eg. 'BK123_4'
 * @param boolean $later_hands Whether to synthetize witnesses as edited by later hands
 *
 * @return Witness[] The witnesses
 */

function get_witnesses ($corresp, $later_hands = false)
{
    $items = [];

    $params = array (
        'status' => current_user_can ('read_private_pages') ? 'private' : 'publish'
    );
    $result = api_json_request ("/data/corresp/$corresp/manuscripts.json/", $params);
    $n_copies_in_witness = [];

    foreach ($result as $r) {
        $xml_id = $r['ms_id'];
        $n_copies_in_witness[$xml_id] = ($n_copies_in_witness[$xml_id] ?? 0) + 1;

        $slug = "/mss/{$r['ms_id']}";
        if (\cceh\capitularia\theme\if_visible ($slug) || $xml_id = 'bk-textzeuge') {
            $n_copy = $n_copies_in_witness[$xml_id];
            $items[] = $witness = new Witness (
                $corresp,
                $xml_id,
                $r['filename'],
                $r['locus'],
                $n_copy
            );
            $do_hands = $later_hands && $r['hands'] != '';
            if ($do_hands) {
                $items[] = $witness->clone_witness ($n_copy, true);
            }
        }
    }

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
    return $bool ? __ ('on', LANG) : __ ('off', LANG);
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
