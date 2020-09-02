/** @module plugins/collation/selector  */

/**
 * @file
 */

import * as tools from 'tools';

/**
 * The vue.js instance that manages the section selector(s).
 * @class module:plugins/collation/selector.VueSelector
 */

Vue.component ('cap-collation-selector', {
    data () {
        return {
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
    'props' : {
        'config' : Object, // a config file section if loaded from config
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
            return ['sortable'];
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
        on_later_hands (event) {
            // click on later hands checkbox
            // it is much easier to implement this by hand than to figure out
            // how to unwatch a variable while programmatically changing it
            // this.later_hands = event.target.checked;
            this.load_witnesses_carry_selection ();
        },
    },
    async mounted () {
        const vm = this;
        await vm.ajax_load_bks ();
    },
    updated () {
        const vm = this;
        const $tbody = $ (vm.$el).find ('table.witnesses tbody');
        $tbody.disableSelection ().sortable ({
            'items'       : 'tr.sortable',
            'handle'      : 'th.handle',
            'axis'        : 'y',
            'cursor'      : 'move',
            'containment' : 'parent',
        });
    },
});
