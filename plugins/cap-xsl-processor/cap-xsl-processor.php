<?php
/*
Plugin Name: Capitularia XSL Processor
Plugin URI:
Description: An xsl processor that caches its output in the wordpress database.
Version:     0.1.0
Author:      Marcello Perathoner
Author URI:
License:     GPLv2 or later
Text Domain: cap-xsl
*/

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

class Cap_XSL_Stats {

    public $pages = 0, $hits = 0, $hits_temp = 0, $misses = 0;
    public $page_cached = 0, $page_mtime = 0, $xml_mtime = 0, $xsl_mtime = 0;

    public function get_tooltip ($post_id) {
        $post_id = intval ($post_id);
        global $wpdb;
        $result = $wpdb->get_results (
            "SELECT meta_key, meta_value FROM wp_postmeta WHERE post_id = $post_id",
            OBJECT_K);
        $hits   = $result['cap_xsl_cache_hits_temp']->meta_value;
        $misses = $result['cap_xsl_cache_misses']->meta_value;
        return "hits: $hits\nmisses: $misses";
    }

    public function get_table_rows () {
        global $wpdb;
        $this->pages = $wpdb->get_var (
            "SELECT COUNT(*)        FROM wp_postmeta WHERE meta_key = 'cap_xsl_cache_time'");
        $this->hits = $wpdb->get_var (
            "SELECT SUM(meta_value) FROM wp_postmeta WHERE meta_key = 'cap_xsl_cache_hits'");
        $this->misses = $wpdb->get_var (
            "SELECT SUM(meta_value) FROM wp_postmeta WHERE meta_key = 'cap_xsl_cache_misses'");

        return "<tr><th>Cached pages</th><td>{$this->pages}</td></tr>\n" .
               "<tr><th>Cache hits</th><td>{$this->hits}</td></tr>\n" .
             "<tr><th>Cache misses</th><td>{$this->misses}</td></tr>\n";
    }
}

class Cap_XSL_Processor {
    /**
     * Our singleton instance
     */
    static $instance = false;

    const NAME = 'Capitularia XSL Processor';

    private $options            = NULL;
    private $shortcode          = 'cap_xsl';
    private $page_has_shortcode = false;
    private $save_post          = false;
    private $do_revision        = false;
    private $stats              = NULL;
    private $post_id            = 0;
    private $cache_time         = 0; // unixtime
    private $modified_time      = 0; // unixtime

    private function __construct () {
        add_action ('init',                  array ($this, 'on_init'));
        add_action ('wp_enqueue_scripts',    array ($this, 'on_enqueue_scripts'));
        add_action ('admin_init',            array ($this, 'on_admin_init'));
        add_action ('admin_menu',            array ($this, 'on_admin_menu'));
        add_action ('admin_bar_menu',        array ($this, 'on_admin_bar_menu'), 200);
        add_action ('admin_enqueue_scripts', array ($this, 'on_admin_enqueue_scripts'));

        add_filter ('the_content', array ($this, 'on_the_content_early'), 5);  // very early before wpautop
        add_filter ('the_content', array ($this, 'on_the_content_late'), 20);  // very late after do_shortcuts
        add_filter ('query_vars',  array ($this, 'on_query_vars'));
    }

    public function on_init () {
        $this->stats = new Cap_XSL_Stats ();
        $this->shortcode = $this->get_opt ('shortcode', $this->shortcode);
        add_shortcode ($this->shortcode, array ($this, 'on_shortcode'));
        wp_register_style ('cap_xsl_front_style', plugins_url ('css/front.css', __FILE__));
    }

    public function on_enqueue_scripts () {
        wp_enqueue_style ('cap_xsl_front_style');
    }

    /**
     * If an instance exists, this returns it.  If not, it creates one and
     * returns it.
     *
     * @return Cap_XSL_Processor
     */
    public static function getInstance () {
        if (!self::$instance)
            self::$instance = new self;
        return self::$instance;
    }

