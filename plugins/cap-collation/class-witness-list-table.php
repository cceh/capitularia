<?php
/**
 * Capitularia Collation Witness List Table class.
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

/**
 * A list table for the collation admin page.
 *
 * Lists all witnesses that contain a certain section of text.
 *
 * @see https://core.trac.wordpress.org/browser/tags/4.4/src/wp-admin/includes/class-wp-list-table.php
 *      \WP_list_Table source code in Trac.
 */

class Witness_List_Table extends \WP_List_Table
{
    private $corresp;

    /**
     * Constructor.
     *
     * @param string $corresp The section id
     * @param array  $args    An associative array of arguments.
     *
     * @see \WP_List_Table::__construct() for more information on default arguments.
     */

    public function __construct ($corresp, $args = array ())
    {
        parent::__construct (
            array (
                'singular' => __ ('Manuscript',  'cap-collation'),
                'plural'   => __ ('Manuscripts', 'cap-collation'),
                'ajax'     => false, // do not use the ajax built-in in table
                'screen'   => isset ($args['screen']) ? $args['screen'] : null,
            )
        );
        $this->corresp = $corresp;
    }

    /**
     * Get a list of CSS classes for the <table> tag.
     *
     * Overrides method in base class.
     *
     * @return array List of CSS classes for the table tag.
     */

    protected function get_table_classes ()
    {
        $classes = parent::get_table_classes ();
        $classes[] = 'cap-collation-table-witnesses';
        return $classes;
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
        $this->items = get_witnesses ($this->corresp);

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
        _e ('No manuscripts found.', 'cap-collation');
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
        return array ();
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
            'sort' => '',
            'cb'   => '<input type="checkbox" />',
            'id'   => _x ('Manuscript Id',  'column heading', 'cap-collation'),
        );
    }

    /**
     * Generates content for a single row of the table
     *
     * @param object $witness The current file
     *
     * @return void
     */

    public function single_row ($witness)
    {
        $id = esc_attr ($witness->get_id ());

        echo ("<tr data-siglum='{$id}'>");
        $this->single_row_columns ($witness);
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
     * @param object $witness The current file
     *
     * @return void
     */

    public function column_cb ($witness)
    {
        $id = esc_attr ($witness->get_id ());
        $select   = esc_html (
            sprintf (
                _x ('Select %s', 'Select a witness by id (screen reader only)', 'cap-collation'),
                $id
            )
        );
        echo ("<label class='screen-reader-text' for='cb-select-$id'>$select</label>");
        echo ("<input type='checkbox' name='witnesses[]' id='cb-select-$id' value='$id' />");
    }

    /**
     * Generates contents of the _sort_ column.
     *
     * Called by the base class.
     *
     * @param object $dummy_witness The current file (not used)
     *
     * @return void
     */

    public function column_sort ($dummy_witness)
    {
        echo ('<span class="dashicons dashicons-sort"></span>');
    }

    /**
     * Generates contents of the _slug_ column.
     *
     * Called by the base class.
     *
     * @param object $witness The current file
     *
     * @return void
     */

    public function column_id ($witness)
    {
        $id = esc_attr ($witness->get_id ());
        echo ("<a href='/mss/{$id}'><strong>{$id}</strong></a>");
    }

    /**
     * Generates and displays row action links.
     *
     * These are the links that appear when hovering over the table row.
     * Clicking on the link initiates an Ajax request that performs the action
     * and automagically redraws the table.
     *
     * @param object $dummy_witness The file being acted upon (not used).
     * @param string $column_name   Current column name.
     * @param string $primary       Primary column name.
     *
     * @return string Row action output for links.
     */

    protected function handle_row_actions ($dummy_witness, $column_name, $primary)
    {
        if ($primary !== $column_name) {
            return '';
        }

        return '';
    }
}
