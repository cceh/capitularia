<?php

/**
 * Capitularia Theme Widgets
 *
 * @package Capitularia
 */

defined ('ABSPATH') or die ('General Protection Fault: Windows will now restart.');

require_once 'class-frontpage-widget-base.php';
require_once 'class-frontpage-text-widget.php';
require_once 'class-frontpage-image-widget.php';
require_once 'class-frontpage-logo-widget.php';

require_once 'class-archive-nav-menu-widget.php';
require_once 'class-categories-nav-menu-widget.php';
require_once 'class-sticky-nav-menu-widget.php';

add_action (
    'widgets_init',
    function () {
        register_widget ('cceh\capitularia\theme\Frontpage_Text_Widget');
        register_widget ('cceh\capitularia\theme\Frontpage_Image_Widget');
        register_widget ('cceh\capitularia\theme\Frontpage_Logo_Widget');
        register_widget ('cceh\capitularia\theme\Archive_Nav_Menu_Widget');
        register_widget ('cceh\capitularia\theme\Categories_Nav_Menu_Widget');
        register_widget ('cceh\capitularia\theme\Sticky_Nav_Menu_Widget');
    }
);
