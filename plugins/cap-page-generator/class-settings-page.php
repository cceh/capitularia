<?php
/**
 * Capitularia Page Generator Settings Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/**
 * Implements the settings (options) page.
 *
 * Found in Wordpress admin under _Settings | Capitularia Page Generator_.
 */

class Settings_Page
{
    /** @var Config The configuration. */
    private $config;

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

    public function __construct ($config)
    {
        $this->config = $config;

        /* Register the Settings page's fields with Wordpress. */
        foreach ($this->config->sections as $section) {
            $section_id = $section[0];

            foreach ($section[1] as $field) {
                $field_id          = $field[0];
                $field_caption     = $field[1];
                $field_description = $field[2];

                add_settings_field (
                    $section_id . '.' . $field_id,
                    $field_caption,
                    array ($this, 'on_options_field'),
                    OPTIONS_PAGE_ID,
                    OPTIONS_PAGE_ID . '_' . $section_id,
                    // array becomes argument of on_options_field ($args)
                    array ($section_id, $field_id, $field_description)
                );
            }
        }

        /* Register only _one_ parameter. @see on_options_field () */
        register_setting (OPTIONS_PAGE_ID, OPTIONS_PAGE_ID, array ($this, 'on_validate'));
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
        echo ("  <form method='post' action='options.php'>\n");
        echo ("    <div id='tabs'>\n");

        // Output the AJAX security fields
        settings_fields (OPTIONS_PAGE_ID);

        // Output the ui-widget-header
        echo ("      <ul>\n");
        foreach ($this->config->sections as $section) {
            $section_id = $section[0];
            $caption    = $this->config->get_opt ($section_id, 'section_caption', $section_id);
            echo ("<li><a href='#tabs-$section_id'>$caption</a></li>\n");
        }
        echo ("      </ul>\n");

        // Output the ui-widget-content
        foreach ($this->config->sections as $section) {
            $section_id = $section[0];
            $caption    = $this->config->get_opt ($section_id, 'section_caption', $section_id);
            echo ("      <div id='tabs-$section_id'>\n");
            echo ("        <h2>$caption</h2>\n");
            echo ('        <table class="form-table">');
            // Output previously registered fields
            do_settings_fields (OPTIONS_PAGE_ID, OPTIONS_PAGE_ID . '_' . $section_id);
            echo ('        </table>');
            echo ("      </div>\n");
        }
        submit_button ();
        echo ("    </div>\n");
        echo ("  </form>\n");
        echo ("</div>\n");
    }

    /**
     * Output an option field.
     *
     * Output (echo) an option field with its description.
     *
     * We want all user entries to be returned into PHP as _one_ string[] called
     * _OPTIONS\_PAGE\_ID_.  This array will be passed by Wordpress to the
     * validation function and stored in the database all in _one_ row.
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
        $section_id  = $args[0];
        $field_id    = $args[1];
        $description = $args[2];
        $page_id     = OPTIONS_PAGE_ID;
        $value       = $this->config->get_opt ($section_id, $field_id);
        echo "<input class='file-input' type='text' name='{$page_id}[{$section_id}.{$field_id}]' value='{$value}' />";
        echo ("<p>{$description}</p>\n");
    }

    /**
     * Validate options entered by user
     *
     * We get all user entries back in one string[] so we can store them in one
     * database row.  This makes validation somewhat more difficult.  @see
     * on\_options\_field ()
     *
     * @param string[] $input Options as entered by admin user
     *
     * @return string[] Validated options
     */

    public function on_validate (array $input)
    {
        $output = array ();
        foreach ($input as $input_field_id => $value) {
            // Find the field in the $sections structure.
            foreach ($this->config->sections as $section) {
                $section_id = $section[0];
                foreach ($section[1] as $field) {
                    $field_id = $field[0];
                    $callable = $field[3];
                    if ($input_field_id == $section_id . '.' . $field_id) {
                        // Field found. Validate it and pass it on.
                        $output[$input_field_id] = call_user_func ($callable, $value);
                    }
                }
            }
        }
        $output['general.section_caption'] = __ ('General', 'capitularia');
        // Merge with old options
        return array_merge (get_option (OPTIONS_PAGE_ID, array ()), $output);
    }
}
