<?php

/**
 * Capitularia Theme functions-include.php file
 *
 * This file only declares symbols (classes, functions, constants) in accordance
 * with PSR-2.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

use cceh\capitularia\lib;

const MAGIC_LOGIN            = '#cap_login_menu#';

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
 * Get the first path component of the slug.
 *
 * If a page has a slug of: "top/sub/current" this function returns "top".
 *
 * @param integer $page_id Wordpress Page ID.
 *
 * @return string The slug root.
 */

function get_slug_root ($page_id)
{
    $path = parse_url (get_page_uri ($page_id), PHP_URL_PATH);
    $a = explode ('/', $path);
    if ($a) {
        return $a[0];
    }
    return '';
}

/**
 * Get the path of the parent page.
 *
 * @param string $path The path of the page.
 *
 * @return string The path of the parent page.
 */

function get_parent_path ($path)
{
    $a = explode ('/', trim ($path, '/'));
    return implode ('/', array_slice ($a, 0, -1));
}

/**
 * Echo a name="value" pair.
 *
 * @param string $name  The name of the attribute.
 * @param string $value The value of the attribute.
 *
 * @return void
 */

function echo_attribute ($name, $value)
{
    // Echoes: name="value"
    $value = esc_attr ($value);
    echo (" $name=\"$value\"");
}

/**
 * Returns an opening <a> containing a permalink to the current page.
 *
 * It is the responsibilty of the caller to close the <a> tag.
 *
 * @return string An opening <a> tag.
 */

function get_permalink_a ()
{
    return (
        '<a href="' .
        get_the_permalink () .
        '" title="' .
        esc_attr (sprintf (__ ('Permalink to %s', 'capitularia'), the_title_attribute ('echo=0'))) .
        '" rel="bookmark">'
    );
}

/**
 * Echo the tag to start the main section.
 *
 * @param string $class CSS classes to add to the tag.
 *
 * @return void
 */

function get_main_start ($class = '')
{
    echo ("<main id='main' class='cap-row main $class'>\n");
}

/**
 * Echo the tag to end the main section.
 *
 * @return void
 */

function get_main_end ()
{
    echo ("</main>\n");
}

/**
 * Echo the tag to start the sideabr section.
 *
 * @return void
 */

function get_sidebar_start ()
{
    echo ("  <nav class='cap-right-col-push sidebar-col'>\n");
    echo ("    <ul>\n");
}

/**
 * Echo the tag to end the sidebar section.
 *
 * @return void
 */

function get_sidebar_end ()
{
    echo ("    </ul>\n");
    echo ("  </nav>\n");
}

/**
 * Echo the tag to start the content section.
 *
 * @return void
 */

function get_content_start ()
{
    echo ("  <div class='cap-left-col-pull content-col'>\n");
}

/**
 * Echo the tag to end the content section.
 *
 * @return void
 */

function get_content_end ()
{
    echo ("  </div>\n");
}

/**
 * Enqueue scripts and CSS
 *
 * Add JS and CSS the wordpress way.
 *
 * N.B. We use our own copy of jquery and bootstrap on the front.
 *
 * @return void
 */

function on_enqueue_scripts ()
{
    lib\enqueue_from_manifest ('cap-runtime.js');
    lib\enqueue_from_manifest ('cap-vendor.js', ['cap-runtime.js']);
    lib\enqueue_from_manifest ('cap-theme-front.js', ['cap-vendor.js']);

    lib\enqueue_from_manifest ('cap-theme-front.css');

    wp_enqueue_style ('dashicons');
}

/**
 * Enqueue admin scripts and CSS
 *
 * Add JS and CSS the wordpress way.
 *
 * N.B. We use wordpress' copy of jquery and jquery-ui on the admin pages, and
 * no bootstrap because it breaks too many things.
 *
 * @return void
 */

function on_admin_enqueue_scripts ()
{
    lib\enqueue_from_manifest ('cap-runtime.js');
    lib\enqueue_from_manifest ('cap-theme-admin.js', ['cap-runtime.js', 'cap-lib-front.js', 'jquery']);

    lib\enqueue_from_manifest ('cap-theme-admin.css');
}

