<?php

/**
 * Widgets
 *
 */

class Cap_Widget_Search_Box extends WP_Widget {

    private $title;

    public function __construct () {
        $widget_ops = array (
            'classname' => 'cap_widget_search_box',
            'description' => __('Search box for taxonomies and ranges.'),
        );
        $control_ops = array ('width' => 400, 'height' => 350);
        parent::__construct ('cap_widget_search_box', __('Capitularia Taxonomies Search Widget'),
                             $widget_ops, $control_ops);
    }

    protected function setup ($args, $instance) {
        $this->title = apply_filters ('widget_title',
                                      empty ($instance['title']) ? '' : $instance['title'],
                                      $instance, $this->id_base);
    }

    public function widget ($args, $instance) {
        $this->setup ($args, $instance);

        echo $args['before_widget'];
        echo ($args['before_title']);
        echo $this->title;
        echo ($args['after_title']);

?>
        <div class="filter-box">

      <form class="filter-form" action="#">

        <label for="filter-kapitularien">Kapitularien</label>
        <select id="filter-kapitularien" name="kapitularien">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-datierung">Datierung</label>
        <select id="filter-datierung" name="datierung">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-herkunft">Herkunft</label>
        <select id="filter-herkunft" name="herkunft">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-institution">Institution</label>
        <select id="filter-institution" name="institution">
          <option value="alle"> - Alle - </option>
          <option value="1"> Option 1</option>
          <option value="2"> Option 2</option>
          <option value="3"> Option 3</option>
        </select>

        <label for="filter-undoder1">und/oder</label>
        <input type="text" id="filter-undoder1" name="undoder1">

        <label for="filter-undoder2">und/oder</label>
        <input type="text" id="filter-undoder2" name="undoder2">

        <input type="submit" value="Absenden"/>
        <a href="javascript:void(0)" class="reset-form">Suche zur&uuml;rcksetzen</a>
      </form>

    </div>
<?php

        echo $args['after_widget'];
    }

    protected function sanitize ($text) {
        return empty ($text) ? '' : strip_tags ($text);
    }

    protected function the_option ($instance, $name, $caption, $placeholder) {
        $value = !empty ($instance[$name]) ? $instance[$name] : '';
        $caption = __($caption);
        $placeholder = __($placeholder);
        echo ("<p><label for=\"{$this->get_field_id ($name)}\">$caption</label>");
        echo ("<input class=\"widefat\" id=\"{$this->get_field_id ($name)}\" name=\"{$this->get_field_name ($name)}\" type=\"text\" value=\"$value\" placeholder=\"$placeholder\"></p>");
    }

    public function update ($new_instance, $old_instance) {
        $instance = $old_instance;
        $instance['title']   = $this->sanitize ($new_instance['title']);
        return $instance;
    }

    public function form ($instance) {
        $this->the_option ($instance, 'title', 'Title', 'New title');
    }

    static function cap_register_widget () {
        register_widget ('Cap_Widget_Search_Box');
    }
}

add_action ('widgets_init', array ('Cap_Widget_Search_Box', 'cap_register_widget'));

?>