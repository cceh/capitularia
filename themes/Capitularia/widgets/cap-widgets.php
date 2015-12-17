<?php

/**
 * Capitularia Theme Widgets
 *
 * @package Capitularia
 */

namespace cceh\capitularia\theme;

require 'class-frontpage-widgets.php';
require 'class-sticky-nav-menu-widget.php';

/**
 * Register all Capitularia theme widgets.
 */

function register_widgets () {
    register_widget ('cceh\capitularia\theme\Frontpage_Text_Widget');
    register_widget ('cceh\capitularia\theme\Frontpage_Image_Widget');
    register_widget ('cceh\capitularia\theme\Frontpage_Logo_Widget');
    register_widget ('cceh\capitularia\theme\Sticky_Nav_Menu_Widget');
}

add_action ('widgets_init', 'cceh\capitularia\theme\register_widgets');
