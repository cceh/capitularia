<?php
/**
 * Capitularia Library functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\lib;

/** AJAX security */
const NONCE_SPECIAL_STRING = 'cap_lib_nonce';

/** AJAX security */
const NONCE_PARAM_NAME     = '_ajax_nonce';

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
 * Sends a JSON response.
 *
 * @param string $cap The capability to query, eg. 'read_private_pages'.
 *
 * @return void
 */

function on_cap_lib_current_user_can ($cap)
{
    wp_send_json (
        array (
            'success' => true,
            'data'    => current_user_can ($cap),
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
        _x ('Save Changes', 'Button: Save Changes in setting page', DOMAIN)
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

function images_dir_path ($file = null)
{
    return WP_CONTENT_DIR . '/dist/images';
}

function languages_dir_path ($file = null)
{
    return WP_CONTENT_DIR . '/dist/languages';
}

function load_plugin_textdomain ($domain, $file)
{
    $locale = apply_filters ('plugin_locale', determine_locale(), $domain);
    $mofile = "/${domain}-${locale}.mo";
    $path   = languages_dir_path () . $mofile;
    // echo ("<pre>$path</pre>\n");
    return \load_textdomain ($domain, $path);
}

function wp_set_script_translations ($handle, $domain, $file)
{
    \wp_set_script_translations (
        $handle,
        $domain,
        languages_dir_path ($file)
    );
}

/**
 * Enqueue scripts or stylesheets from the webpack manifest.
 *
 * @param string        $key          The manifest key, eg. 'cap-collation-front.js'.
 * @param array<string> $dependencies The dependencies, eg. ['vendor.js'].
 *
 * @return void
 */

function enqueue_from_manifest ($key, $dependencies = array ())
{
    static $manifest = null;

    if ($manifest === null) {
        $manifest = WP_CONTENT_DIR . '/dist/manifest.json';
        $manifest = json_decode (file_get_contents ($manifest));
    }

    if (preg_match ('/\.css$/', $key)) {
        // the css may not have been extracted during development
        if (isset ($manifest->{$key})) {
            wp_enqueue_style ($key, $manifest->{$key}, $dependencies, $ver = null);
        }
    } else {
        wp_enqueue_script ($key, $manifest->{$key}, $dependencies, $ver = null);
    }
}

/**
 * Enqueue the frontpage script.
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    $handle = 'cap-lib-front.js';

    enqueue_from_manifest ($handle);

    $data = array (
        'api_url'            => get_opt ('api'),
        'ajaxurl'            => admin_url ('admin-ajax.php'),
        'read_private_pages' => current_user_can ('read_private_pages'),
    );

    if (is_admin ()) {
        $data[NONCE_PARAM_NAME] = wp_create_nonce (NONCE_SPECIAL_STRING);
    }

    wp_localize_script (
        $handle,
        'cap_lib',
        $data
    );
}

/**
 * Enqueue the admin page script.
 *
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    on_enqueue_scripts ();
}

/**
 * Check the AJAX nonce.  Die if invalid.
 *
 * @return void
 */

function check_ajax_referrer ()
{
    \check_ajax_referer (NONCE_SPECIAL_STRING, NONCE_PARAM_NAME);
}

/**
 * Initialize the plugin.
 *
 * @return void
 */

function on_init ()
{
    load_plugin_textdomain (DOMAIN, __FILE__);
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
        __ (NAME, DOMAIN) . ' ' . __ ('Settings', DOMAIN),
        __ (NAME, DOMAIN),
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
        '<a href="options-general.php?page=' . OPTIONS . '">' . __ ('Settings', DOMAIN) . '</a>'
    );
    return $links;
}
