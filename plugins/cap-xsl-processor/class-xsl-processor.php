<?php
/**
 * Capitularia XSL Processor main class.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

/**
 * A caching XSL processor.
 */

class XSL_Processor
{
    private $shortcode          = null;
    private $page_has_shortcode = false;
    private $is_stale           = false;
    /** Flag for on_shortcode (). If false only checks for staleness. */
    private $do_xsl             = false;
    private $do_revision        = false;
    private $post_id            = 0;
    private $cache_time         = 0; // unixtime
    private $page_modified_time = 0; // unixtime
    private $xmlfiles           = array ();
    private $force_reload       = false;

    /**
     * Constructor
     *
     * @return void
     */

    public function __construct ()
    {
        // The default shortcode is 'cap_xsl'.
        $this->shortcode = get_opt ('shortcode', 'cap_xsl');

        add_action ('parse_request',         array ($this, 'on_parse_request'));
        add_action ('cap_xsl_get_xmlfiles',  array ($this, 'on_cap_xsl_get_xmlfiles'));

        // Get our hands in very early before other plugins mess things up.
        add_filter ('the_content', array ($this, 'on_the_content_early'), 1);
        // after do_shortcodes
        add_filter ('the_content', array ($this, 'on_the_content_late'), 20);
    }

    /**
     * Wrap the content in shortcodes.
     *
     * @param string $content The content to wrap.
     * @param array  $atts    Array of the attributes to write on the shortcode.
     *
     * @return The content wrapped in shortcodes.
     */
    private function wrap_in_shortcode ($content, $atts)
    {
        $params  = empty ($atts['params'])       ? '' :       " params=\"{$atts['params']}\"";
        $params .= empty ($atts['stringparams']) ? '' : " stringparams=\"{$atts['stringparams']}\"";
        return "[{$this->shortcode} xml=\"{$atts['xml']}\" xslt=\"{$atts['xslt']}\"$params]\n" .
               "$content\n[/{$this->shortcode}]";
    }

    /**
     * Hide the content of our shortcodes from wpautop.
     *
     * We don't want the wpautop filter applied to our xsl output, but we want
     * it applied to the rest of the page.  We add <pre> and </pre> tags around
     * our shortcodes to turn off the wpautop filter on the xsl output.
     *
     * @param string $content The content
     *
     * @return string The content hidden from wpautop.
     */
    private function hide_shortcodes_from_wpautop ($content)
    {
        $content = str_replace ("[{$this->shortcode} ",  "<pre>[{$this->shortcode} ",   $content);
        $content = str_replace ("[/{$this->shortcode}]", "[/{$this->shortcode}]</pre>", $content);
        return $content;
    }

    /**
     * Strip the shortcodes.
     *
     * Strip our shortcodes, eg. before presenting the post to the user.
     *
     * @param string $content The content with shortcodes.
     *
     * @return string The content with shortcodes removed.
     */
    private function strip_shortcode ($content)
    {
        $content = preg_replace ("/<pre>\\[{$this->shortcode}.*?\\]/s", '', $content);
        $content = str_replace  ("[/{$this->shortcode}]</pre>",         '', $content);
        return $content;
    }

    /**
     * Called at the end of WordPress's built-in request parsing method
     *
     * If _cap\_xsl_ is 'reload' then we refresh the cache unconditionally.
     *
     * @param query $query The query object
     *
     * @return query The query object
     */

    function on_parse_request ($query)
    {
        if (array_key_exists ('cap_xsl', $query->query_vars) &&
            $query->query_vars['cap_xsl'] == 'reload') {
            $this->force_reload = true;
        }
        // error_log ('on_parse_request () ==> force_reload = ' . ($this->force_reload ? 'true' : 'false'));
        return $query;
     }

    /**
     * Check if the cached page in the database is still current else rebuild it
     * and store the fresh version in the database.
     *
     * This is an early hook
     *
     * @param string $content The post content.
     *
     * @return The processed content.
     */

