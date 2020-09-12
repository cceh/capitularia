<?php
/**
 * Capitularia File Includer Settings Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\file_includer;

use cceh\capitularia\lib;

/**
 * Implements the settings (options) page.
 *
 * Found in Wordpress admin under :menuselection:`Settings | Capitularia File
 * Includer`.
 */

class Settings_Page
{
    /**
     * Constructor
     *
     * Add option fields so we can use the Wordpress function
     * do_settings_sections() to output them.
     *
     * Also register *one* POST parameter to be handled and validated by
     * Wordpress.  We want all user entries to be returned into PHP as *one*
     * string array called *OPTIONS_PAGE_ID*.  This array will be passed by
     * Wordpress to the validation function and stored in the database all in
     * *one* row.
     *
     * @return self
     *
     * @see http://planetozh.com/blog/2009/05/handling-plugins-options-in-wordpress-28-with-register_setting/
     *      Blog post: how to store all plugin options into one database row.
     */

    public function __construct ()
    {
        $this->options = OPTIONS;
        $section = OPTIONS . '_section_general';

        add_settings_section (
            $section,
            __ ('General Settings', DOMAIN),
            array ($this, 'on_options_section_general'),
            OPTIONS
        );

        add_settings_field (
            OPTIONS . '_options_root',
            __ ('Root directory', DOMAIN),
            array ($this, 'on_options_field_root'),
            OPTIONS,
            $section
        );
        add_settings_field (
            OPTIONS . '_options_shortcode',
            __ ('Shortcode', DOMAIN),
            array ($this, 'on_options_field_shortcode'),
            OPTIONS,
            $section
        );

        register_setting (OPTIONS, OPTIONS, array ($this, 'on_validate_options'));
    }

    /**
     * Output the Settings page.
     *
     * @throws InvalidArgumentException if the provided argument is not of type
     *     'array'.
     *
     * @return void
     */

    public function display ()
    {
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n<h2>$title</h2>\n<form method='post' action='options.php'>");
        settings_fields (OPTIONS);
        do_settings_sections (OPTIONS);
        lib\save_button ();
        echo ('</form>');
    }

    /**
     * Output the 'general' section.
     *
     * @return void
     */

    public function on_options_section_general ()
    {
    }

    /**
     * Output the root option field with its description.
     *
     * @return void
     */

    public function on_options_field_root ()
    {
        $setting = get_opt ('root');
        echo "<input class='file-input' type='text' name='{$this->options}[root]' value='$setting' />";
        echo '<p>' . sprintf (
            __ (
                'Root directory of the files you want to include, relative to the AFS root.  ' .
                'The AFS root is currently configured as<br>%s',
                DOMAIN
            ),
            lib\get_opt ('afs')
        ) . '</p>';
    }

    /**
     * Output the shortcode option field with its description.
     *
     * @return void
     */

    public function on_options_field_shortcode ()
    {
        $setting = get_opt ('shortcode');
        echo "<input class='file-input' type='text' name='{$this->options}[shortcode]' value='$setting' />";
        echo '<p>' . __ ('The shortcode to use, eg.: cap_include', DOMAIN) . '</p>';
    }

    /**
     * Sanitize a field that should contain a path.
     *
     * @param string $path The path to sanitize
     *
     * @return string Sanitized path without trailing slash.
     */

    private function sanitize_path ($path)
    {
        return rtrim (sanitize_text_field ($path), '/');
    }

    /**
     * Validate options entered by user
     *
     * We get all user entries back in one associative array so that we can
     * store them in one database row.  This makes validation somewhat more
     * difficult.
     *
     * @param array $options Array of key, value: the options as entered on
     *                       the form.
     *
     * @return array Array containing the validated options
     *
     * @see __construct()
     */

    public function on_validate_options ($options)
    {
        $options['root']      = $this->sanitize_path ($options['root']);
        $options['shortcode'] = trim (sanitize_key ($options['shortcode']));
        return $options;
    }
}
