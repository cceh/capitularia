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
  <article id="post-<?php echo (get_the_ID ()); ?>" class='page'>

    <header class="article-header cap-page-header no-print">
      <h2><?php echo (get_the_title ()); ?></h2>
    </header>

    <div class="collation-panel no-print">

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
        <input id="load-config" type="file" @change="on_load_file_chosen" />

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
                  <?php _ex ('Select Capitulary', 'Label for select', 'cap-collation-user'); ?>
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
                  <?php _ex ('Select Section', 'Label for select', 'cap-collation-user'); ?>
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
                <?php _ex ('Include corrections by different hands', 'Checkbox', 'cap-collation-user'); ?>
              </label>
            </div>
          </div>

          <div class="form-group">
            <button class="btn btn-primary" type="button" @click="on_load_manuscripts">
              <?php _ex ('Show Textual Witnesses', 'Button', 'cap-collation-user'); ?>
            </button>

            <button class="btn btn-secondary" type="button" @click="on_load_params">
              <?php _ex ('Load Configuration', 'Button', 'cap-collation-user'); ?>
            </button>
          </div>

          <div v-if="advanced" class="accordion advanced-options">
            <h4>
              <?php _ex ('Advanced Options', 'H4', 'cap-collation-user'); ?>
            </h4>

            <!-- Collation algorithm drop-down menu -->
            <div class="form-group">
              <label for="algorithm">
                <?php _ex ('Select Collation Algorithm', 'Label for drop-down', 'cap-collation-user'); ?>
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
                <?php _ex ('Select Levenshtein Distance', 'Label for drop-down', 'cap-collation-user'); ?>
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
                <?php _ex ('Select Levenshtein Ratio', 'Label for drop-down', 'cap-collation-user'); ?>
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
                  <?php _ex ('Use Segmentation', 'Label for drop-down', 'cap-collation-user'); ?>
                </label>
              </div>

              <!-- Transpositions checkbox -->
              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="transpositions" v-model="transpositions" />
                <label class="form-check-label" for="transpositions">
                  <?php _ex ('Use Transpositions', 'Label for drop-down', 'cap-collation-user'); ?>
                </label>
              </div>
            </div>

            <div class="form-group">
              <!-- Normalizations textbox -->
              <label for="normalizations">
                <?php _ex ('Normalizations', 'Label for textarea', 'cap-collation-user'); ?>
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
          <?php _ex ('Textual Witnesses', 'H3', 'cap-collation-user'); ?>
          <i v-if="spinner" class="spinner fas fa-spin"></i>
        </h3>

        <form>
          <label>
            <?php _ex ('Select Textual Witnesses', 'Label for table', 'cap-collation-user'); ?>
          </label>
          <table id="manuscripts" class="table table-sm table-bordered manuscripts">
            <thead class="thead-light">
              <tr>
                <th></th>
                <th id="cb" class="check-column slim">
                  <label class="screen-reader-text" for="cb-select-all-1">Select All</label>
                  <input id="cb-select-all-1" class="cap-toggle" type="checkbox"
                         title="<?php _ex ('Select all textual witnesses', 'Checkbox', 'cap-collation-user'); ?>">
                </th>
                <th scope="col" id="id" class="manage-column column-id">
                  <?php _ex ('Textual Witness', 'TH', 'cap-collation-user'); ?>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="manuscripts.length == 0">
                <th class="slim" scope="row"></th>
                <th class="slim" scope="row"></th>
                <td>
                  <?php _ex ('No textual witnesses found.', 'message in table', 'cap-collation-user'); ?>
                </td>
              </tr>
              <tr v-for="(w, index) of manuscripts" :data-siglum="w.siglum" :key="w.siglum" style="">
                <th v-if="index > 0" class="handle" scope="row">
                  <i class="fas"
                     title="<?php _ex ('Drag row to reorder the textual witness.',
                                       'title of grip-lines icon', 'cap-collation-user'); ?>"></i>
                </th>
                <th v-else="" class="slim" scope="row"></th>
                <th scope="row" class="check-column slim">
                  <label class="screen-reader-text" :for="'cb-select-' + w.siglum">Select {{ w.title }}</label>
                  <input type="checkbox" class="cap-toggle" :id="'cb-select-' + w.siglum" :value="w.siglum" v-model="checked"
                         title="<?php _ex ('Include this textual witness in the collation.', 'Checkbox', 'cap-collation-user'); ?>">
                </th>
                <td class="id column-id" data-colname="$msg_ms_id">
                  <a :href="'/mss/' + w.siglum">{{ w.title }}</a>
                </td>
              </tr>
            </tbody>
          </table>

          <button id="btn-collate" class="btn btn-primary" type="button" :disabled="checked.length < 2"
                  @click="on_collate">
            <?php _ex ('Collate', 'Button', 'cap-collation-user'); ?>
          </button>

          <button class="btn btn-secondary" type="button" @click="on_save_params">
            <?php _ex ('Save Configuration', 'Button', 'cap-collation-user'); ?>
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
          <?php _ex ('Collation for: {{ corresp }}', 'H3', 'cap-collation-user'); ?>
          <i v-if="spinner" class="spinner fas fa-spin"></i>
        </h3>
        <table v-for="table of tables"
               class="table table-sm table-bordered table-striped collation" :class="table.class">
          <tbody>
            <tr v-for="(row, index) of table.rows" class="witness" :class="row_class (row, index)"
                :data-siglum="row.siglum" :key="row.siglum"
                @mouseover="hovered = row.siglum" @mouseleave="hovered = null">
              <th v-if="index > 0" class="handle no-print" scope="row">
                <i class="fas"
                   title="<?php _ex ('Drag row to reorder the textual witness.',
                                     'title of grip-lines icon', 'cap-collation-user'); ?>"></i>
              </th>
              <th v-else="" class="slim no-print" scope="row"></th>
              <th class="title">{{ row.title }}</th>
              <td v-for="cell in row.cells" :class="cell.class">{{ cell.text }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </article>

</div>

<?php } ?>
