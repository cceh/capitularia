<?php

/**
 * Capitularia Theme shortcodes.php file
 *
 * Define actions for various shortcodes.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * Add the logged_in shortcode.
 *
 * This shortcode outputs its content only to logged-in users.
 *
 * .. code::
 *
 *    [logged_in]You are logged in![/logged_in]
 *
 * @param array  $dummy_atts (unused) The shortocde attributes.
 * @param string $content    The shortcode content.
 *
 * @return string The shortcode content if logged in else the empty string.
 *
 * @shortcode logged_in
 */

function on_shortcode_logged_in ($dummy_atts, $content) // phpcs:ignore
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
 * .. code::
 *
 *    [logged_out]Please log in![/logged_out]
 *
 * @param array  $dummy_atts (unused) The shortocde attributes.
 * @param string $content    The shortcode content.
 *
 * @return string The shortcode content if logged out else the empty string.
 *
 * @shortcode logged_out
 */

function on_shortcode_logged_out ($dummy_atts, $content) // phpcs:ignore
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
 * Make sure the status of a page is in the cache.
 *
 * Some pages with long lists must check the status of hundreds of other pages.
 * Wordpress turns each status check into one SQL query.  This function reads
 * the statuses of all children of a parent page in one SQL query, potentially
 * saving hundreds of queries.
 *
 * @param string $path The path of the page without leading or trailing slashes.
 *
 * @return array A dictionary of path => status which is guaranteed to
 *               contain the page's status if the page exists.
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
 * .. code::
 *
 *    [if_status path="/mss/wien" status="publish"]
 *      <p>Wien is published!</p>
 *    [/if_status]
 *
 * @param array  $atts    The shortocde attributes.  status = status, path = path of page
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the ms. has that status else the empty string.
 *
 * @shortcode if_status
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
 * .. code::
 *
 *    [if_not_status path="/mss/wien" status="publish"]
 *      <p>Wien is not published!</p>
 *    [/if_not_status]
 *
 * @param array  $atts    The shortocde attributes.  status = status, path = path of page
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the ms. doesn't have that status else the empty string.
 *
 * @shortcode if_not_status
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

    // Also look for 'virtual pages' like /bk/42
    if (preg_match ('!^bk/(BK[._])?(\d+\w?)$!', $path, $matches)) {
        $url = bk_to_permalink ('BK.' . $matches[2]);
        if ($url) {
            $path = trim (parse_url ($url, PHP_URL_PATH), '/');
        }
    }
    if (preg_match ('!^mordek/(Mordek[._])?(\d+\w?)$!', $path, $matches)) {
        $url = bk_to_permalink ('Mordek.' . $matches[2]);
        if ($url) {
            $path = trim (parse_url ($url, PHP_URL_PATH), '/');
        }
    }
    if (preg_match ('!^cap/(BK|Mordek)[._]?(\d+\w?)$!', $path, $matches)) {
        $url = bk_to_permalink ($matches[1] . '_' . $matches[2]);
        if ($url) {
            $path = trim (parse_url ($url, PHP_URL_PATH), '/');
        }
    }

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
 * This shortcode outputs its content if the current user can see *any* one of
 * the pages in the path attribute.
 *
 * .. code::
 *
 *    [if_visible path="/mss/secret.html"]
 *      <div>The secret manuscript.</div>
 *    [/if_visible]
 *
 * Use this with multiple pages to find out when to print headers, etc.
 *
 * .. code::
 *
 *    [if_any_visible path="/mss/leo1.html /mss/leo2.html"]
 *      <h2>Hic sunt leones</h2>
 *    [/if_any_visible]
 *
 * @param array  $atts    The shortocde attributes.  path = space separated paths of pages
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the user can see the page in path
                  or else the empty string.
 *
 * @shortcode if_visible
 * @shortcode if_any_visible
 */

function on_shortcode_if_visible ($atts, $content)
{
    foreach (preg_split ('/[\s,]+/', $atts['path']) as $path) {
        if (if_visible ($path)) {
            return do_shortcode ($content);
        }
    }
    return '';
}

