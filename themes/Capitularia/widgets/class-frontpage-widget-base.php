<?php

/**
 * Capitularia Theme Widgets
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * Base class for the front page widgets.
 */

class Frontpage_Widget_Base extends \WP_Widget
{

    /**
     * HTML class of widget container and body.
     *
     * @var string
     */

    protected $class;

    /**
     * Contains data to build the fields in the 'settings' form.
     *
     * May be edited in descendand classes to output different fields.
     *
     * @var (callable|string)[]
     *
     * callable $options[$field][0] Field sanitation function
     * string   $options[$field][1] Caption for option field
     * string   $options[$field][2] Placeholder for option entry field
     */

    protected $options = array ();

    public function __construct ($id, $name, $widget_ops)
    {
        $this->class = $widget_ops['classname'];
        $control_ops = array ('width' => 400, 'height' => 350);
        parent::__construct ($id, $name, $widget_ops, $control_ops);
        $this->options = array (
            'title'   => array (
                array ($this, 'normalize'),  __ ('Title',     'capitularia'), __ ('Enter title',     'capitularia')
            ),
            'content' => array (
                array ($this, 'normalize'),  __ ('Text',      'capitularia'), __ ('Enter text',      'capitularia')
            ),
            'image'   => array (
                array ($this, 'strip_tags'), __ ('Image-URL', 'capitularia'), __ ('Enter image URL', 'capitularia')
            ),
            'image-tooltip' => array (
                array ($this, 'strip_tags'),
                __ ('Image-Tooltip', 'capitularia'),
                __ ('Enter image tooltip', 'capitularia')
            ),
            'link'    => array (
                array ($this, 'strip_tags'), __ ('Link-URL',  'capitularia'), __ ('Enter link-URL',  'capitularia')
            )
        );
    }

    protected function normalize ($text)
    {
        return empty ($text) ? '' : $text;
    }

    protected function strip_tags ($text)
    {
        return strip_tags ($this->normalize ($text));
    }

    protected function sanitize ($text)
    {
        $allowed_html = array (
            'a' => array (
                'href' => array (),
                'title' => array ()
            ),
            'em' => array (),
            'strong' => array (),
            'p' => array (),
            'br' => array (),
        );
        return empty ($text) ? '' : wp_kses ($text, $allowed_html);
    }

    protected function make_link ($text, $link, $classes = 'ssdone')
    {
        return empty ($link) ? $text : "<a href=\"$link\" class=\"$classes\">$text</a>";
    }

    protected function the_widget_title ($args, $instance)
    {
        echo ($args['before_title']);
        echo $instance['title'];
        echo ($args['after_title']);
    }

    protected function the_widget_body ($dummy_args, $instance) // phpcs:ignore
    {
        echo ("<div class=\"{$this->class}-body\">{$instance['content']}</div>\n");
        echo $this->make_link (__ ('read more', 'capitularia'), $instance['link'], 'mehr-lesen ssdone');
    }

    /**
     * Output the widget image.
     *
     * Replaces a leading ~ with the theme image directory url,
     * eg. ~/logo.png => https://server/path/to/images/logo.png
     *
     * @param array $dummy_args (unused) Display arguments including
     *                          'before_title', 'after_title', 'before_widget',
     *                          and 'after_widget'.
     * @param array $instance   Settings for the current widget instance.
     *
     * @return void
     */

    protected function the_widget_image ($dummy_args, $instance) // phpcs:ignore
    {
        $image = $instance['image'];
        $image = preg_replace_callback (
            '|^~/(.*)$|',
            function ($matches) {
                return get_theme_image_uri ($matches[1]);
            },
            $image
        );

        echo $this->make_link (
            "<img src=\"{$image}\" title=\"{$instance['image-tooltip']}\" alt =\"\">",
            $instance['link']
        );
    }

    /**
     * Output the widget.
     *
     * @param array $args     Display arguments including 'before_title', 'after_title',
     *                        'before_widget', and 'after_widget'.
     * @param array $instance Settings for the current widget instance.
     *
     * @return void
     */

    public function widget ($args, $instance)
    {
        foreach ($this->options as $key => $option) {
            $instance[$key] = call_user_func ($option[0], $instance[$key]);
        }

        echo $args['before_widget'];

        $this->the_widget_image ($args, $instance);
        $this->the_widget_title ($args, $instance);
        $this->the_widget_body  ($args, $instance);

        echo $args['after_widget'];
    }

    /*
     * Incipit Admin Page Stuff
     */

    /**
     * Output one option field on the admin page.
     *
     * @param object $instance    The instance
     * @param string $name        Option field name
     * @param string $caption     Option field caption
     * @param string $placeholder Option field placeholder
     *
     * @return void
     */

    protected function the_option ($instance, $name, $caption, $placeholder)
    {
        $value = esc_attr ($this->normalize ($instance[$name]));
        echo ("<p><label for=\"{$this->get_field_id ($name)}\">$caption</label>");
        echo ("<textarea class=\"widefat resizable\" id=\"{$this->get_field_id ($name)}\" " .
              "name=\"{$this->get_field_name ($name)}\" " .
              "value=\"$value\" placeholder=\"$placeholder\">$value</textarea></p>");
    }

    /**
     * Handles updating settings for the current widget instance.
     *
     * @param array $new_instance New settings for this instance as input by the user via
     *                            WP_Widget::form ().
     * @param array $old_instance Old settings for this instance.
     *
     * @return array Settings to save.
     */

    public function update ($new_instance, $old_instance)
    {
        $instance = $old_instance;
        foreach ($this->options as $key => $option) {
            $instance[$key] = call_user_func ($option[0], $new_instance[$key]);
        }
        return $instance;
    }

    /**
     * Outputs the widget settings form.
     *
     * @param array $instance Current settings.
     *
     * @return void
     */

    public function form ($instance)
    {
        foreach ($this->options as $key => $option) {
            $this->the_option ($instance, $key, $option[1], $option[2]);
        }
    }
}
