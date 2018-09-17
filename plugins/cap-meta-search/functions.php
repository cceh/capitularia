<?php
/**
 * Capitularia Meta Search.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

const NONCE_SPECIAL_STRING  = 'cap_meta_search_nonce';
const NONCE_PARAM_NAME      = '_ajax_nonce';
const OPTIONS_PAGE_ID       = 'cap_meta_search_options';
/** Default path to the project directory on AFS. */
const AFS_ROOT              = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';

const GEO_INFO = array (
    'viaf'     => 'http://viaf.org/viaf/',
    'geonames' => 'http://www.geonames.org/',
    'gnd'      => 'http://d-nb.info/gnd/',
);

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

    add_action ('cap_xsl_transformed',              ns ('on_cap_xsl_transformed'),              10, 2);
    add_filter ('cap_meta_search_extract_metadata', ns ('on_cap_meta_search_extract_metadata'), 10, 3);
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
        $options = get_option ('cap_meta_search_options', array ());
    }
    return $options[$name] ? $options[$name] : $default;
}

/**
 * Sanitize a text filed.
 *
 * @param string $text The text to sanitize.
 *
 * @return The sanitized text.
 */

function sanitize ($text)
{
    return empty ($text) ? '' : strip_tags ($text);
}

/**
 * Register the widget with Wordpress.
 *
 * @return void
 */

function on_widgets_init ()
{
    register_widget (ns ('Widget'));
}

/**
 * Highlight the found strings on the page once the user has chose a search
 * result from the search results page.
 *
 * @param string $content The content to highlight.
 *
 * @return string The highlighted content.
 */

function on_the_content ($content)
{
    $highlighter = new Highlighter ();
    return $highlighter->on_the_content ($content);
}

/**
 * Highlight the found strings in the excerpt on the search results page.
 *
 * @param string $content The content to highlight.
 *
 * @return string The highlighted content.
 */

function on_get_the_excerpt ($content)
{
    $highlighter = new Highlighter ();
    return $highlighter->on_get_the_excerpt ($content);
}

/**
 * Hook to automatically extract metadata every time a TEI file gets
 * transformed.
 *
 * @param int    $post_id  The post id.
 * @param string $xml_path The path of the TEI file.
 *
 * @return array Array of messages.
 */

function on_cap_xsl_transformed ($post_id, $xml_path)
{
    $extractor = new Extractor ();
    return $extractor->extract_meta ($post_id, $xml_path);
}

/**
 * Hook to manually extract metadata from TEI files.
 *
 * @param array  $errors   Array of messages.
 * @param int    $post_id  The post id.
 * @param string $xml_path The path of the TEI file.
 *
 * @return array Augmented array of messages.
 */

function on_cap_meta_search_extract_metadata ($errors, $post_id, $xml_path)
{
    $extractor = new Extractor ();
    return array_merge ($errors, $extractor->extract_meta ($post_id, $xml_path));
}

/**
 * Add our custom HTTP query vars
 *
 * @param array $vars The stock query vars
 *
 * @return array The stock and custom query vars
 */