/**
 * Add the if_not_visible shortcode.
 *
 * This shortcode outputs its content if the current user cannot see *any* one
 * of the pages in the path attribute.
 *
 * .. code::
 *
 *    [if_not_visible path="/premium.html"]
 *      <p>Pay to see our boring premium content!</p>
 *    [/if_not_visible]
 *
 * @param array  $atts    The shortocde attributes.  path = space separated paths of pages
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the current user cannot see the page in path
                  else the empty string.
 *
 * @shortcode if_not_visible
 * @shortcode if_any_not_visible
 */

function on_shortcode_if_not_visible ($atts, $content)
{
    foreach (preg_split ('/[\s,]+/', $atts['path']) as $path) {
        if (!if_visible ($path)) {
            return do_shortcode ($content);
        }
    }
    return '';
}

/**
 * Add the if_transcribed shortcode.
 *
 * This shortcode outputs its content if the capitular was already transcribed
 * on that page (in the manuscript with an xml:id equal to the slot of the page).
 *
 * .. code::
 *
 *    [if_transcribed path="/mss/barcelona" bk="BK.42"] and <a>here</a>[/if_transcribed]
 *
 * @param array  $atts    The shortocde attributes.  path = path of page, bk = BK No.
 * @param string $content The shortcode content.
 *
 * @return string The shortcode content if the capitular is transcribed,
                  else the empty string.
 *
 * @shortcode if_transcribed
 */

function on_shortcode_if_transcribed ($atts, $content)
{
    global $wpdb;

    $page  = get_page_by_path (trim ($atts['path'], '/'));
    if ($page) {
        $re_bk = "^{$atts['bk']}(_|$)";
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
 * Add the current_date shortcode.
 *
 * This shortcode outputs the current date using the preferred date
 * representation for the current locale without the time.
 *
 * .. code::
 *
 *    <p>Accessed on: [current_date]</p>
 *
 * yields:
 *
 * .. code::
 *
 *    <p>Accessed on: Jan 1, 1970</p>
 *
 * @param array  $atts          The shortocde attributes.
 * @param string $dummy_content The shortcode content. (empty)
 *
 * @return string The current date.
 *
 * @shortcode current_date
 */

function on_shortcode_current_date ($atts, $dummy_content) // phpcs:ignore
{
    $atts = shortcode_atts (
        array (
            'date' => strftime ('%x')
        ),
        $atts,
        'current_date'
    );

    return $atts['date'];
}

/**
 * Add the permalink shortcode.
 *
 * This shortcode outputs the permalink for the current page.
 *
 * .. code::
 *
 *    <p>URL: [permalink]</p>
 *
 * yields:
 *
 * .. code::
 *
 *    <p>URL: https://example.org/post/123</p>
 *
 * @param array  $dummy_atts    (unused) The shortocde attributes.
 * @param string $dummy_content (unused) The shortcode content.
 *
 * @return string The page permalink.
 *
 * @shortcode permalink
 */

function on_shortcode_permalink ($dummy_atts, $dummy_content) // phpcs:ignore
{
    return get_permalink ();
}

/**
 * Add the cite_as shortcode.
 *
 * This shortcode outputs a short description of how to cite the post.
 *
 * .. code::
 *
 *    <p>[cite_as]</p>
 *
 * @param array  $atts          The shortocde attributes.
 * @param string $dummy_content The shortcode content. (empty)
 *
 * @return string A description of how to cite.
 */

function on_shortcode_cite_as ($atts, $dummy_content) // phpcs:ignore
{
    $atts = shortcode_atts (
        array (
            'author' => get_the_author (),
            'title'  => get_the_title (),
            'url'    => get_permalink (),
            'date'   => strftime ('%x')
        ),
        $atts,
        'cite_as'
    );

    $res = <<<EOF
       <div class="cite_as">
         <h5>[:de]Empfohlene Zitierweise[:en]How to cite[:]</h5>
         <div>
           <span class="author">{$atts['author']}</author>,
           <span class="title">{$atts['title']}</title>,
           [:de]in: Capitularia. Edition der fränkischen Herrschererlasse, bearb. von
           Karl Ubl und Mitarb., Köln 2014 ff.
           [:en]in: Capitularia. Edition of the Frankish Capitularies, ed. by
           Karl Ubl and collaborators, Cologne 2014 ff.
           [:]
           URL: {$atts['url']} ([:de]abgerufen am[:en]accessed on[:] {$atts['date']})
         </div>
       </div>
EOF;
    return $res;
}
