<template>
<div class="row cap-selector">
  <div class="col-md-6 no-print">
    <div class="collation-bk">
      <h3 v-translate>
        Capitulary
      </h3>

      <!--
          // Form with drop-downs for capitulary and corresp selection.  User
          // selection of a capitulary will AJAX-load the corresps drop-down.  User
          // selection of a corresp or user hitting submit will AJAX-load the list of
          // witnesses into the next form.
        -->

      <form>
        <div class="row mb-3">
          <div class="col-sm-6">
            <label class="form-label" v-translate>Select Capitulary</label>
            <div class="dropdown">
              <button class="btn btn-secondary dropdown-toggle dropdown-toggle-split" type="button"
                      :id="id + '-dd-cap'"
                      data-bs-toggle="dropdown" aria-expanded="false">
                {{ bk }}
              </button>
              <ul class="dropdown-menu" :aria-labelledby="id + '-dd-cap'">
                <li v-for="bki in bks" :key="bki">
                  <button class="dropdown-item" type="button" :data-bk="bki" @click="on_select_bk">
                    {{ bki }}
                  </button>
                </li>
              </ul>
            </div>
          </div>

          <div class="col-sm-6">
            <label class="form-label" v-translate>Select Section</label>
            <div class="dropdown">
              <button class="btn btn-secondary dropdown-toggle dropdown-toggle-split" type="button"
                      :id="id + '-dd-sec'"
                      data-bs-toggle="dropdown" aria-expanded="false">
                {{ corresp }}
              </button>
              <ul class="dropdown-menu" :aria-labelledby="id + '-dd-sec'">
                <li v-for="s in corresps" :key="s">
                  <button class="dropdown-item" type="button" :data-corresp="s" @click="on_select_corresp">
                    {{ s }}
                  </button>
                </li>
              </ul>
            </div>
          </div>
        </div>

        <!-- Later Hands checkbox -->
        <div class="form-check">
            <input class="form-check-input" type="checkbox" value="" :id="id + '-lh'"
                   v-model="later_hands" @change="on_later_hands">
            <label class="form-check-label" :for="id + '-lh'">
              {{ 'Include corrections by different hands' | translate }}
            </label>
          </div>
        </form>
      </div>
    </div>

    <!--
      // In this section the user can select which witnesses to collate with
      // checkboxes and the order in which the witnesses should collate through
      // drag-and-drop of the table rows.  On user submit the next step will
      // collate the selected witnesses.
    -->

    <div class="col-md-6 no-print">
      <div class="witnesses-div">
        <h3 v-translate>
          Textual Witnesses
        </h3>

        <form>
          <label class="form-label" v-translate>Select Textual Witnesses</label>
          <table class="table table-sm table-bordered witnesses">
            <thead class="table-light">
              <tr>
                <th scope="col" class="checkbox">
                  <div class="form-check"
                       data-bs-toggle="tooltip" data-bs-placement="left"
                       :title="$t ('Select all textual witnesses')">
                    <input class="form-check-input" type="checkbox" value="" :id="id + '-all'"
                           v-model="select_all">
                    <label class="form-check-label" :for="id + '-all'">
                      {{ 'Textual Witness' | translate }}
                      <i v-if="spinner" class="spinner fas fa-spin" />
                    </label>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="witnesses.length == 0">
                <td v-translate>
                  No textual witnesses found.
                </td>
              </tr>
              <tr v-for="(w, index) of witnesses" :key="w.siglum"
                  :data-siglum="`${corresp}/${w.siglum}`" :class="row_class (w, index)">
                <td class="checkbox">
                  <div class="form-check"
                       data-bs-toggle="tooltip" data-bs-placement="left"
                       :title="$t ('Include this textual witness in the collation.')">
                    <input class="form-check-input" type="checkbox" value="" :id="id + '-' + w.siglum"
                           v-model="w.checked">
                    <label class="form-check-label" :for="id + '-' + w.siglum">
                      <a :href="w.href">{{ w.title }}</a>
                    </label>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </form>
      </div>
    </div>
  </div> <!-- class row -->
</template>

<script>

/** @module plugins/collation/selector  */

/**
 * @file
 */

import uniqueid from 'lodash';

import * as tools from './tools.js';

/**
 * The vue.js instance that manages the section selector(s).
 * @class module:plugins/collation/selector.VueSelector
 */

