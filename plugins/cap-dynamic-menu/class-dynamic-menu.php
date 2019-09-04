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
 * See: src/js/front.js for more information.
 */

class Dynamic_Menu
{
    /** Class constructor */
    public function __construct ()
    {
        add_filter ('wp_get_nav_menu_items', array ($this, 'on_wp_get_nav_menu_items'), 20, 3);
    }

    /**
     * Add dynamic items to the menu.
     *
     * @param array  $items      Old items.
     * @param string $dummy_menu (unused) Menu.
     * @param array  $dummy_args (unused) Menu args.
     *
     * @return array Updated menu.
     */

    public function on_wp_get_nav_menu_items ($items, $dummy_menu, $dummy_args)
    {
        // Only do this on front pages.
        if (is_admin ()) {
            return $items;
        }

        foreach ($items as $key => $item) {
            if (isset ($item->url)) {
                if (strcmp ($item->url, '#cap_dynamic_menu#') === 0) {
                    # the menu will be post-processed by javascript
                    # put the description somewhere in the html so
                    # the javascript can find it
                    $item->target = $item->description;
                }
                if (strcmp ($item->url, '#cap_login_menu#') === 0) {
                    $item->url = wp_login_url (get_permalink ());
                }
            }
        }

        return $items;
    }
}
