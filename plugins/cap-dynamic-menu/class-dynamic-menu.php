<?php
/**
 * Capitularia Dynamic Menu main class
 *
 * @package Capitularia
 */

namespace cceh\capitularia\dynamic_menu;

/**
 * A dynamic menu for in-page navigation.
 *
 * The dynamic menu is generated from xpath expressions that query the page
 * content.  Each xpath expression generates one level of the menu.  Use the
 * standard wordpress admin interface to define the xpath expressions.
 *
 * To make a dynamic menu, insert a _Custom Link_ item into any Wordpress menu
 * and give it a magic url of: _#cap\_dynamic\_menu#_.  The _Custom Link_
 * item will be replaced by the generated menu.
 *
 * Put the xpath expressions for each level of the menu into the _Description_
 * field.  Separate each level with a _§_ (section sign).
 *
 * The default xpath expressions are: //h3[@id]§//h4[@id]§//h5[@id]§//h6[@id],
 * which generate a 4 level deep menu built from h3-h6 elements that have an
 * _id_ attribute.
 *
 * The caption of a generated menu item is taken from the
 * _data-cap-dyn-menu-caption_ attribute on the source element or
 * from the source element's _textContent_.
 *
 * All classes in the _CSS Classes_ field in the Wordpress admin interface are
 * copied over to each generated menu item as class _$class-level-$level_.
 * Eg. a class of _my-menu_ would become _my-menu-level-1_.
 *
 * All classes on the source element that start with _dynamic-menu-_
 * are copied to each generated menu item.
 *
 * Additionally classes named _menu-item_,
 * _dynamic-menu-item_, and
 * _dynamic-menu-item-level-$level_ are added to each generated menu
 * item.
 */

class Dynamic_Menu
{
    /** Class constructor */
    public function __construct ()
    {
        add_filter ('wp_get_nav_menu_items', array ($this, 'on_wp_get_nav_menu_items'), 20, 3);
    }

    /**
     * Create a new menu item in memory.
     *
     * @param string  $caption The menu item caption.
     * @param integer $item_id The menu item id of the new menu entry.
     * @param array   $classes The classes to add to the menu item.
     *
     * @return \WP_Post The new menu item.
     */

    private function new_item ($caption, $item_id, $classes = array ())
    {
        $new_item = new \WP_Post ((object) array ('ID' => $item_id));
        $new_item->target      = '';
        $new_item->description = '';
        $new_item->xfn         = '';

        $new_item->db_id       = $item_id;
        $new_item->menu_order  = $item_id;
        $new_item->post_name   = 'dynamic-menu-item-' . $item_id;

        $new_item->post_type   = 'nav_menu_item';
        $new_item->object      = 'custom';
        $new_item->object_id   = 0;
        $new_item->type        = 'custom';
        $new_item->type_label  = 'Custom';

        $new_item->title       = $caption;
        $new_item->attr_title  = preg_replace ('/\s+/', ' ', trim ($caption));
        $new_item->post_title  = $caption;

        $new_item->classes     = $classes;
        $new_item->classes[]   = 'menu-item';
        $new_item->classes[]   = 'dynamic-menu-item';

        return $new_item;
    }

    /**
     * Add dynamic items to the menu.
     *
     * @param array  $items      Old items.
     * @param string $dummy_menu (unused) Menu.
     * @param array  $dummy_args (unused) Menu args.
     *
     * @return array Menu with new items.
     */

