<?php
/**
 * Capitularia Page Generator.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/**
 * Create pages from TEI files.
 *
 * A key function of the Capitularia site is to present TEI files to the user.
 * The TEI files have to be converted first and stored in the Wordpress
 * database.  The conversion is done by the XSL processor plugin, which is
 * controlled by Wordpress shortcodes.
 *
 * The page generator plugin (this plugin) creates and manages Wordpress pages
 * that contain the appropriate shortcodes for the XSL processor.  The
 * shortcodes are initially empty.  The XSL processor then fills the shortcodes
 * with content the first time the page is viewed.
 *
 * The admin user may choose among different directories and is presented with a
 * table of the TEI files contained therein.  Acting on controls in the table of
 * files the user can manage the created pages.
 *
 * The plugin does nothing on the public pages except displaying a button on the
 * admin toolbar.
 */

class Page_Generator
{
    /** @var string The name of the plugin */
    public $name;

    /** @var Settings_Page Reference to keep the settings page alive */
    public $settings_page = null;

    /** @var Dashboard_Page Reference to keep the dashboard page alive */
    public $dashboard_page = null;

    /**
     * Constructor
     *
     * @return Page_Generator
     */

    public function __construct ()
    {
        $this->name   = __ ('Capitularia Page Generator', 'capitularia');

        add_action ('wp_enqueue_scripts',          array ($this, 'on_enqueue_scripts'));
        add_action ('admin_menu',                  array ($this, 'on_admin_menu'));
        add_action ('admin_bar_menu',              array ($this, 'on_admin_bar_menu'), 200);
        add_action ('admin_enqueue_scripts',       array ($this, 'on_admin_enqueue_scripts'));
        add_action ('wp_ajax_on_cap_action_file',  array ($this, 'on_cap_action_file'));
        add_action ('wp_ajax_on_cap_load_section', array ($this, 'on_cap_load_section'));
        add_filter ('query_vars',                  array ($this, 'on_query_vars'));
    }

    /**
     * AJAX hook
     *
     * @return void
     */

    public function on_cap_action_file ()
    {
        check_ajax_referer (NONCE_SPECIAL_STRING, NONCE_PARAM_NAME);
        if (!current_user_can ('edit_posts')) {
            wp_send_json_error (
                array ('message' => __ ('You have no permission to edit posts.', 'capitularia'))
            );
            exit ();
        }
        $this->dashboard_page = new Dashboard_Page ();
        $this->dashboard_page->on_cap_action_file ();
    }

    /**
     * AJAX hook
     *
     * @return void
     */

    public function on_cap_load_section ()
    {
        // no user permission checks because we are just reading
        $this->dashboard_page = new Dashboard_Page ();
        $this->dashboard_page->on_cap_load_section ();
    }

    /**
     * Enqueue the public pages scripts and styles
     *
     * @return void
     */

    public function on_enqueue_scripts ()
    {
        wp_register_style ('cap-page-gen-front', plugins_url ('css/front.css', __FILE__));
        wp_enqueue_style  ('cap-page-gen-front');
    }

    /**
     * Register _cap\_page\_gen_ as valid HTTP GET parameter
     *
     * We use the _cap\_page\_gen_ parameter to call the dashboard from the
     * _Page Generator_ button on the user's tool bar on the public pages.
     *
     * @param string[] $vars Already registered parameter names
     *
     * @return string[] Augmented registered parameter names.
     */

    public function on_query_vars ($vars)
    {
        $vars[] = 'cap_page_gen';
        return $vars;
    }

    /*
     * Administration page stuff
     */

    /**
     * Enqueue the admin page scripts and styles
     *
     * @return void
     */

    public function on_admin_enqueue_scripts ()
    {
        wp_register_style (
            'cap-page-gen-admin',
            plugins_url ('css/admin.css', __FILE__),
            array ('cap-jquery-ui-css')
        );
        wp_enqueue_style  ('cap-page-gen-admin');

        wp_register_script (
            'cap-page-gen-admin',
            plugins_url ('js/admin.js', __FILE__),
            array ('cap-jquery', 'cap-jquery-ui')
        );
        wp_enqueue_script ('cap-page-gen-admin');

        wp_localize_script (
            'cap-page-gen-admin',
            'cap_page_gen_admin_ajax_object',
            array (
                NONCE_PARAM_NAME => wp_create_nonce (NONCE_SPECIAL_STRING),
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
        $this->settings_page  = new Settings_Page ();
        add_options_page (
            $this->name . ' Options',
            $this->name,
            'manage_options',
            OPTIONS_PAGE_ID,
            array ($this->settings_page, 'display')
        );
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
                'id'    => 'cap_page_gen_open',
                'title' => __ ('Page Generator'),
                'href'  => '/wp-admin/index.php?page=' . DASHBOARD_PAGE_ID,
                'meta'  => array ('class' => 'cap-page-gen',
                                  'title' => $this->name),
            );
            $wp_admin_bar->add_node ($args);
        }
    }
}
