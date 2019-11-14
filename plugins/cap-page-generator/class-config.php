<?php
/**
 * Capitularia Page Generator Configuration Class
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/**
 * Contains configuration parameters.
 */

class Config
{
    /**
     * The configured sections and fields
     *
     * Array of arrays of arrays: sections / fields / properties
     *
     *     foreach ($this->sections as $section) {
     *          $section_id      = $section[0];
     *          $fields          = $section[1];
     *          foreach ($fields as $field) {
     *              $field_id            = $field[0];
     *              $field_caption       = $field[1];
     *              $field_description   = $field[2];
     *              $validation_callback = $field[3];
     *          }
     *     }
     */
    public $sections = null;

    /** @var string[]|null Array of options retrieved from database and cached. */
    private $options = null;

    /** @var string[]|null Array of options retrieved from database and cached. */
    private $cap_fi_options = null;

    /**
     * Constructor
     *
     * @return Config
     */

    public function __construct ()
    {
        $this->sections = null;
    }

    /**
     * Set up the options
     *
     * If we setup the options in the constructor it will be too early for
     * translation to kick in.
     *
     * @return
     */

    public function init ()
    {
        $section_general = array (
            array (
                'section_id_list',
                __ ('List of section ids', LANG),
                sprintf (
                    __ ('List of section ids (space-separated). Eg.: %s', LANG),
                    'mss mss_internal capit_ldf capit_ldf_internal'
                ),
                ns ('cap_sanitize_key_list'),
            ),
            array (
                'xml_root',
                __ ('XML root path', LANG),
                sprintf (
                    __ ('Root directory for XML files in the AFS, eg.: %s', LANG),
                    AFS_ROOT . 'http/docs/cap'
                ),
                ns ('cap_sanitize_path'),
            ),
            array (
                'schema_root',
                __ ('Schema root path', LANG),
                sprintf (
                    __ ('Root directory for schema files in the AFS, eg.: %s', LANG),
                    AFS_ROOT . 'http/docs/cap'
                ),
                ns ('cap_sanitize_path'),
            ),
            array (
                'xmllint_path',
                __ ('xmllint path', LANG),
                sprintf (
                    __ ('The full path to the xmllint utility as seen from the server, eg.: %s', LANG),
                    AFS_ROOT . 'local/bin/xmllint'
                ),
                ns ('cap_sanitize_path'),
            ),
        );
        $section_transform = array (
            array (
                'section_caption',
                __ ('Section name', LANG),
                __ ('The name of this section', LANG),
                ns ('cap_sanitize_caption'),
            ),
            array (
                'shortcode',
                __ ('Shortcode', LANG),
                __ ('The text to insert on all new pages. Use {slug} to insert the page slug.', LANG),
                ns ('cap_sanitize_nothing'),
            ),
            array (
                'xml_dir',
                __ ('XML files directory', LANG),
                sprintf (
                    __ ('The path to the XML files (relative to the XML Root path), eg.: %s', LANG),
                    'publ/mss'
                ),
                ns ('cap_sanitize_path'),
            ),
            array (
                'schema_path',
                __ ('XSL schema', LANG),
                __ ('The path to the xsl schema file (relative to the Schema Root path).', LANG),
                ns ('cap_sanitize_path'),
            ),
            array (
                'slug_path',
                __ ('Slug path', LANG),
                sprintf (
                    __ ('The URL path to the page, eg.: %s', LANG),
                    'capit/ldf'
                ),
                ns ('cap_sanitize_path'),
            ),
            array (
                'slug_prefix',
                __ ('Slug prefix', LANG),
                sprintf (
                    __ ('The slug prefix for the pages, eg.: %s', LANG),
                    'capit-ldf-'
                ),
                ns ('cap_sanitize_key'),
            ),
            array (
                'page_status_list',
                __ ('Page statuses list', LANG),
                sprintf (
                    __ ('The allowed page statuses (space-separated list). Eg.: %s', LANG),
                    'publish private'
                ),
                ns ('cap_sanitize_caption'),
            ),
            array (
                'sidebars',
                __ ('Sidebars', LANG),
                sprintf (
                    __ ('The sidebars (space-separated list). Eg.: %s', LANG),
                    'transcription'
                ),
                ns ('cap_sanitize_caption'),
            ),
        );

        $this->sections = array ();
        $this->sections[] = array ('general', $section_general);

        $sections = explode (' ', $this->get_opt ('general', 'section_id_list'));
        foreach ($sections as $section_id) {
            $this->sections[] = array ($section_id, $section_transform);
        }
    }

    /**
     * Get an option
     *
     * @param string $section_id The section @see $this->sections
     * @param string $field_id   The field (or option) name
     * @param string $default    The default value
     *
     * @return string The option
     */

    public function get_opt ($section_id, $field_id, $default = '')
    {
        if ($this->options === null) {
            $this->options = get_option (OPTIONS, array ());
        }
        return $this->options[$section_id . '.' . $field_id] ?? $default;
    }

    /**
     * Get an option of the File Include Plugin
     *
     * @param string $section_id The section @see $this->sections
     * @param string $field_id   The field (or option) name
     * @param string $default    The default value
     *
     * @return string The option
     */

    public function get_fi_opt ($option_id, $default = '')
    {
        if ($this->cap_fi_options === null) {
            $this->cap_fi_options = get_option (CAP_FI_OPTIONS, array ());
        }
        return $this->cap_fi_options[$option_id] ?? $default;
    }

    /**
     * Get a path
     *
     * @param string $root_id    The root path option name
     * @param string $section_id The section @see $this->sections
     * @param string $path_id    The path option name
     *
     * @return string The path ending in '/'
     */

    public function get_opt_path ($root_id, $section_id, $path_id)
    {
        $path = $this->get_opt ('general', $root_id) . '/';
        return $path . $this->get_opt ($section_id, $path_id) . '/';
    }

    /**
     * Check if a certain page status is allowed in this section.
     *
     * @param string $section_id The section id
     * @param string $status     The status to check
     *
     * @return bool True if section can $status
     */

    public function section_can ($section_id, $status)
    {
        $allowed_statuses = explode (
            ' ',
            $this->get_opt ($section_id, 'page_status_list')
        );
        return in_array ($status, $allowed_statuses);
    }
}
