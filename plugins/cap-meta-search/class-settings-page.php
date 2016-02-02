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
        add_settings_section (
            'section_general',
            __ ('General Settings', 'capitularia'),
            array ($this, 'on_options_section_general'),
            OPTIONS_PAGE_ID
        );

        /* Example of field definition
           add_settings_field (
               'section_genral__xpath',
               'XPath expression',
               array ($this, 'on_options_field_xpath'),
               OPTIONS_PAGE_ID,
               'section_general'
           );
        */

        register_setting (OPTIONS_PAGE_ID, OPTIONS_PAGE_ID, array ($this, 'on_validate_options'));
    }

    public function display ()
    {
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n");
        echo ("<h2>$title</h2>\n");
        echo ("<form method='post' action='options.php'>\n");
        settings_fields (OPTIONS_PAGE_ID);
        do_settings_sections (OPTIONS_PAGE_ID);
        submit_button ();
        echo ("</form>\n");

        echo ("<h3>Stats</h3>\n");
        echo ("<table class='form-table'>\n");
        echo ("</table>\n");
        echo ("</div>\n");
    }

    public function on_options_section_general ()
    {
        $msg = __ ('No settings.', 'capitularia');
        echo ("<div>$msg</div>\n");
    }

    public function on_validate_options ($options)
    {
        return $options;
    }
}