/**
 * Customize <head> <title>
 *
 * Customize the title displayed in the browser window caption and used if you
 * bookmark the page.
 *
 * if root: "Capitularia | Edition der fränkischen Herrschererlasse"
 * else:    "[Name of page] | Capitularia"
 *
 * @param string $title Default title text for current view.
 * @param string $sep   Optional separator.
 *
 * @return string  The customized title.
 */

function on_wp_title ($title, $sep)
{
    if (is_feed ()) {
        return $title;
    }

    global $page, $paged;

    // Add the blog name
    $blog_name = get_bloginfo ('name', 'display');
    $blog_description = get_bloginfo ('description', 'display');

    if (is_home () || is_front_page ()) {
        return "$blog_name $sep $blog_description";
    }
    $title .= $blog_name;

    // Add a page number if necessary:
    if (($paged >= 2 || $page >= 2) && ! is_404 ()) {
        $title .= " $sep " . sprintf (__ ('Page %s', 'capitularia'), max ($paged, $page));
    }

    return $title;
}

/**
 * Mark wiki post titles with "Wiki:"
 *
 * @param string $title   The post title
 * @param int    $post_ID The post ID
 *
 * @return string The edited post title
 */

function on_the_title ($title, $post_ID)
{
    if (get_post_type ($post_ID) === 'wp-help') {
        $title = str_replace ('Private: ', '', $title);
        $title = __ ('Wiki: ', 'capitularia') . $title;
    };
    return $title;
}

/**
 * Add a <body> class.
 *
 * Add a class to the HTML <body> tag depending on which section of the website
 * we are in.  Eg.: adds class="cap-slug-mss" in the /mss/ section of the site.
 *
 * @param array $classes Old classes added by Wordpress or other plugins.
 *
 * @return array New classes
 */

function on_body_class ($classes)
{
    if (is_page ()) {
        $classes[] = esc_attr ('cap-slug-' . get_slug_root (get_the_ID ()));
    }
    return $classes;
}

/**
 * Initialize the theme.
 *
 * @return void
 */

function on_init ()
{
    /**
     * Add excerpt support to pages.
     *
     * Most of our site is pages and not posts, so we need excerpts there.  An
     * excerpt is a quick summary that may be displayed in places where the full
     * content is not appropriate.
     */

    add_post_type_support ('page', 'excerpt');

    /**
     * Register our 2 horizontal navigation menus.
     *
     * The first one is above the logo, the second one below the logo.
     */

    register_nav_menus (
        array (
            'navtop'    => __ ('Top horizontal navigation bar', 'capitularia'),
            'navbottom' => __ ('Bottom horizontal navigation bar', 'capitularia')
        )
    );

    /**
     * Register a custom taxonomy for sidebar selection.
     *
     * Using this taxonomy you can add arbitrary sidebars to arbitrary pages.
     */

    register_taxonomy (
        'cap-sidebar',
        'page',
        array (
            'label' => __ ('Capitularia Sidebar', 'capitularia'),
            'public' => false,
            'show_ui' => true,
            'rewrite' => false,
            'hierarchical' => false,
        )
    );
    register_taxonomy_for_object_type ('cap-sidebar', 'page');
}


/**
 * Add private/draft/future/pending pages to page parent dropdown.
 *
 * Only public pages are eligible for parenting in vanilla Wordpress.  We want
 * other pages also.
 *
 * @param array $dropdown_args The previous args.
 * @param int   $dummy_post    (unused) The post ID.
 *
 * @return array The new args.
 */

function on_dropdown_pages_args ($dropdown_args, $dummy_post = null) // phpcs:ignore
{
    $dropdown_args['post_status'] = array ('publish', 'draft', 'pending', 'future', 'private');
    return $dropdown_args;
}


/**
 * Translate the archive widget month names
 *
 * @param string $month_year Link containing untranslated MMMMMMM YYYY
 *
 * @return string Link containing translated MMMMMMM YYYY
 */

function translate_month_year ($month_year)
{
    return preg_replace_callback (
        '/^(.*?)(\w+)( \d{4}.*)$/',
        function ($matches) {
            return $matches[1] . __ ($matches[2], 'capitularia') . $matches[3];
        },
        $month_year
    );
}

