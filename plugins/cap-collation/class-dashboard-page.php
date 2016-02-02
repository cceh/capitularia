<?php
/**
 * Capitularia Collation Dashboard Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

const COLLATION_ROOT  = AFS_ROOT . '/local/capitularia-collation';

const ALGORITHMS = array (
    'dekker'           => 'Dekker',
    'gst'              => 'Greedy String Tiling',
    'medite'           => 'MEDITE',
    'needleman-wunsch' => 'Needleman-Wunsch',
);

/**
 * Implements the dashboard page.
 *
 * The dashboard page controls the plugin.
 *
 * You open the dashboard page by clicking on _Dashboard | Capitularia
 * Collation_ in the Wordpress admin page.
 */

class Dashboard_Page
{

    private function sort_results ($results)
    {
        // Add a key to all objects in the array that allows for sensible
        // sorting of numeric substrings.
        foreach ($results as $res) {
            $res->key = preg_replace_callback (
                '|\d+|',
                function ($match) {
                    return 'zz' . strval (strlen ($match[0])) . $match[0];
                },
                $res->meta_value
            );
        }

        // Sort the array according to key.
        usort (
            $results,
            function ($res1, $res2) {
                return strcoll ($res1->key, $res2->key);
            }
        );

        return array_map (
            function ($s) {
                return $s->meta_value;
            },
            $results
        );
    }

    private function get_capitulars ()
    {
        global $wpdb;

        $sql = 'SELECT DISTINCT meta_value FROM wp_postmeta ' .
               'WHERE meta_key = \'milestone-capitulare\' ORDER BY meta_value;';

        return $this->sort_results ($wpdb->get_results ($sql));
    }

    private function get_sections ($bk)
    {
        global $wpdb;

        $bk = "{$bk}_%";

        $sql = $wpdb->prepare (
            'SELECT DISTINCT meta_value FROM wp_postmeta ' .
            'WHERE meta_key = \'ab-corresp\' AND meta_value LIKE %s ORDER BY meta_value;',
            $bk
        );

        return $this->sort_results ($wpdb->get_results ($sql));
    }

    private function get_collation_items ($corresp)
    {
        global $wpdb;
        $items = array ();

        $sql = $wpdb->prepare (
            "SELECT DISTINCT post_id FROM wp_postmeta WHERE meta_key = 'ab-corresp' AND meta_value = %s",
            $corresp
        );
        $ids = $wpdb->get_col ($sql);
        foreach ($ids as $id) {
            $sql = $wpdb->prepare (
                "SELECT meta_value FROM wp_postmeta WHERE post_id = %d AND meta_key = 'tei-xml-id'",
                $id
            );
            $xml_id = $wpdb->get_var ($sql);
            $sql = $wpdb->prepare (
                "SELECT meta_value FROM wp_postmeta WHERE post_id = %d AND meta_key = 'tei-filename'",
                $id
            );
            $xml_filename = $wpdb->get_var ($sql);

            if ($xml_id) { // FIXME: why is xml_id sometimes null ?
                $items[] = new Witness ($corresp, $xml_id, $xml_filename);
            }
        }
        return $items;
    }

    /**
     * Output dashboard page.
     *
     * @return void
     */

