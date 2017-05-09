<?php
/**
 * Capitularia Collation Dashboard Page AJAX rotines
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

/**
 * Send a standard json answer with a HTML payload and eventually error
 * messages.
 *
 * @param bool     $success True if success
 * @param string   $message The error message if any
 * @param string[] $html    The HTML as array of strings
 *
 * @return void
 */

function send_json ($success, $message, $html)
{
    $json = array (
        'success' => $success,
        'message' => $message,
        'html' => implode ("\n", $html),
    );
    wp_send_json ($json);
}

/**
 * AJAX endpoint to load the sections drop-down menu
 *
 * Loads the sections drop-down menu when the user selects a capitular.
 *
 * Input:  query parameter bk, eg. 'BK.139'
 * Output: JSON.
 *
 * @return void
 */

function on_cap_load_sections ()
{
    $html[] = array ();
    foreach (get_sections ($_REQUEST['bk']) as $section) {
        $section = esc_attr ($section);
        $html[] = "<option value='$section'>$section</option>";
    }
    send_json (true, '', $html);
}

/**
 * AJAX endpoint to load the manuscript list
 *
 * Loads the manuscript list after the user selected a capitular and section.
 *
 * Input:  query parameter corresp, eg. 'BK.139_1'
 * Output: HTML of table wrapped in JSON.
 *
 * @return void
 */

function on_cap_load_manuscripts ()
{
    $html = array ();
    $html[] = "<div>";
    ob_start ();
    $table = new Witness_List_Table ($_REQUEST['corresp']);
    // $table->set_pagination_args ($this->pagination_args);
    $table->prepare_items ();
    $table->display ();
    $html[] = ob_get_contents ();
    ob_end_clean ();
    $html[] = "</div>";

    send_json (true, '', $html);
}

/**
 * Ajax endpoint to do the collation
 *
 * Do the collation and display the collation output.
 *
 * Input: query parameters
 *   corresp: which section to collate, eg. 'BK.139_1'
 *   manuscripts: a list of manuscript ids to collate,
 *   later_hands: wheter to synthetize manuscripts as edited by later hands
 *   algorithm: which algorithm to use,
 *   segmentation: do a segmentation step,
 *   transpositions: try to recognize transpositions,
 *   normalizations: a list of pairs: original, normalization,
 *   levenshtein_distance: when words are to be considered equal,
 *   levenshtein_ratio: when are words to be considered equal.
 *
 * @return void
 */

function on_cap_load_collation ()
{
    global $cap_collation_algorithms;

    $status = array (); // the status message for the user
    $errors = array (); // the error messages for the user

    $corresp     = $_REQUEST['corresp'];
    $manuscripts = $_REQUEST['manuscripts'];
    $later_hands = $_REQUEST['later_hands'] == 'true';

    $items = get_witnesses_ordered_like ($corresp, $manuscripts, $later_hands);

    $algorithm = isset ($_REQUEST['algorithm']) ? $_REQUEST['algorithm'] : 'default';
    if (!array_key_exists ($algorithm, $cap_collation_algorithms)) {
        $algorithm = 'needleman-wunsch-gotoh';
    }
    $status[] = sprintf (__ ('Algorithm: %s', 'capitularia'), $cap_collation_algorithms[$algorithm]);

    $segmentation   = $_REQUEST['segmentation']   == 'true';
    $transpositions = $_REQUEST['transpositions'] == 'true';

    $normalizations = isset ($_REQUEST['normalizations']) ? $_REQUEST['normalizations'] : array ();

    $witnesses = array ();
    foreach ($items as $item) {
        $item->extract_section ($item->get_corresp (), $errors);
        $item->xml_to_text ();
        // Q: why is pure_text sometimes empty? A: because of bogus markup.
        if ($item->pure_text) {
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
        on_off ($segmentation)
    );
    $status[] = sprintf (
        _x ('Transpositions: %s', '%s = on off', 'capitularia'),
        on_off ($transpositions)
    );

    $json_in = json_encode ($json, JSON_PRETTY_PRINT);

    $html = array ('<div>');

    $collatex = new CollateX ();
    $ret = $collatex->call_collatex_pipes ($json_in);
    if ($ret['error_code'] == 0) {
        $caption = sprintf (__ ('Collation output for %s', 'capitularia'), $corresp);
        $html[] = "<h2>$caption</h2>";
        $data = json_decode ($ret['stdout'], true);
        $tables = $collatex->split_table ($data['table'], 80);
        $n_tables = count ($tables);
        for ($n = 0; $n < $n_tables; $n++) {
            $class = 'collation';
            $class .= ($n == 0) ? ' first' : '';
            $class .= ($n == $n_tables - 1) ? ' last' : '';
            $html[] = "<table class='$class'>";
            $html = array_merge (
                $html,
                $collatex->format_table (
                    $data['witnesses'],
                    $collatex->invert_table ($tables[$n]),
                    $items
                )
            );
            $html[] = '</table>';
        }
        $html[] = '<p>' . implode (', ', $status) . '</p>';
    } else {
        $html[] = '<h2>CollateX Error</h2>';
        $html[] = esc_html ($ret['error_code'] . ' ' . $ret['stdout'] . ' ' . $ret['stderr']);
    }

    /* Debug section */
    $html[] = '<div class="accordion debug-options no-print">';
    $caption = _x ('Debug Output', 'H3', 'capitularia');
    $html[] = "<h3>$caption</h3>";
    $html[] = '<div>';

    $html[] = '<h4>Extracted Sections</h4>';
    foreach ($items as $item) {
        $html[] = '<div>';
        $html[] = "<h5>{$item->get_id ()}</h5>";
        $html[] = "<p>{$item->pure_text}</p>";
        $html[] = '</div>';
    }

    $html[] = '<h4>Collatex Input</h4>';
    $html[] = '<pre>' . esc_html ($json_in) . '</pre>';

    $html[] = '<h4>Collatex Output</h4>';
    $html[] = '<pre>' . esc_html (json_encode (json_decode ($ret['stdout']), JSON_PRETTY_PRINT)) . '</pre>';

    $html[] = '</div>';
    $html[] = '</div>'; // Accordion
    $html[] = '</div>';

    /* Return */
    $msg = (count ($errors) > 0 ?
            '<div class="notice notice-error is-dismissible"><p>' .
            implode ("<br>\n", $errors) . '</p></div>' : '');
    send_json (true, $msg, $html);
}
