<?php

/**
 * Capitularia Front Page Image Widget
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * An image widget for the front page.
 */

class Frontpage_Image_Widget extends Frontpage_Widget_Base
{
    public function __construct ()
    {
        $widget_ops = array (
            'classname' => 'cap_widget_image',
            'description' => __ ('Arbitrary text and image.', 'capitularia')
        );
        parent::__construct (
            'cap_widget_image',
            __ ('Capitularia Image Widget', 'capitularia'),
            $widget_ops
        );
    }
}
