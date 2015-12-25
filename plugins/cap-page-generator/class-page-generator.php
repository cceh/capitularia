<?php
/**
 * Capitularia Page Generator.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/**
 * Create page scaffoldings from TEI files.
 */

class Page_Generator
{
    /**
     * Our singleton instance
     */
    static private $instance = false;

    const NAME                 = 'Capitularia Page Generator';
    const NONCE_SPECIAL_STRING = 'cap_page_generator_nonce';
    const NONCE_PARAM_NAME     = '_ajax_nonce';
    const AFS_ROOT             = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';
    const XMLLINT              = 'local/bin/xmllint --noout --relaxng';

    private $options = null;  // array of options, cached for performance

    private function __construct ()
    {
        add_action ('init',                  array ($this, 'on_init'));
        add_action ('wp_enqueue_scripts',    array ($this, 'on_enqueue_scripts'));
        add_action ('admin_init',            array ($this, 'on_admin_init'));
        add_action ('admin_menu',            array ($this, 'on_admin_menu'));
        add_action ('admin_bar_menu',        array ($this, 'on_admin_bar_menu'), 200);
        add_action ('admin_enqueue_scripts', array ($this, 'on_admin_enqueue_scripts'));

        add_filter ('query_vars',  array ($this, 'on_query_vars'));
    }

    public function on_init ()
    {
        $this->shortcode = $this->get_opt ('shortcode');
    }

    public function on_enqueue_scripts ()
    {
        wp_register_style ('cap-page-gen-front', plugins_url ('css/front.css', __FILE__));
        wp_enqueue_style  ('cap-page-gen-front');
    }

