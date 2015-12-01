<?php

/**
 * Transcription Navigation Menu Widget
 */

/*

The transcription navigation menu is a dynamically generated (from metadata in
the transformed html of the transcription) menu. It uses the standard wordpress
admin interface to define the menu.

Added functionality:

 - If a menu entry has a class of "menu-load-rubriken" we generate a sub-menu
 from the #inhaltsverzeichnis metadata.

 - If a menu entry has a class of "menu-load-bk" we generate a sub-menu from the
   span.milestone elements.

 - The menu is fixed on the browser page by js.

We override the Walker_Nav_Menu class because there's no WP_Menu class to
override yet.

 */


class Cap_Walker_Transcription_Nav_Menu extends Walker_Nav_Menu {

    public function start_el (&$output, $item, $depth = 0, $args = array (), $id = 0) {

        $classes = empty ($item->classes) ? array () : (array) $item->classes;

        if ($item->url == '#null') {
            // HACK: #null is just a placeholder for no url, to use when
            // wordpress admin screen requires an input in this field
            $item->url = '';
        }

        if (in_array ('menu-load-h4', $classes)) {
            $doc = $this->load_html ();
            $xpath  = new \DOMXpath ($doc);
            $out = array ();
            $headers = $xpath->query ("//h4[@id]|//h5[@id]|//h6[@id]");

            foreach ($headers as $header) {
                $id = $header->getAttribute ('id');
                $level = intVal ($header->tagName[1]) - 3;
                $out[] = "<li class='menu-item menu-item-load-h4 menu-item-level-$level'>";
                $out[] = "<a class='ssdone' href='#$id'>{$header->textContent}</a>";
                $out[] = "</li>";
            }
            $output .= implode ("\n", $out);
            return;
        }

        $tmp_output = '';
        parent::start_el ($tmp_output, $item, $depth, $args, $id);

        /*
        if (empty ($item->url)) {
            $tmp_output = preg_replace ('/<a(.*?)>/', '<span${1}>', $tmp_output);
            $tmp_output = str_replace  ('</a>',       '</span>',    $tmp_output);
        }
        */

        if (in_array ('menu-load-rubriken', $classes)) {
            // FIXME: Generating the menus here doesn't work yet because our XML
            // just plain doesn't validate.  Instead we rely on the browser to
            // parse it for better or worse (probably worse) and then use jquery
            // to fill the holes.

            // This is what we may do when the transformed xml validates...
            //
            // $content = apply_filters ('the_content', get_the_content ());
            // $content = str_replace( ']]>', ']]&gt;', $content);
            // $xml = simplexml_load_string ($content);
            // $milestones = $xml->xpath ("//span[@class='milestone']");

            $tmp_output .= "<ul class='menu-dyn-is'><!-- filled by javascript --></ul>";
        }
        if (in_array ('menu-load-bk-js', $classes)) {
            // obsolete js way
            $tmp_output .= "<ul class='menu-dyn-bk'><!-- filled by javascript --></ul>";
        }
        if (in_array ('menu-load-bk', $classes)) {
            // new php way
            $doc = $this->load_html ();
            $xpath  = new \DOMXpath ($doc);
            $out = array ();
            $out[] = "<ul class='menu-bk'>";

            foreach ($xpath->query ("//span[@class='milestone']") as $bk) {
                $id = $bk->getAttribute ('id');
                $text = preg_replace ("/_.*$/u", "", $id);
                $text = str_replace (".", " ", $text);
                $out[] = "  <li class='menu-item menu-item-load-bk'>";
                $out[] = "    <a href='#$id'>$text</a>";
                $out[] = "  </li>";
            }
            $out[] = "</ul>";
            $tmp_output .= implode ("\n", $out);
        }
        $output .= $tmp_output;
    }

    private function load_html () {
        $content = apply_filters ('the_content', get_the_content ());
        // $content = str_replace( ']]>', ']]&gt;', $content);

        $doc = new \DomDocument ();

        // keep server error log small (seems to be a problem at uni-koeln.de)
        libxml_use_internal_errors (true);

        // Hack to load HTML with utf-8 encoding
        $doc->loadHTML ("<?xml encoding='UTF-8'>\n" . $content, LIBXML_NONET);
        foreach ($doc->childNodes as $item)
            if ($item->nodeType == XML_PI_NODE)
                $doc->removeChild ($item); // remove xml declaration
        $doc->encoding = 'UTF-8'; // insert proper encoding
        return $doc;
    }
}

class Cap_Widget_Transcription_Navigation extends WP_Nav_Menu_Widget {

    public function __construct() {
        $widget_ops = array ('description' => __('A navigation menu for transcription pages.', 'capitularia') );
        WP_Widget::__construct ('cap_nav_menu', __('Capitularia Navigation Menu', 'capitularia'), $widget_ops );
    }

    public function widget ($args, $instance) {
        $args['mirsn'] = 'XXX'; // tag *our* menu
        parent::widget ($args, $instance);
    }

    static function on_widget_nav_menu_args ($nav_menu_args, $nav_menu, $args) {
        if (!empty ($args['mirsn'])) { // pick out *our* menu
            $nav_menu_args['walker'] = new Cap_Walker_Transcription_Nav_Menu ();
            $nav_menu_args['container_class'] = 'sidebar-toc';
        }
        return $nav_menu_args;
    }

    static function on_enqueue_scripts () {
        wp_enqueue_script (
            'cap-widget-transcription-navigation-js',
            get_template_directory_uri () . '/widgets/cap-widget-transcription-navigation.js',
            array ('cap-jquery', 'cap-jquery-ui')
        );
    }

    static function on_widgets_init () {
        register_widget ('Cap_Widget_Transcription_Navigation');
    }
}

add_filter ('widget_nav_menu_args',
            array ('Cap_Widget_Transcription_Navigation', 'on_widget_nav_menu_args'), 10, 3);
add_action ('widgets_init',
            array ('Cap_Widget_Transcription_Navigation', 'on_widgets_init'));
add_action ('wp_enqueue_scripts',
            array ('Cap_Widget_Transcription_Navigation', 'on_enqueue_scripts'));

?>