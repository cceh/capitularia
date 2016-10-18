<?php
/**
 * Capitularia Page Generator global functions.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/**
 * Get ID of the parent page of a section
 *
 * Returns the ID of the parent page of a section.
 *
 * @param string $section_id The section id
 *
 * @return mixed The parent page ID or false
 */

function cap_get_parent_id ($section_id)
{
    global $config;

    $page = get_page_by_path ($config->get_opt ($section_id, 'slug_path'));
    return $page ? $page->ID : false;
}

/**
 * Get the current status of a page.
 *
 * @param int $page_id The Wordpress page id
 *
 * @return string The current status
 */

function cap_get_status ($page_id)
{
    if ($page_id !== false) {
        return get_post_status ($page_id);
    }
    return 'delete';
}

/**
 * Get the current status of a section's parent page.
 *
 * We need to check this so as not to make public children of private pages.
 *
 * @param string $section_id The section id
 *
 * @return string The current status
 */

function cap_get_section_page_status ($section_id)
{
    $page_id = cap_get_parent_id ($section_id);
    if ($page_id !== false) {
        return get_post_status ($page_id);
    }
    return 'delete';
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

/*
 * Shortcodes
 */

/**
 * Find out the status of a page.
 *
 * @param array $atts The shortocde attributes.  status = status, path = path of page
 *
 * @return True if page has that status.
 */

function if_status_slow ($atts)
{
    static $cache = array ();

    global $wpdb;

    $status = $atts['status'];
    $path   = $atts['path'];
    if (!array_key_exists ($path, $cache)) {
        $page = get_page_by_path ($path);
        if ($page) {
            $cache[$path] = get_post_status ($page->ID);
        } else {
            $cache[$path] = 'delete';
        }
    }
    return $cache[$path] == $status;
}

function get_parent_path ($path)
{
    $a = explode ('/', trim ($path, '/'));
    return implode ('/', array_slice ($a, 0, -1));
}

function if_status ($atts)
{
    static $parent_cache = array ();
    static $cache = array ();

    global $wpdb;

    $status      = $atts['status'];
    $path        = trim ($atts['path'], '/');
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
 * @param array  $atts       The shortocde attributes.  status = status, path = path of page
 * @param string $content    The shortcode content.
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
 * @param array  $atts       The shortocde attributes.  status = status, path = path of page
 * @param string $content    The shortcode content.
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

add_shortcode ('if_status',     'cceh\capitularia\page_generator\on_shortcode_if_status');
add_shortcode ('if_not_status', 'cceh\capitularia\page_generator\on_shortcode_if_not_status');


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
