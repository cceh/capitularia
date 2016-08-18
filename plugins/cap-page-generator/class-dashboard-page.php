<?php
/**
 * Capitularia Page Generator Dashboard Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\page_generator;

/**
 * Implements the dashboard page.
 *
 * The dashboard page controls the plugin.
 *
 * You open the dashboard page by clicking on _Dashboard | Capitularia Page
 * Generator_ in the Wordpress admin page.
 */

class Dashboard_Page
{
    /** @var Config The configuration. */
    private $config;

    /**
     * Constructor
     *
     * @param Config $config The plugin configuration
     *
     * @return Dashboard_Page
     */

    public function __construct ($config)
    {
        $this->config = $config;
    }

    /**
     * Output dashboard page.
     *
     * @return void
     */

    public function on_menu_dashboard_page ()
    {
        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n");
        echo ("  <h1>$title</h1>\n");

        // output any messages

        echo ("  <div class='cap_page_dash_message'>\n");
        if (isset ($_REQUEST['action']) && isset ($_REQUEST['section']) && isset ($_REQUEST['filenames'])) {
            $section_id = $_REQUEST['section'];
            $action     = $_REQUEST['action'];
            if ($action == '-1' and isset ($_REQUEST['action2'])) {
                $action = $_REQUEST['action2'];
            }
            echo ($this->process_bulk_actions ($action, $section_id, $_REQUEST['filenames']));
        }
        echo ("  </div>\n");

        // output sections
        $sections = array_slice ($this->config->sections, 1);
        $paged = isset ($_REQUEST['paged']) ? $_REQUEST['paged'] : 0;

        echo ("<div id='tabs'>\n");
        echo ("<ul>\n");
        foreach ($sections as $section) {
            $section_id = $section[0];
            $caption    = __ ($this->config->get_opt ($section_id, 'section_caption'));
            $ajax_url   = admin_url ('admin-ajax.php');
            $class = $this->config->section_can ($section_id, 'publish') ? ' cap_can_publish' : ' cap_can_private';
            echo ("  <li>\n");
            echo ("    <a class='navtab $class' data-section='$section_id' ");
            echo ("href='$ajax_url?action=on_cap_load_files&section=$section_id&paged=$paged'>$caption</a>\n");
            echo ("  </li>\n");
        }
        echo ("</ul>\n");

        echo ("</div>\n");
        echo ("</div>\n");
    }

    /**
     * Output one section
     *
     * @param array $section Section descriptor
     *
     * @return void
     */

    public function display_section ($section)
    {
        $section_id = $section[0];
        $caption    = __ ($this->config->get_opt ($section_id, 'section_caption'));
        $xml_dir    = $this->config->get_opt_path ('xml_root', $section_id, 'xml_dir');
        echo ("<div id='tabs-$section_id'>\n");
        echo ("<h2>$caption</h2>\n");
        echo ('<p>' . sprintf (__ ('Reading directory: %s', 'capitularia'), $xml_dir) . "</p>\n");

        $page = DASHBOARD_PAGE_ID;
        $paged = isset ($_REQUEST['paged']) ? $_REQUEST['paged'] : 1;
        $page_url = '/wp-admin/index.php';
        $pagination_args = array (
            'per_page'    => 50,
            'current_url' => "{$page_url}?section={$section_id}&page={$page}",
        );

        $table = new File_List_Table ($section_id, $xml_dir);
        $table->prepare_items ($pagination_args);
        // $this->print_orphaned_metadata ($section, $table);

        echo ("<form action='{$page_url}' id='cap_page_gen_form_{$section_id}' method='get'>");
        // posts back to wp-admin/index.php, ensure that we get back to our
        // current page
        echo ("<input type='hidden' name='page' value='{$page}' />");
        echo ("<input type='hidden' name='paged' value='{$paged}' />");
        echo ("<input type='hidden' name='section' value='{$section_id}' />");

        $table->display ();

        echo ("</form>\n");
        echo ("</div>\n");
    }

    /**
     * Find orphaned metadata
     *
     * @param array           $section Section descriptor
     * @param File_List_Table $table   Table with loaded paths
     *
     * @return void
     */

