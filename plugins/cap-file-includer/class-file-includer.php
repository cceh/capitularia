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
 * The main difficulty here is to get around the wpautop and wptexturizer
 * filters, that were implemented with boundless incompetence.  To do that, we
 * insert <pre> tags around our content, which is the only way to fend those
 * filters off for some portion of a page, instead of disabling them wholesale.
 * We double the <pre> tags in this way: <pre><pre>...</pre></pre> so that we
 * can filter them out again later without danger of removing tags of other
 * provenience.
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
     * Constructor
     *
     * @return self
     */

    public function __construct ()
    {
        $this->do_save = false;
    }

    /**
     * Process our shortcodes.  Step 1: Include the file.
     *
     * Called at prio 9 from on_the_content_early()
     *
     * @see on_the_content_early()
     *
     * @param array  $atts    The shortcode attributes.
     * @param string $content The shortcode content.
     *
     * @return string The content to insert into the shortcode.
     */

    public function on_shortcode_early ($atts, $content)
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
     * Process our shortcodes. Step 2.
     *
     * Clean up the <pre> tags we inserted solely to protect against the dumb
     * wpautop and wptexturizer filters.
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
     * This filter does not run at the customary shortcode filter prio
     * of 11 but earlier at prio 9 so that we can do some work before
     * the wpautop and wptexturizer filters have disfigured our content
     * beyond recognition.
     *
     * Saving to the database also makes the page content searchable by
     * the built-in Wordpress search engine.
     *
     * We cannot save inside the on_shortcode_early hook because there
     * may be more than one shortcode on the page and besides there may
     * be other content too.
     *
     * @param string $content The page content.
     *
     * @return string The page content with our shortcode processed.
     */

    public function on_the_content_early ($content)
    {
        global $post, $wpdb, $shortcode_tags;

        // Disable all shortcodes except ours
        $shortcode_tags_backup = $shortcode_tags;
        $shortcode_tags = array ();

        add_shortcode (
            get_opt ('shortcode', 'cap_include'),
            array ($this, 'on_shortcode_early')
        );

        $content = do_shortcode ($content);

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
}
