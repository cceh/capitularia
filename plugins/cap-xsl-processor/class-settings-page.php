<?php
/**
 * Capitularia XSL-Procesor Settings Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\xsl_processor;

/**
 * Implements the settings (options) page.
 *
 * Found in Wordpress admin under _Settings | Capitularia XSL Processor_.
 */

class Settings_Page
{
    const AFS_ROOT  = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';

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
        add_settings_section (
            'cap_xsl_options_section_general',
            'General Settings',
            array ($this, 'on_options_section_general'),
            'cap_xsl_options'
        );

        add_settings_field (
            'cap_xsl_options_xmlroot',
            'Directory for XML files',
            array ($this, 'on_options_field_xmlroot'),
            'cap_xsl_options',
            'cap_xsl_options_section_general'
        );
        add_settings_field (
            'cap_xsl_options_xsltroot',
            'Directory for XSLT files',
            array ($this, 'on_options_field_xsltroot'),
            'cap_xsl_options',
            'cap_xsl_options_section_general'
        );
        add_settings_field (
            'cap_xsl_options_xsltproc',
            'The XSLT processor',
            array ($this, 'on_options_field_xsltproc'),
            'cap_xsl_options',
            'cap_xsl_options_section_general'
        );
        add_settings_field (
            'cap_xsl_options_shortcode',
            'The Shortcode',
            array ($this, 'on_options_field_shortcode'),
            'cap_xsl_options',
            'cap_xsl_options_section_general'
        );

        register_setting ('cap_xsl_options', 'cap_xsl_options',  array ($this, 'on_validate_options'));
    }

    /**
     * Output the Settings page.
     *
     * @return void
     */

    public function on_menu_options_page ()
    {
        global $cap_xsl_processor_stats;

        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n<h2>$title</h2>\n<form method='post' action='options.php'>");
        settings_fields ('cap_xsl_options');
        do_settings_sections ('cap_xsl_options');
        submit_button ();
        echo ('</form>');

        echo ("<h3>Stats</h3>\n<table class='form-table'>");
        echo ($cap_xsl_processor_stats->get_table_rows ());
        echo ("</table></div>\n");
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
     * Output the xmlroot option field with its description.
     *
     * @return void
     */

    public function on_options_field_xmlroot ()
    {
        $setting = get_opt ('xmlroot');
        echo "<input class='file-input' type='text' name='cap_xsl_options[xmlroot]' value='$setting' />";
        echo '<p>Directory in the AFS, eg.: ' . self::AFS_ROOT . 'http/docs/cap/publ/mss</p>';
    }

    /**
     * Output the xsltroot option field with its description.
     *
     * @return void
     */

    public function on_options_field_xsltroot ()
    {
        $setting = get_opt ('xsltroot');
        echo "<input class='file-input' type='text' name='cap_xsl_options[xsltroot]' value='$setting' />";
        echo '<p>Directory in the AFS, eg.: ' . self::AFS_ROOT . 'http/docs/cap/publ/mss</p>';
    }

    /**
     * Output the xsltproc option field with its description.
     *
     * @return void
     */

    public function on_options_field_xsltproc ()
    {
        $setting = get_opt ('xsltproc');
        echo "<input class='file-input' type='text' name='cap_xsl_options[xsltproc]' value='$setting' />";
        echo '<p>The path to the xslt processor, eg.: /usr/bin/xsltproc</p>';
    }

    /**
     * Output the shortcode option field with its description.
     *
     * @return void
     */

    public function on_options_field_shortcode ()
    {
        $setting = get_opt ('shortcode');
        echo "<input class='file-input' type='text' name='cap_xsl_options[shortcode]' value='$setting' />";
        echo '<p>The shortcode, eg.: cap_xsl</p>';
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
        $options['xmlroot']   = $this->sanitize_path ($options['xmlroot']);
        $options['xsltroot']  = $this->sanitize_path ($options['xsltroot']);
        $options['xsltproc']  = $this->sanitize_path ($options['xsltproc']);
        $options['shortcode'] = trim (sanitize_key ($options['shortcode']));
        return $options;
    }
}
