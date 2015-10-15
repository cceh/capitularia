<?php
/*
Plugin Name: Capitularia Page Generator
Plugin URI:
Description: Generate page stubs from files in a directory.
Version:     0.1.0
Author:      Marcello Perathoner
Author URI:
License:     GPLv2 or later
Text Domain: cap-page-gen
*/

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

class Cap_Page_Generator {
    /**
     * Our singleton instance
     */
    static $instance = false;

    const NAME                 = 'Capitularia Page Generator';
    const NONCE_SPECIAL_STRING = 'cap_nonce';
    const NONCE_PARAM_NAME     = '_ajax_nonce';

    private $options = NULL;  // array of options, cached for performance

    private function __construct () {
        add_action ('init',                  array ($this, 'on_init'));
        add_action ('wp_enqueue_scripts',    array ($this, 'on_enqueue_scripts'));
        add_action ('admin_init',            array ($this, 'on_admin_init'));
        add_action ('admin_menu',            array ($this, 'on_admin_menu'));
        add_action ('admin_bar_menu',        array ($this, 'on_admin_bar_menu'), 200);
        add_action ('admin_enqueue_scripts', array ($this, 'on_admin_enqueue_scripts'));

        add_filter ('query_vars',  array ($this, 'on_query_vars'));
    }

    public function on_init () {
        $this->shortcode = $this->get_opt ('shortcode');
        wp_register_style ('cap_page_gen_front_style', plugins_url ('css/front.css', __FILE__));
    }

    public function on_enqueue_scripts () {
        wp_enqueue_style ('cap_page_gen_front_style');
    }

    /**
     * If an instance exists, this returns it.  If not, it creates one and
     * returns it.
     *
     * @return Cap_Page_Gen_Processor
     */
    public static function getInstance () {
        if (!self::$instance)
            self::$instance = new self;
        return self::$instance;
    }

    private function get_opt ($name, $default = '') {
        if ($this->options === NULL)
            $this->options = get_option ('cap_page_gen_options', array ());
        return $this->options[$name] ? $this->options[$name] : $default;
    }

    private function urljoin ($url1, $url2) {
        return rtrim ($url1, '/') . '/' . $url2;
    }

    private function shortcode ($xml, $xslt) {
        return "[{$this->shortcode} xml=\"$xml\" xslt=\"$xslt\"]\n[/{$this->shortcode}]\n";
    }

    private function add_i18n_tags ($content) {
        return "[:de]\n$content\n[:]\n"; // qTranslate-x
    }

    private function increment_metadata ($post_id, $meta) {
        $n = get_metadata ('post', $post_id, $meta, true) or 0;
        $n++;
        update_post_meta ($post_id, $meta, $n);
        return $n;
    }

    private function sanitize_path ($path) {
        return rtrim (realpath (sanitize_text_field ($path)), '/');
    }

    private function get_page_from_slug ($slug) {
        $args = array (
            'name'           => $slug,
            'post_type'      => 'page',
            'post_status'    => 'any',
        );
        $posts = get_posts ($args);
        return $posts ? $posts[0] : NULL;
    }

    private function get_post_status ($slug) {
        $post = $this->get_page_from_slug ($slug);
        if ($post) {
            return get_post_status ($post->ID);
        }
        return 'delete';
    }

    private function get_manuscript_slug ($path) {
        return sanitize_title (pathinfo ($path, PATHINFO_FILENAME));
    }

    private function get_manuscript_title ($path) {
        libxml_use_internal_errors (true);
        $xml = simplexml_load_file ($path);
        if ($xml === false)
            // FIXME: handle errors here
            return NULL;

        $xml->registerXPathNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
        $xml->registerXPathNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');
        $titles = $xml->xpath ("//tei:titleStmt/tei:title[@type='main']");
        $tmp = array ();
        foreach ($titles as $title) {
            if (isset ($title['xml:lang'])) {
                $lang = $title['xml:lang'];
                $tmp[] = "[:{$lang}]{$title}[:]";
            } else {
                $tmp[] = strval ($title);
            }
        }
        return sanitize_text_field (__(join ("\n", $tmp)), NULL, 'display');
    }

    public function on_query_vars ($vars) {
        $vars[] = 'cap_page_gen';
        return $vars;
    }

    /**
     * Administration page stuff
     *
     */

