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
              <label v-translate class="form-label">Select Capitulary</label>
              <div class="dropdown">
                <button :id="id + '-dd-cap'" class="btn btn-secondary dropdown-toggle"
                        type="button"
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
              <label v-translate class="form-label">Select Section</label>
              <div class="dropdown">
                <button :id="id + '-dd-sec'" class="btn btn-secondary dropdown-toggle"
                        type="button"
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
            <input :id="id + '-lh'" v-model="later_hands" class="form-check-input" type="checkbox"
                   value="" @change="on_later_hands">
            <label v-translate class="form-check-label" :for="id + '-lh'">
                Include corrections by different hands
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
          <label v-translate class="form-label">Select Textual Witnesses</label>
          <table class="table table-sm table-bordered witnesses">
            <thead class="table-light">
              <tr>
                <th scope="col" class="checkbox">
                  <div class="form-check"
                       data-bs-toggle="tooltip" data-bs-placement="left"
                       :title="$t ('Select all textual witnesses')">
                    <input :id="id + '-all'" v-model="select_all" class="form-check-input" type="checkbox"
                           value="">
                    <label class="form-check-label" :for="id + '-all'">
                      {{ $t ('Textual Witness') }}
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
              <tr v-for="(w, index) of witnesses" :key="w.url"
                  :data-url="`${corresp}/${w.url}`" :class="row_class (w, index)">
                <td class="checkbox">
                  <div class="form-check"
                       data-bs-toggle="tooltip" data-bs-placement="left"
                       :title="$t ('Include this textual witness in the collation.')">
                    <input :id="id + '-' + w.url" v-model="w.checked" class="form-check-input" type="checkbox"
                           value="">
                    <label class="form-check-label" :for="id + '-' + w.url">
                      <a :href="w.href">{{ w.short_title }}</a>
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

/** @module plugins/cap-collation/selector */

import { uniqueId } from 'lodash';

import * as tools from './tools.js';

/**
 * The vue.js instance that manages the section selector(s).
 * @class Selector
 */

export default {
    'name'  : 'capCollationSelector',
    'props' : {
        'config' : {
            'type'    : Object, // a config file section if loaded from config
            'default' : {},
        },
    },
    data () {
        return {
            'id'          : 0,     // a unique id for this component
            'bk'          : '',
            'corresp'     : '',
            'later_hands' : false,
            'witnesses'   : [],    // list of items (urls in the form: skara-brae-42?siglum=SB1&hands=XYZ#2)
            'select_all'  : false,
            'bks'         : [],    // the list of bks shown in the dropdown
            'corresps'    : [],    // the list of corresps shown in the dropdown
            'bk_id'       : tools.bk_id, // id of bk-textzeuge, make it accessible to the template
            'spinner'     : false, // if set true shows a spinner
        };
    },
    'computed' : {
        /** @returns The list of selected items in the correct order. */
        'selected' : function () {
            return this.witnesses.filter ((w) => w.checked).map ((w) => w.url);
        },
    },
    'watch' : {
        config () { this.ajax_load_bks (); },
        select_all (new_value) { this.check_all (new_value); },
    },
    async mounted () {
        const vm = this;
        vm.id = `selector_${uniqueId ()}`;
        await vm.ajax_load_bks ();
    },
    /** @lends Selector */
    'methods' : {
        /**
         * Load the bk dropdown.  Called once during setup.
         */
        async ajax_load_bks () {
            const vm = this;

            const response = await tools.api ('/data/capitularies.json/');
            // list of { cap_id, title, transcriptions }
            // Do not show Ansegis etc.
            vm.bks = response.data
                .filter ((r) => r.cap_id.match (/^BK|^Mordek|^Benedictus\.Levita\.1\.279/))
                .map ((r) => r.cap_id);
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

            vm.corresps = response.data.map ((r) => r.cap_id + (r.chapter ? `_${r.chapter}` : ''));
            vm.corresp = config.corresp || vm.corresps[0] || '';
        },
        /**
         * Load the witnesses table.  Called if corresps changes.
         */
        async ajax_load_witnesses () {
            const vm = this;

            vm.spinner = true;
            const response = await tools.api (`/data/corresp/${vm.corresp}/manuscripts.json/`);
            // list of { ms_id, siglum, n, type }
            vm.spinner = false;

            vm.witnesses = response.data.map ((w) => { w.corresp = vm.corresp; return w; });
            vm.witnesses = vm.witnesses.map (tools.fix_witness);
            vm.witnesses.sort ((a, b) => a.sort_key.localeCompare (b.sort_key));

            if (!vm.later_hands) {
                vm.witnesses = vm.witnesses.filter ((w) => w.type === 'original');
            }

            for (const w of vm.witnesses) {
                w.url = tools.build_witness_url (w);
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
            this.witnesses.map ((w) => {
                w.checked = val;
                return w;
            });
        },
        /**
         * Check all witnesses in list but don't uncheck any.
         */
        check_these (items) {
            this.witnesses.map ((w) => {
                if (items.includes (w.url)) {
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
