<?php

/**
 * Capitularia Front Page Text Widget
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * A text widget for the front page.
 */

class Frontpage_Text_Widget extends Frontpage_Widget_Base
{
    public function __construct ()
    {
        $widget_ops = array (
            'classname' => 'cap_widget_text',
            'description' => __ ('Arbitrary text.', 'capitularia')
        );
        parent::__construct (
            'cap_widget_text',
            __ ('Capitularia Text Widget', 'capitularia'),
            $widget_ops
        );
        unset ($this->options['image']);
        unset ($this->options['image-tooltip']);
    }

    protected function the_widget_image ($dummy_args, $dummy_instance)
    {
        /* don't output any image */
    }
}
