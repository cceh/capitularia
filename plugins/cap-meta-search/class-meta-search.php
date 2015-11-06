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
        add_filter ('get_the_excerpt',       array ($this, 'on_get_the_excerpt'));
    }

    public function on_init () {
        add_action ('cap_xsl_transformed',              array ($this, 'on_cap_xsl_transformed'),           10, 2);
        add_filter ('cap_meta_search_extract_metadata', array ($this, 'on_cap_meta_search_extract_metadata'), 10, 3);
    }

    private function meta ($post_id, $key, $node_list, $f = 'trim') {
        delete_post_meta ($post_id, $key);
        foreach ($node_list as $node) {
            $value = call_user_func ($f, $node->nodeValue);
            if (!is_array ($value)) {
                $value = array ($value);
            }
            foreach ($value as $val) {
                add_post_meta ($post_id, $key, $val);
                // error_log ("adding $key=$val to post $post_id");
            }
        }
    }

    private function nmtokens ($in) {
        return explode (' ', $in);
    }

    public function extract_meta ($post_id, $xml_path) {
        libxml_use_internal_errors (true);

        $dom = new \DOMDocument;
        $dom->Load ($xml_path);
        if ($dom === false) {
            return array ("Error: DOMDocument could not parse file: $xml_path");
        }
        $dom->xinclude ();

        $xpath = new \DOMXPath ($dom);
        $xpath->registerNamespace ('tei', 'http://www.tei-c.org/ns/1.0');
        $xpath->registerNamespace ('xml', 'http://www.w3.org/XML/1998/namespace');

        $this->meta (
            $post_id,
            'msitem-corresp',
            $xpath->query ('//tei:msItem/@corresp'),
            array ($this, 'nmtokens')
        );
        $this->meta ($post_id, 'origDate-notBefore', $xpath->query ('//tei:head/tei:origDate/@notBefore'), 'intval');
        $this->meta ($post_id, 'origDate-notAfter',  $xpath->query ('//tei:head/tei:origDate/@notAfter'),  'intval');
        $this->meta ($post_id, 'origPlace',          $xpath->query ('//tei:head/tei:origPlace'));
        $this->meta ($post_id, 'head-title-main',    $xpath->query ('//tei:head/tei:title[@type="main"]'));
        $this->meta (
            $post_id,
            'origPlace-ref',
            $xpath->query ('//tei:head/tei:origPlace/@ref'),
            array ($this, 'nmtokens')
        );

        $errors = libxml_get_errors ();
        libxml_clear_errors ();

        $messages = array ();
        foreach ($errors as $e) {
            $messages[] = "{$e->file}:{$e->line} {$e->level} {$e->code} {$e->message}\n";
        }
        return $messages;
    }

    public function on_cap_xsl_transformed ($post_id, $xml_path) {
        error_log ("on_cap_xsl_transformed ($post_id, $xml_path)");
        $this->extract_meta ($post_id, $xml_path);
    }

    public function on_cap_meta_search_extract_metadata ($errors, $post_id, $xml_path) {
        error_log ("on_cap_meta_search_extract_metadata ($post_id, $xml_path)");
        return array_merge ($errors, $this->extract_meta ($post_id, $xml_path));
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
     * Result snippets and highlighting
     */

    private function get_bounds ($content, $content_len, $match) {
        // offsets in $match are byte offsets even if the regex uses /u !!!
        // convert byte offset into char offset
        $char_offset = mb_strlen (mb_strcut ($content, 0, $match[0][1]));

        $start = max ($char_offset - 100, 0);
        $end   = min ($char_offset + 100, $content_len);

        if ($start && ($space = mb_strpos ($content, ' ', $start))) {
            $start = $space + 1;
        }
        if ($end   && ($space = mb_strpos ($content, ' ', $end))) {
            $end = $space;
        }

        return array ('start' => $start, 'end' => $end);
    }

    private function get_snippets ($content, $regex, $max_snippets = 3) {
        $regex = "#$regex#ui";
        $matches = array ();
        preg_match_all ($regex, $content, $matches, PREG_SET_ORDER | PREG_OFFSET_CAPTURE);

        $content_len = mb_strlen ($content);
        $snippets = array (); // array of array ('start' => pos, 'end' => pos)
        $n_snippets = 0;

        foreach ($matches as $match) {
            $snippet = $this->get_bounds ($content, $content_len, $match);
            if (($n_snippets > 0) && (($snippet['start'] - $snippets[$n_snippets - 1]['end']) < 5)) {
                // extend previous snippet
                $snippets[$n_snippets - 1]['end'] = $snippet['end'];
            } else {
                // add a new snippet
                $snippets[] = $snippet;
                $n_snippets++;
            }
            if ($n_snippets >= $max_snippets) {
                break;
            }
        }

        $text = "<ul>\n";

        foreach ($snippets as $snippet) {
            $start = $snippet['start'];
            $len   = $snippet['end'] - $start;
            $text .= "<li class='snippet'>\n";
            $text .= preg_replace ($regex, '<mark>${0}</mark>', mb_substr ($content, $start, $len));
            $text .= "</li>\n";
        }

        $text .= "</ul>\n";
        return $text;
    }

    private function escape_search_term ($term) {
        return preg_quote ($term, '#');
    }

    public function on_get_the_excerpt ($content) {
        global $wp_query;
        if (!is_admin () && $wp_query->is_main_query () && $wp_query->is_search ()) {
            if ($terms = $wp_query->get ('search_terms')) {
                $content = wp_strip_all_tags (
                    apply_filters ('the_content', get_the_content ()),
                    true
                );
                $terms = array_map (array ($this, 'escape_search_term'), $terms);
                $regex = implode ('|', $terms);
                return $this->get_snippets ($content, $regex);
            }
            return wp_strip_all_tags ($content);
        }
        return $content;
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
