/** @module plugins/collation/front */

import 'selector';
import 'results';

/**
 * We use webpack as a workaround to load javascript modules in Wordpress.
 * Wordpress cannot load javascript modules thru enqueue_script () because it
 * lacks an option to specify type="module" on the <script> element.  Webpack
 * also packs babel-runtime for us.  babel-runtime is required for async
 * functions.

 * @file
 */

// TODO: webpack hot-reloading?

/**
 * The vue.js instance that manages the whole page.
 * @class module:plugins/collation/front.VueFront
 */
const app = new Vue ({
    data () {
        return {
            'sections'  : [{}],
            'collating' : false,
        };
    },
    /** @lends module:plugins/collation/front.VueFront.prototype */
    'methods' : {
        /**
         * Bundle all parameters for on_collate () and on_save_config ().
         *
         * @returns {Object} The parameters for the collate REST API call.
         */
        ajax_params () {
            return {
                'collate' : this.$refs.selector.map (sel => {
                    const data = _.pick (
                        sel.$data,
                        'bk', 'corresp', 'later_hands',
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
            p.always (() => { vm.collating = false; });
        },
        /**
         * Load configuration from a user-local file.  Called from the
         * file dialog ok button.
         */
        on_load_config (event) {
            const vm = this;
            const file_input = event.target;
            const files = file_input.files;
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
            const url = 'data:text/plain,' + encodeURIComponent (JSON.stringify (params, null, 2));
            const b = document.getElementById ('save-config-a');
            b.setAttribute ('href', url);
            b.click ();
        },
        on_add_section () {
            // add an unconfigured section
            this.sections.push ({});
        },
        on_reordered (dummy_new_order) {
            // the user reordered the witnesses in the results table
        },
    },
});

document.addEventListener ('DOMContentLoaded', function () {
    app.$mount ('#vm-cap-collation-user');
});
