<?php
/**
 * Capitularia Page Generator Manuscript class.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/**
 * Represents a manuscript file.
 *
 * This class represents TEI manuscripts stored in a directory on disk.  It also
 * manages manuscripts in Wordpress.
 *
 * N.B. The class name is somewhat a misnomer because it can also represent a
 * Capitulary file.
 */

class Manuscript
{
    /** @var string The filesystem path to the manuscript file. */
    private $path;

    /** @var string The section of the manuscript, eg. 'mss', 'capit/ldf', ... */
    private $section_id;

    /** @var string|null The manuscript title. Cached. */
    private $title = null;

    /**
     * Constructor
     *
     * @param string $section_id The section id
     * @param string $path       The full path to the manuscript file
     *
     * @return void
     */

    public function __construct ($section_id, $path)
    {
        $this->section_id  = $section_id;
        $this->path        = $path;
    }

    /**
     * Getter for $path
     *
     * @return string The path
     */

    public function get_path ()
    {
        return $this->path;
    }

    /**
     * Getter for $section_id
     *
     * @return string The section id
     */

    public function get_section_id ()
    {
        return $this->section_id;
    }

    /**
     * Return the filename
     *
     * @return string The filename and extension (without directories)
     */

    public function get_filename ()
    {
        return pathinfo ($this->path, PATHINFO_BASENAME);
    }

    /**
     * Generate a slug without path.
     *
     * @return string The slug
     */

    public function get_slug ()
    {
        return sanitize_title (pathinfo ($this->path, PATHINFO_FILENAME));
    }

    /**
     * Generate a slug with path.
     *
     * @return string The slug with path, eg. capit/ldf/slug
     */

    public function get_slug_with_path ()
    {
        global $config;

        $slug_path   = $config->get_opt ($this->section_id, 'slug_path');
        $slug_prefix = $config->get_opt ($this->section_id, 'slug_prefix');
        return $slug_path . '/' . $slug_prefix . $this->get_slug ();
    }

    /**
     * Generate a slug with HTML link.
     *
     * @return string The link pointing to slug
     */

    public function get_slug_with_link ()
    {
        $slug = $this->get_slug ();
        $slug_with_path = $this->get_slug_with_path ();
        return "<a href='/$slug_with_path'>$slug</a>";
    }

    /**
     * Extract the manuscript title.
     *
     * Extracts the manuscript title from the TEI file.  Also puts qTranslate-X
     * tags into the title.
     *
     * @return string The manuscript title
     */

    public function get_title ()
    {
        // return cached title
        if ($this->title) {
            return $this->title;
        }

        libxml_use_internal_errors (true);
        $xml = simplexml_load_file ($this->path);
        if ($xml === false) {
            // FIXME: handle errors here
            return null;
        }

        $xml->registerXPathNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
        // $xml->registerXPathNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');
        $titles = $xml->xpath ("//tei:titleStmt/tei:title[@type='main']");
        $tmp = array ();
        foreach ($titles as $title) {
            $lang = $title->attributes ('xml', true)->lang;
            if ($lang == 'ger') {
                $lang = 'de';
            }
            if ($lang == 'eng') {
                $lang = 'en';
            }
            $tmp[] = "[:{$lang}]{$title}";
        }
        $this->title = sanitize_text_field (__ (join (' ', $tmp), 'capitularia'), null, 'display');
        return $this->title;
    }

    /**
     * Validate manuscript against schema.
     *
     * @return array Success or error messages
     */