/**
 * Canonicalize the innumerable different ways the editors write a BK or Mordek no.
 *
 * Accepts (not exhaustive list of examples found in the wild):
 *
 * BK.42
 * BK.042
 * BK_42
 * BK_042
 * bk-nr-42
 * bk-nr-042
 * Mordek.27
 * Mordek_27
 * mordek-nr-27
 * ldf/all-of-the-above
 *
 * Returns:
 *
 * bk-nr-042
 * mordek-nr-27
 *
 * @param string $corresp eg. "BK.42a" or "Mordek_15"
 *
 * @return string The canonical BK no.
 */

function fix_bk_nr ($corresp)
{
    $corresp = basename ($corresp);
    if (preg_match ('/^bk[-._nr]+(\d+)(\w?)$/i', $corresp, $matches)) {
        $corresp = 'bk-nr-' . str_pad ($matches[1], 3, '0', STR_PAD_LEFT) . $matches[2];
    }
    if (preg_match ('/^mordek[-nr._]+(\d+)(\w?)$/i', $corresp, $matches)) {
        $corresp = 'mordek-nr-' . str_pad ($matches[1], 2, '0', STR_PAD_LEFT) . $matches[2];
    }
    return $corresp;
}


/**
 * Get the Capitular page url corresponding to a BK or Mordek No.
 *
 * This function figures out which subdirectory the Capitular page is in,
 * eg. pre814/ or ldf/ or post840/ ...
 *
 * @param string $corresp eg. "BK.42a" or "Mordek_15"
 *
 * @return string The url to the page, eg. "http://.../capit/pre814/bk-nr-042a" or null
 */

function bk_to_permalink ($corresp)
{
    static $cache = array ();

    global $wpdb;

    $corresp = fix_bk_nr ($corresp);

    if (array_key_exists ($corresp, $cache)) {
        return $cache[$corresp];
    }

    $sql = $wpdb->prepare (
        "SELECT ID FROM {$wpdb->posts} WHERE post_name = %s",
        $corresp
    );
    foreach ($wpdb->get_results ($sql) as $row) {
        $url = get_permalink ($row->ID);
        $cache[$corresp] = $url;
        return $url;
    }
    return null;
}

/**
 * Get the manuscript page url corresponding to a manuscript siglum.
 *
 * Note: If the siglum is not unique, a random manuscript with that siglum will be
 * returned.
 *
 * @param string $siglum eg. "Ba2"
 *
 * @return string The path to the page, eg. "/mss/bamberg-sb-can-7/" or null
 */

 function siglum_to_permalink ($siglum)
 {
     $params = array (
         'siglum' => $siglum
     );
     foreach (lib\api_json_request ('/data/manuscripts.json/', $params) as $r) {
         return '/mss/'. $r['ms_id'];
     }
     return null;
 }


/**
 * Redirector for Capitulary pages
 *
 * Eg. redirects from
 *
 *     /capit/BK.42a    => /capit/<subdir>/bk-nr-042a/
 *     /capit/Mordek_27 => /capit/<subdir>/mordek-nr-27/
 *     /bk/42a          => /capit/<subdir>/bk-nr-042a/
 *     /mordek/27       => /capit/<subdir>/mordek-nr-27/
 *
 * We cannot just use mod_rewrite because we don't know which subdirectory the
 * capitulary page is in.
 *
 * @param boolean      $do_parse         (unused) Whether or not to parse the request.
 * @param \WP          $wp               (unused) The current WordPress environment instance.
 * @param array|string $extra_query_vars (unused) Extra passed query variables.
 *
 * @link https://developer.wordpress.org/reference/hooks/do_parse_request/
 *
 * @return boolean The $do_parse parameter unchanged.
 */