    private function get_opt ($name, $default = '') {
        if ($this->options === NULL)
            $this->options = get_option ('cap_xsl_options', array ());
        return $this->options[$name] ? $this->options[$name] : $default;
    }

    private function urljoin ($url1, $url2) {
        return rtrim ($url1, '/') . '/' . $url2;
    }

    private function wrap_in_shortcode ($content, $atts) {
        return "[{$this->shortcode} xml=\"{$atts['xml']}\" xslt=\"{$atts['xslt']}\"]\n$content\n[/{$this->shortcode}]\n";
    }

    private function hide_shortcodes_from_wpautop ($content) {
        // <pre></pre> added to turn off the 'wpautop' filter on the content of our shortcode
        $content = str_replace ("[{$this->shortcode} ",  "<pre>[{$this->shortcode} ",   $content);
        $content = str_replace ("[/{$this->shortcode}]", "[/{$this->shortcode}]</pre>", $content);
        return $content;
    }

    private function strip_pre ($content) {
        // strip the <pre>'s around our shortcodes (before saving the post)
        $content = str_replace ("<pre>[{$this->shortcode} ",   "[{$this->shortcode} ",  $content);
        $content = str_replace ("[/{$this->shortcode}]</pre>", "[/{$this->shortcode}]", $content);
        $content = str_replace ("[/{$this->shortcode}]\n</pre>", "[/{$this->shortcode}]", $content);
        return $content;
    }

    private function strip_shortcode ($content) {
        // strip our shortcodes (before presenting the post to the user)
        $content = preg_replace ("/\\[{$this->shortcode}.*?\\]/s", '', $content);
        $content = str_replace  ("[/{$this->shortcode}]",          '', $content);
        return $content;
    }

    private function add_i18n_tags ($content) {
        return "[:de]\n$content\n[:]\n"; // qTranslate-x
        // return "<!--:de-->\n$content\n<!--:-->\n"; // mqTranslate
    }

    private function increment_metadata ($post_id, $meta) {
        $n = get_metadata ('post', $post_id, $meta, true) or 0;
        $n++;
        update_post_meta ($post_id, $meta, $n);
        return $n;
    }


    public function on_the_content_early ($content) {
        $this->post_id       = intval (get_queried_object_id ());
        $this->cache_time    = intval (get_metadata ('post', $this->post_id, 'cap_xsl_cache_time', true));
        $this->modified_time = intval (get_post_modified_time ('U', true, $this->post_id));
        $this->stats->page_cached = $this->cache_time;
        $this->stats->page_mtime  = $this->modified_time;
        if (strpos ($content, $this->shortcode) !== false) {
            $this->page_has_shortcode = true;
            return $this->hide_shortcodes_from_wpautop ($content);
        }
        return $content;
    }

    public function on_shortcode ($atts, $content = "") {
        // NOTE: this function keeps the shortcode tags around because
        // we still need them in case we have to save the post.
        //
        // BUG: wpautop Works only if the shortcode tag and
        // attributes are on one line.

        // error_log ("on_shortcode ()");

        if (!$this->post_id) {
            // relevanssi uses get_the_content () instead of
            // the_content () and thus does not exercise the
            // 'the_content' filter stack
            return $content;
        }

        $args = shortcode_atts (array (
            'xml' => '',
            'xslt' => '',
        ), $atts);
        $xml  = $this->urljoin ($this->get_opt ('xmlroot'),  $atts['xml']);
        $xslt = $this->urljoin ($this->get_opt ('xsltroot'), $atts['xslt']);
        $xsltproc  = $this->get_opt ('xsltproc');

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
        $do_transform = $this->cache_time < max ($this->modified_time, $xml_file_time, $xslt_file_time);
        // do a transform if http query param cap_xsl == 'reload'
        $do_transform = $do_transform || (get_query_var ('cap_xsl', '') == 'reload');
        $this->save_post |= $do_transform;

        // do a revision only if page or xml changed
        $this->do_revision |= $this->cache_time < max ($this->modified_time, $xml_file_time);

        $this->page_has_shortcode = true;

        $this->stats->xml_mtime = $xml_file_time;
        $this->stats->xsl_mtime = $xslt_file_time;

        if (!$do_transform) {
            // return cached copy
            $this->increment_metadata ($this->post_id, 'cap_xsl_cache_hits');
            $this->increment_metadata ($this->post_id, 'cap_xsl_cache_hits_temp');
            return $this->wrap_in_shortcode ($content, $atts);
        }

        // call XSLT processor
        $output = array ();
        $retval = 666;
        $cmdline = join (' ', array (
            $xsltproc,
            escapeshellarg ($xslt),
            escapeshellarg ($xml)
            // cannot use tidy on such invalid input
            // '| /vol/local/bin/tidy -qni -xml -utf8 -wrap 80'
        ));
        // $output = shell_exec ($cmdline);
        exec ($cmdline, $output, $retval);
        $content = join ("\n", $output);

        return $this->wrap_in_shortcode ($content, $atts);
    }

