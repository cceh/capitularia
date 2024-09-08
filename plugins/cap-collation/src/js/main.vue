<template>
  <div class="cap-collation">
    <cap-collation-selector
      v-for="(section, index) in sections"
      :ref="set_selector_ref" :key="index" :config="section" />

    <div class="row mt-4 no-print">
      <div class="col-md-6 hstack gap-2">
        <button type="button" class="btn btn-secondary"
                data-bs-toggle="tooltip" data-bs-placement="bottom" :title="$t ('Add Section')"
                @click="on_add_section">
          <i class="plus fas" />
        </button>

        <label class="btn btn-secondary ms-auto">
          {{ $t ('Load Configuration') }}
          <input id="load-config" type="file" @change="on_load_config">
        </label>

        <button type="button" class="btn btn-secondary"
                @click="on_save_config">
          {{ $t ('Save Configuration') }}
          <a id="save-config-a" href="" download="saved-config.txt" />
        </button>
      </div>

      <div class="col-md-6">
        <button type="button" class="btn btn-primary"
                :disabled="collating"
                @click="on_collate">
          <i class="spinner fas" :class="{ 'fa-spin' : collating }" />&nbsp;
          {{ $t ('Collate') }}
        </button>
      </div>
    </div> <!-- class row -->

    <!--
          // This finally is the stuff the user actually wants to see.  A set of
          // tables with one row per collated witness, each table representing a
          // collated segment of the witnesses.
          //
          // This section is controlled by a vue.js component in results.js
    -->

    <div class="row">
      <div class="col-12">
        <cap-collation-results ref="results" />
      </div>
    </div>
  </div>
</template>

<script>

/** @module plugins/cap-collation/main */

import { pick } from 'lodash';

import Selector from './selector.vue';
import Results  from './results.vue';

import * as tools from './tools.js';

/**
 * The vue.js instance that manages the whole page.
 * @class Main
 */
export default {
    'name'       : 'capCollationMain',
    'components' : {
        'cap-collation-selector' : Selector,
        'cap-collation-results'  : Results,
    },
    data () {
        return {
            'sections'  : [{}],
            'collating' : false,
            'selectors' : [],
        };
    },
    mounted () {
        tools.update_bs_tooltips ();
    },
    beforeUpdate () {
        this.selectors = [];
    },
    /** @lends Main */
    'methods' : {
        /**
         * Bundle all parameters for on_collate () and on_save_config ().
         *
         * @returns {Object} The parameters for the collate REST API call.
         */
        ajax_params () {
            return {
                'collate' : this.selectors.map ((sel) => {
                    const data = pick (
                        sel.$data,
                        'bk',
                        'corresp',
                        'later_hands'
                    );
                    data.witnesses = sel.selected;
                    return data;
                }),
            };
        },
        on_collate () {
            // click on collate button
            const vm = this;
            vm.collating = true;
            const p = this.$refs.results.collate (this.ajax_params ());
            p.finally (() => { vm.collating = false; });
        },
        set_selector_ref (el) {
            if (el) {
                this.selectors.push (el);
            }
        },
        /**
         * Load configuration from a user-local file.  Called from the
         * file dialog ok button.
         */
        on_load_config (event) {
            const vm = this;
            const file_input = event.target;
            const { files } = file_input;
            if (files.length === 1) {
                const reader = new FileReader ();
                reader.onload = async function (e) {
                    const json = JSON.parse (e.target.result);
                    vm.sections = json.collate;
                };
                reader.readAsText (files[0]);
            }
            file_input.value = null;  // make it fire again even on the same file
            return false; // don't submit form
        },
        /**
         * Save parameters to a user-local file.  Initialize a hidden <a> with a
         * download link and fake a click on it.
         */
        on_save_config () {
            const params = this.ajax_params ();
            const url = `data:text/plain,${encodeURIComponent (JSON.stringify (params, null, 2))}`;
            const b = document.getElementById ('save-config-a');
            b.setAttribute ('href', url);
            b.click ();
        },
        on_add_section () {
            // add an unconfigured section
            this.sections.push ({});
        },
    },
};

</script>

<style lang="scss">
/* main.vue */

div.cap-collation {
    h2 {
        @media print {
            display: none !important;
        }
    }

    h3 {
        margin-top: 1em;
        margin-bottom: 1em;
    }

    @media print {
        .no-print {
            display: none !important;
        }

        #wpcontent,
        #wpfooter {
            margin-left: 0;
        }

        html,
        body {
            background-color: white;
            font-size: 10pt;
        }
    }

    /* hide the 'Choose File' button */
    #load-config, #save-config {
        position: absolute;
        top: 0;
        visibility: hidden;
        z-index: -1;
    }

    .plus {
        &::before {
            content: '\f055'; /* fa-plus-circle */
        }
    }

    .spinner {
        &::before {
            content: '\f013'; /* fa-cog */
        }
    }
}
</style>
