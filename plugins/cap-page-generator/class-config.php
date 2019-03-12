<?php
/**
 * Capitularia Page Generator Configuration Class
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/** @var string Wordpress ID of the settings (option) page */
const OPTIONS_PAGE_ID      = 'cap_page_gen_options';

/** @var string Wordpress ID of the dashboard page */
const DASHBOARD_PAGE_ID    = 'cap_page_gen_dashboard';

/** @var string AJAX security */
const NONCE_SPECIAL_STRING = 'cap_page_gen_nonce';

/** @var string AJAX security */
const NONCE_PARAM_NAME     = '_ajax_nonce';

/** @var string Where our Wordpress is in the filesystem */
const AFS_ROOT             = '/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/';

/** @var string Parameters for the xmllint utility */
const XMLLINT_PARAMS       = '--noout --relaxng';

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

    /**
     * Constructor
     *
     * @return Config
     */

    public function __construct ()
    {
        $namespace = __NAMESPACE__;

        // FIXME: too early for translation

        $section_general = array (
            array (
                'section_id_list',
                __ ('List of section ids', 'cap-page-generator'),
                sprintf (
                    __ ('List of section ids (space-separated). Eg.: %s', 'cap-page-generator'),
                    'mss mss_internal capit_ldf capit_ldf_internal'
                ),
                "$namespace\cap_sanitize_key_list",
            ),
            array (
                'xml_root',
                __ ('XML root', 'cap-page-generator'),
                sprintf (
                    __ ('Root directory for XML files in the AFS, eg.: %s', 'cap-page-generator'),
                    AFS_ROOT . 'http/docs/cap'
                ),
                "$namespace\cap_sanitize_path",
            ),
            array (
                'xsl_root',
                __ ('XSL root', 'cap-page-generator'),
                sprintf (
                    __ ('Root directory for XSL files in the AFS, eg.: %s', 'cap-page-generator'),
                    AFS_ROOT . 'http/docs/cap'
                ),
                "$namespace\cap_sanitize_path",
            ),
            array (
                'schema_root',
                __ ('Schema root', 'cap-page-generator'),
                sprintf (
                    __ ('Root directory for schema files in the AFS, eg.: %s', 'cap-page-generator'),
                    AFS_ROOT . 'http/docs/cap'
                ),
                "$namespace\cap_sanitize_path",
            ),
            array (
                'shortcode',
                __ ('Shortcode',                   'cap-page-generator'),
                __ ('The shortcode, eg.: cap_xsl', 'cap-page-generator'),
                "$namespace\cap_sanitize_key",
            ),
            array (
                'xmllint_path',
                __ ('xmllint path', 'cap-page-generator'),
                sprintf (
                    __ ('The full path to the xmllint utility as seen from the server, eg.: %s', 'cap-page-generator'),
                    AFS_ROOT . 'local/bin/xmllint'
                ),
                "$namespace\cap_sanitize_path",
            ),
        );
        $section_transform = array (
            array (
                'section_caption',
                __ ('Section name', 'cap-page-generator'),
                __ ('Name of this section', 'cap-page-generator'),
                "$namespace\cap_sanitize_caption",
            ),
            array (
                'xml_dir',
                __ ('XML files directory', 'cap-page-generator'),
                sprintf (
                    __ ('Directory (relative to XML root), eg.: %s', 'cap-page-generator'),
                    'publ/mss'
                ),
                "$namespace\cap_sanitize_path",
            ),
            array (
                'xsl_path_list',
                __ ('XSL files list', 'cap-page-generator'),
                __ ('A list of xsl files to run (relative to XSL root) (space-separated list).', 'cap-page-generator'),
                "$namespace\cap_sanitize_path_list",
            ),
            array (
                'schema_path',
                __ ('XSL schema', 'cap-page-generator'),
                __ ('The path to the xsl schema file (relative to schema root).', 'cap-page-generator'),
                "$namespace\cap_sanitize_path",
            ),
            array (
                'slug_path',
                __ ('Slug path', 'cap-page-generator'),
                sprintf (
                    __ ('The URL path to the page, eg.: %s', 'cap-page-generator'),
                    'capit/ldf'
                ),
                "$namespace\cap_sanitize_path",
            ),
            array (
                'slug_prefix',
                __ ('Slug prefix', 'cap-page-generator'),
                sprintf (
                    __ ('The slug prefix for the pages, eg.: %s', 'cap-page-generator'),
                    'capit-ldf-'
                ),
                "$namespace\cap_sanitize_key",
            ),
            array (
                'page_status_list',
                __ ('Page statuses list', 'cap-page-generator'),
                sprintf (
                    __ ('The allowed page statuses (space-separated list). Eg.: %s', 'cap-page-generator'),
                    'publish private'
                ),
                "$namespace\cap_sanitize_caption",
            ),
            array (
                'sidebars',
                __ ('Sidebars', 'cap-page-generator'),
                sprintf (
                    __ ('The sidebars (space-separated list). Eg.: %s', 'cap-page-generator'),
                    'transcription'
                ),
                "$namespace\cap_sanitize_caption",
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
            $this->options = get_option (OPTIONS_PAGE_ID, array ());
        }
        $name = $section_id . '.' . $field_id;
        return $this->options[$name] ? $this->options[$name] : $default;
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
            $this->get_opt ($section_id, 'page_status_list', 'publish private')
        );
        return in_array ($status, $allowed_statuses);
    }
}