function on_query_vars ($vars)
{
    $vars[] = 'capit';
    $vars[] = 'place';
    $vars[] = 'notbefore';
    $vars[] = 'notafter';
    $vars[] = 'places';
    return $vars;
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

    wp_register_style  (
        'jstree-style-default',
        get_template_directory_uri () . '/node_modules/jstree/dist/themes/default/style.css'
    );
    wp_enqueue_style   ('jstree-style-default');

    wp_register_script (
        'jstree',
        get_template_directory_uri () . '/node_modules/jstree/dist/jstree.js',
        array ('cap-jquery')
    );
    wp_enqueue_script  ('jstree');

    wp_register_script (
        'cap-meta-search-front',
        plugins_url ('js/front.js', __FILE__),
        array ('cap-jquery')
    );
    wp_enqueue_script  ('cap-meta-search-front');

    wp_localize_script (
        'cap-meta-search-front',
        'cap_meta_search_front_ajax_object',
        array (
            'ajaxurl' => admin_url ('admin-ajax.php')
        )
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

    wp_register_script (
        'cap-meta-search-admin',
        plugins_url ('js/admin.js', __FILE__),
        array ('jquery')
    );
    wp_enqueue_script  ('cap-meta-search-admin');
    wp_localize_script (
        'cap-meta-search-admin',
        'cap_meta_search_admin_ajax_object',
        array (
            NONCE_PARAM_NAME => wp_create_nonce (NONCE_SPECIAL_STRING),
        )
    );
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
 * Get the children or descendants of a region.
 *
 * We use this function when we build the database query.  If the user selects a
 * region she also wants all places inside that region.
 *
 * @function get_children
 *
 * @param {array}   $places    - The places array.
 * @param {string}  $parent_id - The id of the parent region.
 * @param {boolean} $recurse   - Get children or decendants.
 *
 * @returns {array} associative array of id => place
 */

function get_children ($places, $parent_id, $recurse = false) {
    $result = array ();
    foreach ($places as $pl) {
        if (in_array ($parent_id, $pl->parents)) {
            $result[$pl->id] = $pl;
            // recurse
            if ($recurse) {
                $result += get_children ($places, $pl->id, $recurse);
            }
        }
    }
    return $result;
}

/**
 * Get the children of a node in jstree fromat.
 *
 * jstree loads the tree 'on demand' using ajax.  When the user opens a node,
 * jstree requests only the children of that node but it also needs to know if
 * those children have children of their own to display the 'open' icon.
 *
 * @function get_children_jstree
 *
 * @param {array}  $places    - The places array.
 * @param {string} $parent_id - The id of the parent node.
 *
 * @returns {array} Array of places in (alternative) jstree format.
 */

function get_children_jstree ($places, $parent_id)
{
    $result = array ();
    $p_id = explode ('.', $parent_id);
    $p_id = $p_id[count ($p_id) - 1];
    foreach (get_children ($places, $p_id) as $key => $pl) {
        $pl = clone $pl;
        // build a unique id
        $pl->data->id = $pl->id;
        $pl->id = $parent_id . '.' . $pl->id;
        // change children into a boolean
        $pl->children = count ($pl->children) > 0;
        unset ($pl->descendants);
        $result[] = $pl;
    }
    return $result;
}

/**
 * Load the places structure from the database.
 *
 * @function get_places
 *
 * @returns {array} Array of places objects.
 */

function get_places ()
{
    return json_decode (get_option ('cap_meta_search_places_json'));
}

/**
 * Get the list of names from a list of places.
 *
 * @function get_place_names
 *
 * @param {array}    places    - The places data.
 * @param {string[]} place_ids - Array of place ids.
 *
 * @returns {string[]} Array of place names.
 */

function get_place_names ($places, $place_ids)
{
    $result = array ();
    foreach ($places as $pl) {
        if (in_array ($pl->id, $place_ids)) {
            $result[] = $pl->text;
        }
    }
    return $result;
}

/**
 * Get all authorities urls from a list of places including descendants.
 *
 * @function get_place_authorities
 *
 * @param {array}    places    - The places data.
 * @param {string[]} place_ids - Array of place ids.
 *
 * @returns {string[]} Array of urls.
 */

function get_place_authorities ($places, $place_ids)
{
    // get all descendant places
    $ids = array ();
    foreach ($places as $pl) {
        if (in_array ($pl->id, $place_ids)) {
            $ids += get_children ($places, $pl->id, true);
        }
    }
    $ids = array_merge ($place_ids, array_keys ($ids));

    // get the authorities of all descendants
    $result = array ();
    foreach ($places as $pl) {
        if (in_array ($pl->id, $ids)) {
            foreach (GEO_INFO as $key => $url) {
                if (property_exists ($pl->data, $key)) {
                    $result[$url . $pl->data->{$key}] = true;
                }
            }
        }
    }
    return array_keys ($result);
}

/**
 * AJAX hook to load the jstree gadget.
 *
 * The jstree gadget calls this to retrieve the places info one level at a time.
 *
 * @return void
 */

function on_ajax_cap_places ()
{
    header ('Content-type: application/json');
    $parent_id = sanitize_text_field ($_POST['id']);
    echo (json_encode (get_children_jstree (get_places (), $parent_id)));
    die ();
}

/**
 * AJAX hook to reload the places file.
 *
 * We convert the XML places file into JSON and store the resulting blob in the
 * database as an option.  To further speed up things we precompute the children
 * and descendants of each node.
 *
 * @return void
 */

function on_ajax_cap_reload_places ()
{
    check_ajax_referer (NONCE_SPECIAL_STRING, NONCE_PARAM_NAME);
    if (!current_user_can ('manage_options')) {
        wp_send_json_error (
            array ('message' => __ ('You have no permission to manage options.', 'capitularia'))
        );
    }

    // read places file
    $path = get_opt ('places_path');
    libxml_use_internal_errors (true);
    $xml = simplexml_load_file ($path);
    if ($xml === false) {
        wp_send_json_error (
            array ('message' => sprintf (__ ('Could not load XML file %s.', 'capitularia'), $path))
        );
    }

    $xml->registerXPathNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
    $xml->registerXPathNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');

    $places = array ();   // the output
    $ids = array ();      // dictionary of known ids
    $errors = array ();   // error messages
    $messages = array (); // non-error messages

    foreach ($xml->xpath ("//tei:place[@xml:id]") as $place) {
        $pl = new \stdClass ();
        $pl->data = new \stdClass ();
        $pl->id = (string) $place->attributes ('xml', true)->id;
        $pl->parents = array ();
        $ids[$pl->id] = $pl;

        $tmp = array ();
        foreach ($place->xpath ("tei:*[@xml:lang and not (@corresp)]") as $name) {
            $lang = strtolower ($name->attributes ('xml', true)->lang);
            if ($lang == 'ger') {
                $lang = 'de';
            }
            if ($lang == 'eng') {
                $lang = 'en';
            }
            $tmp[] = "[:{$lang}]{$name}";
        }
        $pl->text = implode ('', $tmp) . '[:]';

        foreach ($place->xpath ("tei:linkGrp[@type='geo']/tei:link[@type]") as $link) {
            $type = strtolower ($link->attributes ()->type);
            $pl->data->{$type} = (string) $link->attributes ()->target;
        }
        foreach ($place->xpath ("tei:country[@corresp]|tei:region[@corresp]") as $corresp) {
            foreach (explode (' ', $corresp->attributes ()->corresp) as $ref) {
                $ref = ltrim ($ref, '#');
                if (array_key_exists ($ref, $ids)) {
                    $pl->parents[] = $ref;
                } else {
                    $errors[] = "<p>Error: Place with id of '{$parent}' not found.</p>";
                }
            }
        }
        if (count ($pl->parents) == 0) { // a root node
            $pl->parents[] = '#';
        }
        $places[] = $pl;
    }

    // compute children and descendants
    foreach ($places as $pl) {
        $pl->children    = array_keys (get_children ($places, $pl->id, false));
        $pl->descendants = array_keys (get_children ($places, $pl->id, true));
    }

    // store in database
    update_option (
        'cap_meta_search_places_json',
        json_encode ($places, JSON_PRETTY_PRINT + JSON_UNESCAPED_UNICODE)
    );

    // give feedbak to the user
    $places_cnt = count ($places);
    $messages[] = __ ("<p>{$places_cnt} places processed.</p>", 'capitularia');

    wp_send_json (
        array ('success' => count ($errors) == 0,
               'data'    => array ('message' => implode ("\n", array_merge ($errors, $messages))),
               // 'data'    => array ('message' => json_encode ($places, JSON_PRETTY_PRINT + JSON_UNESCAPED_UNICODE)),
        ), 200
    );
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