    /**
     * If an instance exists, this returns it.  If not, it creates one and
     * returns it.
     *
     * @return Page_Generator
     */
    public static function get_instance ()
    {
        if (!self::$instance) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    private function get_opt ($name, $default = '')
    {
        if ($this->options === null) {
            $this->options = get_option ('cap_page_gen_options', array ());
        }
        return $this->options[$name] ? $this->options[$name] : $default;
    }

    private function shortcode ($xml, $xslt)
    {
        return "[{$this->shortcode} xml=\"$xml\" xslt=\"$xslt\"]\n[/{$this->shortcode}]\n";
    }

    private function sanitize_path ($path)
    {
        return rtrim (realpath (sanitize_text_field ($path)), '/');
    }

    private function get_page_from_slug ($slug)
    {
        $args = array (
            'name'           => $slug,
            'post_type'      => 'page',
            'post_status'    => 'any',
        );
        $posts = get_posts ($args);
        return $posts ? $posts[0] : null;
    }

    private function get_post_status ($slug)
    {
        $post = $this->get_page_from_slug ($slug);
        if ($post) {
            return get_post_status ($post->ID);
        }
        return 'delete';
    }

    private function get_manuscript_slug ($path)
    {
        return sanitize_title (pathinfo ($path, PATHINFO_FILENAME));
    }

    private function get_manuscript_title ($path)
    {
        libxml_use_internal_errors (true);
        $xml = simplexml_load_file ($path);
        if ($xml === false) {
            // FIXME: handle errors here
            return null;
        }

        $xml->registerXPathNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
        $xml->registerXPathNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');
        $titles = $xml->xpath ("//tei:titleStmt/tei:title[@type='main']");
        $tmp = array ();
        foreach ($titles as $title) {
            if (isset ($title['xml:lang'])) {
                $lang = $title['xml:lang'];
                if ($lang == 'ger') {
                    $lang = 'de';
                }
                if ($lang == 'eng') {
                    $lang = 'en';
                }
                $tmp[] = "[:{$lang}]{$title}[:]";
            } else {
                $tmp[] = strval ($title);
            }
        }
        return sanitize_text_field (__ (join ("\n", $tmp), 'capitularia'), null, 'display');
    }

    public function on_query_vars ($vars)
    {
        $vars[] = 'cap_page_gen';
        return $vars;
    }

    /*
     * Administration page stuff
     */

    public function on_admin_init ()
    {
        add_action ('wp_ajax_on_cap_action_file',  array ($this, 'on_cap_action_file'));

        add_settings_section (
            'cap_page_gen_options_section_general',
            'General Settings',
            array ($this, 'on_options_section_general'),
            'cap_page_gen_options'
        );

        add_settings_field (
            'cap_page_gen_options_xmlroot',
            'Directory for XML files',
            array ($this, 'on_options_field_xmlroot'),
            'cap_page_gen_options',
            'cap_page_gen_options_section_general'
        );
        add_settings_field (
            'cap_page_gen_options_xsltroot',
            'Directory for XSLT files',
            array ($this, 'on_options_field_xsltroot'),
            'cap_page_gen_options',
            'cap_page_gen_options_section_general'
        );
        add_settings_field (
            'cap_page_gen_options_xslschema',
            'The XSL schema',
            array ($this, 'on_options_field_xslschema'),
            'cap_page_gen_options',
            'cap_page_gen_options_section_general'
        );
        add_settings_field (
            'cap_page_gen_options_xsl_header',
            'The XSL for the header',
            array ($this, 'on_options_field_xslheader'),
            'cap_page_gen_options',
            'cap_page_gen_options_section_general'
        );
        add_settings_field (
            'cap_page_gen_options_xsl',
            'The XSL for the main part',
            array ($this, 'on_options_field_xsl'),
            'cap_page_gen_options',
            'cap_page_gen_options_section_general'
        );
        add_settings_field (
            'cap_page_gen_options_xsl_footer',
            'The XSL for the footer',
            array ($this, 'on_options_field_xslfooter'),
            'cap_page_gen_options',
            'cap_page_gen_options_section_general'
        );
        add_settings_field (
            'cap_page_gen_options_shortcode',
            'The Shortcode',
            array ($this, 'on_options_field_shortcode'),
            'cap_page_gen_options',
            'cap_page_gen_options_section_general'
        );

        register_setting ('cap_page_gen_options', 'cap_page_gen_options',  array ($this, 'on_validate_options'));
    }

    public function on_admin_enqueue_scripts ()
    {
        wp_register_style (
            'cap-page-gen-admin',
            plugins_url ('css/admin.css', __FILE__),
            array ('cap-jquery-ui-css')
        );
        wp_enqueue_style  ('cap-page-gen-admin');

        wp_register_script (
            'cap-page-gen-admin',
            plugins_url ('js/admin.js', __FILE__),
            array ('cap-jquery', 'cap-jquery-ui')
        );
        wp_enqueue_script ('cap-page-gen-admin');

        wp_localize_script (
            'cap-page-gen-admin',
            'ajax_object',
            array (
                'ajax_nonce' => wp_create_nonce (self::NONCE_SPECIAL_STRING),
                'ajax_nonce_param_name' => self::NONCE_PARAM_NAME,
            )
        );
    }

    public function on_admin_menu ()
    {
        // adds a menu entry to the settings menu
        add_options_page (
            self::NAME . ' Options',
            self::NAME,
            'manage_options',
            'cap_page_gen_options',
            array ($this, 'on_menu_options_page')
        );
        // adds a menu entry to the plugins menu
        add_submenu_page (
            'index.php',
            self::NAME . ' Dashboard',
            self::NAME,
            'edit_pages',
            'cap_page_gen_dashboard',
            array ($this, 'on_menu_dashboard_page')
        );
    }

    public function on_admin_bar_menu ($wp_admin_bar)
    {
        // add dash button
        if (!is_admin ()) {
            $args = array (
                'id'    => 'cap_page_gen_open',
                'title' => __ ('Page Generator'),
                'href'  => '/wp-admin/index.php?page=cap_page_gen_dashboard',
                'meta'  => array ('class' => 'cap-page-gen',
                                  'title' => self::NAME),
            );
        }
        $wp_admin_bar->add_node ($args);
    }

    private function format_error_message ($error_struct)
    {
        $message = '<p><strong>' . $error_struct[1] . "</strong></p>\n";
        if (count ($error_struct) >= 2 && is_array ($error_struct[2])) {
            $message .= "<ul>\n";
            // Return the array of xml validation errors
            foreach ($error_struct[2] as $e) {
                $message .= '<li>' . esc_html ($e) . "</li>\n";
            }
            $message .= "</ul>\n";
        }
        $class = 'notice-success';
        if ($error_struct[0] == 1) {
            $class = 'notice-warning';
        }
        if ($error_struct[0] >= 2) {
            $class = 'notice-error';
        }
        $message
            = "<div class='notice $class is-dismissible'>$message" .
            "<button class='notice-dismiss' type='button' " .
            "onclick='jQuery (this).parent ().slideUp ();'>" .
            "<span class='screen-reader-text'>Dismiss this notice.</span></button></div>\n";

        return $message;
    }

    /*
     * Incipit AJAX stuff
     */

    private function send_json ($error_struct)
    {
        $json = array (
            'success' => $error_struct[0] < 2, // 0 == success, 1 == warning, 2 == error
            'message' => $this->format_error_message ($error_struct),
        );

        if ($json['success']) {
            // We assume for now that the user dashboard changes only on
            // successful operations.  To update the table we return the new
            // table rows already formatted in HTML as a JSON string.
            ob_start ();
            $xmlroot = $this->get_opt ('xmlroot');
            $items = $this->prepare_items ($xmlroot);
            $table = new File_List_Table ();
            $table->prepare_items ($items);
            $table->display_rows_or_placeholder ();
            $json['rows'] = ob_get_clean ();
        }

        wp_send_json ($json);
    }

    private function set_status ($slug, $status)
    {
        $post = $this->get_page_from_slug ($slug);
        $updated = array ('ID' => $post->ID, 'post_status' => $status);
        return wp_update_post ($updated); // wp_update_post returns 0 on error
    }

    /**
     * Delete all pages with a slug that starts with @slug
     *
     * @param string $slug The post slug.
     *
     * @return int No. of deleted posts.
     */

    private function delete_pages ($slug)
    {
        if (empty ($slug)) {
            return 0;
        }

        global $wpdb;
        $sql = $wpdb->prepare ('select ID from wp_posts where post_name REGEXP %s', "^$slug(-\\d)?\$");
        error_log ("Deleting posts: SQL: $sql");

        $ids = $wpdb->get_col ($sql, 0);

        if (count ($ids) > 9) {
            // guard against disaster
            return 0;
        }

        $count = 0;
        foreach ($ids as $id) {
            // bypass trash or we'll still have the slug in the bloody way
            error_log ("Deleting post: $id");
            if (wp_delete_post ($id, true) !== false) {
                $count++;
            }
        }
        return $count;
    }

    /**
     * Create a page filled in with the appropriate shortcodes.
     *
     * @param string $path   Path to the xml file.
     * @param string $status Status of the new page.
     *
     * @return mixed The new page slug on success, false on error.
     */

    private function create_page ($path, $status)
    {
        $title = $this->get_manuscript_title ($path);
        if (empty ($title)) {
            return 0;
        }

        $parent_id = $this->get_page_from_slug ('mss')->ID;
        $slug  = $this->get_manuscript_slug ($path);

        $xsltroot = $this->get_opt ('xsltroot') . '/';

        // rebase paths according to cap_xsl_processor directories
        $cap_xsl_options = get_option ('cap_xsl_options');
        $xsltroot2 = $cap_xsl_options['xsltroot'] . '/';
        if (strncmp ($xsltroot, $xsltroot2, strlen ($xsltroot2)) == 0) {
            $xsltroot = substr ($xsltroot, strlen ($xsltroot2));
        }
        $xmlroot2 = $cap_xsl_options['xmlroot'] . '/';
        if (strncmp ($path, $xmlroot2, strlen ($xmlroot2)) == 0) {
            $path = substr ($path, strlen ($xmlroot2));
        }

        $content  = $this->shortcode ($path, $xsltroot . $this->get_opt ('xslheader'));
        $content .= $this->shortcode ($path, $xsltroot . $this->get_opt ('xsl'));
        $content .= $this->shortcode ($path, $xsltroot . $this->get_opt ('xslfooter'));

        $new_post = array (
            'post_name'    => $slug,
            'post_title'   => $title,
            'post_content' => $content,
            'post_status'  => $status,
            'post_type'    => 'page',
            'post_parent'  => $parent_id,
            'tags_input'   => array ('xml'),
            'tax_input'    => array ('cap-sidebar' => array ('transcription')),
        );
        $post_id = wp_insert_post ($new_post);
        if ($post_id) {
            $post = get_post ($post_id);
            return $post->post_name;
        }
        return false;
    }

    /**
     * Validate TEI file against schema.
     *
     * @param string $path The path of the TEI file to validate.
     *
     * @return mixed false if file not found, true if file ok, array of errors else
     */

    private function validate_xmllint ($path)
    {
        $schema = $this->get_opt ('xslschema');

        // The user can change the default catalog behaviour by redirecting
        // queries to its own set of catalogs, this can be done by setting the
        // XML_CATALOG_FILES environment variable to a list of catalogs, an
        // empty one should deactivate loading the default /etc/xml/catalog
        // default catalog.
        //
        // $catalog_dir = dirname ($schema);
        // putenv ("XML_CATALOG_FILES=$catalog_dir/catalog.xml");

        $messages = array ();
        $retval = 666;
        $cmdline = join (
            ' ',
            array (
                self::AFS_ROOT . self::XMLLINT,
                escapeshellarg ($schema),
                escapeshellarg ($path),
                '2>&1'
            )
        );
        exec ($cmdline, $messages, $retval); // 0 = ok, 3 = error
        if ($retval == 0) {
            return true;
        }
        return $messages;
    }

    private function slug_to_link ($slug)
    {
        return "<a href='/mss/$slug'>$slug</a>";
    }

    /**
     * Do action on one file.
     *
     * @param string $action   The action to do.
     * @param string $filename The filename of the TEI file.
     *
     * @return array of error code and relatve message
     *         0 = success, 1 = warning, 2 = error
     */

    protected function do_action_on_file ($action, $filename)
    {
        $slug   = $this->get_manuscript_slug ($filename);
        $status = $this->get_post_status ($slug);
        $root   = $this->get_opt ('xmlroot') . '/';
        $a_slug = $this->slug_to_link ($slug);

        error_log ("do_action_on_file ($slug $status => $action $filename)");

        if ($action == 'metadata') {
            // We proxy this action to the Meta Search plugin.
            $page = $this->get_page_from_slug ($slug);
            if (!$page) {
                return array (
                    2,
                    sprintf (__ ('Error while extracting metadata: no page with slug %s.', 'capitularia'), $slug)
                );
            }
            $errors = apply_filters ('cap_meta_search_extract_metadata', array (), $page->ID, $root . $filename);
            if ($errors) {
                return array (
                    2,
                    sprintf (__ ('Errors while extracting metadata from file %s.', 'capitularia'), $a_slug),
                    $errors
                );
            }
            return array (
                0,
                sprintf (__ ('Metadata extracted from file %s.', 'capitularia'), $a_slug)
            );
        }

        if ($action == 'validate') {
            $result = $this->validate_xmllint ($root . $filename);
            if ($result === false) {
                return array (
                    1,
                    sprintf (
                        __ ('Error while validating file %s. Validity of file is unknown.', 'capitularia'),
                        $a_slug
                    )
                );
            }
            if ($result === true) {
                return array (
                    0,
                    sprintf (__ ('File %s is valid TEI.', 'capitularia'), $a_slug)
                );
            }
            return array (
                2,
                sprintf (__ ('File %s is invalid TEI.', 'capitularia'), $a_slug),
                $result
            );
        }

        if ($action == 'refresh') {
            if ($status == 'delete') {
                return array (1, __ ('Cannot refresh unpublished file.', 'capitularia'));
            }
            if ($this->delete_pages ($slug) == 0) {
                return array (
                    2,
                    sprintf (__ ('Error: could not unpublish page %s while refreshing.', 'capitularia'), $a_slug)
                );
            }
            $action = $status;
            $status = 'delete';
        }

        if ($action == $status) {
            return array (
                1,
                sprintf (__ ('The post is already %s.', 'capitularia'), $action)
            );
        }

        if ($action == 'delete') {
            if ($this->delete_pages ($slug) == 0) {
                return array (
                    2,
                    sprintf (__ ('Error: could not unpublish page %s.', 'capitularia'), $a_slug)
                );
            }
            return array (
                0,
                sprintf (__ ('Page %s unpublished.', 'capitularia'), $slug)
            );
        }

        if ($status == 'delete') {
            $this->delete_pages ($slug);
            $new_slug = $this->create_page ($root . $filename, $action);
            if ($new_slug === false) {
                return array (
                    2,
                    sprintf (__ ('Error: could not create page %s.', 'capitularia'), $slug)
                );
            }
            $a_slug = $this->slug_to_link ($new_slug);
            return array (
                0,
                sprintf (__ ('Page %1$s created with status set to %2$s.', 'capitularia'), $a_slug, $action)
            );
        }

        if ($this->set_status ($slug, $action) === 0) {
            return array (
                2,
                sprintf (__ ('Error: could not set page %1$s to status %2$s.', 'capitularia'), $a_slug, $action)
            );
        }
        return array (
            0,
            sprintf (__ ('Page %1$s status set to %2$s.', 'capitularia'), $a_slug, $action)
        );
    }

    protected function process_bulk_actions ($action, $filenames)
    {
        $messages = array ();
        foreach ($filenames as $filename) {
            $messages[] = $this->format_error_message ($this->do_action_on_file ($action, $filename));
        }
        return implode ("\n", $messages);
    }

    public function on_cap_action_file ()
    {
        check_ajax_referer (self::NONCE_SPECIAL_STRING, self::NONCE_PARAM_NAME);
        if (!current_user_can ('edit_posts')) {
            wp_send_json_error (array ('message' => __ ('You have no permission to edit posts.', 'capitularia')));
        }

        $filename = sanitize_file_name ($_POST['path']);
        $action   = sanitize_key ($_POST['user_action']);

        $this->send_json ($this->do_action_on_file ($action, $filename));
    }

    public function prepare_items ($xmlroot)
    {
        $files = scandir ($xmlroot);
        $items = array ();
        foreach ($files as $file) {
            if ($file[0] == '.') {
                continue;
            }
            $path = $xmlroot . '/' . $file;
            if (is_dir ($path) || !is_readable ($path)) {
                continue;
            }

            $slug  = $this->get_manuscript_slug ($path);
            $title = $this->get_manuscript_title ($path);
            if (empty ($title)) {
                continue;
            }

            $status = $this->get_post_status ($slug);

            $item = new \stdClass ();
            $item->slug     = esc_attr ($slug);
            $item->filename = esc_html ($file);
            $item->status   = esc_attr ($status);
            $items[] = $item;
        }
        return $items;
    }

    private function p ($text)
    {
        echo ("<p>$text</p>\n");
    }

    /**
     * Output dashboard page.
     *
     * Found in wordpress admin under 'Dashboard' | 'Capitularia Page
     * Generator'.  Here's where we control the plugin.
     *
     * @return Nothing
     */

    public function on_menu_dashboard_page ()
    {
        $xmlroot = $this->get_opt ('xmlroot');
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n  <h2>$title</h2>\n");

        echo ("<div class='cap_page_dash_message'>\n");
        if (isset ($_REQUEST['action']) && isset ($_REQUEST['filenames'])) {
            $action = $_REQUEST['action'];
            if ($action == '-1' and isset ($_REQUEST['action2'])) {
                $action = $_REQUEST['action2'];
            }
            echo ($this->process_bulk_actions ($action, $_REQUEST['filenames']));
        }
        echo ("</div>\n");

        $this->p (sprintf (__ ('Reading directory: %s', 'capitularia'), $xmlroot));
        echo ("<form id='cap_page_gen_form' method='get'>");
        // posts back to wp-admin/index.php, ensure that we get back to our
        // current page
        echo ("<input type='hidden' name='page' value='{$_REQUEST['page']}' />");

        $items = $this->prepare_items ($xmlroot);
        $table = new File_List_Table ();
        $table->prepare_items ($items);
        $table->display ();

        echo ("</form></div>\n");
    }

    /**
     * Our settings page.  Found in wordpress admin under 'Settings' |
     * 'Capitularia Page Generator'.
     *
     * @return Nothing
     */

    public function on_menu_options_page ()
    {
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n<h2>$title</h2>\n<form method='post' action='options.php'>");
        settings_fields ('cap_page_gen_options');
        do_settings_sections ('cap_page_gen_options');
        submit_button ();
        echo ('</form>');
    }

    public function on_options_section_general ()
    {
    }

    public function on_options_field_xmlroot ()
    {
        $setting = $this->get_opt ('xmlroot');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xmlroot]' value='$setting' />";
        $this->p (
            sprintf (
                __ ('Directory in the AFS, eg.: %s', 'capitularia'),
                self::AFS_ROOT . 'http/docs/cap/publ/mss'
            )
        );
    }

