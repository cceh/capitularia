<?php
/**
 * Capitularia Page Generator File List Table class.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

use cceh\capitularia\lib;

/**
 * The file list table on the dashboard page.
 *
 * Lists all the files in a directory plus status information.
 *
 * @see https://core.trac.wordpress.org/browser/tags/4.4/src/wp-admin/includes/class-wp-list-table.php
 *      \WP_list_Table source code in Trac.
 */

class File_List_Table extends \WP_List_Table
{
    /**
     * HTML classes for table rows.
     *
     * Classes set according to current page status. To colorize our table rows
     * in the canonical way we use the same classes as Wordpress admin notices.
     */

    private $status_to_notice_class = array (
        'publish' => 'notice-success',
        'private' => 'notice-warning',
        'delete'  => 'notice-error',
    );

    /**
     * Enum bulk actions
     *
     * An associative array of bulk actions and relative captions for the action
     * links and the drop-down menus above and below the table.
     */

    private $bulk_actions = array ();

    /**
     * Enum statuses of manuscripts
     *
     * An associative array of statuses and relative captions.  A manuscript can
     * have a public page, a private page, or not have any page at all.
     */

    private $statuses = array ();

    /** The section id */
    private $section_id;
    /** The directory to scan */
    private $directory;
    /** The scanned files */
    public $paths;
    /** The URI path to the xml file. */
    private $xml_path;

    /**
     * Constructor.
     *
     * @param string $section_id The section id
     * @param string $directory  The directory to scan
     * @param array  $args       An associative array of arguments.
     *
     * @see \WP_List_Table::__construct() for more information on default arguments.
     */

    public function __construct ($section_id, $directory, $args = array ())
    {
        global $config;

        // Fix for: "Undefined index: hook_suffix".  See:
        // https://core.trac.wordpress.org/ticket/29933
        $GLOBALS['hook_suffix'] = '';

        parent::__construct (
            array (
                'singular' => __ ('TEI file',  LANG),
                'plural'   => __ ('TEI files', LANG),
                'ajax'     => false, // do not use the ajax built-in in table
                'screen'   => isset ($args['screen']) ? $args['screen'] : null,
            )
        );

        $this->section_id = $section_id;
        $this->directory  = $directory;

        if ($config->section_can ($section_id, 'publish')
            // do not make public children of private pages
            && cap_get_section_page_status ($section_id) == 'publish'
        ) {
            $this->bulk_actions['publish']  = _x ('Publish',           'bulk action', LANG);
        }
        if ($config->section_can ($section_id, 'private')) {
            $this->bulk_actions['private']  = _x ('Publish privately', 'bulk action', LANG);
        }
        $this->bulk_actions['delete']           = _x ('Unpublish',        'bulk action', LANG);
        $this->bulk_actions['refresh']          = _x ('Refresh',          'bulk action', LANG);
        $this->statuses['publish'] = _x ('Published',           'file status', LANG);
        $this->statuses['private'] = _x ('Published privately', 'file status', LANG);
        $this->statuses['delete']  = _x ('Not published',       'file status', LANG);

        $this->paths = array ();

        $this->xml_path = lib\urljoin (
            $config->get_opt ('general', 'xml_root_uri'),
            $config->get_opt ($section_id, 'xml_dir')
        );
    }

    /**
     * Get a list of CSS classes for the list table table tag.
     *
     * Overrides method in base class.
     *
     * @return array List of CSS classes for the table tag.
     */

    protected function get_table_classes ()
    {
        $classes = parent::get_table_classes ();
        $classes[] = 'cap_page_gen_table_files';
        return $classes;
    }

    /**
     * Recursively scan a directory.
     *
     * @param string $root  The root directory
     * @param array  $paths Array of strings: the paths still to scan
     *
     * @return void
     */

    public function scandir_recursive ($root, &$paths)
    {
        foreach (scandir ($root) as $filename) {
            if ($filename[0] == '.') {
                continue;
            }
            $path = $root . $filename;
            if (!is_readable ($path)) {
                continue;
            }
            if (is_dir ($path)) {
                $this->scandir_recursive ($path, $paths);
            } else {
                $paths[] = $path;
            }
        }
    }

    /**
     * Prepare the items to show in the table.
     *
     * Overrides abstract method in base class.
     *
     * @return void
     */

    public function prepare_items ()
    {
        $this->items = array ();

        /* Read the files from the directories. */

        $this->paths = array ();
        $this->scandir_recursive ($this->directory, $this->paths);

        /* Pagination support */

        $this->_pagination_args['total_items'] = count ($this->paths);
        $this->set_pagination_args ($this->_pagination_args); // recalculate total_pages

        $per_page = $this->_pagination_args['per_page'];
        $paths = array_slice ($this->paths, (($this->get_pagenum () - 1) * $per_page), $per_page);

        foreach ($paths as $path) {
            $manuscript = new Manuscript ($this->section_id, $path);
            $title = $manuscript->get_title ();
            if (empty ($title)) {
                // file we could not parse
                continue;
            }
            $this->items[] = $manuscript;
        }

        $columns = $this->get_columns ();
        $hidden = array ();
        $sortable = $this->get_sortable_columns ();
        $this->_column_headers = array ($columns, $hidden, $sortable);
    }

