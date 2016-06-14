<?php
/**
 * Capitularia Collation
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

/**
 * Create collations from TEI files.
 */

class Collation
{
    /**
     * Constructor
     *
     * @return Collation
     */

    private $name;

    public function __construct ()
    {
        $this->name   = __ ('Capitularia Collation', 'capitularia');

        add_action ('wp_enqueue_scripts',              array ($this, 'on_enqueue_scripts'));
        add_action ('admin_menu',                      array ($this, 'on_admin_menu'));
        add_action ('admin_bar_menu',                  array ($this, 'on_admin_bar_menu'), 200);
        add_action ('admin_enqueue_scripts',           array ($this, 'on_admin_enqueue_scripts'));
        add_filter ('query_vars',                      array ($this, 'on_query_vars'));

        add_action ('wp_ajax_on_cap_load_sections',    array ($this, 'on_cap_load_sections'));
        add_action ('wp_ajax_on_cap_load_manuscripts', array ($this, 'on_cap_load_manuscripts'));
        add_action ('wp_ajax_on_cap_load_collation',   array ($this, 'on_cap_load_collation'));
    }

    /**
     * Add our custom HTTP query vars
     *
     * @param array $vars The stock query vars
     *
     * @return array The stock and custom query vars
     */

    public function on_query_vars ($vars)
    {
        $vars[] = 'bk';
        return $vars;
    }


    /**
     * Enqueue the public pages scripts and styles
     *
     * @return void
     */

    public function on_enqueue_scripts ()
    {
        wp_register_style ('cap-collation-front', plugins_url ('css/front.css', __FILE__));
        wp_enqueue_style  ('cap-collation-front');
    }

    /*
     * Incipit Administration page stuff
     */

    /**
     * Enqueue the admin page scripts and styles
     *
     * @return void
     */

    public function on_admin_enqueue_scripts ()
    {
        wp_register_style (
            'cap-collation-admin',
            plugins_url ('css/admin.css', __FILE__),
            array ('cap-jquery-ui-css')
        );
        wp_enqueue_style  ('cap-collation-admin');

        wp_register_script (
            'cap-collation-admin',
            plugins_url ('js/admin.js', __FILE__),
            array ('cap-jquery', 'cap-jquery-ui')
        );
        wp_enqueue_script ('cap-collation-admin');

        wp_localize_script (
            'cap-collation-admin',
            'ajax_object',
            array (
                'ajax_nonce' => wp_create_nonce (NONCE_SPECIAL_STRING),
                'ajax_nonce_param_name' => NONCE_PARAM_NAME,
            )
        );
    }

    /**
     * Add menu entries to the Wordpress admin menu.
     *
     * Adds menu entries for the settings (options) and the dashboard pages to
     * the Wordpress settings and dashboard admin page menus respectively.
     *
     * @return void
     */

    public function on_admin_menu ()
    {
        // adds a menu entry to the settings menu
        /*
        $this->settings_page  = new Settings_Page ($this->config);
        add_options_page (
            $this->name . ' Options',
            $this->name,
            'manage_options',
            OPTIONS_PAGE_ID,
            array ($this->settings_page, 'display')
        );
        */
        // adds a menu entry to the dashboard menu
        $this->dashboard_page = new Dashboard_Page ();
        add_submenu_page (
            'index.php',
            $this->name . ' Dashboard',
            $this->name,
            'edit_pages',
            DASHBOARD_PAGE_ID,
            array ($this->dashboard_page, 'on_menu_dashboard_page')
        );
    }

    /**
     * Add a dashboard button to the Wordpress toolbar.
     *
     * @param \WP_Admin_Bar $wp_admin_bar The \WP_Admin_Bar object
     *
     * @return void
     */

    public function on_admin_bar_menu ($wp_admin_bar)
    {
        if (!is_admin () && current_user_can ('edit_pages')) {
            $args = array (
                'id'    => 'cap_collation_open',
                'title' => _x ('Collation', 'Admin bar button caption', 'capitularia'),
                'href'  => '/wp-admin/index.php?page=' . DASHBOARD_PAGE_ID,
                'meta'  => array ('class' => 'cap-collation',
                                  'title' => $this->name),
            );
            $wp_admin_bar->add_node ($args);
        }
    }

    /**
     * AJAX hook
     *
     * @return void
     */

    public function on_cap_load_sections ()
    {
        // no user permission checks because we are just reading
        $this->dashboard_page = new Dashboard_Page ();
        $this->dashboard_page->on_cap_load_sections ();
    }

    /**
     * AJAX hook
     *
     * @return void
     */

    public function on_cap_load_manuscripts ()
    {
        // no user permission checks because we are just reading
        $this->dashboard_page = new Dashboard_Page ();
        $this->dashboard_page->on_cap_load_manuscripts ();
    }

    /**
     * AJAX hook
     *
     * @return void
     */

    public function on_cap_load_collation ()
    {
        // no user permission checks because we are just reading
        $this->dashboard_page = new Dashboard_Page ();
        $this->dashboard_page->on_cap_load_collation ();
    }
}