    public function on_the_content_late ($content) {
        // This function saves the post if it needs saving and finally strips the shortcode tags.

        if (!$this->page_has_shortcode) {
            return $content;
        }

        // error_log ("on_the_content () page id = $this->post_id");

        $content = $this->strip_pre ($content);

        if ($this->save_post) {
            // error_log ("on_the_content () saving ...");

            // update metadata
            $this->increment_metadata ($this->post_id, 'cap_xsl_cache_misses');
            update_post_meta ($this->post_id, 'cap_xsl_cache_time', time ());
            update_post_meta ($this->post_id, 'cap_xsl_cache_hits_temp',  0);

            if (!$this->do_revision) {
                // error_log ("on_the_content () revisions disabled");
                // Turn off revisions for this save.  See:
                // https://core.trac.wordpress.org/browser/tags/4.3.1/src/wp-includes/revision.php#L150
                // Note: we cannot use the 'wp_revisions_to_keep' filter
                // because it would delete all previous revisions.
                add_filter (
                    'wp_save_post_revision_post_has_changed',
                    function ($post_has_changed, $last_revision, $post) { return false; },
                    10, 3
                );
            }

            // cache xslt output in database
            $my_post = array (
                'ID'           => $this->post_id,
                'post_content' => $this->add_i18n_tags ($content)
            );
            // error_log ("on_the_content () before update_post ...");
            wp_update_post ($my_post);
            // error_log ("on_the_content () after update_post ...");
        }

        return $this->strip_shortcode ($content);
    }

    public function on_query_vars ($vars) {
        $vars[] = 'cap_xsl';
        return $vars;
    }

    /**
     * Administration page stuff
     *
     */

    public function on_admin_init () {
        // Our "Settings" page
        // CSS for the "Settings" page
        wp_register_style ('cap_xsl_admin_style', plugins_url ('css/admin.css', __FILE__));

        add_settings_section (
            'cap_xsl_options_section_general',
            'General Settings',
            array ($this, 'on_options_section_general'),
            'cap_xsl_options'
        );

        add_settings_field (
            'cap_xsl_options_xmlroot',
            'Directory for XML files',
            array ($this, 'on_options_field_xmlroot'),
            'cap_xsl_options',
            'cap_xsl_options_section_general'
        );
        add_settings_field (
            'cap_xsl_options_xsltroot',
            'Directory for XSLT files',
            array ($this, 'on_options_field_xsltroot'),
            'cap_xsl_options',
            'cap_xsl_options_section_general'
        );
        add_settings_field (
            'cap_xsl_options_xsltproc',
            'The XSLT processor',
            array ($this, 'on_options_field_xsltproc'),
            'cap_xsl_options',
            'cap_xsl_options_section_general'
        );
        add_settings_field (
            'cap_xsl_options_shortcode',
            'The Shortcode',
            array ($this, 'on_options_field_shortcode'),
            'cap_xsl_options',
            'cap_xsl_options_section_general'
        );

        register_setting ('cap_xsl_options', 'cap_xsl_options',  array ($this, 'on_validate_options'));
    }