    /**
     * Message to be displayed when there are no items
     *
     * Overrides method in base class.
     *
     * @return string The message
     */

    public function no_items ()
    {
        _e ('No TEI files found.', LANG);
    }

    /**
     * Get the list of bulk actions.
     *
     * Overrides method in base class.
     *
     * @return array (option_name => option_title)
     */

    protected function get_bulk_actions ()
    {
        return $this->bulk_actions;
    }

    /**
     * Get a list of table columns.
     *
     * Overrides abstract method in base class.
     *
     * @return array (internal_name => HTML content)
     */

    public function get_columns ()
    {
        return array (
            'cb'         => '<input type="checkbox" />',
            'slug'       => _x ('Slug',     'column heading', LANG),
            'status'     => _x ('Status',   'column heading', LANG),
            'title'      => _x ('Title',    'Manuscript title column heading',    LANG),
        );
    }

    /**
     * Generates content for a single row of the table
     *
     * @param object $manuscript The current file
     *
     * @return void
     */

    public function single_row ($manuscript)
    {
        $slug       = esc_attr ($manuscript->get_slug ());
        $filename   = esc_attr ($manuscript->get_filename ());

        $class = $this->status_to_notice_class[$manuscript->get_status ()];
        echo ("<tr id='{$slug}' data-filename='{$filename}' " .
              "data-slug='{$slug}' data-section='{$this->section_id}' class='$class'>");
        $this->single_row_columns ($manuscript);
        echo ('</tr>');
    }

    /*
     * Table columns output
     */

    /**
     * Generates contents of the _cb_ column.
     *
     * Called by the base class.
     *
     * @param object $manuscript The current file
     *
     * @return void
     */

    public function column_cb ($manuscript)
    {
        $slug     = esc_attr ($manuscript->get_slug ());
        $filename = esc_attr ($manuscript->get_filename ());
        $select   = esc_html (
            sprintf (
                _x ('Select %s', 'Select a filename (screen reader only)', LANG),
                $filename
            )
        );

        echo ("<label class='screen-reader-text' for='cb-select-$slug'>$select</label>");
        echo ("<input type='checkbox' name='filenames[]' id='cb-select-$slug' value='$filename' />");
    }

    /**
     * Generates contents of the _status_ column.
     *
     * Called by the base class.
     *
     * @param object $manuscript The current file
     *
     * @return void
     */

    public function column_status ($manuscript)
    {
        $status = esc_attr ($manuscript->get_status ());
        $status = $this->statuses[$status];

        echo ("<span class='cap-published-status cap-published-status-{$status}'>$status</span>");
    }

    /**
     * Generates contents of the _slug_ column.
     *
     * Called by the base class.
     *
     * @param object $manuscript The current file
     *
     * @return void
     */

    public function column_slug ($manuscript)
    {
        $slug      = esc_attr ($manuscript->get_slug ());
        $full_slug = esc_attr ($manuscript->get_slug_with_path ());
        $status    = esc_attr ($manuscript->get_status ());

        $td = "<strong>{$slug}</strong>";
        echo ($status == 'delete' ? $td : "<a href='/{$full_slug}'>$td</a>");
    }

    /**
     * Generates contents of the _title_ column.
     *
     * Called by the base class.
     *
     * @param object $manuscript The current file
     *
     * @return void
     */

    public function column_title ($manuscript)
    {
        $xml_file = esc_html ($this->xml_path . '/' . $manuscript->get_filename ());
        echo esc_html ($manuscript->get_title ());
        echo ("<div class='row-actions'>");
        echo ("<a href='$xml_file'>$xml_file</a>\n");
        echo ('</div>');
    }

    /**
     * Generates and displays row action links.
     *
     * These are the links that appear when hovering over the table row.
     * Clicking on the link initiates an Ajax request that performs the action
     * and automagically redraws the table.
     *
     * @param object $manuscript  File being acted upon.
     * @param string $column_name Current column name.
     * @param string $primary     Primary column name.
     *
     * @return string Row action output for links.
     */

    protected function handle_row_actions ($manuscript, $column_name, $primary)
    {
        if ($primary !== $column_name) {
            return '';
        }

        $actions = array ();
        foreach ($this->bulk_actions as $action => $caption) {
            $classes = ["cap-page-generator-action"];
            if ($action == 'delete') {
                // if 'delete' make it red
                $classes[] = submitdelete;
            }
            $class = join (' ', $classes);
            $actions[$action] = "<a class=\"{$class}\" data-action=\"{$action}\">{$caption}</a>";
        }
        $status = $manuscript->get_status ();
        // do not show actions that would change nothing
        unset ($actions[$status]);
        // do not show these actions for unpublished files
        if ($status == 'delete') {
            unset ($actions['refresh']);
        }
        return $this->row_actions ($actions);
    }
}
