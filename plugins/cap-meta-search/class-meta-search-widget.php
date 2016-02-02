<?php
/**
 * Capitularia Meta Search search box widget
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

/**
 * A metadata search box widget.
 */

class Widget extends \WP_Widget
{
    /**
     * Our singleton instance
     */
    static private $instance = false;

    private $title;
    private $your_search = array ();

    public function __construct ()
    {
        $widget_ops = array (
            'classname' => 'cap_meta_search_widget',
            'description' => __ ('Search widget for Capitularia metadata.', 'capitularia'),
        );
        $control_ops = array ('width' => 400, 'height' => 350);
        parent::__construct (
            'cap_meta_search_widget',
            __ ('Capitularia Search Box Widget', 'capitularia'),
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
    public static function get_instance ()
    {
        if (!self::$instance) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    /**
     * Setup the widget
     *
     * @param array $dummy_args The widget arguments
     * @param array $instance   The widget instance
     *
     * @return void
     */

    protected function setup ($dummy_args, $instance)
    {
        $this->title = apply_filters (
            'widget_title',
            empty ($instance['title']) ? '' : $instance['title'],
            $instance,
            $this->id_base
        );
    }

    /**
     * Add our custom HTTP query vars
     *
     * @param array $vars The stock query vars
     *
     * @return array The stock and custom query vars
     */

    public function on_query_vars ($vars)
    {
        $vars[] = 'capit';
        $vars[] = 'place';
        $vars[] = 'notbefore';
        $vars[] = 'notafter';
        return $vars;
    }

    /**
     * Enqueue javascript
     *
     * @return void
     */

    public function on_enqueue_scripts ()
    {
        wp_enqueue_script ('cap-meta-search-front');
    }

    /**
     * Echo <select> options from SQL query
     *
     * Output the options for a HTML <select> element.  Sort numeric substrings
     * in a sensible way for humans, eg. 'BK 2' before 'BK 12'
     *
     * @param string $sql The SQL query
     *
     * @return void
     */

    private function echo_options ($sql)
    {
        global $wpdb;
        $bks = $wpdb->get_results ($sql);

        $all = _x ('All', '\'All\' option in drop-down', 'capitularia');
        echo ("    <option value=''>$all</option>\n");

        // Add a key to all objects in the array that allows for sensible
        // sorting of numeric substrings.
        foreach ($bks as $bk) {
            $bk->key = preg_replace_callback (
                '|\d+|',
                function ($match) {
                    return strval (strlen ($match[0])) . $match[0];
                },
                $bk->meta_value
            );
        }

        // Sort the array according to key.
        usort (
            $bks,
            function ($bk1, $bk2) {
                return strcoll ($bk1->key, $bk2->key);
            }
        );

        // Output
        foreach ($bks as $bk) {
            echo ("    <option value='{$bk->meta_value}'>{$bk->meta_value}</option>\n");
        }
    }

    /**
     * Echo a HTML <select> element with options.
     *
     * @param string $caption  The caption for the <select>
     * @param string $id       The xml id and name of the <select>
     * @param string $meta_key The meta key
     * @param string $tooltip  The tooltip for the <select>
     *
     * @return void
     */

    private function echo_select ($caption, $id, $meta_key, $tooltip)
    {
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

    /**
     * Echo a text <input> field
     *
     * @param string $caption     The caption for the <input>
     * @param string $id          The xml id and nameof the <input>
     * @param string $placeholder The placeholder text
     * @param string $tooltip     The tooltip
     *
     * @return void
     */

    private function echo_input ($caption, $id, $placeholder, $tooltip)
    {
        $tooltip     = esc_attr ($tooltip);
        $placeholder = esc_attr ($placeholder);
        echo ("<div class='cap-meta-search-field cap-meta-search-field-$id'>\n");
        echo ("  <label for='$id'>$caption</label>\n");
        echo ("  <input type='text' id='$id' name='$id' placeholder='$placeholder' title='$tooltip' />\n");
        echo ("</div>\n");
        $this->help_text[] = "<p><b>$caption:</b> $tooltip</p>\n";
    }

    /**
     * Output the widget
     *
     * @param array  $args     The arguments to the widget
     * @param object $instance The widget instance
     *
     * @return void
     */

    public function widget ($args, $instance)
    {
        $this->setup ($args, $instance);

        echo $args['before_widget'];
        echo ($args['before_title']);
        echo $this->title;
        echo ($args['after_title']);

        $this->help_text = array ();

        echo ("<div class='cap-meta-search-box'>\n");
        echo ("<form action='/'>\n");

        $label   = __ ('Capitularies contained', 'capitularia');
        $tooltip = __ ('Only show manuscripts that contain this capitulary.', 'capitularia');
        $this->echo_select ($label, 'capit',     'msitem-corresp', $tooltip);

        echo ("<div class='ui-helper-clearfix'>\n");
        $label   = __ ('After', 'capitularia');
        $tooltip = __ ('Only show manuscripts created after this year.', 'capitularia');
        $this->echo_input  ($label, 'notbefore', '700',  $tooltip);

        $label   = __ ('Before', 'capitularia');
        $tooltip = __ ('Only show manuscripts created before this year.', 'capitularia');
        $this->echo_input  ($label, 'notafter',  '1000', $tooltip);
        echo ("</div>\n");

        $label   = __ ('Origin', 'capitularia');
        $tooltip = __ ('Only show manuscripts created in this region.', 'capitularia');
        $this->echo_select ($label, 'place',     'origPlace-geonames', $tooltip);

        $label       = __ ('Free Text', 'capitularia');
        $tooltip     = __ ('Free text search', 'capitularia');
        $placeholder = __ ('Free Text', 'capitularia');
        $this->echo_input  ($label, 's', $placeholder, $tooltip);

        echo ("<div class='cap-meta-search-buttons ui-helper-clearfix'>\n");

        $label   = __ ('Search', 'capitularia');
        $tooltip = __ ('Start the search', 'capitularia');
        echo ("  <input class='cap-meta-search-submit' type='submit' value='$label' title='$tooltip' />\n");

        $label   = __ ('Help', 'capitularia');
        $tooltip = __ ('Show some help', 'capitularia');
        echo ("  <input class='cap-meta-search-help'   type='button' value='$label' title='$tooltip' " .
              "onclick='on_cap_meta_search_toggle_help ()' />\n");

        echo ("</div>\n");

        echo ("</form>\n");
        echo ("<div class='cap-meta-search-help-text'>\n");
        echo (implode ("\n", $this->help_text));
        echo ("</div>\n");
        echo ("</div>\n");

        echo $args['after_widget'];
    }

    /**
     * Convert HTTP query into SQL query.
     *
     * Operates on the Wordpress query object.
     *
     * @param WP_Query $query The Wordpress query object
     *
     * @return void
     *
     * @see https://codex.wordpress.org/Class_Reference/WP_Query Class Reference
     * WP_Query
     */

    public function on_pre_get_posts ($query)
    {
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
                        $this->your_search[] = sprintf (__ ('contains %s', 'capitularia'), $val);
                        continue;
                    }
                    if ($key == 'notbefore') {
                        $val = absint ($val);
                        $meta_query_args[] = array (
                            'key' => 'origDate-notBefore',
                            'value' => $val,
                            'compare' => '>=',
                            'type' => 'NUMERIC'
                        );
                        $this->your_search[] = sprintf (__ ('after %d', 'capitularia'), $val);
                        continue;
                    }
                    if ($key == 'notafter') {
                        $val = absint ($val);
                        $meta_query_args[] = array (
                            'key' => 'origDate-notAfter',
                            'value' => $val,
                            'compare' => '<=',
                            'type' => 'NUMERIC'
                        );
                        $this->your_search[] = sprintf (__ ('before %d', 'capitularia'), $val);
                        continue;
                    }
                    if ($key == 'place') {
                        $val = sanitize_text_field ($val);
                        $meta_query_args[] = array (
                            'key' => 'origPlace-geonames',
                            'value' => $val,
                            'compare' => '=',
                            'type' => 'CHAR'
                        );
                        $this->your_search[] = sprintf (__ ('in %s', 'capitularia'), $val);
                        continue;
                    }
                }
                $query->set ('meta_query', $meta_query_args);
            }
        }
    }

