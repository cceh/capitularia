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
    /**
     * The filesystem path to the manuscript file.
     *
     * @var string
     */
    private $path;

    /**
     * The section of the manuscript, eg. 'mss', 'capit/ldf', ...
     *
     * @var string
     */
    private $section_id;

    /**
     * The xml:id of the manuscript. Cached.
     *
     * @var string|null
     */
    private $xml_id = null;

    /**
     * The title of the manuscript. Cached.
     *
     * @var string|null
     */
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
     * Generate a slug (without path).
     *
     * @return string The slug
     */

    public function get_slug ()
    {
        return $this->get_xml_id ();
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
     * Generate a HTML link that points to the page.
     *
     * A link the user can click to get to the relative page.
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
     * Get the xml:id of this manuscript.
     *
     * @return string The xml:id.
     */

    public function get_xml_id ()
    {
        // return cached xml_id
        if ($this->xml_id) {
            return $this->xml_id;
        }
        $this->parse_tei ();
        return $this->xml_id;
    }

    /**
     * Get the title of this manuscript.
     *
     * @return string The title.
     */

    public function get_title ()
    {
        // return cached title
        if ($this->title) {
            return $this->title;
        }
        $this->parse_tei ();
        return $this->title;
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
     * Extract the manuscript id and title.
     *
     * Extracts the manuscript id and title from the TEI file.  We need the id
     * for the post metadata.  We need the title for the file list table.
     *
     * Also puts qTranslate-X tags into the title iff the title has an xml:lang
     * attribute.
     *
     * @return void
     */

    public function parse_tei ()
    {
        libxml_use_internal_errors (true);
        $xml = simplexml_load_file ($this->path);
        if ($xml === false) {
            // FIXME: handle errors here
            return null;
        }

        $xml->registerXPathNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
        $xml->registerXPathNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');

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
        // __ () calls qTranslate-xt
        $this->title = sanitize_text_field (__ (join (' ', $tmp), LANG), null, 'display');

        $teis = $xml->xpath ('/tei:TEI[@xml:id]');
        foreach ($teis as $tei) {
            $this->xml_id = sanitize_text_field (trim ($tei->attributes ('xml', true)->id));
        }
    }

    /**
     * Delete all pages with our slug
     *
     * Slugs must be unique for all children of one page, but the same slug may
     * be used by more than one page provided each has a different parent
     * page. Eg. /mss and /internal/mss both have the slug 'mss' but a
     * different parent page, so we must account for that.
     *
     * We also delete all pages that have the same slug with a hyphen and number
     * appended.  Eg. deleting the page /mss/my-slug would also delete the pages
     * /mss/my-slug-1 and /mss/my-slug-42, but not the page
     * /internal/mss/my-slug.
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
                    __ ('Error: could not unpublish page %s.', LANG),
                    $this->get_slug_with_link ()
                )
            );
        }
        return array (0, sprintf (__ ('Page %s unpublished.', LANG), $slug));
    }

    /**
     * Create a page containing one or more shortcodes.
     *
     * Build the content for the new page.  Some pages are made of more than one
     * transformation, eg. the transcription pages have a header, transcription
     * and footer.
     *
     * @param string $status Status to set on the newly created page.
     *
     * @return array Success or error messages
     */

    private function create_page ($status)
    {
        global $post, $config;

        // Set the page title
        $title = $this->get_title ();
        if (empty ($title)) {
            $title = __ ('No title', LANG);
        }

        // Put the shortcode onto the page
        $content = $config->get_opt ($this->section_id, 'shortcode');

        // The page slug
        $slug = $this->get_slug ();

        // Add a taxonomy entry that controls which sidebar is displayed.
        $sidebars = $config->get_opt ($this->section_id, 'sidebars');

        // Do not make public a child of a private page
        if (($status == 'public') && (cap_get_section_page_status ($this->section_id) == 'private')) {
            $status = 'private';
        }

        // Finally call Wordpress to create the page.
        $new_post = array (
            'post_name'    => $slug,
            'post_title'   => $title,
            'post_content' => $content,
            'post_status'  => $status,
            'post_type'    => 'page',
            'post_parent'  => cap_get_parent_id ($this->section_id),
            'tags_input'   => array ('xml'),
            'tax_input'    => array ('cap-sidebar' => explode (' ', $sidebars)),
        );
        $post_id = wp_insert_post ($new_post);
        if ($post_id) {
            // set the global $post for the cap_file_include plugin
            $post = get_post ($post_id);
            if ($slug == $post->post_name) {
                // add metadata to wp_postmeta
                delete_post_meta ($post_id, 'tei-xml-id');
                add_post_meta ($post_id, 'tei-xml-id', $this->get_xml_id ());
                // pipe the new page through the cap_file_include plugin to
                // generate the page content for the search engine
                $content = get_the_content ('', false, $post_id);
                apply_filters ('the_content', $content);
                // return white smoke
                return array (
                    0,
                    sprintf (
                        __ ('Page %1$s created with status set to %2$s.', LANG),
                        $this->get_slug_with_link (),
                        $status
                    )
                );
            }
        }
        return array (2, sprintf (__ ('Error: could not create page %s.', LANG), $slug));
    }

    /**
     * Perform an action on the manuscript.
     *
     * Actions:
     *   publish:  create the page with publish status
     *   private:  create the page with private status
     *   refresh:  re-create the page with the same status as before
     *   delete:   delete the page
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
        $slug   = $this->get_slug ();
        $status = $this->get_status ();

        error_log ("do_action ($this->section_id $slug $status => $action $this->path)");

        if ($action == $status) {
            // nothing to do
            return array (1, sprintf (__ ('The post is already %s.', LANG), $action));
        }
        if ($action == 'refresh') {
            $action = $status;
        }

        switch ($action) {
            case 'publish':
            case 'private':
                $this->delete_pages ();
                return $this->create_page ($action);
            case 'delete':
                return $this->delete_pages ();
        }
    }
}