    public function on_admin_init () {
        // Our "Settings" page
        // CSS for the "Settings" page
        wp_register_style ('cap_page_gen_admin_style', plugins_url ('css/admin.css', __FILE__));

        wp_register_script ('cap_page_gen_admin_js', plugins_url ('js/admin.js', __FILE__), array ('jquery'));

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

    public function on_admin_enqueue_scripts () {
        wp_enqueue_style ('cap_page_gen_admin_style');
        wp_enqueue_script ('cap_page_gen_admin_js');
        wp_localize_script ('cap_page_gen_admin_js', 'ajax_object',
                            array ('ajax_nonce' => wp_create_nonce (self::NONCE_SPECIAL_STRING),
                                   'ajax_nonce_param_name' => self::NONCE_PARAM_NAME,
                            ));
    }

    public function on_admin_menu () {
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

    public function on_admin_bar_menu ($wp_admin_bar) {
        // add dash button
        if (!is_admin ()) {
            $args = array (
                'id'    => 'cap_page_gen_open',
                'title' => __ ('Page Generator'),
                'href'  => '/wp-admin/index.php?page=cap_page_gen_options',
                'meta'  => array ('class' => 'cap-page-gen',
                                  'title' => self::NAME),
            );
        }
        $wp_admin_bar->add_node ($args);
    }

    /**
     * AJAX
     *
     *
     * @return
     */

    private function set_status ($slug, $status) {
        $post = $this->get_page_from_slug ($slug);
        $post['post_status'] = $status;
        return wp_update_post ($post) === 0; // wp_update_post returns 0 on error
    }

    private function delete ($slug) {
        $post = $this->get_page_from_slug ($slug);
        if (!$post)
            return false;
        error_log ("Cap_Page_Generator::delete () $slug {$post->ID}");

        return wp_delete_post ($post->ID, true);
    }

    private function send_json ($error, $success_msg, $error_msg) {
        if ($error) {
            wp_send_json_error (array (
                'message' => $error_msg
            ));
        }
        wp_send_json_success (array (
            'message' => $success_msg,
        ));
    }

    /**
     * Create a page filled in with the appropriate shortcodes.
     *
     * @param path    Path to the xml file.
     * @param status  Status of the new page.
     *
     * @return  0 on error
     */

    function create_page ($path, $status) {
        $title = $this->get_manuscript_title ($path);
        if (empty ($title))
            return 0;

        $parent_id = $this->get_page_from_slug ('mss')->ID;
        $slug  = $this->get_manuscript_slug ($path);

        $xsltroot = $this->get_opt ('xsltroot') . '/';

        // rebase paths according to cap_xsl_processor directories
        $cap_xsl_options = get_option ('cap_xsl_options');
        $xsltroot2 = $cap_xsl_options['xsltroot'] . '/';
        if (strcmp ($xsltroot, $xsltroot2, strlen ($xsltroot2)) == 0) {
            $xsltroot = substr ($xsltroot, strlen ($xsltroot2));
        }
        $xmlroot2 = $cap_xsl_options['xmlroot'] . '/';
        if (strcmp ($path, $xmlroot2, strlen ($xmlroot2)) == 0) {
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
        );
        return wp_insert_post ($new_post);
    }

    function on_cap_action_file () {
        check_ajax_referer (self::NONCE_SPECIAL_STRING, self::NONCE_PARAM_NAME);
        if (!current_user_can ('edit_posts'))
            wp_send_json_error (array ('message' => 'You have no permission to edit posts.'));

        $filename   = sanitize_file_name ($_POST['path']);
        $slug       = sanitize_key ($_POST['slug']);
        $action     = sanitize_key ($_POST['user_action']);
        $status     = $this->get_post_status ($slug);

        error_log ("on_cap_action_file () $action $status $filename $slug");

        if ($status == $action)
            wp_send_json_error (array ('message' => "The post is already $action"));

        if ($action == 'delete') {
            $this->send_json ($this->delete ($slug) === false,
                              __("Page $slug deleted."), __("Error: could not delete page $slug."));
        }

        if ($status == 'delete') {
            // create a new page
            $root = $this->get_opt ('xmlroot') . '/';
            $this->send_json ($this->create_page ($root . $filename, $action) === 0,
                              __("Page $slug created."),
                              __("Error: could not create page $slug."));
        }

        // only change published status
        $this->send_json ($this->set_status ($slug, $action) === false,
                          __("Page $slug status set to $action"),
                          __("Error: could not set page $slug to status $action."));
    }

    /**
     * Our main page.  Found in wordpress admin under 'Dashboard' | 'Capitularia
     * Page Generator'.  Here's where we control the plugin.
     *
     *
     * @return Nothing
     */

    public function on_menu_dashboard_page () {
        $xmlroot = $this->get_opt ('xmlroot');
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n  <h2>$title</h2>\n");
        echo ("<p>Reading directory: {$xmlroot}</p>\n");

        $files = scandir ($xmlroot);
        if ($files) {
            echo ("<table class='wp-list-table widefat fixed striped pages dash-files-status'>\n");
            echo ("<thead><tr><td id='cb' class='manage-column column-cb check-column'>
<label class='screen-reader-text' for='cb-select-all-1'>Select All</label>
<input id='cb-select-all-1' type='checkbox'>
</td><th>Slug</th><th>Action</th><th class='title'>Title</th></tr></thead><tbody>\n");
            foreach ($files as $file) {
                if ($file[0] == '.')
                    continue;
                $path = $xmlroot . '/' . $file;
                if (is_dir ($path) || !is_readable ($path))
                    continue;

                $slug  = $this->get_manuscript_slug ($path);
                $title = $this->get_manuscript_title ($path);
                if (empty ($title))
                    continue;

                $status = $this->get_post_status ($slug);
                $b_pub  = $this->make_action_button ('publish', $status, $slug, $file);
                $b_priv = $this->make_action_button ('private', $status, $slug, $file);
                $b_del  = $this->make_action_button ('delete',  $status, $slug, $file);
                $aslug  = $status != 'delete' ? "<a href='/mss/$slug'>$slug</a>" : $slug;
                echo ("<tr data-path='$file' data-slug='$slug' class='cap-status-$status'>\n");
                echo ("<th class='check-column' scope='row'><input id='cb-select-$slug' type='checkbox' value='$slug' name='post[]'></th>");
                echo ("<td>$aslug</td><td>$b_pub$b_priv$b_del</td><td>$title</td></tr>\n");
            }
            echo ("</tbody></table>\n");
        }

        echo ("</div>\n");
    }

    private function make_action_button ($action, $status, $slug, $path) {
        $disable = $action == $status ? "disabled='disabled'" : "";
        $path = esc_attr ($path);
        $slug = esc_attr ($slug);
        return  "<button class='status status-$status action-$action' $disable onclick=\"on_cap_action_file (this, '$action')\">$action</button>";
    }

    /**
     * Our settings page.  Found in wordpress admin under 'Settings' |
     * 'Capitularia Page Generator'.
     *
     *
     * @return Nothing
     */

    public function on_menu_options_page () {
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n<h2>$title</h2>\n<form method='post' action='options.php'>");
        settings_fields ('cap_page_gen_options');
        do_settings_sections ('cap_page_gen_options');
        submit_button ();
        echo ('</form>');
    }

    public function on_options_section_general () {
    }

    public function on_options_field_xmlroot () {
        $setting = $this->get_opt ('xmlroot');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xmlroot]' value='$setting' />";
        echo "<p>Directory in the AFS, eg.: /afs/rrz/vol/www/projekt/capitularia/http/docs/cap/publ/mss</p>";
    }

    public function on_options_field_xsltroot () {
        $setting = $this->get_opt ('xsltroot');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xsltroot]' value='$setting' />";
        echo "<p>Directory in the AFS, eg.: /afs/rrz/vol/www/projekt/capitularia/http/docs/cap/publ/transform</p>";
    }

    public function on_options_field_xslschema () {
        $setting = $this->get_opt ('xslschema');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xslschema]' value='$setting' />";
        echo "<p>The path to the xsl schema file.</p>";
    }