    private function validate_xmllint ()
    {
        global $config;

        $xmllint_path = $config->get_opt ('general', 'xmllint_path');
        $schema_path  = $config->get_opt_path ('schema_root', $this->get_section_id (), 'schema_path');
        $link         = $this->get_status () == 'delete' ? $this->get_slug () : $this->get_slug_with_link ();

        // The user can change the default catalog behaviour by redirecting
        // queries to its own set of catalogs, this can be done by setting the
        // XML_CATALOG_FILES environment variable to a list of catalogs, an
        // empty one should deactivate loading the default /etc/xml/catalog
        // default catalog.
        //
        // $catalog_dir = dirname ($schema_path);
        // putenv ("XML_CATALOG_FILES=$catalog_dir/catalog.xml");

        $messages = array ();
        $retval = 666;
        $cmdline = join (
            ' ',
            array (
                $xmllint_path,
                XMLLINT_PARAMS,
                escapeshellarg (rtrim ($schema_path, '/')),
                escapeshellarg ($this->path),
                '2>&1'
            )
        );
        exec ($cmdline, $messages, $retval); // 0 = ok, 3 = error
        if ($retval == 0) {
            return array (
                0,
                sprintf (__ ('File %s is valid TEI.', 'capitularia'), $link)
            );
        }
        if ($retval == 3 || $retval == 4) {
            return array (
                2,
                sprintf (__ ('File %s is invalid TEI.', 'capitularia'), $link),
                $messages
            );
        }
        return array (
            1,
            sprintf (
                __ ('Validity of file %s is unknown.', 'capitularia'),
                $link
            ),
            $messages
        );
    }

    /**
     * Get ID of page
     *
     * @return mixed The page ID or false
     */

    public function get_page_id ()
    {
        $page = get_page_by_path ($this->get_slug_with_path ());
        return $page ? $page->ID : false;
    }

    /**
     * Get the current status of a manuscript page.
     *
     * @return string The current status
     */

    public function get_status ()
    {
        $page_id = $this->get_page_id ();
        if ($page_id !== false) {
            return get_post_status ($page_id);
        }
        return 'delete';
    }

    /**
     * Set the 'published' status of a page.
     *
     * @param string $status The new status to set
     *
     * @return array Success or error messages
     *

    private function set_status ($status)
    {
        $link    = $this->get_slug_with_link ();
        $page_id = $this->get_page_id ();

        $updated = array ('ID' => $page_id, 'post_status' => $status);
        if (wp_update_post ($updated) === 0) { // returns 0 on error
            return array (
                2,
                sprintf (__ ('Error: could not set page %1$s to status %2$s.', 'capitularia'), $link, $status)
            );
        }
        return array (
            0,
            sprintf (__ ('Page %1$s status set to %2$s.', 'capitularia'), $link, $status)
        );
    }
    */

    /**
     * Delete all pages with our slug
     *
     * Slugs must be unique for all children of one page, but the same slug may
     * be used by more than one page provided each has a different parent
     * page. Eg. /mss and /internal/mss both have the slug 'mss' but a
     * different parent page, so we must account for that.
     *
     * We also delete all pages that have the same slug with a hyphen and number
     * appended.  Eg. deleting the page _/mss/my-slug_ would also delete the
     * pages _/mss/my-slug-1_ and _/mss/my-slug-42_, but not the page
     * _/internal/mss/my-slug_.
     *
     * @return array Success or error messages
     */

    private function delete_pages ()
    {
        $slug = $this->get_slug ();

        global $wpdb;
        $sql = $wpdb->prepare (
            "SELECT ID FROM {$wpdb->posts} WHERE post_name REGEXP %s AND post_parent = %d",
            "^$slug(-\\d+)?\$",
            cap_get_parent_id ($this->section_id)
        );
        error_log ("Deleting posts: SQL: $sql");

        $ids = $wpdb->get_col ($sql, 0);

        if (count ($ids) > 9) {
            // guard against disaster
            return array (2, 'Disaster!');
        }

        $count = 0;
        foreach ($ids as $id) {
            // bypass trash or we'll still have the slug in the bloody way
            error_log ("Deleting post: $id");
            if (wp_delete_post ($id, true) !== false) {
                $count++;
            }
        }
        if ($count == 0) {
            return array (
                2,
                sprintf (
                    __ ('Error: could not unpublish page %s.', 'capitularia'),
                    $this->get_slug_with_link ()
                )
            );
        }
        return array (
            0,
            sprintf (__ ('Page %s unpublished.', 'capitularia'), $slug)
        );
    }

    /**
     * Create a page containing one or more shortcodes.
     *
     * @param string $status Status to set on the newly created page.
     *
     * @return array Success or error messages
     */

