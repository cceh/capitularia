<?php

/**
 * Capitularia Theme Sticky Navigation Menu Widget
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * A sticky navigation menu widget for the sidebar.
 */

class Sticky_Nav_Menu_Widget extends \WP_Nav_Menu_Widget
{
    public function __construct ()
    {
        $widget_ops = array ('description' => __ ('A sticky navigation menu.', 'capitularia'));
        // FIXME: really WP_Widget (not parent)?
        \WP_Widget::__construct (
            'cap_sticky_nav_menu',
            __ ('Capitularia Sticky Navigation Menu', 'capitularia'),
            $widget_ops
        );

        add_filter ('widget_nav_menu_args', array ($this, 'on_widget_nav_menu_args'), 10, 3);
    }

    public function widget ($args, $instance)
    {
        $args['mirsn'] = 'XXX'; // tag *our* menu
        parent::widget ($args, $instance);
    }

    public static function on_widget_nav_menu_args ($nav_menu_args, $dummy_nav_menu, $args) // phpcs:ignore
    {
        if (!empty ($args['mirsn'])) {                          // pick out *our* menu
            $nav_menu_args['container_class'] = 'sidebar-toc';  // this makes the widget sticky
            $nav_menu_args['menu_class']      = 'menu clearfix';
        }
        return $nav_menu_args;
    }
}