    /**
     * Add search terms to 'You searched for ...'
     *
     * @param string   $sql   The SQL query (unused)
     * @param WP_Query $query The wordpress query object
     *
     * @return The SQL query (unchanged)
     */

    public function on_posts_search ($sql, $query)
    {
        // echo ("<pre>" . print_r ($query, true) . "</pre>");
        if (isset ($query->query_vars['search_terms'])) {
            foreach ($query->query_vars['search_terms'] as $term) {
                $this->your_search[] = esc_attr ($term);
            }
        }
        return $sql;
    }

    /**
     * Adds custom stopwords
     *
     * @param array $stopwords The stock stopwords
     *
     * @return array The stock and custom stopwords
     */

    public function on_wp_search_stopwords ($stopwords)
    {
        $stopwords = array_merge ($stopwords, explode (' ', 'der die das'));
        return $stopwords;
    }

    /**
     * Generate the "You searched for ..." message
     *
     * Generate a message like "You searched for BK.123 not before 950 and
     * 'Karl'".
     *
     * @param string $message The free text searched for.
     *
     * @return string "You searched for ..."
     */

    public function on_cap_meta_search_your_search ($message)
    {
        return  implode (' &middot; ', $this->your_search) . $message;
    }

    protected function sanitize ($text)
    {
        return empty ($text) ? '' : strip_tags ($text);
    }

    /**
     * Output one option field
     *
     * @param array  $instance    The widet options
     * @param string $name        The option name
     * @param string $caption     The caption
     * @param string $placeholder The placeholder
     *
     * @return void
     */

    protected function the_option ($instance, $name, $caption, $placeholder)
    {
        $value = !empty ($instance[$name]) ? $instance[$name] : '';
        echo ("<p><label for=\"{$this->get_field_id ($name)}\">$caption</label>");
        echo ("<input class=\"widefat\" id=\"{$this->get_field_id ($name)}\" " .
              "name=\"{$this->get_field_name ($name)}\" type=\"text\" value=\"$value\" " .
              "placeholder=\"$placeholder\"></p>");
    }

    /**
     * Update widget settings on save
     *
     * @param array $new_instance Values just sent to be saved.
     * @param array $old_instance Previously saved values from database.
     *
     * @return array
     */

    public function update ($new_instance, $old_instance)
    {
        $instance = $old_instance;
        $instance['title'] = $this->sanitize ($new_instance['title']);
        return $instance;
    }

    /**
     * Outputs the widget options form on admin
     *
     * @param array $instance The widget options
     *
     * @return void
     */

    public function form ($instance)
    {
        $this->the_option ($instance, 'title', __ ('Title', 'capitularia'), __ ('New title', 'capitularia'));
    }
}