export default {
    'props' : {
        'config' : Object, // a config file section if loaded from config
    },
    data () {
        return {
            'id'          : 0,     // a unique id for this component
            'bk'          : '',
            'corresp'     : '',
            'later_hands' : false,
            'witnesses'   : [],    // list of sigla (urls in the form: skara-brae-42?hands=XYZ#2)
            'select_all'  : false,
            'bks'         : [],    // the list of bks shown in the dropdown
            'corresps'    : [],    // the list of corresps shown in the dropdown
            'bk_id'       : tools.bk_id, // id of bk-textzeuge, make it accessible to the template
            'spinner'     : false, // if set true shows a spinner
        };
    },
    'computed' : {
        /** @returns The list of selected sigla in the correct order. */
        'selected' : function () {
            return this.witnesses.filter (w => w.checked).map (w => w.siglum);
        },
    },
    'watch' : {
        config () { this.ajax_load_bks (); },
        select_all (new_value) { this.check_all (new_value); },
    },
    async mounted () {
        const vm = this;
        await vm.ajax_load_bks ();
        this.id = uniqueid ();
    },
    /** @lends module:plugins/collation/front.VueFront.prototype */
    'methods' : {
        /**
         * Load the bk dropdown.  Called once during setup.
         */
        async ajax_load_bks () {
            const vm = this;

            const response = await tools.api ('/data/capitularies.json/');
            // list of { cap_id, title, transcriptions }
            // Do not show Ansegis etc.
            vm.bks = response.filter ((r) => r.cap_id.match (/^BK|^Mordek/)).map ((r) => r.cap_id);
            vm.bk = vm.config.bk || vm.bks[0] || '';

            await vm.ajax_load_corresps (vm.config);
            vm.later_hands = vm.config.later_hands || false;
            await vm.load_witnesses_carry_selection (vm.config);
        },
        /**
         * Load the corresps dropdown.  Called if bk changes.
         */
        async ajax_load_corresps (config = {}) {
            const vm = this;

            const response = await tools.api (`/data/capitulary/${vm.bk}/chapters.json/`);
            // list of { chapter, transcriptions }

            vm.corresps = response.map ((r) => r.cap_id + (r.chapter ? `_${r.chapter}` : ''));
            vm.corresp = config.corresp || vm.corresps[0] || '';
        },
        /**
         * Load the witnesses table.  Called if corresps changes.
         */
        async ajax_load_witnesses () {
            const vm = this;

            vm.spinner = true;
            const response = await tools.api (`/data/corresp/${vm.corresp}/manuscripts.json/`);
            // list of { ms_id, n, type }
            vm.spinner = false;

            vm.witnesses = response.map (tools.parse_witness_response);
            vm.witnesses.sort ((a, b) => a.sort_key.localeCompare (b.sort_key));

            if (!vm.later_hands) {
                vm.witnesses = vm.witnesses.filter (w => { return w.type === 'original'; });
            }

            for (const w of vm.witnesses) {
                if (w.ms_id) {
                    w.href = `/mss/${w.ms_id}/#${w.locus}`;
                }
            }
            tools.update_bs_tooltips ();
        },
        /**
         * Reload the witnesses table while keeping selected items intact (if possible).
         */
        async load_witnesses_carry_selection (config = {}) {
            const vm = this;
            const selected = vm.selected.slice ();
            vm.select_all = false;

            await vm.ajax_load_witnesses ();
            vm.check_these (config.witnesses || selected);
        },
        /**
         * Check or uncheck all witnesses.
         */
        check_all (val) {
            this.witnesses.map (w => {
                w.checked = val;
                return w;
            });
        },
        /**
         * Check all witnesses in list but don't uncheck any.
         */
        check_these (sigla) {
            this.witnesses.map (w => {
                if (sigla.includes (w.siglum)) {
                    w.checked = true;
                }
                return w;
            });
        },
        /**
         * The class(es) to apply to the witnesses table rows.
         */
        row_class (dummy_w, dummy_index) {
            return [];
        },
        /*
         * User Interface handlers
         */
        async on_select_bk (event) {
            // click on button in dropdown
            const vm = this;
            vm.bk = event.target.getAttribute ('data-bk');
            await vm.ajax_load_corresps ();
            await vm.load_witnesses_carry_selection ();
        },
        on_select_corresp (event) {
            // click on button in dropdown
            this.corresp = event.target.getAttribute ('data-corresp');
            this.load_witnesses_carry_selection ();
        },
        on_later_hands () {
            // click on later hands checkbox
            // it is much easier to implement this by hand than to figure out
            // how to unwatch a variable while programmatically changing it
            // this.later_hands = event.target.checked;
            this.load_witnesses_carry_selection ();
        },
    },
};
</script>

<style lang="scss">
/* selector.vue */

button.dropdown-toggle {
    text-align: left;
    width: 100%;
}

.dropdown-menu {
    width: 100%;
    max-height: 500px;
    overflow-y: scroll;
}

table.witnesses {
    th,
    td {
        &.checkbox {
            padding-left: 0.5rem;
        }
    }
}
</style>
