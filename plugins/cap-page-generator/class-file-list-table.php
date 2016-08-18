<?php
/**
 * Capitularia Page Generator File List Table class.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/**
 * A list table for the page generator admin page.
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

        parent::__construct (
            array (
                'singular' => __ ('TEI file',  'capitularia'),
                'plural'   => __ ('TEI files', 'capitularia'),
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
            $this->bulk_actions['publish']  = _x ('Publish',           'bulk action', 'capitularia');
        }
        if ($config->section_can ($section_id, 'private')) {
            $this->bulk_actions['private']  = _x ('Publish privately', 'bulk action', 'capitularia');
        }
        $this->bulk_actions['delete']   = _x ('Unpublish',         'bulk action', 'capitularia');
        $this->bulk_actions['refresh']  = _x ('Refresh',           'bulk action', 'capitularia');
        if ($config->get_opt ($section_id, 'schema_path')) {
            $this->bulk_actions['validate'] = _x ('Validate',          'bulk action', 'capitularia');
        }
        $this->bulk_actions['metadata'] = _x ('Extract metadata',  'bulk action', 'capitularia');

        $this->statuses['publish'] = _x ('Published',           'file status', 'capitularia');
        $this->statuses['private'] = _x ('Published privately', 'file status', 'capitularia');
        $this->statuses['delete']  = _x ('Not published',       'file status', 'capitularia');

        $this->paths = array ();
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
     * @param string   $root  The root directory
     * @param string[] $paths The array of paths
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
     * @param array $pagination_args Arguments to pass to set_pagination_args ().
     *
     * @return void
     */

    public function prepare_items ($pagination_args)
    {
        $this->items = array ();

        /* Read the files from the directories. */

        $this->paths = array ();
        $this->scandir_recursive ($this->directory, $this->paths);

        /* Pagination support */

        $pagination_args['total_items'] = count ($this->paths);
        $this->set_pagination_args ($pagination_args);

        $per_page = $pagination_args['per_page'];
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
        _e ('No TEI files found.', 'capitularia');
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
            'slug'       => _x ('Slug',     'column heading', 'capitularia'),
            'status'     => _x ('Status',   'column heading', 'capitularia'),
            'title'      => _x ('Title',    'Manuscript title column heading',    'capitularia'),
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
                _x ('Select %s', 'Select a filename (screen reader only)', 'capitularia'),
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
        echo esc_html ($manuscript->get_title ());
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
            // if 'delete' make it red
            $class = ($action == 'delete') ? ' class="submitdelete"' : '';
            $actions[$action] = "<a{$class} onclick=\"on_cap_action_file (this, '{$action}')\">{$caption}</a>";
        }
        $status = $manuscript->get_status ();
        // do not show actions that would change nothing
        unset ($actions[$status]);
        // do not show these actions for unpublished files
        if ($status == 'delete') {
            unset ($actions['refresh']);
            unset ($actions['metadata']);
        }
        return $this->row_actions ($actions);
    }


    /**
     * Display the pagination gadget.
     *
     * Stolen from the WP sources.  This version allows you to specify the url
     * to navigate to.  We need that because when this function is called we are
     * inside an AJAX call but the navigation must use the url of the
     * surrounding page.
     *
     * @param string $which The 'top' or 'bottom' paginator
     *
     * @return int
     */

    protected function pagination ($which)
    {
        if (empty ($this->_pagination_args)) {
            return;
        }

        $total_items = $this->_pagination_args['total_items'];
        $total_pages = $this->_pagination_args['total_pages'];
        $infinite_scroll = false;
        if (isset ($this->_pagination_args['infinite_scroll'])) {
            $infinite_scroll = $this->_pagination_args['infinite_scroll'];
        }

        if ('top' === $which && $total_pages > 1) {
            $this->screen->render_screen_reader_content ('heading_pagination');
        }

        $output = '<span class="displaying-num">' . sprintf (
            _n ('%s item', '%s items', $total_items, 'capitularia'),
            number_format_i18n ($total_items)
        ) . '</span>';

        $current = $this->get_pagenum ();

        $current_url = $this->_pagination_args['current_url'];

        $current_url = remove_query_arg (array ('hotkeys_highlight_last', 'hotkeys_highlight_first'), $current_url);

        $page_links = array();

        $total_pages_before = '<span class="paging-input">';
        $total_pages_after  = '</span>';

        $disable_first = $disable_last = $disable_prev = $disable_next = false;

        if ($current == 1) {
            $disable_first = true;
            $disable_prev = true;
        }
        if ($current == 2) {
            $disable_first = true;
        }
        if ($current == $total_pages) {
            $disable_last = true;
            $disable_next = true;
        }
        if ($current == $total_pages - 1) {
            $disable_last = true;
        }

        if ($disable_first) {
            $page_links[] = '<span class="tablenav-pages-navspan" aria-hidden="true">&laquo;</span>';
        } else {
            $page_links[] = sprintf (
                "<a class='first-page' href='%s'><span class='screen-reader-text'>%s</span><span aria-hidden='true'>%s</span></a>",
                esc_url (remove_query_arg ('paged', $current_url)),
                __ ('First page', 'capitularia'),
                '&laquo;'
            );
        }

        if ($disable_prev) {
            $page_links[] = '<span class="tablenav-pages-navspan" aria-hidden="true">&lsaquo;</span>';
        } else {
            $page_links[] = sprintf (
                "<a class='prev-page' href='%s'><span class='screen-reader-text'>%s</span><span aria-hidden='true'>%s</span></a>",
                esc_url (add_query_arg ('paged', max (1, $current-1), $current_url)),
                __ ('Previous page', 'capitularia'),
                '&lsaquo;'
            );
        }

        if ('bottom' === $which) {
            $html_current_page  = $current;
            $total_pages_before = '<span class="screen-reader-text">' .
                                __ ('Current Page', 'capitularia') .
                                '</span><span id="table-paging" class="paging-input">';
        } else {
            $html_current_page = sprintf (
                "%s<input class='current-page' id='current-page-selector' type='text' name='paged' value='%s' size='%d' aria-describedby='table-paging' />",
                '<label for="current-page-selector" class="screen-reader-text">' . __ ('Current Page', 'capitularia') . '</label>',
                $current,
                strlen ($total_pages)
            );
        }
        $html_total_pages = sprintf ("<span class='total-pages'>%s</span>", number_format_i18n ($total_pages));
        $page_links[] = $total_pages_before . sprintf (
            _x ('%1$s of %2$s', 'paging', 'capitularia'),
            $html_current_page,
            $html_total_pages
        ) . $total_pages_after;

        if ($disable_next) {
            $page_links[] = '<span class="tablenav-pages-navspan" aria-hidden="true">&rsaquo;</span>';
        } else {
            $page_links[] = sprintf (
                "<a class='next-page' href='%s'><span class='screen-reader-text'>%s</span><span aria-hidden='true'>%s</span></a>",
                esc_url (add_query_arg ('paged', min ($total_pages, $current+1), $current_url)),
                __ ('Next page', 'capitularia'),
                '&rsaquo;'
            );
        }

        if ($disable_last) {
            $page_links[] = '<span class="tablenav-pages-navspan" aria-hidden="true">&raquo;</span>';
        } else {
            $page_links[] = sprintf (
                "<a class='last-page' href='%s'><span class='screen-reader-text'>%s</span><span aria-hidden='true'>%s</span></a>",
                esc_url (add_query_arg ('paged', $total_pages, $current_url)),
                __ ('Last page', 'capitularia'),
                '&raquo;'
            );
        }

        $pagination_links_class = 'pagination-links';
        if (!empty ($infinite_scroll)) {
            $pagination_links_class = ' hide-if-js';
        }
        $output .= "\n<span class='$pagination_links_class'>" . join ("\n", $page_links) . '</span>';

        if ($total_pages) {
            $page_class = $total_pages < 2 ? ' one-page' : '';
        } else {
            $page_class = ' no-pages';
        }
        $this->_pagination = "<div class='tablenav-pages{$page_class}'>$output</div>";

        echo $this->_pagination;
    }
}
