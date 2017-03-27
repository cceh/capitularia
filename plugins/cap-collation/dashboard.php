<?php
/**
 * Capitularia Collation Dashboard Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation;

/**
 * Implements the dashboard page.
 *
 * The dashboard page controls the plugin.
 *
 * You open the dashboard page by clicking on _Dashboard | Capitularia
 * Collation_ in the Wordpress admin page.
 */

/**
 * Output dashboard page.
 *
 * Outputs the dashboard page when the user selects it from the admin menu.
 * Most of the content of the page is loaded with AJAX in multiple steps.
 *
 * @return void
 */

function on_menu_dashboard_page ()
{
    global $cap_collation_algorithms;

    $title = esc_html (get_admin_page_title ());

    // The various buttons.  Using Wordpress functions to get the HTML for the
    // buttons so they will match the look of the theme.

    $button_manuscripts = get_submit_button (
        _x ('Show manuscripts', 'Button: Show manuscripts', 'capitularia'),
        'primary',
        'show-manuscripts',
        false
    );
    $button_collate = get_submit_button (
        _x ('Collate', 'Button: Start the collation', 'capitularia'),
        'primary',
        'collate',
        false,
        array ('onclick' => 'return on_cap_load_collation()')
    );
    $button_load = str_replace (
        'type="submit"',
        'type="button"',
        get_submit_button (
            _x ('Load Config', 'Button: Load the collation config', 'capitularia'),
            'load',
            'load-config',
            false,
            array ('onclick' => 'return click_on_load_params()')
        )
    );
    $button_save = str_replace (
        'type="submit"',
        'type="button"',
        get_submit_button (
            _x ('Save Config', 'Button: Save the collation config', 'capitularia'),
            'save',
            'save-config',
            false,
            array ('onclick' => 'return save_params()')
        )
    );

    $html = array ();

    // <a> is a helper element we use to fake a user click on a download button.
    // This will open a file-save dialog box.  The file to save consists of a
    // JSON structure encoding all paramters relevant to a collation run,
    // eg. capitular, section, ordered list of manuscripts, etc.  See
    // save_params () in admin.js.

    $html[] = <<<EOT
        <a id="save-fake-download" href="" download="" style="display: none;"></a>
        <div class="wrap">
          <h1>$title</h1>
          <div class="inner-wrap">
            <div class="collation-panel collation-load-params no-print">
              <input id="load-params" type="file" onchange="return load_params(this)" />
              $button_load
            </div>
EOT;

    // Form with drop-downs for capitulary and section selection.  User
    // selection of a capitulary will AJAX-load the sections drop-down.  User
    // selection of a section or user hitting submit will AJAX-load the list of
    // manuscripts into the next form.

    $caption    = _x ('Capitulary', 'H2 caption', 'capitularia');
    $caption2   = _x ('Select Capitulary and Section', 'Label: for select', 'capitularia');
    $page       = DASHBOARD_PAGE_ID;

    $html[] = <<<EOT
        <div id="collation-capitulary" class="collation-capitulary no-print">
          <h2>$caption</h2>
          <form onsubmit="return on_cap_load_manuscripts()">
            <input type="hidden" name="page" value="$page" />
            <table>
              <tr>
                <td><label for="bk">$caption</label></td>
                <td>
                  <select id="bk" name="bk" onchange="on_cap_load_sections ()">
EOT;

    foreach (get_capitulars () as $capitular) {
        $capitular = esc_attr ($capitular);
        $html[] = "<option value='$capitular'>$capitular</option>";
    }

    $html[] = <<<EOT
                  </select>
                </td>
                <td>
                  <select id="section" name="section" onchange="on_cap_load_manuscripts ()">
                    <option value="">empty</option>
                  </select>
                </td>
                <td>$button_manuscripts</td>
              </tr>
            </table>
          </form>
        </div>
EOT;

    // on_cap_load_manuscripts() loads #manuscripts-tbody with an AJAX-retrieved
    // array of rows containing manuscript items.  The user may select which
    // manuscripts to collate and the order in which the manuscripts should
    // collate through drag-and-drop between two tables.  On user submit the
    // next step will collate the selected manuscripts.

    $caption  = _x ('Manuscripts', 'H2 caption', 'capitularia');
    $caption2 = __ ('Drag and drop to sort and move between lists.', 'capitularia');
    $caption3 = __ ('Manuscripts to collate', 'capitularia');
    $caption4 = __ ('Manuscripts to ignore', 'capitularia');
    $label1   = __ ('Include edits by later hands', 'capitularia');

    $html[] = <<<EOT
    <div id="manuscripts-div" class="manuscripts-div no-print" style="display: none">
      <h2>$caption</h2>
      <p>$caption2</p>
      <form onsubmit="return on_cap_load_collation ()">
        <div class="ui-helper-clearfix">
          <table class="manuscripts manuscripts-collated">
            <thead><tr><td>$caption3</td></tr></thead>
            <tbody id="manuscripts-tbody"><!-- rows loaded thru AJAX --></tbody>
          </table>
          <table class="manuscripts manuscripts-ignored">
            <thead><tr><td>$caption4</td></tr></thead>
            <tbody></tbody>
          </table>
        </div>
        <div>
          <label for="later_hands">$label1</label>
          <input type="checkbox" id="later_hands" name="later_hands" value="later_hands" />
        </div>
EOT;

    // Collation algorithm drop-down menu

    $caption  = _x ('Advanced Options', 'H3 caption', 'capitularia');
    $caption2 = _x ('Select Collation Algorithm', 'Label: for drop-down', 'capitularia');

    $html[] = <<<EOT
        <div class="accordion advanced-options">
          <h3>$caption</h3>
          <div>
            <table>
              <tr>
                <td><label for="algorithm">$caption2</label></td>
                <td>
                  <select id="algorithm" name="algorithm">
EOT;

    $default = 'needleman-wunsch-gotoh';
    foreach ($cap_collation_algorithms as $algo => $algorithm) {
        $def = ($algo == $default) ? ' selected="selected"' : '';
        $html[] = "<option value='$algo'$def>$algorithm</option>";
    }

    // Levenshtein distance drop-down menu

    $caption = _x ('Select Levenshtein distance', 'Label: for drop-down', 'capitularia');
    $or      = _x ('or', 'Either this or that, not both.', 'capitularia');

    $html[] = <<<EOT
                  </select>
                </td>
              </tr>
              <tr>
                <td><label for="levenshtein_distance">$caption</label></td>
                <td>
                  <select id="levenshtein_distance" name="levenshtein_distance">
EOT;

    for ($i = 0; $i < 5; $i++) {
        $html[] = "<option value='$i'>$i</option>";
    }

    // Levenshtein ratio drop-down menu

    $caption = _x ('Select Levenshtein ratio', 'Label: for drop-down', 'capitularia');

    $html[] = <<<EOT
                  </select>
                $or
                </td>
              </tr>
              <tr>
                <td><label for='levenshtein_ratio'>$caption</label></td>
                <td>
                  <select id="levenshtein_ratio" name="levenshtein_ratio">
EOT;

    $default = '1.0';
    foreach (explode (' ', '1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1') as $i) {
        $def = ($i == $default) ? ' selected="selected"' : '';
        $html[] = "<option value='$i'$def>$i</option>";
    }

    // Use segmentation checkbox

    $caption = _x ('Use segmentation', 'Label: for drop-down', 'capitularia');

    $html[] = <<<EOT
                  </select>
                </td>
              </tr>
              <tr>
                <td><label for="segmentation">$caption</label></td>
                <td>
                  <input type="checkbox" id="segmentation" name="segmentation" value="segmentation" />
                </td>
              </tr>
EOT;

    // Transpositions checkbox

    $caption = _x ('Use transpositions', 'Label: for drop-down', 'capitularia');

    $html[] = <<<EOT
              <tr>
                <td><label for='transpositions'>$caption</label></td>
                <td>
                  <input type="checkbox" id="transpositions" name="transpositions" value="transpositions" />
                </td>
              </tr>
EOT;

    // Normalizations textbox

    $caption  = _x ('Normalizations', 'Label: for textarea', 'capitularia');
    $caption2 = _x ('One or more lines in the form: raw=normalized', 'Help text', 'capitularia');

    $html[] = <<<EOT
                <tr>
                  <td>
                    <label for="normalizations">$caption</label>
                    <p>$caption2</p>
                  </td>
                  <td>
                    <textarea id="normalizations" name="normalizations" rows="4" cols="50"></textarea>
                  </td>
                </tr>
              </table>
            </div>
          </div>
EOT;

    // on_cap_load_collation () will AJAX-load #collation-tables.  This finally
    // is the stuff the user actually wants to see.  A set of tables with one
    // row per collated manuscript, each table representing a collated segment
    // of the manuscripts.

    $html[] = <<<EOT
            <table>
              <tr>
                <td>$button_collate $button_save</td>
                <td></td>
              </tr>
            </table>
          </form>
        </div>
        <div id="collation-tables" class="collation-tables" style="display: none"></div>
      </div>
    </div>
EOT;

    echo (implode ("\n", $html));
}
