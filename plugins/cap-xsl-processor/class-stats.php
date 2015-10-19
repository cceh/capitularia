<?php
/**
 * Capitularia XSL Processor Stats class.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

class Stats
{

    public $pages       = 0;
    public $hits        = 0;
    public $hits_temp   = 0;
    public $misses      = 0;
    public $page_cached = 0;
    public $page_mtime  = 0;
    public $xml_mtime   = 0;
    public $xsl_mtime   = 0;

    public function get_tooltip ($post_id) {
        $post_id = intval ($post_id);
        global $wpdb;
        $result = $wpdb->get_results (
            "SELECT meta_key, meta_value FROM wp_postmeta WHERE post_id = $post_id",
            OBJECT_K
        );
        $hits   = $result['cap_xsl_cache_hits_temp']->meta_value;
        $misses = $result['cap_xsl_cache_misses']->meta_value;
        return "hits: $hits\nmisses: $misses";
    }

    public function get_table_rows () {
        global $wpdb;
        $this->pages = $wpdb->get_var (
            "SELECT COUNT(*)        FROM wp_postmeta WHERE meta_key = 'cap_xsl_cache_time'"
        );
        $this->hits = $wpdb->get_var (
            "SELECT SUM(meta_value) FROM wp_postmeta WHERE meta_key = 'cap_xsl_cache_hits'"
        );
        $this->misses = $wpdb->get_var (
            "SELECT SUM(meta_value) FROM wp_postmeta WHERE meta_key = 'cap_xsl_cache_misses'"
        );

        return "<tr><th>Cached pages</th><td>{$this->pages}</td></tr>\n" .
               "<tr><th>Cache hits</th><td>{$this->hits}</td></tr>\n" .
             "<tr><th>Cache misses</th><td>{$this->misses}</td></tr>\n";
    }
}
