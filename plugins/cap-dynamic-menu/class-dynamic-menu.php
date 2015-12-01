<?php
/**
 * Capitularia Dynamic Menu main class.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\dynamic_menu;

class Dynamic_Menu
{
    /**
     * Our singleton instance
     */
    static private $instance = false;

    const NAME = 'Capitularia Dynamic Menu';

    /**
     * If an instance exists, this returns it.  If not, it creates one and
     * returns it.
     *
     * @return Dynamic_Menu
     */
    public static function getInstance () {
        if (!self::$instance) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    private function __construct () {
        add_action ('wp_enqueue_scripts',    array ($this, 'on_enqueue_scripts'));
        add_filter ('wp_get_nav_menu_items', array ($this, 'on_wp_get_nav_menu_items'), 20, 3);
    }

    private function load_html () {
        $content = apply_filters ('the_content', get_the_content ());
        // $content = str_replace( ']]>', ']]&gt;', $content);

        $doc = new \DomDocument ();

        // keep server error log small (seems to be a problem at uni-koeln.de)
        libxml_use_internal_errors (true);

        // Hack to load HTML with utf-8 encoding
        $doc->loadHTML ("<?xml encoding='UTF-8'>\n" . $content, LIBXML_NONET);
        foreach ($doc->childNodes as $item) {
            if ($item->nodeType == XML_PI_NODE) {
                $doc->removeChild ($item); // remove xml declaration
            }
        }
        $doc->encoding = 'UTF-8'; // insert proper encoding
        return $doc;
    }

    public function on_wp_get_nav_menu_items ($items, $menu, $args) {
        if (is_admin ()) {
            return $items;
        }
        // check if the menu contains a dynamic element
        $is_dynamic_menu = false;
        $max_item_id = 0;
        foreach ($items as $key => $item) {
            $max_item_id = max ($max_item_id, $item->ID);
            if (isset ($item->url) && stristr ($item->url, '#cap_dynamic_menu#') !== false) {
                $is_dynamic_menu = true;
            }
        }
        if (!$is_dynamic_menu) {
            return $items;
        }

        // menu contains a dynamic element
        $new_items = array ();
        $doc = $this->load_html ();
        $xpath  = new \DOMXpath ($doc);
        foreach ($items as $key => $item) {
            if (isset ($item->url) && stristr ($item->url, '#cap_dynamic_menu#') !== false) {
                // get levels out of description field
                $desc = isset ($item->description) ? $item->description :
                      '//h3[@id]|//h4[@id]|//h5[@id]|//h6[@id]';
                $levels = explode ('|', $desc);

                $parent_on_level = array ();
                $parent_on_level[] = $item->menu_item_parent;
                // mark nodes with special attribute
                $level_no = 0;
                foreach ($levels as $level) {
                    ++$level_no;
                    foreach ($xpath->query ($level) as $e) {
                        $e->setAttribute ('data-cap-level', strVal ($level_no));
                    }
                    $parent_on_level[] = $item->menu_item_parent;
                }

                // get all marked nodes in document order
                foreach ($xpath->query ('//*[@data-cap-level]') as $e) {
                    $max_item_id++;
                    $id         = $e->getAttribute ('id');
                    $caption    = $e->textContent;
                    $node_level = intVal ($e->getAttribute ('data-cap-level')); // 1..max

                    $new_item = new \WP_Post ((object) array ('ID' => $max_item_id));
                    $new_item->target           = '';
                    $new_item->description      = '';
                    $new_item->xfn              = '';

                    $new_item->menu_order       = $max_item_id;
                    $new_item->post_type        = 'nav_menu_item';
                    $new_item->object           = 'custom';
                    $new_item->object_id        = $item->object_id + $max_item_id;
                    $new_item->type             = 'custom';
                    $new_item->type_label       = 'Custom';
                    $new_item->title            = $caption;
                    $new_item->attr_title       = $caption;
                    $new_item->post_title       = $caption;
                    $new_item->url              = "#$id";
                    $new_item->post_name        = "dynamic-menu-item-$max_item_id";
                    $new_item->classes          = array ();
                    $new_item->classes[]        = 'menu-item';
                    $new_item->classes[]        = 'dynamic-menu-item';
                    $new_item->classes[]        = "dynamic-menu-item-level-$node_level";

                    // the menu hierarchy fields
                    $new_item->db_id              = $max_item_id;
                    $new_item->menu_item_parent   = $parent_on_level[$node_level - 1];
                    $parent_on_level[$node_level] = $new_item->db_id;

                    $new_items[$new_item->post_name] = $new_item;

                    error_log ("Menu Item: $new_item->title $new_item->post_name $new_item->menu_item_parent");
                }
            } else {
                $new_items[$key] = $item;
            }
        }
        return $new_items;
    }

    public function on_enqueue_scripts () {
        wp_register_style  ('cap-dynamic-menu-front', plugins_url ('css/front.css', __FILE__));
        wp_register_script (
            'cap-dynamic-menu-front',
            plugins_url ('js/front.js', __FILE__),
            array ('cap-jquery', 'cap-jquery-ui')
        );
        wp_enqueue_script  ('cap-dynamic-menu-front');
        // wp_enqueue_style   ('cap-dynamic-menu-front');
    }

    public static function on_activation () {
    }

    public static function on_deactivation () {
    }

    public static function on_uninstall () {
    }
}
