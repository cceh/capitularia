<?php

/**
 * Capitularia Theme shortcodes.php file
 *
 * Define actions for various shortcodes.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/** The URL to the Capitularia image server. */
const IMAGE_SERVER_URL = 'http://images.cceh.uni-koeln.de/capitularia/';

/**
 * Add the logged_in shortcode.
 *
 * This shortcode outputs its content only to logged-in users.
 *
 * @param array  $dummy_atts (unused) The shortocde attributes.
 * @param string $content    The shortcode content.
 *
 * @return string The shortcode content if logged in else ''.
 */

function on_shortcode_logged_in ($dummy_atts, $content)
{
    if (is_user_logged_in ()) {
        return do_shortcode ($content);
    }
    return '';
}

/**
 * Add the logged_out shortcode.
 *
 * This shortcode outputs its content only to logged-out users.
 *
 * @param array  $dummy_atts (unused) The shortocde attributes.
 * @param string $content    The shortcode content.
 *
 * @return string The shortcode content if logged out else ''.
 */

function on_shortcode_logged_out ($dummy_atts, $content)
{
    if (!is_user_logged_in ()) {
        return do_shortcode ($content);
    }
    return '';
}

/**
 * Add the cap_image_server shortcode.
 *
 * This shortcode wraps the content in a link to the image server if the user is
 * logged in.
 *
 * @param array  $atts    The shortocde attributes.
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content wrapped in a link.
 */

