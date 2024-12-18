<?php
/**
 * Capitularia Meta Search search box widget
 *
 * @package Capitularia_Meta_Search
 */

namespace cceh\capitularia\meta_search;

use \cceh\capitularia\lib;

/**
 * A metadata search box widget.
 */

class Widget extends \WP_Widget
{
    /** The widget title (caption) */
    private $title;

    /**
     * Constructor
     *
     * @return void
     */

    public function __construct ()
    {
        $this->query = null;

        $widget_ops = array (
            'classname' => 'cap_meta_search_widget',
            'description' => __ ('Search widget for Capitularia metadata.', DOMAIN),
        );
        $control_ops = array ('width' => 400, 'height' => 350);
        parent::__construct (
            'cap_meta_search_widget',
            __ ('Capitularia Search Box Widget', DOMAIN),
            $widget_ops,
            $control_ops
        );
    }

    /**
     * Setup the widget
     *
     * @param array $dummy_args The widget arguments
     * @param array $instance   The widget instance
     *
     * @return void
     */

    protected function setup ($dummy_args, $instance) // phpcs:ignore
    {
        $this->title = apply_filters (
            'widget_title',
            empty ($instance['title']) ? '' : $instance['title'],
            $instance,
            $this->id_base
        );
    }

    /**
     * Echo the <option>s of a <select>.
     *
     * Echo the <option>s for a HTML <select> element.  Sort numeric substrings
     * in a sensible way for humans, eg. 'BK 2' before 'BK 12'
     *
     * @param array  $items    Array of strings: The items to display in the drop-down
     * @param string $selected The item in the list to select
     *
     * @return void
     */

    private function echo_options ($items, $selected)
    {
        $all = _x ('All', '\'All\' option in drop-down', DOMAIN);
        echo "    <option value=''>$all</option>\n";

        foreach ($items as $item) {
            $sel = $item === $selected ? ' selected' : '';
            echo "    <option value='{$item}'{$sel}>{$item}</option>\n";
        }
    }

    /**
     * Echo a HTML <select> element with options.
     *
     * @param string $caption The caption for the <select>
     * @param string $id      The xml id and name of the <select>
     * @param array  $items   Array of strings: The items to display in the drop-down
     * @param string $tooltip The tooltip for the <select>
     *
     * @return void
     */

    private function echo_select ($caption, $id, $items, $tooltip)
    {
        $tooltip  = esc_attr ($tooltip);
        $selected = stripslashes (esc_attr ($_GET[$id] ?? ''));
        echo "<div class='cap-meta-search-field cap-meta-search-field-$id'>\n";
        echo "  <label for='$id'>$caption</label>\n";
        echo "  <select id='$id' name='$id' data-bs-toggle='tooltip' title='$tooltip' >\n";
        $this->echo_options ($items, $selected);
        echo "  </select>\n";
        echo "</div>\n";
        $this->help_text[] = "<p><b>$caption:</b> $tooltip</p>\n";
    }

    /**
     * Echo a HTML <div> element to contain a jstree of place names.
     *
     * @param string $caption The caption for the <select>
     * @param string $id      The xml id and name of the <select>
     * @param string $tooltip The tooltip for the <select>
     *
     * @return void
     */

    private function echo_places_tree ($caption, $id, $tooltip)
    {
        $tooltip = esc_attr ($tooltip);
        echo "<label for='$id'>$caption</label>\n";
        echo "<div id='$id' class='cap-meta-search-places' data-bs-toggle='tooltip' title='$tooltip'>\n";
        echo "</div>\n";
        $this->help_text[] = "<p><b>$caption:</b> $tooltip</p>\n";

        lib\enqueue_from_manifest ('cap-meta-search-front.js', ['cap-theme-front.js']);

        lib\enqueue_from_manifest ('cap-meta-search-front.css');
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
        $value       = stripslashes (esc_attr ($_GET[$id] ?? ''));
        echo "<div class='cap-meta-search-field cap-meta-search-field-$id'>\n";
        echo "  <label for='$id'>$caption</label>\n";
        echo "  <input type='text' id='$id' name='$id' placeholder='$placeholder' data-bs-toggle='tooltip' title='$tooltip' value='$value' />\n";
        echo "</div>\n";
        $this->help_text[] = "<p><b>$caption:</b> $tooltip</p>\n";
    }