    public function on_the_content_early ($content)
    {
        // error_log ('on_the_content_early () ==> enter');

        $this->post_id            = intval (get_queried_object_id ());
        $this->cache_time         = intval (get_metadata ('post', $this->post_id, 'cap_xsl_cache_time', true));
        $this->page_modified_time = intval (get_post_modified_time ('U', true, $this->post_id));

        // Do our shortcode very early in the filter chain.  We want to use the
        // very handy do_shortcode () function, so we have to remove all other
        // shortcodes before calling it and reinstate them afterwards.
        $current_shortcodes = $GLOBALS['shortcode_tags'];

        remove_all_shortcodes ();
        add_shortcode ($this->shortcode, array ($this, 'on_shortcode'));

        $this->do_xsl   = false; // tell do_shortcode that it should only check timestamps
        $this->is_stale = false; // do_shortcode will set is_stale as a side effect
        $content = do_shortcode ($content);

        if ($this->is_stale) {
            // The cached content is not current any more. Run the XSL and store
            // the results in the database.  We have already taken care that our
            // shortcode tags are still present.
            //
            // NOTE: we are using a low-level database read because we must be
            // sure that no other plugin has mucked with the content before we
            // save it again. (eg. before qTranslate-X adds its stupid
            // do-you-want-this-in-another-language notices.)

            // error_log ('saving post ...');

            $content = null; // release some mem

            // get_the_content () may get called more than once per HTTP
            // request, eg. it may get called by the dynamic menu plugin.  Make
            // sure we regenerate the page only once.
            $this->force_reload = false;

            global $wpdb;
            $sql = $wpdb->prepare ("SELECT post_content FROM $wpdb->posts WHERE ID = %d", $this->post_id);
            // error_log ("SQL: $sql");
            $content = $wpdb->get_var ($sql);

            // Run do_shortcode again to actually do the xsl
            remove_all_shortcodes ();
            add_shortcode ($this->shortcode, array ($this, 'on_shortcode'));
            // error_log ('Used memory before do_shortcode: ' . memory_get_usage ());
            // error_log ('Peak memory before do_shortcode: ' . memory_get_peak_usage ());
            $this->do_xsl = true;   // tell do_shortcode to run xsl
            $content = do_shortcode ($content);

            if (!$this->do_revision) {
                suppress_revisions ();
            }

            // cache xslt output in database
            $my_post = array (
                'ID'           => $this->post_id,
                'post_content' => $content,
            );
            // error_log ('on_the_content_early () before update_post ...');
            kses_remove_filters ();
            gc_collect_cycles ();
            // error_log ('Used memory before wp_update: ' . memory_get_usage ());
            // error_log ('Peak memory before wp_update: ' . memory_get_peak_usage ());
            wp_update_post ($my_post);
            // error_log ('Used memory after wp_update : ' . memory_get_usage ());
            // error_log ('Peak memory after wp_update : ' . memory_get_peak_usage ());
            kses_init_filters ();

            // clear cache and reload global post
            // qtranslate-x will use the global post to return the wrong time to us!!!
            clean_post_cache ($this->post_id);
            global $post;
            $post = get_post ($this->post_id);

            $this->cache_time = intval (get_post_modified_time ('U', true, $this->post_id));
            // $this->cache_time = time ();

            // update metadata
            increment_metadata ($this->post_id, 'cap_xsl_cache_misses');
            update_post_meta ($this->post_id, 'cap_xsl_cache_time', $this->cache_time);
            update_post_meta ($this->post_id, 'cap_xsl_cache_hits_temp',  0);

            do_action ('cap_xsl_page_refreshed', $this->post_id);
            // error_log ('on_the_content_early () after update_post ...');
        } else {
            increment_metadata ($this->post_id, 'cap_xsl_cache_hits');
            increment_metadata ($this->post_id, 'cap_xsl_cache_hits_temp');
        }

        // restore shortcodes
        $GLOBALS['shortcode_tags'] = $current_shortcodes;

        if ($this->page_has_shortcode) {
            $content = $this->hide_shortcodes_from_wpautop ($content);
        }

        // error_log ('on_the_content_early () ==> exit');
        return $content;
    }

    /**
     * Check if one shortcode content is still current, else rebuild it from
     * XML.
     *
     * @param array  $atts    The shortcode attributes.
     * @param string $content The content. May be stale.
     *
     * @return The shortcode with current content.
     */