    public function on_menu_dashboard_page ()
    {
        $html = array ();
        $html[] = '<div class="wrap">';

        $title = esc_html (get_admin_page_title ());
        $html[] = "  <h1>$title</h1>";
        $html[] = '<div>';
        $caption = _x ('Capitulary', 'H2 caption', 'capitularia');
        $html[] = "<h2>$caption</h2>";
        $page = DASHBOARD_PAGE_ID;

        // AJAX form for Capitulary selection. Loads sections list.

        $html[] = '<div class="collation-capitulary">';
        $html[] = '<form onsubmit="return on_cap_load_sections()">';
        $html[] = "<input type='hidden' name='page' value='{$page}' />";

        $html[] = '<table>';

        // Capitular

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Select a Capitulary', 'Label: text input', 'capitularia');
        $html[] = "<label for='bk'>$caption</label>";
        $html[] = '</td>';

        $html[] = '<td>';
        $capitulars = $this->get_capitulars ();
        $html[] = '<select id="bk" name="bk">';
        foreach ($capitulars as $capitular) {
            $capitular = esc_attr ($capitular);
            $html[] = "<option value='$capitular'>$capitular</option>";
        }
        $html[] = '</select>';
        $html[] = '</td>';
        $html[] = '</tr>';

        $html[] = '<tr>';
        $html[] = '<td>';
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = get_submit_button (
            _x ('Show Sections', 'Button: Show sections of a Capitulary', 'capitularia'),
            'primary',
            'submit',
            false
        );
        $html[] = '</td>';
        $html[] = '</tr>';
        $html[] = '</table>';
        $html[] = '</form>';
        $html[] = '</div>';

        // Placeholder for AJAX-retrieved section list.  The previous form will
        // load into this.  This will then contain code to load the next section.

        $html[] = '<div id="collation-sections" class="collation-sections">';
        $html[] = '</div>';

        // Placeholder for AJAX-retrieved collation manuscripts.  The previous div will
        // load into this.  This will then contain code to load the next section.

        $html[] = '<div id="collation-manuscripts" class="collation-manuscripts">';
        $html[] = '</div>';

        // Placeholder for AJAX-retrieved collation tables.  The previous div will
        // load into this.  This is the stuff the user wants to see.

        $html[] = '<div id="collation-tables" class="collation-tables">';
        $html[] = '</div>';

        $html[] = '</div>';
        $html[] = '</div>';

        echo (implode ("\n", $html));
    }

    /**
     * Ajax endpoint
     *
     * Handles AJAX-loading of the sections of a capitular.
     *
     * @return void
     */

    public function on_cap_load_sections ()
    {
        $bk = $_REQUEST['bk'];

        $html = array ('<div class="collation-sections">');
        $caption = _x ('Section', 'H2 caption', 'capitularia');
        $html[] = "<h2>$caption</h2>";
        $html[] = '<form onsubmit="return on_cap_load_manuscripts()">';
        $html[] = '<table>';

        // Sections

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = sprintf (_x ('Select a section in Capitulary %s', 'Label: for drop-down', 'capitularia'), $bk);
        $html[] = "<label for='section'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $sections = $this->get_sections ($bk);
        $html[] = '<select id="section" name="section">';
        foreach ($sections as $section) {
            $section = esc_attr ($section);
            $html[] = "<option value='$section'>$section</option>";
        }
        $html[] = '</select>';
        $html[] = '</td>';
        $html[] = '</tr>';

        // Algorithm

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Select Collation Algorithm', 'Label: for drop-down', 'capitularia');
        $html[] = "<label for='algorithm'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<select id="algorithm" name="algorithm">';
        foreach (ALGORITHMS as $algo => $algorithm) {
            $html[] = "<option value='$algo'>$algorithm</option>";
        }
        $html[] = '</select>';
        $html[] = '</td>';
        $html[] = '</tr>';

        // Levenshtein distance

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Select Levenshtein distance', 'Label: for drop-down', 'capitularia');
        $html[] = "<label for='levenshtein'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<select id="levenshtein" name="levenshtein">';
        for ($i = 0; $i < 5; $i++) {
            $html[] = "<option value='$i'>$i</option>";
        }
        $html[] = '</select>';
        $html[] = '</td>';
        $html[] = '</tr>';

        // Proportional Levenshtein distance

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Select proportional Levenshtein distance', 'Label: for drop-down', 'capitularia');
        $html[] = "<label for='proportional_levenshtein'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<select id="proportional_levenshtein" name="proportional_levenshtein">';
        foreach (explode (' ', '0.0 0.1 0.2 0.25 0.3 0.4 0.5') as $i) {
            $html[] = "<option value='$i'>$i</option>";
        }
        $html[] = '</select>';
        $html[] = '</td>';
        $html[] = '</tr>';

        // Segmentation

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Use segmentation', 'Label: for drop-down', 'capitularia');
        $html[] = "<label for='segmentation'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<input type="checkbox" id="segmentation" name="segmentation" value="segmentation" />';
        $html[] = '</td>';
        $html[] = '</tr>';

        // Transpositions

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Use transpositions', 'Label: for drop-down', 'capitularia');
        $html[] = "<label for='transpositions'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<input type="checkbox" id="transpositions" name="transpositions" value="transpositions" />';
        $html[] = '</td>';
        $html[] = '</tr>';

        // Collate button

        $html[] = '<tr>';
        $html[] = '<td>';
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = get_submit_button (
            _x ('Collate', 'Button: Start the collation', 'capitularia'),
            'primary',
            'submit',
            false
        );
        $html[] = '</td>';
        $html[] = '</tr>';

        $html[] = '</table>';
        $html[] = '</form>';
        $html[] = '</div>';

        $json = array (
            'success' => true,
            'message' => '',
            'html' => implode ("\n", $html),
        );
        wp_send_json ($json);
    }

