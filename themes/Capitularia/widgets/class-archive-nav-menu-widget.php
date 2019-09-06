<?php

/**
 * Capitularia Theme Archive Navigation Menu Widget
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

/**
 * A navigation menu widget for a custom archives menu.
 *
 * To display the post archives with our custom dynamic menu we need to have the
 * list of archives somewhere in the HTML page for the menu to grab.  This wrapper
 * injects that list into the HTML page inside a hidden block and then
 * lets the menu do its thing.
 */

class Archive_Nav_Menu_Widget extends \WP_Nav_Menu_Widget
{
    private $menu_id;

    public function __construct ()
    {
        $widget_ops = array ('description' => __ ('A custom archives navigation menu.', 'capitularia'));
        // FIXME: really WP_Widget (not parent)?
        \WP_Widget::__construct (
            'cap_archive_nav_menu',
            __ ('Capitularia Archive Navigation Menu', 'capitularia'),
            $widget_ops
        );
    }

    public function widget ($args, $instance)
    {
        $a = array ();
        $a[] = '<nav style="display: none">';
        $a[] = '  <ul class="index-archives">';
        $a[] = '    <li><a>' . __ ('Archive', 'capitularia') . '</a></li>';
        $a[] = '    <li>';
        $a[] = '      <ul>';
        $a[] = wp_get_archives (array ('type' => 'monthly', 'show_post_count' => true, 'echo' => false));
        $a[] = '      </ul>';
        $a[] = '    </li>';
        $a[] = '  </ul>';
        $a[] = '</nav>';
        echo (join ($a, "\n"));

        parent::widget ($args, $instance);
    }
}