function on_do_parse_request ($do_parse, $wp, $extra_query_vars) // phpcs:ignore
{
    $request = isset ($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : '';
    // error_log ('Request was: ' . $request);

    if (preg_match ('!^/bk/(BK[._])?(\d+\w?)$!i', $request, $matches)) {
        $url = bk_to_permalink ('BK.' . $matches[2]);
        if ($url) {
            wp_redirect ($url);
            exit ();
        }
    }
    if (preg_match ('!^/mordek/(Mordek[._])?(\d+\w?)$!i', $request, $matches)) {
        $url = bk_to_permalink ('Mordek.' . $matches[2]);
        if ($url) {
            wp_redirect ($url);
            exit ();
        }
    }
    if (preg_match ('!^/capit/(BK|Mordek)(.*)$!i', $request, $matches)) {
        $url = bk_to_permalink ($matches[1] . $matches[2]);
        if ($url) {
            wp_redirect ($url);
            exit ();
        }
    }
    if (preg_match ('!^/siglum/(.*)$!i', $request, $matches)) {
        $url = siglum_to_permalink ($matches[1]);
        if ($url) {
            wp_redirect ($url);
            exit ();
        }
    }
    return $do_parse;
}

/**
 * Add dynamic url to login menu.  Remove text from twitter and fb logos.
 *
 * @param array    $atts  The old HTML attributes.
 * @param WP_Post  $item  The current menu item.
 * @param stdClass $args  An object of wp_nav_menu() arguments.
 * @param int      $depth Depth of menu item. Used for padding.
 *
 * @return array  The updated HTML attributes.
 */

function on_nav_menu_link_attributes ($atts, $item, $args, $depth) // phpcs:ignore
{
    if (isset ($item->url)) {
        if (strcmp ($item->url, MAGIC_LOGIN) === 0) {
            $atts['href']  = wp_login_url (get_permalink ());
            $atts['class'] = 'logo-login';
        }
        if (strpos ($item->url, 'twitter.com') !== false) {
            $atts['class'] = 'logo-social logo-twitter';
            $item->title   = '';
        }
        if (strpos ($item->url, 'facebook.com') !== false) {
            $atts['class'] = 'logo-social logo-facebook';
            $item->title   = '';
        }
    }
    return $atts;
}

/**
 * Allow upload of SVG files.
 *
 * @param array $mimes The old list of allowed mime types.
 *
 * @return array The updated list of allowed mime types.
 */

function on_upload_mimes ($mimes)
{
    $mimes['svg'] = 'image/svg+xml';
    return $mimes;
}

/**
 * Redirect the user to the current page after login
 *
 * @param string               $redirect_to           The redirect destination URL.
 * @param string               $requested_redirect_to The requested redirect destination URL
 *                                                    passed as a parameter.
 * @param \WP_User | \WP_Error $user                  WP_User object if login was successful,
 *                                                    WP_Error object otherwise.
 *
 * @return string The target URL of the redirection.
 *
 * @link https://developer.wordpress.org/reference/hooks/login_redirect/
 */

function on_login_redirect ($redirect_to, $requested_redirect_to, $user) // phpcs:ignore
{
    return $requested_redirect_to;
}

/**
 * HACK! make the "WP Help" wiki plugin's post type searchable
 *
 * @param string        $post_type        The post type
 * @param \WP_Post_Type $post_type_object The post object
 *
 * @return void
 */

function on_registered_post_type ($post_type, $post_type_object)
{
    if ($post_type == 'wp-help') {
        $post_type_object->publicly_queryable  = true;
        $post_type_object->exclude_from_search = false;
    };
}

/**
 * Search only wiki pages if search string contains 'wiki:'
 *
 * @param \WP_Query $query The query
 *
 * @return void
 */

function on_pre_get_posts ($query)
{
    if (!is_admin () && $query->is_main_query ()) {
        if ($query->is_search) {
            $s = $query->get ('s');
            if (stristr ($s, 'wiki:') !== false) {
                $query->set ('post_type', 'wp-help');
                $query->set ('s', str_replace ('wiki:', '', $s));
            }
        }
    }
}

/**
 * REST endpoint to get user information from auth cookie
 *
 * @param \WP_REST_Request $request The request
 *
 * @return void
 */

function cap_rest_user_info (\WP_REST_Request $request)
{
    $cookie = $request['auth_cookie'];
    if ($cookie === false) {
        foreach ($_COOKIE as $name => $value) {
            if (strncmp ($name, 'wordpress_logged_in_', 20) === 0) {
                // error_log ($name);
                // error_log ($value);
                $cookie = $value;
                break;
            }
        }
    }
    if ($cookie !== false) {
        $user_id = wp_validate_auth_cookie ($cookie, 'logged_in');
        if ($user_id !== false) {
            $data = get_userdata ($user_id);
            if (is_object ($data)) {
                wp_send_json_success ($data);
            }
        }
    }
    wp_send_json_error ();
}

/**
 * Remove widget-block-editor
 *
 * @return void
 */

function on_after_setup_theme ()
{
    remove_theme_support ('widgets-block-editor');
}