    /**
     * Ajax endpoint
     *
     * Handles AJAX-loading of the manuscripts of a section.
     *
     * @return void
     */

    public function on_cap_load_manuscripts ()
    {
        $corresp      = $_REQUEST['corresp'];
        $algorithm    = isset ($_REQUEST['algorithm']) ? $_REQUEST['algorithm'] : 'default';
        if (!array_key_exists ($algorithm, ALGORITHMS)) {
            $algorithm = 'needleman-wunsch';
        }
        $levenshtein    = intval (isset ($_REQUEST['levenshtein']) ? $_REQUEST['levenshtein'] : 0);
        $levenshtein    = max (min ($levenshtein, 10), 0);
        $p_levenshtein  = doubleval (
            isset ($_REQUEST['proportional_levenshtein']) ?
            $_REQUEST['proportional_levenshtein'] : 0.0
        );
        $p_levenshtein  = max (min ($p_levenshtein, 1.0), 0.0);
        $segmentation   = $_REQUEST['segmentation']   == 'true';
        $transpositions = $_REQUEST['transpositions'] == 'true';
        $items = $this->get_collation_items ($corresp);

        $witnesses = array ();
        foreach ($items as $item) {
            $item->extract_section ();
            $item->xml_to_text ();
            if ($item->pure_text) { // FIXME: why is this sometimes empty ?
                $witnesses[] = $item->to_collatex ();
            }
        }
        $json = array (
            'witnesses' => $witnesses,
            'algorithm' => $algorithm,
        );
        // !!! tokenComparator works only in our custom patched version !!!
        if ($levenshtein > 0) {
            $json['tokenComparator'] = array ('type' => 'levenshtein', 'distance' => $levenshtein);
        }
        if ($p_levenshtein > 0.0) {
            $json['tokenComparator'] = array ('type' => 'proportional_levenshtein', 'distance' => $p_levenshtein);
        }
        $json['joined']         = $segmentation;
        $json['transpositions'] = $transpositions;

        $json_in = json_encode ($json, JSON_PRETTY_PRINT);

        $tmp = array ();

        $collatex = new CollateX ();
        $ret = $collatex->call_collatex_pipes ($json_in);
        if ($ret['error_code'] == 0) {
            $caption = sprintf (__ ('Collation output for %s', 'capitularia'), $corresp);
            $tmp[] = "<h2>$caption</h2>";
            $tmp[] = "Algorithm: $algorithm Levenshtein: $levenshtein Prop_Levenshtein: $p_levenshtein";
            $data = json_decode ($ret['stdout'], true);
            $data['table'] = $collatex->invert_table ($data['table']);
            $tmp[] = $collatex->format_table ($data);
        } else {
            $tmp[] = '<h2>CollateX Error</h2>';
            $tmp[] = esc_html ($ret['error_code'] . ' ' . $ret['stdout'] . ' ' . $ret['stderr']);
        }

        /* Output hidden debug section */
        $tmp[] = "<div class='debug'>";
        $tmp[] = '<h2>Debug Sections</h2>';
        foreach ($items as $item) {
            $tmp[] = "<h3>{$item->xml_id}</h3>";
            $tmp[] = "<p>{$item->pure_text}</p>";
        }
        $tmp[] = '<h2>Debug Collatex Input</h2>';
        $tmp[] = '<pre>' . esc_html ($json_in) . '</pre>';
        $tmp[] = '</div>';

        /* Return */
        $json = array (
            'success' => true,
            'message' => '',
            'html' => '<div>' . implode ("\n", $tmp) . '</div>',
        );
        wp_send_json ($json);
    }
}
