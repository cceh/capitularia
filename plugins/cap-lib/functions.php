<?php
/**
 * Capitularia Library functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\lib;

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
 * Add an AJAX action on both the admin and the front side.
 *
 * @param string $action The ajax wp_ajax_$action
 *
 * @return void
 */

function add_nopriv_action ($action)
{
    $action = 'on_cap_lib_' . $action;
    add_action ('wp_ajax_'        . $action, ns ($action));
    add_action ('wp_ajax_nopriv_' . $action, ns ($action));
}

/**
 * Make a key that sorts in a sensible way.
 *
 * Make a key that sorts the numbers in strings in a sensible way, eg. (BK1, BK2,
 * BK10), or (paris-bn-lat-4626, paris-bn-lat-18238).
 *
 * @param string $s Any string
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
 * AJAX endpoint to get the API server endpoint
 *
 * Send JSON response with the URL to talk directly to the API server.
 *
 * @return void
 */

function on_cap_lib_get_api_endpoint ()
{
    wp_send_json (
        array (
            'success' => true,
            'url'     => get_opt ('api'),
        )
    );
}

/**
 * AJAX endpoint to query user capabilities
 *
 * Send JSON response.
 *
 * @return void
 */

function on_cap_lib_current_user_can ($what)
{
    wp_send_json (
        array (
            'success' => true,
            'data'    => current_user_can ($what),
        )
    );
}

/**
 * AJAX endpoint get list of visible xml:ids
 *
 * Get a list of the xml:ids of all published or privately published files.  The
 * API server calls this function to update its database.
 *
 * Output: JSON list of visible xml:ids
 *
 * @return void
 */

function on_cap_lib_get_published_ids ()
{
    $status = $_REQUEST['status'] ?? 'publish';

    wp_send_json (
        array (
            'success'   => true,
            'pubstatus' => $status,
            'ids'       => get_published_ids ($status),
        )
    );
}

/**
 * Get a list of the xml:ids of all published or privately published
 * manuscripts.
 *
 * If $status == 'publish' return all published manuscripts, if $status ==
 * 'private' return all privately published manuscripts.  These two sets are
 * distinct.
 *
 * @param string $status - Include all manuscripts with this visibility.
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
 * Make a json request to the configured API.
 *
 * @param string $endpoint Endpoint relative to configured root.
 * @param array  $params   URL parameters to send.
 *
 * @return string The decoded JSON response.
 */

function api_json_request ($endpoint, $params = array ())
{
    $request = new \WP_Http ();
    error_log (get_opt ('api') . $endpoint);
    $url = get_opt ('api') . $endpoint;
    if ($params) {
        $query = http_build_query ($params);
        // Remove array indices, that is turn a[0]=42&a[1]=69 into a[]=42&a[]=69
        $query = preg_replace ('/%5B[0-9]+%5D/simU', '%5B%5D', $query);
        $url .= '?' . $query;
    }
    $result = $request->request (
        $url,
        array (
            'timeout' => 120
        )
    );
    if ($result instanceof \WP_Error) {
        return array ('status' => 500);
    }
    $body = $result['body'];
    // if ($result['response'] !== 200) {
    //    error_log ($body);
    // }
    return json_decode ($body, true);
}

/**
 * Output a localized 'save changes' button
 *
 * @return void
 */

function save_button ()
{
    submit_button (
        _x ('Save Changes', 'Button: Save Changes in setting page', LANG)
    );
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
 * Join two paths.  The second one may be absolute or relative.
 *
 * @param string $url1 The first path.
 * @param string $url2 The second path.
 *
 * @return url1 and url2 joined by exactly one slash.
 */

function urljoin ($url1, $url2)
{
    if (empty ($url2)) {
        return $url1;
    }
    if ($url2[0] === '/') {
        return $url2;
    }
    return rtrim ($url1, '/') . '/' . $url2;
}

/**
 * Enqueue the frontpage scripts and styles
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    // wp_register_style ('cap-lib-front', plugins_url ('css/front.css', __FILE__));
    // wp_enqueue_style  ('cap-lib-front');

    wp_register_script (
        'cap-lib-front',
        plugins_url ('js/front.js', __FILE__),
        array ()
    );

    wp_localize_script (
        'cap-lib-front',
        'cap_lib',
        array (
            'api_url' => get_opt ('api'),
            'ajaxurl' => admin_url ('admin-ajax.php')
        )
    );
}

/**
 * Initialize the plugin.
 *
 * @return void
 */

function on_init ()
{
    load_plugin_textdomain (LANG, false, basename (dirname (__FILE__)) . '/languages/');
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
    wp_register_style ('cap-lib-admin', plugins_url ('css/admin.css', __FILE__));
    wp_enqueue_style  ('cap-lib-admin');
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
        __ (NAME, LANG) . ' ' . __ ('Settings', LANG),
        __ (NAME, LANG),
        'manage_options',
        OPTIONS,
        array (new Settings_Page (), 'display')
    );
}

/**
 * Add a link to our settings page to the plugins admin dashboard.
 *
 * Adds hack value.
 *
 * @param array $links The old links
 *
 * @return array The augmented links
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
 * Things to do when an admin activates the plugin
 *
 * @return void
 */

function on_activation ()
{
}

/**
 * Things to do when an admin deactivates the plugin
 *
 * @return void
 */

function on_deactivation ()
{
}

/**
 * Things to do when an admin uninstalls the plugin
 *
 * @return void
 */

function on_uninstall ()
{
}