function on_shortcode_cap_image_server ($atts, $content)
{
    if (is_user_logged_in () && isset ($atts['id']) && isset ($atts['n'])) {
        // build url out of attributes
        $id = $atts['id'];
        $n = $atts['n'];

        $matches = array ();
        if (preg_match ('/(\d+)(.+)/', $n, $matches)) {
            $num = str_pad ($matches[1], 4, '0', STR_PAD_LEFT);
            $num .= $matches[2];
            return '<a href="' . IMAGE_SERVER_URL . "$id/{$id}_{$num}.jpg\" target=\"_blank\">$content</a>";
        }
    }
    return $content;
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
 * Make sure the status of a page is in the cache.
 *
 * Some pages with long lists are checking the status of hundreds of other
 * pages.  Wordpress turns each status check into one SQL query.  This function
 * reads the statuses of all children of a parent page in one SQL query,
 * potentially saving hundreds of queries.
 *
 * @param string $path The path of the page without leading or trailing slashes.
 *
 * @return array  A dictionary of path => status which is guaranteed to
 *                contain the pages status if the page exists.
 */

function get_page_status_in_cache ($path)
{
    static $parent_cache = array ();
    static $cache = array ();

    global $wpdb;

    $path        = trim ($path, '/');
    $parent_path = get_parent_path ($path);

    if (!array_key_exists ($parent_path, $parent_cache)) {
        $parent_page = get_page_by_path ($parent_path);
        $parent_cache[$parent_path] = true;
        if ($parent_page) {
            $sql = $wpdb->prepare (
                "SELECT post_name, post_status FROM {$wpdb->posts} WHERE post_parent = %d",
                $parent_page->ID
            );
            foreach ($wpdb->get_results ($sql) as $row) {
                $cache[$parent_path . '/' . $row->post_name] = $row->post_status;
            }
        }
    }
    return $cache;
}

/**
 * Find out the status of a page.
 *
 * @param array $atts The shortocde attributes.  status = status, path = path of page
 *
 * @return True if page has that status.
 */

function if_status ($atts)
{
    $path   = trim ($atts['path'], '/');
    $status = $atts['status'];
    $cache  = get_page_status_in_cache ($path);

    if (array_key_exists ($path, $cache)) {
        return $cache[$path] == $status;
    }
    return $status == 'delete';
}

/**
 * Add the if_status shortcode.
 *
 * This shortcode outputs its content if the ms. has that status.
 *
 * @param array  $atts    The shortocde attributes.  status = status, path = path of page
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the ms. has that status else ''.
 */

function on_shortcode_if_status ($atts, $content)
{
    if (if_status ($atts)) {
        return do_shortcode ($content);
    }
    return '';
}

/**
 * Add the if_not_status shortcode.
 *
 * This shortcode outputs its content if the ms. doesn't have that status.
 *
 * @param array  $atts    The shortocde attributes.  status = status, path = path of page
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the ms. doesn't have that status else ''.
 */

function on_shortcode_if_not_status ($atts, $content)
{
    if (!if_status ($atts)) {
        return do_shortcode ($content);
    }
    return '';
}

/**
 * Check if the current user can see a page.
 *
 * Check if the user's permissions are sufficient to see a particular page.
 *
 * @param string $path The path of the page.
 *
 * @return True if the current user can see the page.
 */

function if_visible ($path)
{
    $path  = trim ($path, '/');
    $cache = get_page_status_in_cache ($path);

    if (array_key_exists ($path, $cache)) {
        return (
            $cache[$path] == 'publish' ||
            ($cache[$path] == 'private' && current_user_can ('read_private_pages'))
        );
    }
    return false; // page does not exist
}

/**
 * Add the if_visible shortcode.
 *
 * This shortcode outputs its content if the current user can see the page in path.
 *
 * @param array  $atts    The shortocde attributes.  path = path of page
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the user can see the page in path.
 */

function on_shortcode_if_visible ($atts, $content)
{
    if (if_visible ($atts['path'])) {
        return do_shortcode ($content);
    }
    return '';
}

/**
 * Add the if_not_visible shortcode.
 *
 * This shortcode outputs its content if the current user cannot see the page in path.
 *
 * @param array  $atts    The shortocde attributes.  path = path of page
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the current user cannot see the page in path.
 */

function on_shortcode_if_not_visible ($atts, $content)
{
    if (!if_visible ($atts['path'])) {
        return do_shortcode ($content);
    }
    return '';
}

/**
 * Add the if_transcribed shortcode.
 *
 * This shortcode outputs its content if the capitular was already transcribed
 * on that page (in that manuscript).
 *
 * @param array  $atts    The shortocde attributes.  path = path of page, bk = BK No.
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the capitular is transcribed, else nothing.
 */

function on_shortcode_if_transcribed ($atts, $content)
{
    global $wpdb;

    $page  = get_page_by_path (trim ($atts['path'], '/'));
    if ($page) {
        $re_bk = '^' . $atts['bk'];
        $sql = $wpdb->prepare (
            "SELECT post_id FROM {$wpdb->postmeta} " .
            "WHERE meta_key = 'milestone-capitulare' AND post_id = %d " .
            'AND meta_value REGEXP %s',
            $page->ID,
            $re_bk
        );
        if ($wpdb->get_results ($sql)) {
            return do_shortcode ($content);
        }
    }
    return '';
}

/**
 * Add the cite_as shortcode.
 *
 * This shortcode outputs a short description of how to cite the post.
 *
 * @param array  $dummy_atts    The shortocde attributes.
 * @param string $dummy_content The shortcode content. (empty)
 *
 * @return string A description of how to cite.
 */

function on_shortcode_cite_as ($dummy_atts, $dummy_content)
{
    $author = get_the_author ();
    $title  = get_the_title ();
    $url    = get_permalink ();
    $date   = strftime ('%x');

    $res = <<<EOF
       <div class="cite_as">
         <h5>[:de]Empfohlene Zitierweise[:en]How to cite[:]</h5>
         <div>
           <span class="author">$author</author>,
           <span class="title">$title</title>,
           [:de]in: Capitularia. Edition der fränkischen Herrschererlasse, bearb. von
           Karl Ubl und Mitarb., Köln 2014 ff.
           [:en]in: Capitularia. Edition of the Frankish Capitularies, ed. by
           Karl Ubl and collaborators, Cologne 2014 ff.
           [:]
           URL: $url ([:de]abgerufen am:[:en]accessed on:[:] $date)
         </div>
       </div>
EOF;
    return $res;
}
