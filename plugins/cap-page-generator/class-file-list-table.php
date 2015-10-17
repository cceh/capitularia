<?php
/**
 * Capitularia Page Generator File List Table class.
 *
 * @package Capitularia
 */

if (!class_exists ('WP_List_Table')) {
   require_once (ABSPATH . 'wp-admin/includes/class-wp-list-table.php');
}

class Cap_Page_Generator_File_List_Table extends WP_List_Table {

    /**
     * Constructor.
     *
     * @see WP_List_Table::__construct() for more information on default arguments.
     *
     * @param array $args An associative array of arguments.
     */

    public function __construct ($args = array ()) {
        parent::__construct (array (
            'singular' => 'TEI file',
            'plural'   => 'TEI files',
            'ajax'     => true,
            'screen'   => isset ($args['screen']) ? $args['screen'] : null,
        ));
    }

    protected function get_table_classes () {
        $classes = parent::get_table_classes ();
        $classes[] = 'cap_page_gen_table_files';
        return $classes;
    }

    public function ajax_user_can () {
        return current_user_can ('edit_posts');
    }

    public function prepare_items ($items) {
        global $per_page;

        $this->items = $items;
        $columns = $this->get_columns ();
        $hidden = array ();
        $sortable = $this->get_sortable_columns ();
        $this->_column_headers = array ($columns, $hidden, $sortable);

        $this->set_pagination_args (array ('total_items' => count ($items),
                                           'per_page' => $per_page));
    }

    public function no_items() {
        _e ('No TEI files found.');
    }

    protected function get_bulk_actions () {
        $actions = array ();
        $actions['publish'] = _x ('Publish',           'publish TEI file');
        $actions['private'] = _x ('Publish privately', 'publish TEI file');
        $actions['delete']  = _x ('Delete',            'publish TEI file');

        return $actions;
    }

    public function get_columns () {
        return array (
            'cb'         => '<input type="checkbox" />',
            'slug'       => _x ('Slug',   'publish TEI file'),
            'status'     => _x ('Status', 'publish TEI file'),
            'filename'   => __ ('Filename'),
        );
    }

    function process_bulk_action () {
        if ($this->current_action () == 'delete') {
            wp_die( 'Items deleted (or they would be if we had items to delete)!' );
        }
    }

    public function single_row ($file) {
        echo ("<tr id='{$file->slug}' data-path='{$file->filename}' data-slug='{$file->slug}' class='cap-published-status-{$file->status}'>");
        $this->single_row_columns ($file);
        echo ('</tr>');
    }

    /**
     * Table columns output
     *
     */

    public function column_cb ($file) {
        $u_select = sprintf (__ ('Select %s'), $file->filename);
        $u_slug = $file->slug;
        $u_filename = $file->filename;

        echo ("<label class='screen-reader-text' for='cb-select-$u_slug'>$u_select</label>");
        echo ("<input type='checkbox' name='filenames[]' id='cb-select-$u_slug' value='$u_filename' />");
    }

    public function column_status ($file) {
        $a = array ();
        $a['publish'] = _x ('Published',           'publish TEI file');
        $a['private'] = _x ('Published privately', 'publish TEI file');
        $a['delete']  = _x ('Not published',       'publish TEI file');
        $status = $a[$file->status];

        echo ("<span class='cap-published-status cap-published-status-{$file->status}'>$status</span>");
    }

    public function column_slug ($file) {
        $td = "<strong>{$file->slug}</strong>";
        if ($file->status != 'delete') {
            $td = "<a href='/mss/{$file->slug}'>$td</a>";
        }
        echo ($td);
    }

    public function column_filename ($file) {
        echo $file->filename;
    }

    public function column_default ($file, $column_name) {
        echo $column_name;
    }

    /**
     * Generates and displays row action links.
     *
     * @since 4.3.0
     * @access protected
     *
     * @param object $file        File being acted upon.
     * @param string $column_name Current column name.
     * @param string $primary     Primary column name.
     * @return string Row action output for links.
     */

    protected function handle_row_actions ($file, $column_name, $primary) {
        if ($primary !== $column_name) {
            return '';
        }

        $u_publish = _x ('Publish',           'publish TEI file');
        $u_private = _x ('Publish privately', 'publish TEI file');
        $u_delete  = _x ('Delete',            'publish TEI file');

        $actions = array ();
        $actions['publish'] = "<a onclick=\"on_cap_action_file (this, 'publish')\">$u_publish</a>";
        $actions['private'] = "<a onclick=\"on_cap_action_file (this, 'private')\">$u_private</a>";
        $actions['delete']  = "<a onclick=\"on_cap_action_file (this, 'delete')\" class='submitdelete'>$u_delete</a>";
        unset ($actions[$file->status]);
        return $this->row_actions ($actions);
    }
}
