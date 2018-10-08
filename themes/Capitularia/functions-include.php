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
 * Echo a src="img" pair.
 *
 * The src will be pointing to the theme images directory.
 *
 * @param string $img The image filename.
 *
 * @return void
 */

function echo_theme_image ($img)
{
    echo ('src="' . get_bloginfo ('template_directory') . "/img/$img\"");
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

function get_main_start ($class = '')
{
    echo ("<main id='main' class='cap-row main $class'>\n");
}

function get_main_end ()
{
    echo ("</main>\n");
}

function get_sidebar_start ()
{
    echo ("  <nav class='cap-right-col-push sidebar-col'>\n");
    echo ("    <ul>\n");
}

function get_sidebar_end ()
{
    echo ("    </ul>\n");
    echo ("  </nav>\n");
}

function get_content_start ()
{
    echo ("  <div class='cap-left-col-pull content-col'>\n");
}

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
    $template_dir = get_template_directory_uri ();

    wp_enqueue_style ('cap-front',       "$template_dir/css/front.css");
    wp_enqueue_style ('dashicons');

    wp_enqueue_script ('cap-jquery',    "$template_dir/node_modules/jquery/dist/jquery.js");
    wp_enqueue_script ('cap-custom-js', "$template_dir/js/custom.js", array ('cap-jquery'));
    wp_enqueue_script ('cap-piwik',     "$template_dir/js/piwik-wrapper.js");

    $bs_dep = array ('cap-jquery', 'cap-popper-js', 'cap-bs-util-js');

    wp_enqueue_script ('cap-popper-js',      "$template_dir/node_modules/popper.js/dist/umd/popper.js");
    wp_enqueue_script ('cap-bs-util-js',     "$template_dir/node_modules/bootstrap/js/dist/util.js");
    wp_enqueue_script ('cap-bs-tooltip-js',  "$template_dir/node_modules/bootstrap/js/dist/tooltip.js",  $bs_dep);
    wp_enqueue_script ('cap-bs-collapse-js', "$template_dir/node_modules/bootstrap/js/dist/collapse.js", $bs_dep);
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
    $template_dir = get_template_directory_uri ();

    wp_enqueue_style ('cap-admin',   "$template_dir/css/admin.css");

    /*
     * Register jquery-ui CSS for the use of plugins
     *
     * Quandary: Wordpress (as of 4.3) comes with a version of jquery and jquery-ui
     * but lacks the jquery-ui css styles.  If we provide just our own jquery-ui css
     * styles, we may get out of sync with the jquery-ui javascript provided by
     * Wordpress.  But if we provide the whole jquery-ui of our own we may get out
     * of sync with Wordpress' assumptions of the actual jquery-ui version.
     *
     * Currently we provide our own jquery-ui CSS file.
     */

    wp_register_style ('cap-jquery-ui-css', "$template_dir/css/jquery-ui.css");
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
 * @function on_the_title
 *
 * @param string title - The post title
 * @param int post_ID  - The post ID
 *
 * @return The edited post title
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
 * Initialize the plugin.
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
 * @param int   $dummy_post    (unused) The post ID .
 *
 * @return array The new args.
 */

function on_dropdown_pages_args ($dropdown_args, $dummy_post = null)
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

/*
 * Redirect user to current page after login
 */

function on_login_redirect ($redirect_to, $requested_redirect_to, $user)
{
    return $requested_redirect_to;
}

/*
 * Redirect from /bk/BK.42a to /capit/<subdir>/bk-nr-042a/
 *
 * We cannot just use mod_rewrite because we don't know which subdirectory the
 * capitular page is in.
 */

function on_do_parse_request ($do_parse, $dummy_wp, $dummy_extra_query_vars)
{
    $request = isset ($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : '';
    // error_log ('Request was: ' . $request);

    if (preg_match ('!^/bk/(BK[._])?(\d+\w?)$!', $request, $matches)) {
        $url = bk_to_permalink ('BK.' . $matches[2]);
        if ($url) {
            wp_redirect ($url);
            exit ();
        }
    }
    if (preg_match ('!^/mordek/(Mordek[._])?(\d+\w?)$!', $request, $matches)) {
        $url = bk_to_permalink ('Mordek.' . $matches[2]);
        if ($url) {
            wp_redirect ($url);
            exit ();
        }
    }
    return $do_parse;
}

/**
 * HACK! make the "WP Help" wiki plugin's post type searchable
 *
 * @function on_registered_post_type
 *
 * @param string       $post_type        - The post type
 * @param WP_Post_Type $post_type_object - The post object
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
 * @function on_pre_get_posts
 *
 * @param WP_Query $query - The query
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
