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

    if (array_key_exists ($corresp, $cache)) {
        return $cache[$corresp];
    }

    $post_name = null;
    if (preg_match ('/^BK[._](\d+)(\w?)$/', $corresp, $matches)) {
        $post_name = 'bk-nr-' . str_pad ($matches[1], 3, '0', STR_PAD_LEFT) . $matches[2];
    }
    if (preg_match ('/^Mordek[._](\d+)(\w?)$/', $corresp, $matches)) {
        $post_name = 'mordek-nr-' . str_pad ($matches[1], 2, '0', STR_PAD_LEFT) . $matches[2];
    }
    if ($post_name) {
        $sql = $wpdb->prepare (
            "SELECT ID FROM {$wpdb->posts} WHERE post_name = %s",
            $post_name
        );
        foreach ($wpdb->get_results ($sql) as $row) {
            $url = get_permalink ($row->ID);
            $cache[$corresp] = $url;
            return $url;
        }
    }
    return null;
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
 * Add the current_date shortcode.
 *
 * This shortcode outputs the current date.
 *
 * @param array  $atts          The shortocde attributes.
 * @param string $dummy_content The shortcode content. (empty)
 *
 * @return string The current date.
 */

function on_shortcode_current_date ($atts, $dummy_content)
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
 * Add the cite_as shortcode.
 *
 * This shortcode outputs a short description of how to cite the post.
 *
 * @param array  $atts          The shortocde attributes.
 * @param string $dummy_content The shortcode content. (empty)
 *
 * @return string A description of how to cite.
 */

function on_shortcode_cite_as ($atts, $dummy_content)
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

/**
 * The changes shortcode.
 *
 * This shortcode outputs a table of the tei:change entries in all the mss.
 *
 * @param array  $atts          The shortocde attributes.
 * @param string $dummy_content The shortcode content. (empty)
 *
 * @return string A HTML table.
 */

function on_shortcode_cap_changes ($atts, $dummy_content)
{
    global $wpdb;

    $atts = shortcode_atts (
        array (
            'cutoff' => '1970-01-01',
            'prefix' => 'A',
        ),
        $atts,
        'changes'
    );

    $cutoff = date ('Y-m-d', strtotime ($atts['cutoff']));
    $prefix = htmlspecialchars ($atts['prefix']);
    $publish = current_user_can ('read_private_pages') ? '' : "AND p.post_status = 'publish'";
    $date_format = __ ('Y-m-d', 'capitularia'); // ISO 8601

    $sql = $wpdb->prepare (
        "SELECT p.ID as post_id, p.post_title, p.post_status, pm2.meta_value as xml_id, pm.meta_value as cchange " .
        "FROM wp_posts p, wp_postmeta pm, wp_postmeta as pm2 " .
        "WHERE p.ID = pm.post_id  AND pm.meta_key  = 'change' AND pm.meta_value >= %s $publish " .
        "  AND p.ID = pm2.post_id AND pm2.meta_key = 'tei-xml-id'" .
        "ORDER BY xml_id, cchange",
        array ($cutoff)
    );
    $old_post_id = -1;
    $old_alpha = '_';
    $rows = $wpdb->get_results ($sql);

    // Add a key to all objects in the array that allows for sensible
    // sorting of numeric substrings.
    foreach ($rows as $row) {
        $row->key = preg_replace_callback (
            '|\d+|',
            function ($match) {
                return 'zz' . strval (strlen ($match[0])) . $match[0];
            },
            $row->xml_id
        ) . $row->cchange;
    }

    // Sort the array according to key.
    usort (
        $rows,
        function ($row1, $row2) {
            return strcoll ($row1->key, $row2->key);
        }
    );
    $res = [];

    $res[] = "<div class='mss-changes'>";
    if (count ($rows)) {
        $res[] = "<table>";
        foreach ($rows as $row) {
            if ($old_post_id != $row->post_id) {
                if ($old_alpha != $row->post_title[0]) {
                    $id = $row->post_title[0];
                    $res[] = "<tr>";
                    $res[] = "  <th id='{$prefix}{$id}' colspan='2'>$id</th>";
                    $res[] = "<tr>";
                    $old_alpha = $id;
                }
                $res[] = "<tr>";
                $res[] = "  <td colspan='2' class='mss-status-post-status-{$row->post_status}'>";
                $res[] = "<a href='/mss/{$row->xml_id}'>{$row->post_title}</a>";
                $res[] = "</td>";
                $res[] = "</tr>";
                $old_post_id = $row->post_id;
            };
            list ($date, $who, $what) = explode ('/', $row->cchange);
            $date = date_i18n ($date_format, strtotime ($date));
            if (!empty ($what)) {
                $res[] = "<tr>";
                $res[] = "  <td class='date'>{$date}</td>";
                $res[] = "  <td class='what'>{$what}</td>";
                $res[] = "</tr>";
            }
        }
        $res[] = "</table>";
    } else {
        $res[] = '<p>';
        $res[] = __ ('None', 'capitularia');
        $res[] = "</p>";
    }
    $res[] = "</div>";

    return join ("\n", $res);
}

