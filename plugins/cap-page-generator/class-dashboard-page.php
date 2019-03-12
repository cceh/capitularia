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
    /** @var array The standard pagination args. */
    private $pagination_args;

    /**
     * Constructor
     *
     * @return Dashboard_Page
     */

    public function __construct ()
    {
        $this->pagination_args = array (
            'per_page' => 50,
        );
    }

    /**
     * Output dashboard page.
     *
     * Outputs bare jQuery-UI tabs. They get filled by AJAX.  Also outputs
     * messages we get thru AJAX.
     *
     * @return void
     */

    public function on_menu_dashboard_page ()
    {
        global $cap_page_generator_config;

        $title = esc_html (get_admin_page_title ());
        echo ("<div class='wrap'>\n");
        echo ("  <h1>$title</h1>\n");

        // If this is a bulk action request, process the bulk action and print
        // any resulting messages.

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

        $sections = array_slice ($cap_page_generator_config->sections, 1);
        $paged = isset ($_REQUEST['paged']) ? $_REQUEST['paged'] : 1;

        echo ("<div id='tabs'>\n");
        echo ("<ul>\n");
        foreach ($sections as $section) {
            $section_id = $section[0];
            $caption    = __ ($cap_page_generator_config->get_opt ($section_id, 'section_caption'));
            $ajax_url   = admin_url ('admin-ajax.php');
            $class = $cap_page_generator_config->section_can ($section_id, 'publish')
                   ? ' cap_can_publish' : ' cap_can_private';
            echo ("  <li>\n");
            echo ("    <a class='navtab $class' data-section='$section_id' ");
            echo ("href='$ajax_url?action=on_cap_load_section&section=$section_id&paged=$paged'>$caption</a>\n");
            echo ("  </li>\n");
        }
        echo ("</ul>\n");

        echo ("</div>\n");
        echo ("</div>\n");
    }

    /**
     * Output one section
     *
     * @param array   $section Section descriptor
     * @param integer $paged   The page to go to
     *
     * @return void
     */

    public function display_section ($section, $paged)
    {
        global $cap_page_generator_config;

        $section_id = $section[0];
        $caption    = __ ($cap_page_generator_config->get_opt ($section_id, 'section_caption'));
        $xml_dir    = $cap_page_generator_config->get_opt_path ('xml_root', $section_id, 'xml_dir');
        echo ("<div id='tabs-$section_id' class='section'>\n");
        echo ("<h2>$caption</h2>\n");
        echo ('<p>' . sprintf (__ ('Reading directory: %s', 'cap-page-generator'), $xml_dir) . "</p>\n");

        $page = DASHBOARD_PAGE_ID;
        $page_url = '/wp-admin/index.php';

        $table = new File_List_Table ($section_id, $xml_dir);
        $table->set_pagination_args ($this->pagination_args);
        $table->prepare_items ();

        echo ("<form method='get' action='{$page_url}' id='cap_page_gen_form_{$section_id}' " .
              "data-section='{$section_id}' data-paged='{$paged}'>");
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
        if ($error_struct[0] >= 1) {
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
     * Handles user actions performed on one or more files using the file
     * checkboxes and the bulk actions dropdown menu.
     *
     * @param string $action     The action to perform
     * @param string $section_id The section id
     * @param array  $filenames  The filenames of the files to perform the action on
     *
     * @return string Error messages formatted as HTML
     *
     * @see on_cap_action_file ()
     */

    private function process_bulk_actions ($action, $section_id, $filenames)
    {
        global $cap_page_generator_config;

        $messages = array ();
        $path = $cap_page_generator_config->get_opt_path ('xml_root', $section_id, 'xml_dir');
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
     * Handles user actions performed on one file using the links inside a table
     * row.
     *
     * @return void
     *
     * @see process_bulk_actions ()
     */

    public function on_cap_action_file ()
    {
        global $cap_page_generator_config;

        $user_action = sanitize_key       ($_POST['user_action']);
        $section_id  = sanitize_key       ($_POST['section']);
        $filename    = sanitize_file_name ($_POST['filename']);

        $path = $cap_page_generator_config->get_opt_path ('xml_root', $section_id, 'xml_dir');
        $manuscript = new Manuscript ($section_id, $path . $filename);
        $result = $manuscript->do_action ($user_action);
        $this->send_json ($section_id, $result);
    }

    /**
     * Ajax endpoint
     *
     * Load a section (represented by a jquery tab) in response to the user
     * clicking on a tab or using the table pager.
     *
     * @return void
     */

    public function on_cap_load_section ()
    {
        global $cap_page_generator_config;

        $section_id = sanitize_key ($_REQUEST['section']);
        $paged = isset ($_REQUEST['paged']) ? intval ($_REQUEST['paged']) : 1;

        foreach ($cap_page_generator_config->sections as $section) {
            if ($section[0] == $section_id) {
                $this->display_section ($section, $paged);
                wp_die ();
            }
        }
    }

    /**
     * Send the result of an Ajax action back to the user.
     *
     * The reason we use JSON instead of just sending HTML is that we want to
     * send both, HTML and success / error messages.  A table update is sent as
     * a JSON string of HTML table rows that simply replace the old table rows.
     * We assume for now that the user dashboard changes only on successful
     * operations.
     *
     * @param string $section_id   The section id
     * @param array  $error_struct The error messages
     *
     * @return void
     */

    private function send_json ($section_id, $error_struct)
    {
        global $cap_page_generator_config;

        $json = array (
            'success' => $error_struct[0] < 2, // 0 == success, 1 == warning, 2 == error
            'message' => $this->format_error_message ($error_struct),
        );

        if ($json['success']) {
            // capture HTML output in string
            ob_start ();
            $xml_dir = $cap_page_generator_config->get_opt_path ('xml_root', $section_id, 'xml_dir');
            $table = new File_List_Table ($section_id, $xml_dir);
            $table->set_pagination_args ($this->pagination_args);
            $table->prepare_items ();
            $table->display_rows_or_placeholder ();
            // return HTML output in JSON
            $json['rows'] = ob_get_clean ();
        }

        wp_send_json ($json);
    }
}