    public function on_admin_enqueue_scripts () {
        wp_enqueue_style ('cap_xsl_admin_style');
    }

    public function on_admin_menu () {
        // adds a menu entry to the settings menu
        add_options_page (
            self::NAME . ' Options',
            self::NAME,
            'manage_options',
            'cap_xsl_options',
            array ($this, 'on_menu_options_page')
        );
    }

    public function on_admin_bar_menu ($wp_admin_bar) {
        // add clear cache button
        if ($this->page_has_shortcode) {
            // error_log ("on_admin_bar_menu ()");

            $args = array (
                'id'    => 'cap_xsl_cache_reload',
                'title' => 'XSL',
                'href'  => $_SERVER["REQUEST_URI"] . '?cap_xsl=reload',
                'meta'  => array ('class' => 'cap-xsl',
                                  'title' => self::NAME . "\n" . $this->stats->get_tooltip ($this->post_id))
            );
            $wp_admin_bar->add_node ($args);
        }
    }

    public function on_menu_options_page () {
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n<h2>$title</h2>\n<form method='post' action='options.php'>");
        settings_fields ('cap_xsl_options');
        do_settings_sections ('cap_xsl_options');
        submit_button ();
        echo ('</form>');

        echo ("<h3>Stats</h3>\n<table class='form-table'>");
        echo ($this->stats->get_table_rows ());
        echo ("</table></div>\n");
    }

    public function on_options_section_general () {
    }

    public function on_options_field_xmlroot () {
        $setting = $this->get_opt ('xmlroot');
        echo "<input class='file-input' type='text' name='cap_xsl_options[xmlroot]' value='$setting' />";
        echo "<p>Directory in the AFS, eg.: /afs/rrz/vol/www/projekt/capitularia/http/docs/cap/publ/mss</p>";
    }

    public function on_options_field_xsltroot () {
        $setting = $this->get_opt ('xsltroot');
        echo "<input class='file-input' type='text' name='cap_xsl_options[xsltroot]' value='$setting' />";
        echo "<p>Directory in the AFS, eg.: /afs/rrz/vol/www/projekt/capitularia/http/docs/cap/publ/transform</p>";
    }

    public function on_options_field_xsltproc () {
        $setting = $this->get_opt ('xsltproc');
        echo "<input class='file-input' type='text' name='cap_xsl_options[xsltproc]' value='$setting' />";
        echo "<p>The path to the xslt processor, eg.: /usr/bin/xsltproc</p>";
    }

    public function on_options_field_shortcode () {
        $setting = $this->get_opt ('shortcode');
        echo "<input class='file-input' type='text' name='cap_xsl_options[shortcode]' value='$setting' />";
        echo "<p>The shortcode, eg.: cap_xsl</p>";
    }

    private function sanitize_path ($path) {
        return rtrim (realpath (sanitize_text_field ($path)), '/');
    }

    public function on_validate_options ($options) {
        $options['xmlroot']   = $this->sanitize_path ($options['xmlroot']);
        $options['xsltroot']  = $this->sanitize_path ($options['xsltroot']);
        $options['xsltproc']  = $this->sanitize_path ($options['xsltproc']);
        $options['shortcode'] = trim (sanitize_key ($options['shortcode']));
        return $options;
    }

    public static function on_activation () {
    }

    public static function on_deactivation () {
    }

    public static function on_uninstall () {
    }

}

$i = Cap_XSL_Processor::getInstance ();

register_activation_hook   (__FILE__, array ($i, 'on_activation'));
register_deactivation_hook (__FILE__, array ($i, 'on_deactivation'));
register_uninstall_hook    (__FILE__, array ($i, 'on_uninstall'));
