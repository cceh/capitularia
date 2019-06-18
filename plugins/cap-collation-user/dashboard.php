<?php
/**
 * Capitularia Collation Dashboard Page
 *
 * @package Capitularia
 */

namespace cceh\capitularia\collation_user;

/**
 * Output the dashboard page.
 *
 * This page uses vue.js to manipulate its content.  Most content is retrieved
 * by AJAX, see also: dashboard-ajax.php.  We use a .php file instead of a
 * vue.js template because it makes translation easier.
 *
 * @return void
 */

function dashboard_page ()
{
?>

<div class="cap-collation-user">
  <div class="collation-panel collation-load-params no-print">

    <!--
      <a> is a helper element we use to fake a user click on a download button.
      This will open a file-save dialog box.  The file to save consists of a
      JSON structure encoding all paramters relevant to a collation run,
      eg. capitular, corresp, ordered list of manuscripts, etc.  See
      on_save_params () in front.js.
    -->

    <a id="save-fake-download" href="" download="" style="display: none;"></a>
  </div>

  <div class="row">
    <div id="collation-bk" class="col-md-6 collation-bk no-print">
      <input id="load-params" type="file" @change="on_load_file_chosen" />

      <h3>
        <?php _ex ('Capitulary', 'H3', 'cap-collation-user'); ?>
      </h3>

      <!--
        Form with drop-downs for capitulary and corresp selection.  User
        selection of a capitulary will AJAX-load the corresps drop-down.  User
        selection of a corresp or user hitting submit will AJAX-load the list of
        manuscripts into the next form.
      -->

      <form>
        <div class="form-row">

          <div class="col-sm-6">
            <div class="form-group">
              <label>
                <?php _ex ('Select Capitulary', 'Label: for select', 'cap-collation-user'); ?>
              </label>
              <div class="dropdown">
                <button type="button" class="btn btn-secondary dropdown-toggle" id="bk-label"
                   data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                   {{ bk }}
                </button>
                <div id="bk" class="dropdown-menu" aria-labelledby="bk-label">
                  <button v-for="bk in bks" class="dropdown-item" type="button"
                          :data-bk="bk" @click="on_load_corresps">{{ bk }}</button>
                </div>
              </div>
            </div>
          </div>

          <div class="col-sm-6">
            <div class="form-group">
              <label>
                <?php _ex ('Select Section', 'Label: for select', 'cap-collation-user'); ?>
              </label>
              <div class="dropdown">
                <button type="button" class="btn btn-secondary dropdown-toggle" id="corresp-label"
                   data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                   {{ corresp }}
                </button>
                <div id="corresp" class="dropdown-menu" aria-labelledby="corresp-label">
                  <button v-for="s in corresps" class="dropdown-item" type="button"
                          :data-corresp="s" @click="on_load_manuscripts">{{ s }}</button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="form-group">
          <div class="form-check">
            <input class="form-check-input" type="checkbox" id="later_hands" v-model="later_hands" />
            <label class="form-check-label" for="later_hands">
              <?php _ex ('Include later hands', 'Label for checkbox', 'cap-collation-user'); ?>
            </label>
          </div>
          <div class="form-check">
            <input class="form-check-input" type="checkbox" id="all_copies" v-model="all_copies" />
            <label class="form-check-label" for="all_copies">
              <?php _ex ('Include all copies', 'Label for checkbox', 'cap-collation-user'); ?>
            </label>
          </div>
        </div>

        <div class="form-group">
          <button class="btn btn-primary" type="button" @click="on_load_manuscripts">
            <?php _ex ('Show manuscripts', 'Button: Show manuscripts', 'cap-collation-user'); ?>
          </button>

          <button class="btn btn-secondary" type="button" @click="on_load_params">
            <?php _ex ('Load Config', 'Button: Load the collation config', 'cap-collation-user'); ?>
          </button>
        </div>

        <div v-if="advanced" class="accordion advanced-options">
          <h4>
            <?php _ex ('Advanced Options', 'H4', 'cap-collation-user'); ?>
          </h4>

          <!-- Collation algorithm drop-down menu -->
          <div class="form-group">
            <label for="algorithm">
              <?php _ex ('Select Collation Algorithm', 'Label: for drop-down', 'cap-collation-user'); ?>
            </label>
            <div class="dropdown">
              <button type="button" class="btn btn-secondary dropdown-toggle" id="algorithm-label"
                      data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                 {{ algorithm.name }}
              </button>
              <div id="algorithm" class="dropdown-menu" aria-labelledby="algorithm-label">
                <button v-for="(algo, index) in algorithms" class="dropdown-item" type="button"
                        :data-index="index" @click="on_algorithm">{{ algo.name }}</button>
              </div>
            </div>
          </div>

          <!-- Levenshtein distance drop-down menu -->
          <div class="form-group">
            <label for="ld">
              <?php _ex ('Select Levenshtein distance', 'Label: for drop-down', 'cap-collation-user'); ?>
            </label>
            <div class="dropdown">
              <button type="button" class="btn btn-secondary dropdown-toggle" id="ld-label"
                      data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                 {{ levenshtein_distance }}
              </button>
              <div id="ld" class="dropdown-menu" aria-labelledby="ld-label">
                <button v-for="ld in levenshtein_distances" class="dropdown-item" type="button"
                        :data-ld="ld" @click="on_ld">{{ ld }}</button>
              </div>
            </div>
          </div>

          <?php _ex ('or', 'Either this or that, not both.', 'cap-collation-user'); ?>

          <!-- Levenshtein ratio drop-down menu -->
          <div class="form-group">
            <label for="lr">
              <?php _ex ('Select Levenshtein ratio', 'Label: for drop-down', 'cap-collation-user'); ?>
            </label>
            <div class="dropdown">
              <button type="button" class="btn btn-secondary dropdown-toggle" id="lr-label"
                      data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                 {{ levenshtein_ratio }}
              </button>
              <div id="lr" class="dropdown-menu" aria-labelledby="lr-label">
                <button v-for="lr in levenshtein_ratios" class="dropdown-item" type="button"
                        :data-lr="lr" @click="on_lr">{{ lr }}</button>
              </div>
            </div>
          </div>

          <div class="form-group">
            <!-- Use segmentation checkbox -->
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="segmentation" v-model="segmentation" />
              <label class="form-check-label" for="segmentation">
                <?php _ex ('Use segmentation', 'Label: for drop-down', 'cap-collation-user'); ?>
              </label>
            </div>

            <!-- Transpositions checkbox -->
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="transpositions" v-model="transpositions" />
              <label class="form-check-label" for="transpositions">
                <?php _ex ('Use transpositions', 'Label: for drop-down', 'cap-collation-user'); ?>
              </label>
            </div>
          </div>

          <div class="form-group">
            <!-- Normalizations textbox -->
            <label for="normalizations">
              <?php _ex ('Normalizations', 'Label: for textarea', 'cap-collation-user'); ?>
            </label>
            <p>
              <?php _ex ('One or more lines in the form: raw=normalized', 'Help text', 'cap-collation-user'); ?>
            </p>
            <textarea id="normalizations" name="normalizations" rows="4"></textarea>
          </div>
        </div> <!-- accordion -->
      </form>
    </div>

    <!--
      In this section the user can select which manuscripts to collate with
      checkboxes and the order in which the manuscripts should collate through
      drag-and-drop of the table rows.  On user submit the next step will
      collate the selected manuscripts.

      This section is controlled by a vue.js instance in front.js
    -->

    <div id="collation-manuscripts" class="col-md-6 manuscripts-div no-print">
      <h3>
        <span v-if="spinner" class="spinner"></span>
        <?php _ex ('Manuscripts', 'H3', 'cap-collation-user'); ?>
      </h3>

      <form>
        <label>
          <?php _ex ('Select Manuscripts', 'Label for table', 'cap-collation-user'); ?>
        </label>
        <table id="manuscripts" class="table table-sm table-bordered manuscripts">
          <caption>
            <?php _ex ('Manuscripts that contain {{ corresp }}', 'Caption for table', 'cap-collation-user'); ?>
          </caption>
          <thead class="thead-light">
            <tr>
              <th id="cb" class="manage-column column-cb check-column">
                <label class="screen-reader-text" for="cb-select-all-1">Select All</label>
                <input id="cb-select-all-1" class="cap-toggle" type="checkbox"
                       title="<?php _ex ('Select all manuscripts', 'Checkbox', 'cap-collation-user'); ?>">
              </th>
              <th scope="col" id="id" class="manage-column column-id">
                <?php _ex ('Manuscript', 'TH', 'cap-collation-user'); ?>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="manuscripts.length == 0">
              <th></th>
              <td>
                <?php _ex ('No Manuscripts Found', 'message in table', 'cap-collation-user'); ?>
              </td>
            </tr>
            <tr v-for="w of manuscripts" :data-siglum="w.siglum" :key="w.siglum" style="">
              <th scope="row" class="check-column">
                <label class="screen-reader-text" :for="'cb-select-' + w.siglum">Select {{ w.title }}</label>
                <input type="checkbox" class="cap-toggle" :id="'cb-select-' + w.siglum" :value="w.siglum" v-model="checked">
              </th>
              <td class="id column-id" data-colname="$msg_ms_id">
                <a :href="'/mss/' + w.siglum"><strong>{{ w.title }}</strong></a>
              </td>
            </tr>
          </tbody>
        </table>

        <button id="btn-collate" class="btn btn-primary" type="button" :disabled="checked.length < 2"
                @click="on_collate">
          <?php _ex ('Collate', 'Button: Start the collation', 'cap-collation-user'); ?>
        </button>

        <button class="btn btn-secondary" type="button" @click="on_save_params">
          <?php _ex ('Save Config', 'Button: Save the collation config', 'cap-collation-user'); ?>
        </button>
      </form>
    </div>
  </div> <!-- class row -->

  <!--
    This finally is the stuff the user actually wants to see.  A set of
    tables with one row per collated manuscript, each table representing a
    collated segment of the manuscripts.

    This section is controlled by a vue.js instance in front.js
  -->

  <div class="row">
    <div id="collation-results" class="col-12 collation-tables">
      <h3>
        <span v-if="spinner" class="spinner"></span>
        <?php _ex ('Collation Result for: {{ corresp }}', 'H3', 'cap-collation-user'); ?>
      </h3>
      <table v-for="table of tables"
             class="table table-sm table-bordered table-striped collation" :class="table.class">
        <tbody>
          <tr v-for="row of table.rows" class="witness" :class="row_class (row)"
              :data-siglum="row.siglum" :key="row.siglum"
              @mouseover="hovered = row.siglum" @mouseleave="hovered = null">
            <th class="title">{{ row.title }}</th>
            <td v-for="cell in row.cells" :class="cell.class">{{ cell.text }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<?php } ?>