    public function on_shortcode ($atts, $content = '')
    {
        // NOTE: this function keeps the shortcode tags around because
        // we still need them in case we have to save the post.
        //
        // BUG: wpautop Works only if the shortcode tag and
        // attributes are on one line.

        // error_log ("on_shortcode () ==> enter");

        $this->page_has_shortcode = true;

        if (!$this->post_id) {
            // relevanssi uses get_the_content () instead of
            // the_content () and thus does not exercise the
            // 'the_content' filter stack
            return $content;
        }

        $atts = shortcode_atts (
            array (
                'xml'          => '',
                'xslt'         => '',
                'params'       => '',
                'stringparams' => '',
            ),
            $atts
        );
        $xml          = urljoin (get_opt ('xmlroot'),  $atts['xml']);
        $xslt         = urljoin (get_opt ('xsltroot'), $atts['xslt']);
        $params       = wp_parse_args ($atts['params']);
        $stringparams = wp_parse_args ($atts['stringparams']);
        $xsltproc     = get_opt ('xsltproc');

        $xml_file_time  = intval (filemtime ($xml));
        $xslt_file_time = intval (filemtime ($xslt));

        if (!$xml_file_time) {
            return "XML file $xml not found.";
        }
        if (!$xslt_file_time) {
            return "XSLT file $xslt not found.";
        }

        // phpinfo ();
        // passthru ('/usr/bin/xsltproc --help');
        // passthru ('/vol/local/bin/tidy -help');

        // do a transform if any of page, xml, or xsl changed
        $do_transform = $this->cache_time < max ($this->page_modified_time, $xml_file_time, $xslt_file_time);
        $do_transform = $do_transform || $this->force_reload;
        $this->is_stale |= $do_transform;

        // do a revision only if page or xml changed
        $this->do_revision |= $this->cache_time < max ($this->page_modified_time, $xml_file_time);

        // Keep track of the XML files that make up this page.
        if (!in_array ($xml, $this->xmlfiles)) {
            $this->xmlfiles[] = $xml;
        }

        if (!$this->do_xsl || !$do_transform) {
            // Cached copy of this XSL is current. Return the cached copy. The
            // shortcode is already stripped, so we must add it again, so that
            // we can protect our content from the dreaded wp_autop.

            // error_log ('on_shortcode () ==> exit cached');
            return $this->wrap_in_shortcode ($content, $atts);
        }

        // The cached copy is out of date. Run the XSLT processor. Then add the
        // shortcodes back so we can save them into the db.

        $retval    = 666;
        $cmdline   = array ();
        $cmdline[] = $xsltproc;
        foreach ($params as $key => $value) {
            $key       = escapeshellarg ($key);
            $value     = escapeshellarg ($value);
            $cmdline[] = "--param $key $value";
        }
        foreach ($stringparams as $key => $value) {
            $key       = escapeshellarg ($key);
            $value     = escapeshellarg ($value);
            $cmdline[] = "--stringparam $key $value";
        }
        $cmdline[] = escapeshellarg ($xslt);
        $cmdline[] = escapeshellarg ($xml);
        // '| /vol/local/bin/tidy -qni -xml -utf8 -wrap 80'

        // redirect stderr to stdout to keep server error logs small
        // (seems to be a problem at uni-koeln.de)
        $cmdline[] = '2>/dev/null';

        $cmdline = join (' ', $cmdline);

        $output = array ();
        exec ($cmdline, $output, $retval);
        if (strncmp ($output[0], '<?xml ', 6) == 0) {
            array_shift ($output);
        }
        array_unshift ($output, '<div class="xsl-output">');
        $output[] = '</div>';
        $content = join ("\n", $output);

        // A hook to let other plugins know that we just transformed a file.
        // Used by the metadata extraction plugin to keep metadata up-to-date.
        do_action ('cap_xsl_transformed', $this->post_id, $xml, $xslt, $params, $stringparams);

        // error_log ('on_shortcode () ==> exit transformed');

        return $this->wrap_in_shortcode ($content, $atts);
    }

    /**
     * Late hook on the content.  Remove our shortcode tags that we kept around
     * only to fend wpautop off.
     *
     * @param string $content The content
     *
     * @return The content with our shortcodes stripped off.
     */

    public function on_the_content_late ($content)
    {
        if ($this->page_has_shortcode) {
            return $this->strip_shortcode ($content);
        }
        return $content;
    }

    /**
     * Hook to return the list of source xml files.
     *
     * @return array List of xml files.
     */

    public function on_cap_xsl_get_xmlfiles ()
    {
        return $this->xmlfiles;
    }

    /**
     * Does this page have a shortcode on it?
     *
     * @return boolean True if the page has a shortcode.
     */

    public function has_shortcode ()
    {
        return $this->page_has_shortcode;
    }
}
