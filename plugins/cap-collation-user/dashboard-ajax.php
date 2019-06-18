<?php
/**
 * Capitularia Collation Dashboard Page AJAX routines
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation_user;

$map_sigla = function ($siglum)
{
    $xlate = array (
        '_bk-textzeuge' => 'Boretius-Krause Edition',
    );
    $title = $xlate[$siglum] ?? $siglum;
    $copy = _x (' ${1}. copy',  'extra copies of capitularies', 'cap-collation-user');
    $corr = _x (' corrected',   'corrected version',            'cap-collation-user');

    $title = preg_replace ('/#(\d+)/',       $copy, $title);
    $title = preg_replace ('/[?]hands=XYZ/', $corr, $title);

    return array (
        'siglum' => $siglum,
        'title'  => $title,
    );
};

/**
 * AJAX endpoint to load the bks drop-down menu
 *
 * Loads the bks drop-down menu on initial page load.
 *
 * Output: JSON list of bks
 *
 * @return void
 */

function on_cap_collation_user_load_bks ()
{
    wp_send_json (array (
        'success' => true,
        'bks'     => get_capitulars (),
    ));
}


/**
 * AJAX endpoint to load the corresps drop-down menu
 *
 * Loads the corresps drop-down menu when the user selects a capitular.
 *
 * Input:  query parameter bk, eg. 'BK.139'
 * Output: JSON list of corresps
 *
 * @return void
 */

function on_cap_collation_user_load_corresps ()
{
    $bk = $_REQUEST['bk'];

    wp_send_json (array (
        'success'  => true,
        'corresps' => get_corresps ($bk),
    ));
}


/**
 * AJAX endpoint to load the manuscript list
 *
 * Loads the manuscript list after the user selected a capitular and corresp.
 *
 * Input:  query parameter corresp, eg. 'BK.139_1'
 * Output: JSON list of manuscripts that witness corresp.
 *
 * @return void
 */

function on_cap_collation_user_load_manuscripts ()
{
    $corresp     = $_REQUEST['corresp'];
    $later_hands = $_REQUEST['later_hands'] == 'true';
    $all_copies  = $_REQUEST['all_copies']  == 'true';

    global $map_sigla;
    wp_send_json (array (
        'success'   => true,
        'witnesses' => array_map (
            $map_sigla,
            array_map (
                function ($witness) {
                    return $witness->get_id ();
                },
                get_witnesses ($corresp, $later_hands, $all_copies)
            )
        ),
    ));
}


/**
 * Ajax endpoint to do the collation
 *
 * Do the collation and display the collation output.
 *
 * Input: query parameters
 *   corresp: which corresp to collate, eg. 'BK.139_1'
 *   manuscripts: a list of manuscript ids to collate,
 *   later_hands: whether to synthetize manuscripts as edited by later hands
 *   all_copies: whether to collate more than one copy per manuscript
 *   algorithm: which algorithm to use,
 *   segmentation: do a segmentation step,
 *   transpositions: try to recognize transpositions,
 *   normalizations: a list of pairs: original, normalization,
 *   levenshtein_distance: when words are to be considered equal,
 *   levenshtein_ratio: when are words to be considered equal.
 *
 * @return void
 */

function on_cap_collation_user_load_collation ()
{
    $status = array (); // the status message for the user
    $errors = array (); // the error messages for the user

    $corresp     = $_REQUEST['corresp'];
    $manuscripts = $_REQUEST['manuscripts'];
    $later_hands = $_REQUEST['later_hands'] == 'true';
    $all_copies  = $_REQUEST['all_copies']  == 'true';

    $algorithm = $_REQUEST['algorithm'] ?? 'needleman-wunsch-gotoh';
    $status[] = sprintf (__ ('Algorithm: %s', 'cap-collation-user'), $algorithm);

    $segmentation   = $_REQUEST['segmentation']   == 'true';
    $transpositions = $_REQUEST['transpositions'] == 'true';

    $normalizations = $_REQUEST['normalizations'] ?? array ();

    $witnesses = get_witnesses ($corresp, $later_hands, $all_copies);
    $texts = array ();
    foreach ($witnesses as $item) {
        if (in_array ($item->get_id (), $manuscripts)) {
            $item->extract_corresp ($item->get_corresp (), $errors);
            $item->xml_to_text ();
            // Q: why is pure_text sometimes empty? A: because of bogus markup.
            if ($item->pure_text) {
                $texts[] = $item->to_collatex ($normalizations);
            }
        }
    }
    $json = array (
        'witnesses' => $texts,
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
        $status[] = sprintf (__ ('Levenshtein distance: %s', 'cap-collation-user'), $dist);
    }

    if (isset ($_REQUEST['levenshtein_ratio'])) {
        $ratio = doubleval ($_REQUEST['levenshtein_ratio']);
        $ratio = max (min ($ratio, 1.0), 0.0);
        $json['tokenComparator'] = array (
            'type' => 'levenshtein',
            'ratio' => $ratio,
        );
        $status[] = sprintf (__ ('Levenshtein ratio: %s', 'cap-collation-user'), $ratio);
    }

    $json['joined']         = $segmentation;
    $json['transpositions'] = $transpositions;
    $status[] = sprintf (
        _x ('Segmentation: %s',   '%s = on off', 'cap-collation-user'),
        on_off ($segmentation)
    );
    $status[] = sprintf (
        _x ('Transpositions: %s', '%s = on off', 'cap-collation-user'),
        on_off ($transpositions)
    );

    $json_in = json_encode ($json, JSON_PRETTY_PRINT);

    $collatex = new CollateX ();
    $data = $collatex->call_collatex_pipes ($json_in);
    $data = json_decode ($data['stdout'], true);

    global $map_sigla;
    wp_send_json (array (
        'success'     => true,
        'corresp'     => $corresp,
        // the ms ids in the requested order.  we have to roundtrip the order
        // because the user may have messed with the selection while waiting
        'order'       => $manuscripts,
        'later_hands' => $later_hands,
        'all_copies'  => $all_copies,
        'witnesses'   => array (
            'manuscripts' => array_map ($map_sigla, $data['witnesses']),
            'table'       => $data['table'],
        ),
        // the ms ids in the requested order.  we have to roundtrip the order
        // because the user may have messed with the selection while waiting
        'status' => $status,
        'errors' => $errors,
    ));
}
