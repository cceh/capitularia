<?php
/**
 * Capitularia Meta Search Settings Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\meta_search;

/**
 * Implements the settings (options) page.
 *
 * Found in Wordpress admin under _Settings | Capitularia Meta Search_.
 */

class Settings_Page
{
    /**
     * Constructor
     *
     * Add option fields so we can use the Wordpress function
     * do_settings_fields() to output them.
     *
     * Also register _one_ POST parameter to be handled and validated by
     * Wordpress.
     *
     * @return Settings_Page
     */

    public function __construct ()
    {
        $section = OPTIONS . '_section_general';

        add_settings_section (
            $section,
            __ ('General Settings', LANG),
            array ($this, 'on_options_section_general'),
            OPTIONS
        );

        add_settings_field (
            OPTIONS . '_places_path',
            __ ('Path for the XML Places file', LANG),
            array ($this, 'on_options_field_places_path'),
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
        echo ("<div class='wrap'>\n");
        echo ("  <h2>$title</h2>\n");
        echo ("  <div class='cap_message'></div>\n");

        echo ("<form method='post' action='options.php'>\n");
        settings_fields (OPTIONS);
        do_settings_sections (OPTIONS);
        save_button ();
        echo ("</form>\n");

        echo ('<h3>' . __ ('Places File', LANG) . "</h3>\n");
        echo ("<div>\n");
        submit_button (
            _x ('Reload Places File', 'Button: Admin reload the places file', LANG),
            'secondary',
            'reload-places',
            true,
            array ('onclick' => 'cap_meta_search_admin.on_reload_places ()')
        );
        echo ("</div>\n");

        echo ("</div>\n");
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
     * Output the places path option field with its description.
     *
     * @return void
     */

    public function on_options_field_places_path ()
    {
        $options = OPTIONS;
        $setting = get_opt ('places_path');
        echo "<input class='file-input' type='text' name='{$options}[places_path]' value='$setting' />";
        echo '<p>' . __ ('File path in the AFS, eg.:', LANG) .
                   ' ' . AFS_ROOT . 'http/docs/cap/intern/workspace/places.xml</p>';
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
        return rtrim (realpath (sanitize_text_field ($path)), '/');
    }

    /**
     * Validate options entered by user.
     *
     * @param string[] $options Options as entered by admin user
     *
     * @return string[] Validated options
     */

    public function on_validate_options ($options)
    {
        $options['places_path'] = $this->sanitize_path ($options['places_path']);
        return $options;
    }
}