/**
 * The downloads shortcode.
 *
 * This shortcode outputs a table of the downloadable xml files.
 *
 * @param array  $atts          The shortocde attributes.
 * @param string $dummy_content The shortcode content. (empty)
 *
 * @return string A HTML table.
 */

function on_shortcode_cap_downloads ($atts, $dummy_content)
{
    global $wpdb;

    $atts = shortcode_atts (
        array (
            'th1' => '[:de]Handschrift[:en]Manuscript[:]',
            'th2' => '[:de]XML-Dateien[:en]XML Files[:]',
            'th3' => '[:de]Beschreibung (Mordek 1995)[:en]Description (Mordek 1995)[:]',
        ),
        $atts,
        'downloads'
    );

    $publish = current_user_can ('read_private_pages') ? '1' : "p.post_status = 'publish'";

    // Get the /mss page id.
    $sql = $wpdb->prepare (
        "SELECT id FROM wp_posts WHERE post_name = 'mss' AND post_parent = 0;",
        array ()
    );
    $mss_page_id = $wpdb->get_var ($sql);

    $sql = $wpdb->prepare (
        "SELECT DISTINCT p.post_title, p.post_status, pm.meta_value as xml_id, pm2.meta_value as mordek_page " .
        "FROM wp_posts p " .
        "JOIN      wp_postmeta pm  ON (p.ID = pm.post_id  AND pm.meta_key  = 'tei-xml-id') " .
        "LEFT JOIN wp_postmeta pm2 ON (p.ID = pm2.post_id AND pm2.meta_key = 'mordek-1995-pages') " .
        "WHERE p.post_parent = %d AND $publish " .
        "ORDER BY xml_id",
        array ($mss_page_id)
    );
    $old_alpha = '_';
    $rows = $wpdb->get_results ($sql);

    // Add a key to all objects in the array that allows for sensible
    // sorting of numeric substrings.
    foreach ($rows as $row) {
        $row->key = preg_replace_callback (
            '|\d+|',
            function ($match) {
                return 'zz' . strval (strlen ($match[0])) . $match[0];
            },
            $row->xml_id
        );
    }

    // Sort the array according to key.
    usort (
        $rows,
        function ($row1, $row2) {
            return strcoll ($row1->key, $row2->key);
        }
    );
    $res = [];

    $res[] = "<div class='resources-downloads'>";
    $res[] = "<table>";
    $res[] = "<thead>";
        $res[] = "<tr>";
        $res[] = "  <th class='title'>{$atts['th1']}</th>";
        $res[] = "  <th class='xml-download'>{$atts['th2']}</th>";
        $res[] = "  <th class='pdf-download'>{$atts['th3']}</th>";
        $res[] = "</tr>";
    $res[] = "</thead>";
    $res[] = "</tbody>";
    foreach ($rows as $row) {
        if ($row->xml_id[0] === '_') { // BK Superstruktur
            continue;
        }
        if ($old_alpha != $row->post_title[0]) {
            $id = $row->post_title[0];
            $res[] = "<tr>";
            $res[] = "  <th id='{$prefix}{$id}' colspan='3'>$id</th>";
            $res[] = "<tr>";
            $old_alpha = $id;
        }
        $res[] = "<tr class='mss-status-post-status-{$row->post_status}'>";
        $res[] = "  <td class='title'><a href='/mss/{$row->xml_id}'>{$row->post_title}</a></td>";
        $res[] = "  <td class='xml-download'>(<a href='/cap/publ/mss/{$row->xml_id}.xml' target='_blank'>xml</a>)</td>";
        $pdf_page = intval ($row->mordek_page);
        if ($pdf_page > 0) {
            $pdf_page += 45; // 45 == pdf offset
            $res[] = "  <td class='pdf-download'>(<a href='/cap/publ/resources/Mordek_Bibliotheca_1995.pdf#page={$pdf_page}' target='_blank'>pdf S. {$row->mordek_page}</a>)</td>";
        } else {
            $res[] = "  <td class='pdf-download'></td>";
        }
        $res[] = "</tr>";
    }
    $res[] = "</tbody>";
    $res[] = "</table>";
    $res[] = "</div>";

    return join ("\n", $res);
}