    public function on_wp_get_nav_menu_items ($items, $dummy_menu, $dummy_args)
    {
        // Only do this on front pages.
        if (is_admin ()) {
            return $items;
        }

        // Check if the menu contains a dynamic element.  Also get the highest
        // menu id while we are at it.
        $is_dynamic_menu = false;
        $next_item_id = 0;

        foreach ($items as $key => $item) {
            $next_item_id = max ($next_item_id, $item->ID);
            if (isset ($item->url)) {
                if (stristr ($item->url, '#cap_dynamic_menu#') !== false) {
                    $is_dynamic_menu = true;
                }
                if (stristr ($item->url, '#cap_login_menu#') !== false) {
                    $is_dynamic_menu = true;
                }
            }
        }

        // Bail out if the menu does not contain dynamic elements.
        if (!$is_dynamic_menu) {
            return $items;
        }

        // The menu contains a dynamic element.
        $new_items = array ();
        $doc = load_html ();
        $xpath  = new \DOMXpath ($doc);
        foreach ($items as $key => $item) {
            if (isset ($item->url)) {
                // Build a dynamic menu entry.  The menu entry with the url of
                // '#cap_dynamic_menu#' will be converted into a full-blown
                // hierarchic menu whose entries are parsed from the page HTML.
                if (stristr ($item->url, '#cap_dynamic_menu#') !== false) {
                    // get levels out of description field
                    $desc = isset ($item->description) ? $item->description :
                          '//h3[@id]§//h4[@id]§//h5[@id]§//h6[@id]';
                    $levels = explode ('§', $desc);
                    $item_classes = isset ($item->classes) ? $item->classes : array ();

                    // We need to get all nodes that match any of our level xpath
                    // expressions in document order.
                    //
                    // 1. For each level mark all relevant nodes with the
                    // XML-attribute 'data-cap-level' ...

                    $parent_on_level = array ();
                    $parent_on_level[] = $item->menu_item_parent;
                    $level_no = 0;
                    foreach ($levels as $level) {
                        ++$level_no;
                        // undo fucking wp_texturizer
                        $level = str_replace ('′', "'", $level);
                        $level = str_replace ('’', "'", $level);
                        $level = str_replace ('”', '"', $level);
                        // error_log ("Level = '$level'");
                        foreach ($xpath->query (trim ($level)) as $e) {
                            $e->setAttribute ('data-cap-level', strVal ($level_no));
                        }
                        $parent_on_level[] = $item->menu_item_parent;
                    }

                    // 2. Find all nodes with the XML-attribute 'data-cap-level'
                    // in document order and output the respective menu entry.

                    foreach ($xpath->query ('//*[@data-cap-level]') as $e) {
                        $id         = $e->getAttribute ('id');
                        $caption    = $e->hasAttribute ('data-cap-dyn-menu-caption') ?
                                    $e->getAttribute ('data-cap-dyn-menu-caption') : $e->textContent;
                        $node_level = intVal ($e->getAttribute ('data-cap-level')); // 1..max

                        // build the new menu entry
                        $next_item_id++;
                        $new_item = $this->new_item ($caption, $next_item_id, $item_classes);
                        $new_item->url       = empty ($id) ? $e->getAttribute ('href') : "#$id";

                        // add classes keyed to level
                        $new_item->classes[] = "dynamic-menu-item-level-$node_level";
                        foreach ($item_classes as $class) {
                            $new_item->classes[] = "$class-level-$node_level";
                        }

                        // Copy classes that start with 'dynamic-menu-' from the
                        // HTML of the page to the menu.  This is a way to style
                        // arbitrary entries of the menu.
                        $classes = $e->hasAttribute ('class') ? $e->getAttribute ('class') : '';
                        foreach (explode (' ', $classes) as $class) {
                            if (strncmp ($class, 'dynamic-menu-', 13) == 0) {
                                $new_item->classes[] = $class;
                            }
                        }

                        // Tell Wordpress the structure of our menu by setting
                        // the menu hierarchy fields.
                        $new_item->menu_item_parent   = $parent_on_level[$node_level - 1];
                        $parent_on_level[$node_level] = $new_item->db_id;

                        $new_items[$new_item->post_name] = $new_item;

                        // error_log ("Menu Item: $new_item->title $new_item->post_name $new_item->menu_item_parent");
                    }
                    continue;
                }

                // Build menu entry that points to the login page.
                if (stristr ($item->url, '#cap_login_menu#') !== false) {
                    $item->url = wp_login_url (get_permalink ());
                    // error_log ("Login menu url: {$item->url}");
                    $new_items[$key] = $item;
                    continue;
                }
            }
            // else add unprocessed items
            $new_items[$key] = $item;
        }
        return $new_items;
    }
}
