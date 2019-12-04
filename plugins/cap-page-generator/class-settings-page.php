<?php
/**
 * Capitularia Page Generator Settings Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

use cceh\capitularia\lib;
use cceh\capitularia\file_includer;

/**
 * Implements the settings (options) page.
 *
 * Found in Wordpress admin under :menuselection:`Settings | Capitularia Page
 * Generator`.
 */

class Settings_Page
{
    /**
     * Constructor
     *
     * Add option fields so we can use the Wordpress function
     * do_settings_fields() to output them.  All field descriptions are stored
     * in the Config class.
     *
     * Also register _one_ POST parameter to be handled and validated by
     * Wordpress.
     *
     * @return Settings_Page
     */

    public function __construct ()
    {
        global $config;

        /* Register the Settings page's fields with Wordpress. */
        foreach ($config->sections as $section) {
            $section_id = $section[0];

            foreach ($section[1] as $field) {
                $field_id          = $field[0];
                $field_caption     = $field[1];
                $field_description = $field[2];

                add_settings_field (
                    $section_id . '.' . $field_id,
                    $field_caption,
                    array ($this, 'on_options_field'),
                    OPTIONS,
                    OPTIONS . '_' . $section_id,
                    // array becomes argument of on_options_field ($args)
                    array ($section_id, $field_id, $field_description)
                );
            }
        }

        /* Register only _one_ parameter. @see on_options_field() */
        register_setting (OPTIONS, OPTIONS, array ($this, 'on_validate'));
    }

    /**
     * Output the Settings page.
     *
     * @return void
     */

    public function display ()
    {
        global $config;

        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n");
        echo ("  <h2>$title</h2>\n");
        echo ('  <p><a href="/wp-admin/index.php?page=' . DASHBOARD . '">' . __ ('Dashboard', LANG) . "</a></p>\n");
        echo ("  <form method='post' action='options.php'>\n");
        echo ("    <div id='tabs'>\n");

        // Output the AJAX security fields
        settings_fields (OPTIONS);

        // Output the ui-widget-header
        echo ("      <ul>\n");
        foreach ($config->sections as $section) {
            $section_id = $section[0];
            $caption    = __ ($config->get_opt ($section_id, 'section_caption', $section_id));
            $class      = 'navtab';
            $class      .= $config->section_can ($section_id, 'private') ? ' cap_can_private' : '';
            $class      .= $config->section_can ($section_id, 'publish') ? ' cap_can_publish' : '';
            echo ("<li><a class='$class' href='#tabs-$section_id'>$caption</a></li>\n");
        }
        echo ("      </ul>\n");

        // Output the ui-widget-content
        foreach ($config->sections as $section) {
            $section_id = $section[0];
            $caption    = __ ($config->get_opt ($section_id, 'section_caption', $section_id));
            echo ("      <div id='tabs-$section_id'>\n");
            echo ("        <h2>$caption</h2>\n");
            echo ('        <table class="form-table">');
            // Output previously registered fields
            do_settings_fields (OPTIONS, OPTIONS . '_' . $section_id);
            echo ('        </table>');
            echo ("      </div>\n");
        }
        lib\save_button ();
        echo ("    </div>\n");
        echo ("  </form>\n");
        echo ("</div>\n");
    }

    /**
     * Output an option field.
     *
     * Output (echo) an option field with its description.
     *
     * We want all user entries to be returned into PHP as *one* string[] called
     * *OPTIONS_PAGE_ID*.  This array will be passed by Wordpress to the
     * validation function and stored in the database all in *one* row.
     *
     * @param array $args The arguments registered with add_settings_field ()
     *
     * @return void
     *
     * @see http://planetozh.com/blog/2009/05/handling-plugins-options-in-wordpress-28-with-register_setting/
     *      Blog post: how to store all plugin options into one database row.
     */

    public function on_options_field ($args)
    {
        global $config;

        $section_id  = $args[0];
        $field_id    = $args[1];
        $description = $args[2];
        $page_id     = OPTIONS;
        $value       = $config->get_opt ($section_id, $field_id);
        if ($field_id === 'shortcode') {
            echo ("<textarea class='file-input' name='{$page_id}[{$section_id}.{$field_id}]'>$value</textarea>");
            echo ("<p>{$description}</p>\n");
            $cap_fi_root = file_includer\get_root ();
            echo ('<p>' . sprintf (
                __ ('N.B. The File Includer plugin root is set to:<br>%s', LANG),
                $cap_fi_root
            ) . "</p>\n");
        } else {
            echo ("<input class='file-input' type='text' name='{$page_id}[{$section_id}.{$field_id}]' value='{$value}' />");
            echo ("<p>{$description}</p>\n");
        }
    }

    /**
     * Validate options entered by user
     *
     * We get all user entries back in one string[] so we can store them in one
     * database row.  This makes validation somewhat more difficult.
     *
     * @see on_options_field()
     *
     * @param array $options Array of key, value: the options as entered on
     *                       the form.
     *
     * @return array Array containing the validated options
     */

    public function on_validate (array $options)
    {
        global $config;

        $output = array ();
        foreach ($options as $options_id => $value) {
            // Find the field in the $sections structure.
            foreach ($config->sections as $section) {
                $section_id = $section[0];
                foreach ($section[1] as $field) {
                    $field_id = $field[0];
                    $callable = $field[3];
                    if ($options_id == $section_id . '.' . $field_id) {
                        // Field found. Validate it and pass it on.
                        $output[$options_id] = call_user_func ($callable, $value);
                    }
                }
            }
        }
        $output['general.section_caption'] = __ ('General', LANG);
        // Merge with old options
        return array_merge (get_option (OPTIONS, array ()), $output);
    }
}
