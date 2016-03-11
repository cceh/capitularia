<?php
/**
 * Capitularia Collation Dashboard Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

const COLLATION_ROOT = AFS_ROOT . '/local/capitularia-collation';

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
    private $algorithms;

    /**
     * Constructor
     *
     * @return Dashboard_Page
     */

    public function __construct ()
    {
        $this->algorithms = array (
            'dekker'               => _x ('Dekker',               'Collation Algorithm', 'capitularia'),
            'gst'                  => _x ('Greedy String Tiling', 'Collation Algorithm', 'capitularia'),
            'medite'               => _x ('MEDITE',               'Collation Algorithm', 'capitularia'),
            'needleman-wunsch'     => _x ('Needleman-Wunsch',     'Collation Algorithm', 'capitularia'),
            'new-needleman-wunsch' => _x ('New Needleman-Wunsch', 'Collation Algorithm', 'capitularia'),
        );
    }

    /**
     * Sort strings with numbers
     *
     * Sort the numbers in the strings in a sensible way, eg. BK1, BK2, BK10.
     *
     * @param array $unsorted The return fron an SQL query
     *
     * @return string[] The sorted array of strings
     */

    private function sort_results ($unsorted)
    {
        // Add a key to all objects in the array that allows for sensible
        // sorting of numeric substrings.
        foreach ($unsorted as $res) {
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
            $unsorted,
            function ($res1, $res2) {
                return strcoll ($res1->key, $res2->key);
            }
        );

        return array_map (
            function ($s) {
                return $s->meta_value;
            },
            $unsorted
        );
    }

    /**
     * Get a list of all capitulars
     *
     * @return string[] All capitulars
     */

    private function get_capitulars ()
    {
        global $wpdb;

        $sql = 'SELECT DISTINCT meta_value FROM wp_postmeta ' .
               'WHERE meta_key = \'milestone-capitulare\' ORDER BY meta_value;';

        return $this->sort_results ($wpdb->get_results ($sql));
    }

    /**
     * Get a list of all sections of a capitular
     *
     * @param string $bk The capitular
     *
     * @return string[] The sections in the capitular
     */

    private function get_sections ($bk)
    {
        global $wpdb;

        $bk = "{$bk}_%";

        $sql = $wpdb->prepare (
            'SELECT DISTINCT meta_value FROM wp_postmeta ' .
            'WHERE meta_key = \'corresp\' AND meta_value LIKE %s ORDER BY meta_value;',
            $bk
        );

        return $this->sort_results ($wpdb->get_results ($sql));
    }

    /**
     * Get all witnesses for a Corresp
     *
     * @param string $corresp The corresp eg. 'BK123_4'
     *
     * @return Witness[] The witnesses
     */

    private function get_witnesses ($corresp)
    {
        global $wpdb;
        $items = array ();

        $sql = $wpdb->prepare (
            "SELECT DISTINCT post_id FROM wp_postmeta WHERE meta_key = 'corresp' AND meta_value = %s",
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

            // FIXME: Q: Why is xml_id sometimes null? A: Because
            // the TEI file is bogus and doesn't have one.
            if (empty ($xml_id)) {
                $xml_id = basename ($xml_filename, '.xml');
            }

            $items[] = new Witness ($corresp, $xml_id, $xml_filename);
        }

        // sort according to $xml_id
        usort (
            $items,
            function ($item1, $item2) {
                return strcoll ($item1->sort_key, $item2->sort_key);
            }
        );

        return $items;
    }

    /**
     * Get witnesses for a Corresp in a predetermined order
     *
     * @param string $corresp The corresp eg. 'BK123_4'
     * @param array  $order   An array of xml ids
     *
     * @return Witness[] The ordered witnesses
     */

    private function get_witnesses_ordered_like ($corresp, $order)
    {
        $witnesses = $this->get_witnesses ($corresp);
        $items = array ();

        foreach ($order as $xml_id) {
            foreach ($witnesses as $witness) {
                if ($witness->xml_id == $xml_id) {
                    $items[] = $witness;
                }
            }
        }

        return $items;
    }

    /**
     * Return 'on' or 'off'
     *
     * @param boolean $bool The status
     *
     * @return string The localized message
     */

    private function on_off ($bool)
    {
        return $bool ? __ ('on', 'capitularia') : __ ('off', 'capitularia');
    }

    /**
     * Output dashboard page.
     *
     * @return void
     */

    public function on_menu_dashboard_page ()
    {
        $html = array ();
        // Helper element to fake download of parameters we want to save.  This
        // will be click()ed by JS.
        $html[] = '<a id="save-fake-download" href="" download="" style="display: none;"></a>';

        $html[] = '<div class="wrap">';

        $title = esc_html (get_admin_page_title ());
        $html[] = "  <h1>$title</h1>";
        $html[] = '<div class="inner-wrap">';

        // AJAX form for Capitulary selection. Loads sections list.

        $html[] = '<div id="collation-capitulary" class="collation-capitulary no-print">';
        $caption = _x ('Capitulary', 'H2 caption', 'capitularia');
        $html[] = "<h2>$caption</h2>";
        $page = DASHBOARD_PAGE_ID;
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
        $html[] = '<select id="bk" name="bk" onchange="on_cap_load_sections()">';
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
        $html[] = '<td class="load-params">';
        $html[] = '<input id="load-params" type="file" onchange="return load_params(this)">';

        $html[] = str_replace (
            'type="submit"',
            'type="button"',
            get_submit_button (
                _x ('Load Config', 'Button: Load the collation config', 'capitularia'),
                'load',
                'load',
                false,
                array ('onclick' => 'return click_on_load_params()')
            )
        );


        $html[] = '</td>';
        $html[] = '</tr>';
        $html[] = '</table>';
        $html[] = '</form>';
        $html[] = '</div>';

        // Placeholder for AJAX-retrieved section list.  The previous form will
        // load into this.  This will then contain code to load the next section.

        $html[] = '<div id="collation-sections" class="collation-sections no-print">';
        $html[] = '</div>';

        // Placeholder for AJAX-retrieved manuscript list.  The previous form will
        // load into this.  This will then contain code to load the next section.

        $html[] = '<div id="manuscripts-div" class="manuscripts-div no-print">';
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

        $html = array ('<div class="collation-sections no-print">');
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
        $html[] = '<select id="section" name="section" onchange="on_cap_load_manuscripts()">';
        foreach ($sections as $section) {
            $section = esc_attr ($section);
            $html[] = "<option value='$section'>$section</option>";
        }
        $html[] = '</select>';
        $html[] = '</td>';
        $html[] = '</tr>';

        // Collate button

        $html[] = '<tr>';
        $html[] = '<td>';
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = get_submit_button (
            _x ('Show manuscripts', 'Button: Show manuscripts', 'capitularia'),
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
        $corresp = $_REQUEST['corresp'];

        $html = array ('<div>');
        $caption = _x ('Manuscripts', 'H2 caption', 'capitularia');
        $html[] = "<h2>$caption</h2>";
        $caption = __ ('Drag and drop to sort and move between lists.', 'capitularia');
        $html[] = "<p>$caption</p>";

        $html[] = '<form onsubmit="return on_cap_load_collation()">';

        // Table of manuscripts for collation
        $html[] = '<div class="ui-helper-clearfix">';
        $html[] = '<table class="manuscripts manuscripts-collated">';

        $html[] = '<thead>';
        $html[] = '<tr>';
        $html[] = '<td>';
        $html[] = __ ('Manuscripts to collate', 'capitularia');
        $html[] = '</td>';
        $html[] = '</tr>';
        $html[] = '</thead>';

        $html[] = '<tbody>';
        $items = $this->get_witnesses ($corresp);
        foreach ($items as $item) {
            $html[] = "<tr data-siglum='$item->xml_id'>";
            $html[] = '<td>';
            $html[] = $item->xml_id;
            $html[] = '</td>';
            $html[] = '</tr>';
        }
        $html[] = '</tbody>';
        $html[] = '</table>';

        // Table of manuscripts to ignore

        $html[] = '<table class="manuscripts manuscripts-ignored">';

        $html[] = '<thead>';
        $html[] = '<tr>';
        $html[] = '<td>';
        $html[] = __ ('Manuscripts to ignore', 'capitularia');
        $html[] = '</td>';
        $html[] = '</tr>';
        $html[] = '</thead>';

        $html[] = '<tbody>';
        $html[] = '</tbody>';
        $html[] = '</table>';

        $html[] = '</div>';

        // Algorithm

        $html[] = '<table>';
        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Select Collation Algorithm', 'Label: for drop-down', 'capitularia');
        $html[] = "<label for='algorithm'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<select id="algorithm" name="algorithm">';
        $default = 'new-needleman-wunsch';
        $default = 'dekker';
        foreach ($this->algorithms as $algo => $algorithm) {
            $def = ($algo == $default) ? ' selected="selected"' : '';
            $html[] = "<option value='$algo'$def>$algorithm</option>";
        }
        $html[] = '</select>';
        $html[] = '</td>';
        $html[] = '</tr>';

        // Levenshtein distance

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Select Levenshtein distance', 'Label: for drop-down', 'capitularia');
        $html[] = "<label for='levenshtein_distance'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<select id="levenshtein_distance" name="levenshtein_distance">';
        for ($i = 0; $i < 5; $i++) {
            $html[] = "<option value='$i'>$i</option>";
        }
        $html[] = '</select>';
        $html[] = _x ('or', 'Either this or that, not both.', 'capitularia');
        $html[] = '</td>';
        $html[] = '</tr>';

        // Levenshtein ratio

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Select Levenshtein ratio', 'Label: for drop-down', 'capitularia');
        $html[] = "<label for='levenshtein_ratio'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<select id="levenshtein_ratio" name="levenshtein_ratio">';
        $default = '0.6';
        foreach (explode (' ', '1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1') as $i) {
            $def = ($i == $default) ? ' selected="selected"' : '';
            $html[] = "<option value='$i'$def>$i</option>";
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

        // Normalizations

        $html[] = '<tr>';
        $html[] = '<td>';
        $caption = _x ('Normalizations', 'Label: for textarea', 'capitularia');
        $html[] = "<label for='normalizations'>$caption</label>";
        $html[] = '</td>';
        $html[] = '<td>';
        $html[] = '<textarea id="normalizations" name="normalizations" rows="4" cols="50" />';
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
        $html[] = str_replace (
            'type="submit"',
            'type="button"',
            get_submit_button (
                _x ('Save Config', 'Button: Save the collation config', 'capitularia'),
                'save',
                'save',
                false,
                array ('onclick' => 'return save_params()')
            )
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

    public function on_cap_load_collation ()
    {
        $status = array (); // the status message for the user

        $corresp     = $_REQUEST['corresp'];
        $manuscripts = $_REQUEST['manuscripts'];
        // $items = $this->get_witnesses ($corresp);
        $items = $this->get_witnesses_ordered_like ($corresp, $manuscripts);

        $algorithm = isset ($_REQUEST['algorithm']) ? $_REQUEST['algorithm'] : 'default';
        if (!array_key_exists ($algorithm, $this->algorithms)) {
            $algorithm = 'new-needleman-wunsch';
        }
        $status[] = sprintf (__ ('Algorithm: %s', 'capitularia'), $this->algorithms[$algorithm]);

        $segmentation   = $_REQUEST['segmentation']   == 'true';
        $transpositions = $_REQUEST['transpositions'] == 'true';

        $normalizations = isset ($_REQUEST['normalizations']) ? $_REQUEST['normalizations'] : array ();

        $witnesses = array ();
        foreach ($items as $item) {
            $item->extract_section ($item->get_corresp ());
            $item->xml_to_text ();
            if ($item->pure_text) { // FIXME: Q: why is this sometimes empty? A:
                                    // because of bogus markup.
                $witnesses[] = $item->to_collatex ($normalizations);
            }
        }
        $json = array (
            'witnesses' => $witnesses,
            'algorithm' => $algorithm,
        );

        // !!! tokenComparators works only in our custom patched version !!!

        if (isset ($_REQUEST['levenshtein_distance'])) {
            $dist = intval ($_REQUEST['levenshtein_distance']);
            $dist = max (min ($dist, 10), 0);
            $json['tokenComparator'] = array (
                'type' => 'levenshtein',
                'distance' => $dist,
            );
            $status[] = sprintf (__ ('Levenshtein distance: %s', 'capitularia'), $dist);
        }

        if (isset ($_REQUEST['levenshtein_ratio'])) {
            $ratio = doubleval ($_REQUEST['levenshtein_ratio']);
            $ratio = max (min ($ratio, 1.0), 0.0);
            $json['tokenComparator'] = array (
                'type' => 'levenshtein',
                'ratio' => $ratio,
            );
            $status[] = sprintf (__ ('Levenshtein ratio: %s', 'capitularia'), $ratio);
        }

        $json['joined']         = $segmentation;
        $json['transpositions'] = $transpositions;
        $status[] = sprintf (
            _x ('Segmentation: %s',   '%s = on off', 'capitularia'),
            $this->on_off ($segmentation)
        );
        $status[] = sprintf (
            _x ('Transpositions: %s', '%s = on off', 'capitularia'),
            $this->on_off ($transpositions)
        );

        $json_in = json_encode ($json, JSON_PRETTY_PRINT);

        $tmp = array ();

        $collatex = new CollateX ();
        $ret = $collatex->call_collatex_pipes ($json_in);
        if ($ret['error_code'] == 0) {
            $caption = sprintf (__ ('Collation output for %s', 'capitularia'), $corresp);
            $tmp[] = "<h2>$caption</h2>";
            $data = json_decode ($ret['stdout'], true);
            $tables = $collatex->split_table ($data['table'], 80);
            $n_tables = count ($tables);
            for ($n = 0; $n < $n_tables; $n++) {
                $class = 'collation';
                $class .= ($n == 0) ? ' first' : '';
                $class .= ($n == $n_tables - 1) ? ' last' : '';
                $tmp[] = "<table class='$class'>";
                $tmp = array_merge (
                    $tmp,
                    $collatex->format_table (
                        $data['witnesses'],
                        $collatex->invert_table ($tables[$n]),
                        $manuscripts
                    )
                );
                $tmp[] = '</table>';
            }
            $tmp[] = '<p>' . implode (', ', $status) . '</p>';
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