    private function create_page ($status)
    {
        global $config;

        $title = $this->get_title ();
        if (empty ($title)) {
            $title = __ ('No title', 'capitularia');
        }

        // do not make public children of private pages
        if (($status == 'public') && (cap_get_section_page_status ($this->section_id) == 'private')) {
            $status = 'private';
        }

        $slug     = $this->get_slug ();
        $xsl_root = $config->get_opt ('general', 'xsl_root') . '/';

        // rebase paths according to cap_xsl_processor directories
        $cap_xsl_options = get_option ('cap_xsl_options', array ());

        error_log ("xsl_root = $xsl_root");
        error_log ("path = $this->path");
        $path     = cap_make_path_relative_to ($this->path, $cap_xsl_options['xmlroot']);

        $content = '';
        $shortcode = $config->get_opt ('general', 'shortcode');
        foreach (explode (' ', $config->get_opt ($this->section_id, 'xsl_path_list')) as $xsl) {
            $xsl = cap_make_path_relative_to ($xsl_root . $xsl, $cap_xsl_options['xsltroot']);
            $content .= "[{$shortcode} xml=\"{$path}\" xslt=\"{$xsl}\"][/{$shortcode}]\n";
        }

        $new_post = array (
            'post_name'    => $slug,
            'post_title'   => $title,
            'post_content' => $content,
            'post_status'  => $status,
            'post_type'    => 'page',
            'post_parent'  => cap_get_parent_id ($this->section_id),
            'tags_input'   => array ('xml'),
            'tax_input'    => array ('cap-sidebar' => array ('transcription')),
        );
        $post_id = wp_insert_post ($new_post);
        if ($post_id) {
            $post = get_post ($post_id);
            if ($slug == $post->post_name) {
                return array (
                    0,
                    sprintf (
                        __ ('Page %1$s created with status set to %2$s.', 'capitularia'),
                        $this->get_slug_with_link (),
                        $status
                    )
                );
            }
        }
        return array (
            2,
            sprintf (__ ('Error: could not create page %s.', 'capitularia'), $slug)
        );
    }

    /**
     * Extract metadata from manuscript.
     *
     * @return array Success or error message
     */

    private function extract_metadata ()
    {
        $slug    = $this->get_slug ();
        $page_id = $this->get_page_id ();

        if ($page_id === false) {
            return array (
                2,
                sprintf (__ ('Error while extracting metadata: no page with slug %s.', 'capitularia'), $slug)
            );
        }
        // We proxy this action to the Meta Search plugin.
        $errors = apply_filters (
            'cap_meta_search_extract_metadata',
            array (),
            $page_id,
            $this->path
        );
        if ($errors) {
            return array (
                2,
                sprintf (
                    __ ('Errors while extracting metadata from file %s.', 'capitularia'),
                    $this->get_slug_with_link ()
                ),
                $errors
            );
        }
        return array (
            0,
            sprintf (
                __ ('Metadata extracted from file %s.', 'capitularia'),
                $this->get_slug_with_link ()
            )
        );
    }

    /**
     * Perform an action on the manuscript.
     *
     * @param string $action The action to perform with the manuscript.
     *
     * @return array {
     *            0 => int    error code: 0 = success, 1 = warning, 2 = error,
     *            1 => string success or error message,
     *            2 => array  optionally more error messages
     *         }
     */

    public function do_action ($action)
    {
        $slug       = $this->get_slug ();
        $status     = $this->get_status ();

        error_log ("do_action ($this->section_id $slug $status => $action $this->path)");

        if ($action == $status) {
            // nothing to do
            return array (
                1,
                sprintf (__ ('The post is already %s.', 'capitularia'), $action)
            );
        }

        switch ($action) {
            case 'publish':
            case 'private':
                $this->delete_pages ();
                return $this->create_page ($action);
            case 'delete':
                return $this->delete_pages ();
            case 'metadata':
                return $this->extract_metadata ();
            case 'validate':
                return $this->validate_xmllint ();
            case 'refresh':
                $this->delete_pages ();
                return $this->do_action ($status);
        }
    }
}