    public function on_options_field_xsltroot ()
    {
        $setting = $this->get_opt ('xsltroot');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xsltroot]' value='$setting' />";
        $this->p (
            sprintf (
                __ ('Directory in the AFS, eg.: %s', 'capitularia'),
                self::AFS_ROOT . 'http/docs/cap/publ/transform'
            )
        );
    }

    public function on_options_field_xslschema ()
    {
        $setting = $this->get_opt ('xslschema');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xslschema]' value='$setting' />";
        $this->p (__ ('The path to the xsl schema file.', 'capitularia'));
    }

    public function on_options_field_xsl ()
    {
        $setting = $this->get_opt ('xsl');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xsl]' value='$setting' />";
        $this->p (__ ('The filename of the main xsl file.', 'capitularia'));
    }

    public function on_options_field_xslheader ()
    {
        $setting = $this->get_opt ('xslheader');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xslheader]' value='$setting' />";
        $this->p (__ ('The filename of the xsl header file.', 'capitularia'));
    }

    public function on_options_field_xslfooter ()
    {
        $setting = $this->get_opt ('xslfooter');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xslfooter]' value='$setting' />";
        $this->p (__ ('The filename of the xsl footer file.', 'capitularia'));
    }

    public function on_options_field_shortcode ()
    {
        $setting = $this->get_opt ('shortcode');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[shortcode]' value='$setting' />";
        $this->p (__ ('The shortcode, eg.: cap_xsl', 'capitularia'));
    }

    public function on_validate_options ($options)
    {
        $options['xmlroot']   = $this->sanitize_path ($options['xmlroot']);
        $options['xsltroot']  = $this->sanitize_path ($options['xsltroot']);
        $options['xslschema'] = $this->sanitize_path ($options['xslschema']);
        $options['xsl']       = sanitize_file_name   ($options['xsl']);
        $options['xslheader'] = sanitize_file_name   ($options['xslheader']);
        $options['xslfooter'] = sanitize_file_name   ($options['xslfooter']);
        $options['shortcode'] = trim (sanitize_key   ($options['shortcode']));
        return $options;
    }

    public static function on_activation ()
    {
    }

    public static function on_deactivation ()
    {
    }

    public static function on_uninstall ()
    {
    }
}
