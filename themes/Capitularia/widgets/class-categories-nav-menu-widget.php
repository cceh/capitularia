<?php

/**
 * Capitularia Theme Categories Navigation Menu Widget
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * A navigation menu widget for a custom categories menu.
 *
 * To display the post categories with our custom dynamic menu we need to have the
 * list of categories somewhere in the HTML page for the menu to grab.  This wrapper
 * injects that list into the HTML page inside a hidden block and then
 * lets the menu do its thing.
 */

class Categories_Nav_Menu_Widget extends \WP_Nav_Menu_Widget
{
    private $menu_id;

    public function __construct ()
    {
        $widget_ops = array ('description' => __ ('A custom categories navigation menu.', 'capitularia'));
        // FIXME: really WP_Widget (not parent)?
        \WP_Widget::__construct (
            'cap_categories_nav_menu',
            __ ('Capitularia Categories Navigation Menu', 'capitularia'),
            $widget_ops
        );
    }

    public function widget ($args, $instance)
    {
        $a = array ();
        $a[] = '<nav style="display: none">';
        $a[] = '  <ul class="index-categories">';
        $a[] = '    <li><a>' . __ ('Categories', 'capitularia') . '</a></li>';
        $a[] = '    <li>';
        $a[] = '      <ul>';
        $a[] = wp_list_categories (array ('show_count' => true, 'echo' => false));
        $a[] = '      </ul>';
        $a[] = '    </li>';
        $a[] = '  </ul>';
        $a[] = '</nav>';
        echo (join ($a, "\n"));

        parent::widget ($args, $instance);
    }
}
