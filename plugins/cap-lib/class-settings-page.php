<?php
/**
 * Capitularia Library Settings Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\lib;

/**
 * Implements the settings (options) page.
 *
 * Found in Wordpress admin under _Settings | Capitularia Library_.
 */

class Settings_Page
{
    /**
     * Constructor
     *
     * Add option fields so we can use the Wordpress function
     * do_settings_sections() to output them.
     *
     * Also register _one_ POST parameter to be handled and validated by
     * Wordpress.  We want all user entries to be returned into PHP as _one_
     * string[] called _OPTIONS\_PAGE\_ID_.  This array will be passed by
     * Wordpress to the validation function and stored in the database all in
     * _one_ row.
     *
     * @return Settings_Page
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
            __ ('General Settings', LANG),
            array ($this, 'on_options_section_general'),
            OPTIONS
        );

        add_settings_field (
            OPTIONS . '_afs',
            __ ('AFS Root', LANG),
            array ($this, 'on_options_field_afs'),
            OPTIONS,
            $section
        );

        add_settings_field (
            OPTIONS . '_api',
            __ ('API Entrypoint', LANG),
            array ($this, 'on_options_field_api'),
            OPTIONS,
            $section
        );

        register_setting (OPTIONS, OPTIONS, array ($this, 'on_validate_options'));
    }

    /**
     * Output the Settings page.
     *
     * @return void
     */

    public function display ()
    {
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n<h2>$title</h2>\n<form method='post' action='options.php'>");
        settings_fields (OPTIONS);
        do_settings_sections (OPTIONS);
        save_button ();
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
     * Output the AFS option field with its description.
     *
     * @return void
     */

    public function on_options_field_afs ()
    {
        $setting = get_opt ('afs');
        echo "<input class='file-input' type='text' name='{$this->options}[afs]' value='$setting' />";
        echo '<p>' . sprintf (__ ('Root directory of Capitularia in the AFS', LANG)) . '</p>';
    }

    /**
     * Output the API option field with its description.
     *
     * @return void
     */

    public function on_options_field_api ()
    {
        $setting = get_opt ('api');
        echo "<input class='file-input' type='text' name='{$this->options}[api]' value='$setting' />";
        echo '<p>' . sprintf (__ ('Capitularia API Server entrypoint', LANG)) . '</p>';
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
     * We get all user entries back in one string[] so we can store them in one
     * database row.  This makes validation somewhat more difficult.  @see
     * \_\_construct ()
     *
     * @param string[] $options Options as entered by admin user
     *
     * @return string[] Validated options
     */

    public function on_validate_options ($options)
    {
        $options['afs'] = $this->sanitize_path ($options['afs']);
        $options['api'] = $this->sanitize_path ($options['api']);
        return $options;
    }
}
