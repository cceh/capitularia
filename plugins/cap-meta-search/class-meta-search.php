<?php
/**
 * Capitularia Meta Search main class.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

class Meta_Search
{
    /**
     * Our singleton instance
     */
    static private $instance = false;

    const NAME                 = 'Capitularia Meta Search';
    const NONCE_SPECIAL_STRING = 'cap_meta_search_nonce';
    const NONCE_PARAM_NAME     = '_ajax_nonce';
    const AFS_ROOT = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';

    private $options            = null;

    private function __construct () {
        add_action ('init',                  array ($this, 'on_init'));
        add_action ('wp_enqueue_scripts',    array ($this, 'on_enqueue_scripts'));
        add_action ('admin_init',            array ($this, 'on_admin_init'));
        add_action ('admin_menu',            array ($this, 'on_admin_menu'));
        add_action ('admin_bar_menu',        array ($this, 'on_admin_bar_menu'), 200);
        add_action ('admin_enqueue_scripts', array ($this, 'on_admin_enqueue_scripts'));
    }

    public function on_init () {
        add_action ('cap_xsl_transformed', array ($this, 'on_cap_xsl_transformed'), 10, 2);
    }

    private function meta ($post_id, $key, $node_list, $f = 'trim') {
        delete_post_meta ($post_id, $key);
        foreach ($node_list as $node) {
            $value = $f ($node->nodeValue);
            if (!is_array ($value)) {
                $value = array ($value);
            }
            foreach ($value as $val) {
                add_post_meta ($post_id, $key, $val);
                error_log ("adding $key=$val to post $post_id");
            }
        }
    }

    public function on_cap_xsl_transformed ($post_id, $xml_path) {
        libxml_use_internal_errors (true);
        error_log ("on_cap_xsl_transformed ($post_id, $xml_path)");

        $dom = new \DOMDocument;
        $dom->Load ($xml_path);
        if ($dom === false) {
            return false;
        }
        $dom->xinclude ();

        $xpath = new \DOMXPath ($dom);
        $xpath->registerNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
        $xpath->registerNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');

        $this->meta ($post_id, 'msitem-corresp',     $xpath->query ('//tei:msItem/@corresp'));
        $this->meta ($post_id, 'origDate-notBefore', $xpath->query ('//tei:head/tei:origDate/@notBefore'), 'intval');
        $this->meta ($post_id, 'origDate-notAfter',  $xpath->query ('//tei:head/tei:origDate/@notAfter'),  'intval');
        $this->meta ($post_id, 'origPlace',          $xpath->query ('//tei:head/tei:origPlace'));
        $this->meta ($post_id, 'head-title-main',    $xpath->query ('//tei:head/tei:title[@type="main"]'));
        $this->meta (
            $post_id,
            'origPlace-ref',
            $xpath->query ('//tei:head/tei:origPlace/@ref'),
            function ($in) {
                return explode (' ', $in);
            }
        );

        $errors = libxml_get_errors ();
        libxml_clear_errors ();
    }

    public function on_enqueue_scripts () {
        wp_register_style  ('cap-meta-search-front', plugins_url ('css/front.css', __FILE__));
        wp_enqueue_style   ('cap-meta-search-front');
        wp_register_script (
            'cap-meta-search-front',
            plugins_url ('js/front.js', __FILE__),
            array ('jquery', 'jquery-ui-progressbar')
        );
    }

    /**
     * If an instance exists, this returns it.  If not, it creates one and
     * returns it.
     *
     * @return Meta_Search
     */
    public static function getInstance () {
        if (!self::$instance) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    private function get_option ($name, $default = '') {
        return cap_get_option ('cap_meta_search', $name, $default);
    }

    private function urljoin ($url1, $url2) {
        return rtrim ($url1, '/') . '/' . $url2;
    }

    /**
     * Administration page stuff
     */

    public function on_admin_init () {
        add_settings_section (
            'cap_meta_search_options_section_general',
            'General Settings',
            array ($this, 'on_options_section_general'),
            'cap_meta_search_options'
        );

        add_settings_field (
            'cap_meta_search_options_xpath',
            'XPath expression',
            array ($this, 'on_options_field_xpath'),
            'cap_meta_search_options',
            'cap_meta_search_options_section_general'
        );

        register_setting (
            'cap_meta_search_options',
            'cap_meta_search_options',
            array ($this, 'on_validate_options')
        );
    }

    public function on_admin_enqueue_scripts () {
        wp_register_style ('cap-meta-search-admin', plugins_url ('css/admin.css', __FILE__));
        wp_enqueue_style  ('cap-meta-search-admin');
    }

    public function on_admin_menu () {
        // adds a menu entry to the settings menu
        add_options_page (
            self::NAME . ' Options',
            self::NAME,
            'manage_options',
            'cap_meta_search_options',
            array ($this, 'on_menu_options_page')
        );
    }

    public function on_admin_bar_menu ($wp_admin_bar) {
        // add meta load button

        // this works because admin_bar_menu is one of the last hooks called
        $xmlfiles = do_action ('cap_xsl_get_xmlfiles');

        if (count ($xmlfiles) > 0) {
            wp_enqueue_script  ('cap-meta-search-front');
            wp_localize_script (
                'cap-meta-search-front', 'ajax_object',
                array ('ajax_nonce' => wp_create_nonce (self::NONCE_SPECIAL_STRING),
                       'ajax_nonce_param_name' => self::NONCE_PARAM_NAME
                )
            );

            $xmlfile = esc_attr ($xmlfiles[0]);
            $args = array (
                'id'      => 'cap_meta_search_extract_metadata',
                'title'   => 'Metadata',
                'onclick' => 'on_cap_meta_search_extract_metadata ($post->ID, $xmlfile);',
                'meta'    => array ('class' => 'cap-meta-search-reload',
                                    'title' => self::NAME . ': Extract metadata from TEI file.'),
            );
            $wp_admin_bar->add_node ($args);
        }
    }

    public function on_menu_options_page () {
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n<h2>$title</h2>\n<form method='post' action='options.php'>");
        settings_fields ('cap_meta_search_options');
        do_settings_sections ('cap_meta_search_options');
        submit_button ();
        echo ('</form>');

        echo ("<h3>Stats</h3>\n<table class='form-table'>");
        echo ("</table></div>\n");
    }

    public function on_options_section_general () {
    }

    public function on_options_field_xpath () {
        $setting = $this->get_option ('xpath');
        echo "<input class='file-input' type='text' name='cap_meta_search_options[xpath]' value='$setting' />";
        echo '<p>XPath expression</p>';
    }

    private function sanitize_path ($path) {
        return rtrim (realpath (sanitize_text_field ($path)), '/');
    }

    public function on_validate_options ($options) {
        // $options['xpath']   = $this->sanitize_xpath ($options['xpath']);
        return $options;
    }

    public static function on_activation () {
    }

    public static function on_deactivation () {
    }

    public static function on_uninstall () {
    }
}
