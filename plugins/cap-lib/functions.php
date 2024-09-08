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
    add_action ('wp_ajax_'        . $action, ns ('on_' . $action));
    add_action ('wp_ajax_nopriv_' . $action, ns ('on_' . $action));
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
 * Parse a query string in a standard-compliant way.
 *
 * PHP's parse_str function does not process query strings in the standard way, when it
 * comes to duplicate fields.  If multiple fields of the same name exist in a query
 * string, every other web processing language would read them into an array, but PHP
 * silently overwrites them.  This function handles them in a sane way.
 *
 * @param string $query A standard query string, eg. a=1&b=2&a=3
 *
 * @return array An associative array of name => value or name => [value1, value2]
 */
function sane_parse_str ($query) {
    $arr = array();

    foreach (explode('&', $query) as $pair) {
        if (strpos ($pair, '=') === false) {
            $pair .= '=';
        }
        list ($name, $value) = explode ('=', $pair, 2);
        $name = urldecode ($name);
        $value = urldecode ($value);

        if (isset ($arr[$name])) {
            # stick multiple values into an array
            if (is_array ($arr[$name])) {
                $arr[$name][] = $value;
            } else {
                $arr[$name] = array ($arr[$name], $value);
            }
        } else {
            $arr[$name] = $value;
        }
    }
    return $arr;
}

/**
 * AJAX tunnel to the API server
 *
 * Usage example: if you need to hide private posts for non-logged in users.
 *
 * This function is invoked through a POST call to Wordpress and executes a GET call on
 * the API.  The endpoint on the API side is given by the 'endpoint' parameter in the
 * POST multipart body.  The query string is given by the POST query string.  This
 * function adds a 'status' parameter to the query string but otherwise passes it on
 * unchanged.
 *
 * Call example:
 *
 *    const fd = new FormData ();
 *    fd.set ('action',   'cap_lib_query_api');
 *    fd.set ('endpoint', '/solr/select.json/');
 *    return axios.post (get_api_entrypoint (), fd, { 'params' : query });
 *
 *
 * @return void
 */

function on_cap_lib_query_api ()
{
    $params = sane_parse_str ($_SERVER['QUERY_STRING']);
    $endpoint = $_POST['endpoint'];

    error_log ("on_cap_lib_query_api $endpoint " . print_r ($params, true));

    wp_send_json (api_json_request($endpoint, $params, true));
}

 /**
 * AJAX endpoint to get the API server endpoint
 *
 * Answers with the configured URL of the API server.
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
 * Answers true if the user has a given capability.
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
 * @return string[] A list of xml:id
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
 * Use this function to query the python application server.
 *
 * Optionally adds a 'status' parameter that is 'private' if the user is allowed to see
 * private posts, else 'publish'.
 *
 * @param string  $endpoint   Endpoint relative to configured root.
 * @param array   $params     URL parameters to send.
 * @param boolean $add_status If true adds a status param to the query.
 *
 * @return string The decoded JSON response.
 */

function api_json_request ($endpoint, $params = array (), $add_status = false)
{
    $request = new \WP_Http ();
    $url = get_opt ('api') . $endpoint;
    // error_log ($url);
    if ($add_status) {
        $params['status'] = current_user_can ('read_private_pages') ? 'private' : 'publish';
    }
    if ($params) {
        $query = http_build_query ($params);
        // Remove array indices, that is turn a[0]=42&a[1]=69 into a=42&a=69. PHP is too
        // dumb to understand the standard format as input, so you have to add [] as a
        // hack workaround if you need multiple params with the same name.  Everybody
        // else understands the standard format so we have to take them out again before
        // passing it on.
        $query = preg_replace ('/%5B\d*%5D/simU', '', $query);
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
    //    error_log (print_r($body, true));
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
 * @return string url1 and url2 joined by exactly one slash.
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
 * Return the public uri of a manifest item.
 *
 * Return the public uri where manifest items distributed by the Capitularia
 * theme an plugins are found.
 *
 * @param string $key The manifest key.
 *
 * @return string The uri
 */

function get_manifest_uri ($key)
{
    static $manifest = null;

    if ($manifest === null) {
        $manifest = WP_CONTENT_DIR . '/dist/manifest.json';
        $manifest = json_decode (file_get_contents ($manifest));
    }
    return isset ($manifest->{$key}) ? $manifest->{$key} : null;
}


/**
 * Return the public uri of the images directory.
 *
 * Return the public uri where the stock images distributed by the Capitularia
 * theme an plugins are found.
 *
 * @return string The uri
 */

function images_dir_uri ()
{
    $uri = content_url ();
    return "$uri/dist/images";
}

/**
 * Return the local path to the images directory.
 *
 * Return the local path where the stock images distributed by the Capitularia
 * theme an plugins are found.
 *
 * @return string The path
 */

function images_dir_path ()
{
    return WP_CONTENT_DIR . '/dist/images';
}

/**
 * Get the url of an image from a manifest key.
 *
 * @param string $key The image key in manifest.
 *
 * @return string The public url of the image.
 */

function get_image_uri ($key)
{
    return get_manifest_uri ("images/$key");
}

/**
 * Return the local path the languages directory.
 *
 * Return the local path where the language files distributed by the Capitularia
 * theme an plugins are found.
 *
 * @return string The path
 */

function languages_dir_path ()
{
    return WP_CONTENT_DIR . '/dist/languages';
}

/**
 * Load the PHP translations for a text domain.
 *
 * Load a .mo file into the text domain $domain.
 *
 * @param string $domain The text domain.
 *
 * @return bool True on success, false on failure.
 */

function load_textdomain ($domain)
{
    $locale = apply_filters ('plugin_locale', determine_locale (), $domain);
    $mo_file = "/{$domain}-{$locale}.mo";
    $mo_path = languages_dir_path () . $mo_file;
    // echo ("<pre>$mo_path</pre>\n");
    return \load_textdomain ($domain, $mo_path);
}

/**
 * Load the Javascript translations for a text domain.
 *
 * Load a .json file into the Javascript text domain $domain.
 *
 * @param string $key    The manifest key used to register the script.
 * @param string $domain The text domain.
 *
 * @return bool True on success, false on failure.
 */

function wp_set_script_translations ($key, $domain)
{
    \wp_set_script_translations (
        $key,
        $domain,
        languages_dir_path ()
    );
}

/**
 * Enqueue scripts or stylesheets from the webpack manifest.
 *
 * @param string        $key          The manifest key, eg. 'cap-collation-front.js'.
 * @param array<string> $dependencies The dependencies, eg. ['vendor.js'].
 *
 * @return bool True on success.
 */

function enqueue_from_manifest ($key, $dependencies = array ())
{
    $uri = get_manifest_uri ($key);
    if ($uri === null) {
        return false;
    }

    if (preg_match ('/\.css$/', $key)) {
        // note: the css may not exist (eg. not have been extracted during
        // development)
        wp_enqueue_style ($key, $uri, $dependencies, $ver = null);
    } else {
        wp_enqueue_script ($key, $uri, $dependencies, $ver = null);
    }
    return true;
}

/**
 * Enqueue the frontpage script.
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    $handle = 'cap-lib-front.js';

    wp_enqueue_script('wp-util');
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
    load_textdomain (DOMAIN);
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
