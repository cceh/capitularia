<?php
/**
 * Capitularia File Includer Main Class
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

use cceh\capitularia\lib;

/**
 * Implements the inclusion engine.
 *
 * One difficulty is to get in early enough so that the qtranslate-x plugin has
 * not translated away the unwanted languages.  We need all languages to be
 * there when we have to save the page.  qtranslate-x hooks into 'the_posts' so
 * we must too.
 *
 * The other difficulty is to protect the included content from the wpautop and
 * wptexturizer filters, which were implemented with boundless incompetence and
 * try to put <p>'s around the included content everywhere and fuck up the HTML
 * attributes with curly quotes.
 *
 * To get around those filters we insert <pre> tags around the included content,
 * which is the only way to fend those filters off for some portion of a page,
 * instead of disabling them wholesale.  We double the <pre> tags in this way:
 * <pre><pre>...</pre></pre> so that we can filter them out again later without
 * danger of removing tags of other provenience.
 *
 * We have to save the included content to the database to make it searchable by
 * the built-in Wordpress search engine.
 */

class FileIncluderEngine
{
    /**
     * Do we have to save the post?
     *
     * @var boolean
     */

    private $do_save;

    /**
     * A ref to the post being processed.
     *
     * @var \WP_Post
     */
    private $post;

    /**
     * Process our shortcodes.  Step 1: Include the file.
     *
     * Called very early from on_the_posts ().
     *
     * @param array  $atts    The shortcode attributes.
     * @param string $content The shortcode content.
     *
     * @return string The content to insert into the shortcode.
     *
     * @see on_the_content_early()
     */

    public function on_shortcode_early ($atts, $content)
    {
        global $wpdb;

        $atts = shortcode_atts (
            array (
                'path' => '',
                'post' => false,
            ),
            $atts
        );

        // replace {slug} with the page slug
        $path = preg_replace ('/\{slug\}/', $this->post->post_name, $atts['path']);

        $root = realpath (get_root ());
        $path = realpath (lib\urljoin ($root, $path));

        // check if somebody is trying to read outside the root path
        if (strncmp ($root, $path, strlen ($root)) !== 0) {
            return sprintf (_x ('%s: Illegal path: %s', 'Plugin name', DOMAIN), NAME, $path);
        }

        if (!is_readable ($path)) {
            return '<div class="error">' . sprintf (__ ('File not found: %s', DOMAIN), $path) . '</div>';
        }

        // check if the file is newer than the post last modified date
        $filetime = intval (filemtime ($path));
        $posttime = intval (get_post_modified_time ('U', true, $this->post->ID));

        error_log ("filetime = $filetime, posttime = $posttime, path = $path");

        // If the file was never read or if the file is newer than the
        // post, read (and maybe post-process) the file.
        if (!$content || $filetime > $posttime) {
            error_log ("Reading the file: $path");

            // remember to save it too
            $this->do_save = true;

            // Parse an XML or HTML file but always return HTML because
            // we will paste it into a HTML page.  Some XSLT output
            // needs further post-processing.  This is signalled by the
            // 'post' parameter.  Finally, put a <div> around the
            // content so we can explicitly target it with CSS.
            $doc = load_xml_or_html (file_get_contents ($path));
            if ($atts['post']) {
                $doc = post_process ($doc);
            }
            $output = explode ("\n", save_html ($doc));
            // remove eventual xml declaration
            if (strncmp ($output[0], '<?xml ', 6) == 0) {
                array_shift ($output);
            }
            $content = '<div class="xsl-output">' . join ("\n", $output) . '</div>';
        }

        // Keep the shortcodes around because, if we have to save the
        // post, we need to save them too.  Also put <pre> tags around
        // the content as a protection against wpautop and wptexturizer.
        return make_shortcode_around ($atts, $content);
    }

    /**
     * Process our shortcodes. Step 2.
     *
     * Called after wpautop and wptexturizer did their nefarious work.  Clean up
     * the <pre> tags we inserted only to protect against them.
     *
     * @param array  $dummy_atts (unused) The shortcode attributes.
     * @param string $content    The shortcode content.
     *
     * @return string The content with <pre> tags stripped.
     */

    function on_shortcode ($dummy_atts, $content) // phpcs:ignore
    {
        return do_shortcode (strip_pre ($content));
    }

    /**
     * Process our shortcodes. Step 1.
     *
     * We are forced to hook into 'the_posts' because the qtranslate-x plugin
     * does it this way and we must get in before qtranslate-x has 'translated'
     * away the unwanted languages.
     *
     * We cannot save inside the on_shortcode_early hook because there
     * may be more than one shortcode on the page and besides there may
     * be other content too.
     *
     * @param \WP_Post[] $posts The array of posts.
     * @param \WP_Query  $query The query.
     *
     * @return \WP_Post[] The array of posts with our shortcode processed.
     */

    public function on_the_posts ($posts, $query)
    {
        if (!is_array ($posts)) {
            return $posts;
        }

        if ($query->query_vars['post_type'] == 'nav_menu_item') {
            return $posts;
        }

        global $wpdb, $shortcode_tags;

        foreach ($posts as $post) {
            $this->do_save = false;
            $this->post    = $post;

            // Disable all shortcodes except ours
            $shortcode_tags_backup = $shortcode_tags;
            $shortcode_tags = array ();

            add_shortcode (
                get_opt ('shortcode', 'cap_include'),
                array ($this, 'on_shortcode_early')
            );

            $post->post_content = do_shortcode ($post->post_content);

            $shortcode_tags = $shortcode_tags_backup;

            // Maybe save the shortcodes with content to the database.
            if ($this->do_save) {
                error_log ("Saving post $post->ID");

                // Not using wp_update_post () because its effect depends on the
                // capabilities of the user that is viewing the page, eg.  their
                // capability to save <script>s or not.  Also it creates revisions,
                // which we don't want.  In the end we are better off doing it
                // manually.
                $sql = $wpdb->prepare (
                    "UPDATE {$wpdb->posts}
                     SET post_content = %s,
                         post_modified = NOW(),
                         post_modified_gmt = UTC_TIMESTAMP()
                     WHERE ID = %d",
                    strip_pre ($post->post_content),
                    $post->ID
                );
                $wpdb->query ($sql);
            }
        }

        return $posts;
    }
}