    public function on_options_field_xsl () {
        $setting = $this->get_opt ('xsl');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xsl]' value='$setting' />";
        echo "<p>The filename of the main xsl file.</p>";
    }

    public function on_options_field_xslheader () {
        $setting = $this->get_opt ('xslheader');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xslheader]' value='$setting' />";
        echo "<p>The filename of the xsl header file.</p>";
    }

    public function on_options_field_xslfooter () {
        $setting = $this->get_opt ('xslfooter');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[xslfooter]' value='$setting' />";
        echo "<p>The filename of the xsl footer file.</p>";
    }

    public function on_options_field_shortcode () {
        $setting = $this->get_opt ('shortcode');
        echo "<input class='file-input' type='text' name='cap_page_gen_options[shortcode]' value='$setting' />";
        echo "<p>The shortcode, eg.: cap_xsl</p>";
    }

    public function on_validate_options ($options) {
        $options['xmlroot']   = $this->sanitize_path ($options['xmlroot']);
        $options['xsltroot']  = $this->sanitize_path ($options['xsltroot']);
        $options['xslschema'] = $this->sanitize_path ($options['xslschema']);
        $options['xsl']       = sanitize_file_name   ($options['xsl']);
        $options['xslheader'] = sanitize_file_name   ($options['xslheader']);
        $options['xslfooter'] = sanitize_file_name   ($options['xslfooter']);
        $options['shortcode'] = trim (sanitize_key   ($options['shortcode']));
        return $options;
    }

    public static function on_activation () {
    }

    public static function on_deactivation () {
    }

    public static function on_uninstall () {
    }

}

$i = Cap_Page_Generator::getInstance ();

register_activation_hook   (__FILE__, array ($i, 'on_activation'));
register_deactivation_hook (__FILE__, array ($i, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($i, 'on_uninstall'));
