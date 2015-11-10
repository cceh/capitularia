<?php
/**
 * Capitularia Meta Search search box widget
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

class Widget extends \WP_Widget
{
    /**
     * Our singleton instance
     */
    static private $instance = false;

    private $title;
    private $your_search = array ();

    public function __construct () {
        $widget_ops = array (
            'classname' => 'cap_meta_search_widget',
            'description' => __('Search widget for Capitularia metadata.'),
        );
        $control_ops = array ('width' => 400, 'height' => 350);
        parent::__construct (
            'cap_meta_search_widget',
            __('Capitularia Search Box Widget'),
            $widget_ops,
            $control_ops
        );
        add_action ('pre_get_posts',               array ($this, 'on_pre_get_posts'));
        add_action ('wp_enqueue_scripts',          array ($this, 'on_enqueue_scripts'));

        add_filter ('query_vars',                  array ($this, 'on_query_vars'));
        add_filter ('posts_search',                array ($this, 'on_posts_search'), 10, 2);
        add_filter ('wp_search_stopwords',         array ($this, 'on_wp_search_stopwords'));
        add_filter ('cap_meta_search_your_search', array ($this, 'on_cap_meta_search_your_search'));

    }

    /**
     * If an instance exists, this returns it.  If not, it creates one and
     * returns it.
     *
     * @return Search_Widget
     */
    public static function getInstance () {
        if (!self::$instance) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    protected function setup ($args, $instance) {
        $this->title = apply_filters (
            'widget_title',
            empty ($instance['title']) ? '' : $instance['title'],
            $instance, $this->id_base
        );
    }

    public function on_query_vars ($vars) {
        $vars[] = 'capit';
        $vars[] = 'place';
        $vars[] = 'notbefore';
        $vars[] = 'notafter';
        return $vars;
    }

    public function on_enqueue_scripts () {
        wp_enqueue_script  ('cap-meta-search-front');
    }

    private function echo_options ($sql) {
        global $wpdb;

        $all = __('Alle');
        echo ("    <option value=''>$all</option>\n");

        $bks = $wpdb->get_results ($sql);
        foreach ($bks as $bk) {
            $bk->key = preg_replace_callback (
                '|\d+|',
                function ($match) {
                    return strval (strlen ($match[0])) . $match[0];
                },
                $bk->meta_value
            );
        }
        usort ($bks, function ($bk1, $bk2) { return strcoll ($bk1->key, $bk2->key); } );
        foreach ($bks as $bk) {
            echo ("    <option value='{$bk->meta_value}'>{$bk->meta_value}</option>\n");
        }
    }

    private function echo_select ($caption, $id, $meta_key, $tooltip) {
        $tooltip = esc_attr ($tooltip);
        echo ("<div class='cap-meta-search-field cap-meta-search-field-$id'>\n");
        echo ("  <label for='$id'>$caption</label>\n");
        echo ("  <select id='$id' name='$id' title='$tooltip' >\n");
        $this->echo_options (
            "SELECT distinct meta_value FROM wp_postmeta WHERE meta_key = '$meta_key'"
        );
        echo ("  </select>\n");
        echo ("</div>\n");
        $this->help_text[] = "<p><b>$caption:</b> $tooltip</p>\n";
    }

    private function echo_input ($caption, $id, $placeholder, $tooltip) {
        $tooltip     = esc_attr ($tooltip);
        $placeholder = esc_attr ($placeholder);
        echo ("<div class='cap-meta-search-field cap-meta-search-field-$id'>\n");
        echo ("  <label for='$id'>$caption</label>\n");
        echo ("  <input type='text' id='$id' name='$id' placeholder='$placeholder' title='$tooltip' />\n");
        echo ("</div>\n");
        $this->help_text[] = "<p><b>$caption:</b> $tooltip</p>\n";
    }

    public function widget ($args, $instance) {
        $this->setup ($args, $instance);

        echo $args['before_widget'];
        echo ($args['before_title']);
        echo $this->title;
        echo ($args['after_title']);

        $this->help_text = array ();

        echo ("<div class='cap-meta-search-box'>\n");
        echo ("<form action='/'>\n");

        $tooltip = __ ('Nur Handschriften anzeigen, die dieses Kapitular enthalten.');
        $this->echo_select ('Enthaltene Kapitularien', 'capit',     'msitem-corresp', $tooltip);

        echo ("<div class='ui-helper-clearfix'>\n");
        $tooltip = __ ('Nur Handschriften anzeigen, die nach diesem Jahr entstanden sind.');
        $this->echo_input  ('Nach',                    'notbefore', '700',  $tooltip);

        $tooltip = __ ('Nur Handschriften anzeigen, die vor diesem Jahr entstanden sind.');
        $this->echo_input  ('Vor',                     'notafter',  '1000', $tooltip);
        echo ("</div>\n");

        // $this->echo_select ('Herkunft',                'place',     'origPlace');

        $tooltip = __ ('Freie Textsuche');
        $this->echo_input  ('Text',                    's',         'Suchtext', $tooltip);

        echo ("<div class='cap-meta-search-buttons ui-helper-clearfix'>\n");
        echo ("  <input class='cap-meta-search-submit' type='submit' value='Suchen' />\n");
        echo ("  <input class='cap-meta-search-help'   type='button' value='Hilfe' onclick='on_cap_meta_search_toggle_help ()' />\n");
        echo ("</div>\n");

        echo ("</form>\n");
        echo ("<div class='cap-meta-search-help-text'>\n");
        echo (implode ("\n", $this->help_text));
        echo ("</div>\n");
        echo ("</div>\n");

        echo $args['after_widget'];
    }

    public function on_pre_get_posts ($query) {
        if (!is_admin () && $query->is_main_query ()) {
            if ($query->is_search) {
                $this->your_search = array ();
                // error_log ('cceh\capitularia\meta_search\Widget::on_pre_get_posts ()');
                // error_log (print_r ($query->query, true));
                $meta_query_args = array ();

                foreach ($query->query as $key => $val) {
                    // error_log ("key = $key, value = $val");
                    if (empty ($val)) {
                        continue;
                    }
                    if ($key == 'capit') {
                        $val = sanitize_text_field ($val);
                        $meta_query_args[] = array (
                            'key' => 'msitem-corresp',
                            'value' => $val,
                            'compare' => '=',
                            'type' => 'CHAR'
                        );
                        $this->your_search[] = sprintf (__("cap. %s"), $val);
                        continue;
                    }
                    if ($key == 'notbefore') {
                        $val = absint ($val);
                        $meta_query_args[] = array (
                            'key' => 'origDate-notBefore',
                            'value' => absint ($val),
                            'compare' => '>=',
                            'type' => 'NUMERIC'
                        );
                        $this->your_search[] = sprintf (__("after %d"), $val);
                        continue;
                    }
                    if ($key == 'notafter') {
                        $val = absint ($val);
                        $meta_query_args[] = array (
                            'key' => 'origDate-notAfter',
                            'value' => absint ($val),
                            'compare' => '<=',
                            'type' => 'NUMERIC'
                        );
                        $this->your_search[] = sprintf (__("before %d") , $val);
                        continue;
                    }
                    if ($key == 'place') {
                        $val = sanitize_text_field ($val);
                        $meta_query_args[] = array (
                            'key' => 'origPlace',
                            'value' => $val,
                            'compare' => '=',
                            'type' => 'CHAR'
                        );
                        $this->your_search[] = sprintf (__("in %s"), $val);
                        continue;
                    }
                }
                $query->set ('meta_query', $meta_query_args);
            }
        }
    }

    public function on_posts_search ($sql, $query) {
        // echo ("<pre>" . print_r ($query, true) . "</pre>");
        if (isset ($query->query_vars['search_terms'])) {
            foreach ($query->query_vars['search_terms'] as $term) {
                $this->your_search[] = esc_attr ($term);
            }
        }
        return $sql;
    }

    public function on_wp_search_stopwords ($stopwords) {
        $stopwords = array_merge ($stopwords, explode (' ', 'der die das'));
        return $stopwords;
    }

    /**
     * Generate the "You searched for BK.123 not before 950 and 'Karl'" message.
     *
     * @param message
     *
     * @return
     */

    public function on_cap_meta_search_your_search ($message) {
        return  implode (' &middot; ', $this->your_search) . $message;
    }

    protected function sanitize ($text) {
        return empty ($text) ? '' : strip_tags ($text);
    }

    protected function the_option ($instance, $name, $caption, $placeholder) {
        $value = !empty ($instance[$name]) ? $instance[$name] : '';
        $caption = __($caption);
        $placeholder = __($placeholder);
        echo ("<p><label for=\"{$this->get_field_id ($name)}\">$caption</label>");
        echo ("<input class=\"widefat\" id=\"{$this->get_field_id ($name)}\" " .
              "name=\"{$this->get_field_name ($name)}\" type=\"text\" value=\"$value\" " .
              "placeholder=\"$placeholder\"></p>");
    }

    public function update ($new_instance, $old_instance) {
        $instance = $old_instance;
        $instance['title'] = $this->sanitize ($new_instance['title']);
        return $instance;
    }

    public function form ($instance) {
        $this->the_option ($instance, 'title', 'Title', 'New title');
    }
}
