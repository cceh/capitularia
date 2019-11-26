<?php
/**
 * Capitularia File Includer Main Class
 *
 * The main difficulty here is to get around the wpautop and
 * wptexturizer filters, that were implemented with boundless
 * incompetence.  To do that, we insert <pre> tags around our content,
 * which is the only way to fend those filters off for some portion of a
 * page, instead of disabling them wholesale.  We double the <pre> tags
 * in this way: <pre><pre>...</pre></pre> so that we can filter them out
 * again later without danger of removing tags of other provenience.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

use cceh\capitularia\lib;

/**
 * Implements the inclusion engine.
 */

class FileIncluderEngine
{
    /** Do we have to save the post? */
    private $do_save;

    /**
     * Constructor
     *
     * @return FileIncluderEngine;
     */

    public function __construct ()
    {
        $this->do_save = false;
    }

    /**
     * Include the file.
     *
     * @param array  $atts    The shortcode attributes.
     * @param string $content The shortcode content.
     *
     * @return The content to insert into the shortcode.
     */

    public function on_shortcode_prio_9 ($atts, $content)
    {
        global $post, $wpdb;

        $atts = shortcode_atts (
            array (
                'path' => '',
                'post' => false,
            ),
            $atts
        );

        // replace {slug} with the page slug
        $path = preg_replace ('/\{slug\}/', $post->post_name, $atts['path']);

        $root = realpath (get_root ());
        $path = realpath (lib\urljoin ($root, $path));

        // check if somebody is trying to read outside the root path
        if (strncmp ($root, $path, strlen ($root)) !== 0) {
            return sprintf (_x ('%s: Illegal path: %s', 'Plugin name', LANG), NAME, $path);
        }

        if (!is_readable ($path)) {
            return '<div class="error">' . sprintf (__ ('File not found: %s', LANG), $path) . '</div>';
        }

        // check if the file is newer than the post last modified date
        $filetime = intval (filemtime ($path));
        $posttime = intval (get_post_modified_time ('U', true, $post->ID));

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
     * Process our shortcodes.
     *
     * This filter does not run at the customary shortcode filter prio
     * of 11 but earlier at prio 9 so that we can do some work before
     * the wpautop and wptexturizer filters have disfigured our content
     * beyond recognition.
     *
     * Saving to the database also makes the page content searchable by
     * the built-in Wordpress search engine.
     *
     * We cannot save inside the on_shortcode_prio_9 hook because there
     * may be more than one shortcode on the page and besides there may
     * be other content too.
     *
     * @param string $content The page content.
     *
     * @return The content
     */

    public function on_the_content_early ($content)
    {
        global $post, $wpdb, $shortcode_tags;

        // Disable all shortcodes except ours
        $shortcode_tags_backup = $shortcode_tags;
        $shortcode_tags = array ();

        add_shortcode (
            get_opt ('shortcode', 'cap_include'),
            array ($this, 'on_shortcode_prio_9')
        );

        $content = do_shortcode ($content);

        $shortcode_tags = $shortcode_tags_backup;

        // Maybe save the shortcodes with content to the database.
        if ($this->do_save) {
            error_log ("Saving post $post->ID");

            // NOTE: the effect of wp_update_post () depends on the
            // capabilities of the user that is viewing the page, eg.
            // their capability to save <script>s or not.  Also it
            // creates revisions, which we don't want.  In the end we
            // are better off doing it manually.
            $sql = $wpdb->prepare (
                "UPDATE {$wpdb->posts} SET post_content = %s WHERE ID = %d",
                strip_pre ($content),
                $post->ID
            );
            $wpdb->query ($sql);
        }

        // Return with all shortcodes ready and protected against
        // wpautop and wptexturizer.
        return $content;
    }

    /**
     * Do not store any revisions for our updates.
     *
     * @param integer $num Default no. of revisions to keep.
     *
     * @return 0 if we initiated the update else $num
     */

    public function on_wp_revisions_to_keep ($num)
    {
        return $this->do_save ? 0 : $num;
    }
}