    /**
     * Output the widget.  Overrides the base class method.
     *
     * @param array $args     Display arguments including 'before_title', 'after_title',
     *                        'before_widget', and 'after_widget'.
     * @param array $instance The settings for the particular instance of the widget.
     *
     * @return void
     *
     * @see \WP_Widget::widget()
     */

    public function widget ($args, $instance)
    {
        $this->setup ($args, $instance);

        echo $args['before_widget'];
        echo $args['before_title'];
        echo $this->title;
        echo $args['after_title'];

        $this->help_text = array ();

        echo "<div class='cap-meta-search-box'>\n";
        echo "<form action='/'>\n";

        $capitulars = get_capitulars ();

        $label   = __ ('In Capitulary', DOMAIN);
        $tooltip = __ ('Search only in this capitulary.', DOMAIN);
        $this->echo_select ($label, 'capit', $capitulars, $tooltip);

        echo "<div class='clearfix'>\n";
        $label   = __ ('After', DOMAIN);
        $tooltip = __ ('Search only in manuscript parts created in or after this year.', DOMAIN);
        $this->echo_input  ($label, 'notbefore', '700',  $tooltip);

        $label   = __ ('Before', DOMAIN);
        $tooltip = __ ('Search only in manuscript parts created before or in this year.', DOMAIN);
        $this->echo_input  ($label, 'notafter',  '1000', $tooltip);
        echo "</div>\n";

        $label   = __ ('Origin', DOMAIN);
        $tooltip = __ ('search only in manuscript parts created in this region.', DOMAIN);
        $this->echo_places_tree ($label, 'places', $tooltip);

        $label       = __ ('Free Text In Transcription', DOMAIN);
        $tooltip     = __ ('Free text search in transcription', DOMAIN);
        $placeholder = __ ('Free Text', DOMAIN);

        $this->echo_input  ($label, 's', $placeholder, $tooltip);

        echo "<div class='cap-meta-search-buttons clearfix'>\n";

        $label   = __ ('Search', DOMAIN);
        $tooltip = __ ('Start the search', DOMAIN);
        echo "  <input class='cap-meta-search-submit' type='submit' value='$label' data-bs-toggle='tooltip' title='$tooltip' />\n";

        $label   = __ ('Help', DOMAIN);
        $tooltip = __ ('Show some help', DOMAIN);
        echo "  <input class='cap-meta-search-help'   type='button' value='$label' data-bs-toggle='tooltip' title='$tooltip' />\n";

        echo "</div>\n";

        echo "</form>\n";
        echo "<div class='cap-meta-search-help-text'>\n";
        echo implode ("\n", $this->help_text);
        echo "</div>\n";
        echo "</div>\n";

        echo $args['after_widget'];
    }

    /**
     * Update widget settings on save.  Overrides the base class method.
     *
     * @param array $new_instance New settings for this instance as input by the user via
     *                            WP_Widget::form().
     * @param array $old_instance Old settings for this instance.
     *
     * @return array Settings to save or bool false to cancel saving.
     *
     * @see \WP_Widget::update()
     */

    public function update ($new_instance, $old_instance)
    {
        $instance = $old_instance;
        $instance['title'] = sanitize ($new_instance['title']);
        return $instance;
    }

    /**
     * Outputs the widget options form on the admin page. Overrides the base
     * class method.
     *
     * @param array $instance Current settings.
     *
     * @return void
     *
     * @see \WP_Widget::form()
     */

    public function form ($instance)
    {
        $this->the_option ($instance, 'title', __ ('Title', DOMAIN), __ ('New title', DOMAIN));
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

    public function the_option ($instance, $name, $caption, $placeholder)
    {
        $value = !empty ($instance[$name]) ? $instance[$name] : '';
        echo "<p><label for=\"{$this->get_field_id ($name)}\">$caption</label>";
        echo "<input class=\"widefat\" id=\"{$this->get_field_id ($name)}\" " .
             "name=\"{$this->get_field_name ($name)}\" type=\"text\" value=\"$value\" " .
             "placeholder=\"$placeholder\"></p>";
    }
}