    public function print_orphaned_metadata ($section, $table)
    {
        global $wpdb;
        $section_id = $section[0];

        /* Get all the metadata we know in a dict. */

        $sql = $wpdb->prepare (
            "SELECT ID, post_name, meta_value FROM {$wpdb->posts}, {$wpdb->postmeta} " .
            "WHERE ID = post_id AND meta_key = 'tei-filename' AND post_parent = %d",
            cap_get_parent_id ($section_id)
        );
        $known_slugs = array ();
        foreach ($wpdb->get_results ($sql) as $row) {
            // echo ("<!-- In Metadata: {$row->meta_value} -->");
            $known_slugs[$row->meta_value] = $row->post_name;
        }

        /* Remove still current metadata from dict. */

        foreach ($table->paths as $path) {
            // echo ("<!-- Found: {$path} -->");
            unset ($known_slugs[$path]);
        }

        /* Output the orphaned metadata. */

        if ($known_slugs) {
            echo ('<ul>');
            foreach ($known_slugs as $path => $slug) {
                echo ("<li>Orphaned metadata: '{$slug}': '{$path}'</li>");
            }
            echo ('</ul>');
        }
    }

    /**
     * Format error message as HTML snippet.
     *
     * These notices get inserted at the top of the dashboard page.  The user
     * can click on the cross icon to dismiss the notice.
     *
     * @param array $error_struct The error struct
     *
     * @return $string HTML-formatted message
     */

    private function format_error_message ($error_struct)
    {
        $message = '<p><strong>' . $error_struct[1] . "</strong></p>\n";
        if (count ($error_struct) > 2 && is_array ($error_struct[2])) {
            $message .= "<ul>\n";
            // Return the array of xml validation errors
            foreach ($error_struct[2] as $e) {
                $message .= '<li>' . esc_html ($e) . "</li>\n";
            }
            $message .= "</ul>\n";
        }
        $class = 'notice-success';
        if ($error_struct[0] == 1) {
            $class = 'notice-warning';
        }
        if ($error_struct[0] >= 2) {
            $class = 'notice-error';
        }
        $message = "<div class='notice $class is-dismissible'>$message</div>\n";

        return $message;
    }

    /**
     * Handle bulk actions
     *
     * @param string $action     The action to perform
     * @param string $section_id The section id
     * @param array  $filenames  The filenames of the files to perform the action on
     *
     * @return string Error messages formatted as HTML
     */

    private function process_bulk_actions ($action, $section_id, $filenames)
    {
        $messages = array ();
        $path = $this->config->get_opt_path ('xml_root', $section_id, 'xml_dir');
        foreach ($filenames as $filename) {
            $manuscript = new Manuscript ($section_id, $path . $filename);
            $result = $manuscript->do_action ($action);
            $messages[] = $this->format_error_message ($result);
        }
        return implode ("\n", $messages);
    }

    /*
     * Incipit AJAX stuff
     */

    /**
     * Ajax endpoint
     *
     * Handles user actions submitted with Ajax.
     *
     * @return void
     *
     * @see process_bulk_actions ()
     */

    public function on_cap_action_file ()
    {
        $user_action = sanitize_key       ($_POST['user_action']);
        $section_id  = sanitize_key       ($_POST['section']);
        $filename    = sanitize_file_name ($_POST['filename']);

        $path = $this->config->get_opt_path ('xml_root', $section_id, 'xml_dir');
        $manuscript = new Manuscript ($section_id, $path . $filename);
        $result = $manuscript->do_action ($user_action);
        $this->send_json ($section_id, $result);
    }

    /**
     * Ajax endpoint
     *
     * Handles AJAX-loading of jquery-ui tabs.
     *
     * @return void
     */

    public function on_cap_load_files ()
    {
        $section_id  = sanitize_key ($_GET['section']);
        foreach ($this->config->sections as $section) {
            if ($section[0] == $section_id) {
                $this->display_section ($section);
                wp_die ();
            }
        }
    }

    /**
     * Send the result of an Ajax action back to the user.
     *
     * This may be an error message or an update to the dashboard table.  An
     * update is sent as a JSON string of HTML table rows that simply replace
     * the old table rows.  We assume for now that the user dashboard changes
     * only on successful operations.
     *
     * @param string $section_id   The section id
     * @param array  $error_struct The error messages
     *
     * @return void
     */

    private function send_json ($section_id, $error_struct)
    {
        $json = array (
            'success' => $error_struct[0] < 2, // 0 == success, 1 == warning, 2 == error
            'message' => $this->format_error_message ($error_struct),
        );

        if ($json['success']) {
            // capture HTML output in string
            ob_start ();
            $xml_dir = $this->config->get_opt_path ('xml_root', $section_id, 'xml_dir');
            $table = new File_List_Table ($section_id, $xml_dir);
            $table->prepare_items ();
            $table->display_rows_or_placeholder ();
            // return HTML output in JSON
            $json['rows'] = ob_get_clean ();
        }

        wp_send_json ($json);
    }
}
