<?php
/**
 * Capitularia Collation Dashboard Page
 *
 * @package Capitularia Collation Tool
 */

namespace cceh\capitularia\collation_user;

// phpcs:disable Generic.WhiteSpace.ScopeIndent.Incorrect

/**
 * Build the dashboard page.
 *
 * This page uses vue.js to manipulate its content.  Vue.js then retrieves
 * further content by AJAX.  We use a this template instead of a vue.js template
 * because it makes translation easier.
 *
 * @return string The HTML of the dashboard page.
 */

function dashboard_page ()
{
    ob_start ();
    ?>

<div id="vm-cap-collation-user" class="cap-collation-user">

  <cap-collation-selector inline-template ref="selector" v-for="(section, index) in sections"
    :key="index" v-bind:config="section">
    <div class="row">
      <div class="col-md-6 no-print">

        <div class="collation-bk">
          <h3>
            <?php _ex ('Capitulary', 'H3', 'cap-collation-user'); ?>
          </h3>

          <?php
          // Form with drop-downs for capitulary and corresp selection.  User
          // selection of a capitulary will AJAX-load the corresps drop-down.  User
          // selection of a corresp or user hitting submit will AJAX-load the list of
          // witnesses into the next form.
          ?>

          <form>
            <div class="form-row">

              <div class="col-sm-6">
                <div class="form-group">
                  <label>
                    <?php _ex ('Select Capitulary', 'Label for select', 'cap-collation-user'); ?>
                  </label>
                  <b-dropdown block :text="bk">
                    <b-dd-item-btn v-for="bk in bks" :key="bk" :data-bk="bk"
                                   @click="on_select_bk">{{ bk }}</b-dd-item-btn>
                  </b-dropdown>
                </div>
              </div>

              <div class="col-sm-6">
                <div class="form-group">
                  <label>
                    <?php _ex ('Select Section', 'Label for select', 'cap-collation-user'); ?>
                  </label>
                  <b-dropdown block :text="corresp">
                    <b-dd-item-btn v-for="s in corresps" :key="s" :data-corresp="s"
                                   @click="on_select_corresp">{{ s }}</b-dd-item-btn>
                  </b-dropdown>
                </div>
              </div>
            </div>

            <!-- Later Hands checkbox -->
            <b-form-checkbox v-model="later_hands" @change="on_later_hands">
              <?php _ex ('Include corrections by different hands', 'Checkbox', 'cap-collation-user'); ?>
            </b-form-checkbox>
          </form>

        </div>
      </div>

      <?php
        // In this section the user can select which witnesses to collate with
        // checkboxes and the order in which the witnesses should collate through
        // drag-and-drop of the table rows.  On user submit the next step will
        // collate the selected witnesses.
      ?>

      <div class="col-md-6 no-print">
        <div class="witnesses-div">
          <h3>
            <?php _ex ('Textual Witnesses', 'H3', 'cap-collation-user'); ?>
          </h3>

          <form>
            <label>
              <?php _ex ('Select Textual Witnesses', 'Label for table', 'cap-collation-user'); ?>
            </label>
            <table class="table table-sm table-bordered witnesses">
              <thead class="thead-light">
                <tr>
                  <th scope="col" class="checkbox">
                    <b-form-checkbox v-model="select_all" v-b-tooltip.hover.left
                           title="<?php _ex ('Select all textual witnesses', 'Checkbox', 'cap-collation-user'); ?>">
                      <?php _ex ('Textual Witness', 'TH', 'cap-collation-user'); ?>
                      <i v-if="spinner" class="spinner fas fa-spin"></i>
                    </b-form-checkbox>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="witnesses.length == 0">
                  <td>
                    <?php _ex ('No textual witnesses found.', 'message in table', 'cap-collation-user'); ?>
                  </td>
                </tr>
                <tr v-for="(w, index) of witnesses" :data-siglum="`${corresp}/${w.siglum}`"
                    :key="w.siglum" :class="row_class (w, index)">
                  <td class="checkbox">
                    <b-form-checkbox v-model="w.checked" v-b-tooltip.hover.left
                           title="<?php
                                  _ex (
                                      'Include this textual witness in the collation.',
                                      'Checkbox',
                                      'cap-collation-user'
                                  );
                                  ?>">
                      {{ w.title }}
                    </b-form-checkbox>
                  </td>
                </tr>
              </tbody>
            </table>
          </form>
        </div>
      </div>
    </div> <!-- class row -->
  </cap-collation-selector>

  <div class="row mt-4 no-print">
    <div class="col-md-6">
      <b-button @click="on_add_section" v-b-tooltip.hover.bottom
                title="<?php _ex ('Add Section', 'Button', 'cap-collation-user'); ?>">
        <i class="plus fas"></i>
      </b-button>

      <label class="btn btn-secondary ml-2 mb-0">
        <?php _ex ('Load Configuration', 'Button', 'cap-collation-user'); ?>
        <input id="load-config" type="file" @change="on_load_config" />
      </label>

      <b-button class="ml-2" @click="on_save_config">
        <?php _ex ('Save Configuration', 'Button', 'cap-collation-user'); ?>
        <a id="save-config-a" href="" download="saved-config.txt"></a>
      </b-button>
    </div>

    <div class="col-md-6">
      <b-button variant="primary" :disabled="collating" @click="on_collate">
        <i class="spinner fas" :class="{ 'fa-spin' : collating }"></i>&nbsp;
        <?php _ex ('Collate', 'Button', 'cap-collation-user'); ?>
      </b-button>
    </div>
  </div> <!-- class row -->

  <?php
        // This finally is the stuff the user actually wants to see.  A set of
        // tables with one row per collated witness, each table representing a
        // collated segment of the witnesses.
        //
        // This section is controlled by a vue.js component in results.js
    ?>

  <div class="row">
    <div class="col-12">
      <cap-collation-results inline-template ref="results" @reordered="on_reordered">
        <div id="vm-collation-results" class="collation-tables">
          <h3>
            <?php _ex ('Collation Results', 'H3', 'cap-collation-user'); ?>
          </h3>
          <table v-for="table of tables"
                 class="table table-sm table-bordered table-striped collation" :class="table.class">
            <tbody>
              <tr v-for="(row, index) of table.rows" class="witness" :class="row_class (row, index)"
                  :data-siglum="row.siglum" :key="row.siglum"
                  @mouseover="hovered = row.siglum" @mouseleave="hovered = null">
                <th class="slim handle no-print" scope="row">
                  <i class="fas"
                    title="<?php _ex (
                        'Drag row to reorder the textual witness.',
                        'title of grip-lines icon',
                        'cap-collation-user'
                    ); ?>"></i>
                </th>
                <th class="title">{{ row.title }}</th>
                <td v-for="cell in row.cells" :class="cell.class">{{ cell.text }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </cap-collation-results>
    </div>
  </div>

</div>

<?php
   return ob_get_clean ();
}
?>
