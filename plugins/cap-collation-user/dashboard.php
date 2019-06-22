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

<div id="vm-cap-collation-user" class="cap-collation-user">
  <article id="post-<?php echo (get_the_ID ()); ?>" class='page'>

    <header class="article-header cap-page-header no-print">
      <h2><?php echo (get_the_title ()); ?></h2>
    </header>

    <div class="collation-panel no-print">

      <!--
        <a> is a helper element we use to fake a user click on a download button.
        This will open a file-save dialog box.  The file to save consists of a
        JSON structure encoding all paramters relevant to a collation run,
        eg. capitular, corresp, list of selected witnesses, etc.  See
        on_save_config () in front.js.
      -->

      <a id="save-fake-download" href="" download="" style="display: none;"></a>
      <input id="load-config" type="file" @change="on_load_config" />
    </div>

    <div class="row">
      <div class="col-md-6 no-print">

        <div class="collation-bk">
          <h3>
            <?php _ex ('Capitulary', 'H3', 'cap-collation-user'); ?>
          </h3>

          <!--
              Form with drop-downs for capitulary and corresp selection.  User
              selection of a capitulary will AJAX-load the corresps drop-down.  User
              selection of a corresp or user hitting submit will AJAX-load the list of
              witnesses into the next form.
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
                              :data-bk="bk" @click="on_select_bk">{{ bk }}</button>
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
                              :data-corresp="s" @click="on_select_corresp">{{ s }}</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Later Hands checkbox -->
            <div class="form-group">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="later_hands"
                       v-model="later_hands" @click="on_later_hands" />
                <label class="form-check-label" for="later_hands">
                  <?php _ex ('Include corrections by different hands', 'Checkbox', 'cap-collation-user'); ?>
                </label>
              </div>
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

        <button class="btn btn-secondary" type="button" @click="on_load_config_redirect">
          <?php _ex ('Load Configuration', 'Button', 'cap-collation-user'); ?>
        </button>

        <button class="btn btn-secondary ml-2" type="button" @click="on_save_config">
          <?php _ex ('Save Configuration', 'Button', 'cap-collation-user'); ?>
        </button>
      </div>

      <!--
        In this section the user can select which witnesses to collate with
        checkboxes and the order in which the witnesses should collate through
        drag-and-drop of the table rows.  On user submit the next step will
        collate the selected witnesses.
      -->

      <div class="col-md-6 no-print">
        <div class="witnesses-div">
          <h3>
            <?php _ex ('Textual Witnesses', 'H3', 'cap-collation-user'); ?>
            <i v-if="spinner" class="spinner fas fa-spin"></i>
          </h3>

          <form>
            <label>
              <?php _ex ('Select Textual Witnesses', 'Label for table', 'cap-collation-user'); ?>
            </label>
            <table id="witnesses" class="table table-sm table-bordered witnesses">
              <thead class="thead-light">
                <tr>
                  <th></th>
                  <th id="cb" class="slim">
                    <label class="screen-reader-text" for="cb-select-all-1">Select All</label>
                    <input id="cb-select-all-1" class="cap-toggle" type="checkbox"
                           @click="on_select_all"
                           title="<?php _ex ('Select all textual witnesses', 'Checkbox', 'cap-collation-user'); ?>">
                  </th>
                  <th scope="col">
                    <?php _ex ('Textual Witness', 'TH', 'cap-collation-user'); ?>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="witnesses.length == 0">
                  <th class="slim" scope="row"></th>
                  <th class="slim" scope="row"></th>
                  <td>
                    <?php _ex ('No textual witnesses found.', 'message in table', 'cap-collation-user'); ?>
                  </td>
                </tr>
                <tr v-for="(w, index) of witnesses" :data-siglum="w.siglum"
                    :key="w.siglum" :class="row_class (w, index)">
                  <th class="slim handle" scope="row">
                    <i class="fas"
                       title="<?php _ex ('Drag row to reorder the textual witness.',
                              'title of grip-lines icon', 'cap-collation-user'); ?>"></i>
                  </th>
                  <th scope="row" class="slim">
                    <label class="screen-reader-text" :for="'cb-select-' + w.siglum">Select {{ w.title }}</label>
                    <input type="checkbox" class="cap-toggle" :id="'cb-select-' + w.siglum"
                           :value="w.siglum" v-model="w.checked" :disabled="w.siglum == bk_id"
                           title="<?php _ex ('Include this textual witness in the collation.',
                                  'Checkbox', 'cap-collation-user'); ?>">
                  </th>
                  <td v-if="w.siglum == bk_id">{{ w.title }}</td>
                  <td v-else=""><a :href="'/mss/' + w.siglum">{{ w.title }}</a></td>
                </tr>
              </tbody>
            </table>

          </form>
        </div>

        <button id="btn-collate" class="btn btn-primary" type="button"
                :disabled="selected.length < 2"
                @click="on_collate">
          <?php _ex ('Collate', 'Button', 'cap-collation-user'); ?>
        </button>
      </div>

    </div> <!-- class row -->

    <!--
      This finally is the stuff the user actually wants to see.  A set of
      tables with one row per collated witness, each table representing a
      collated segment of the witnesses.

      This section is controlled by a vue.js component in front.js
    -->

    <div class="row">
      <div class="col-12">
        <cap-collation-user-results inline-template
                                    ref="results" :corresp="corresp" :sigla="sigla"
                                    @reordered="on_reordered">
          <div id="vm-collation-results" class="collation-tables">
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
                  <th class="slim handle no-print" scope="row">
                    <i class="fas"
                       title="<?php _ex ('Drag row to reorder the textual witness.',
                              'title of grip-lines icon', 'cap-collation-user'); ?>"></i>
                  </th>
                  <th class="title">{{ row.title }}</th>
                  <td v-for="cell in row.cells" :class="cell.class">{{ cell.text }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </cap-collation-user-results>
      </div>
    </div>

  </article>
</div>

<?php } ?>
