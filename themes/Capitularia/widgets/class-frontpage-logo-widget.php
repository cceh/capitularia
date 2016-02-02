<?php

/**
 * Capitularia Front Page Logo Widget
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * A logo widget for the front page.
 */

class Frontpage_Logo_Widget extends Frontpage_Widget_Base
{
    public function __construct ()
    {
        $widget_ops = array (
            'classname' => 'cap_widget_logo',
            'description' => __ ('Image and link for the logo bar.', 'capitularia')
        );
        parent::__construct (
            'cap_widget_logo',
            __ ('Capitularia Logo Widget', 'capitularia'),
            $widget_ops
        );
        unset ($this->options['title']);
        unset ($this->options['content']);
    }

    protected function make_link ($text, $link, $classes = 'ssdone')
    {
        return empty ($link) ? $text : "<a target=\"_blank\" href=\"$link\" class=\"$classes\">$text</a>";
    }

    protected function the_widget_title ($dummy_args, $dummy_instance)
    {
        /* don't output any title */
    }

    protected function the_widget_body ($dummy_args, $dummy_instance)
    {
        /* don't output any body */
    }
}
