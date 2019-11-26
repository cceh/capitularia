import * as tools from 'tools';
import 'results';

/*
 * We use webpack as a workaround to load javascript modules in Wordpress.
 * Wordpress cannot load javascript modules thru enqueue_script () because it
 * lacks an option to specify type="module" on the <script> element.  Webpack
 * also packs babel-runtime for us.  babel-runtime is required for async
 * functions.
 */

// TODO: webpack hot-reloading?

(function ($) {
    $ (document).ready (function () {
        /* The vue.js instance for the whole page. */
        new Vue ({
            'el'   : '#vm-cap-collation-user',
            'data' : {
                'bk'          : '',
                'corresp'     : '',
                'later_hands' : false,
                'witnesses'   : [],    // list of sigla (urls in the form: skara-brae-42?hands=XYZ#2)
                'select_all'  : false,
                'pre_select'  : null,  // list of witnesses to select after next ajax load
                'bks'         : [],    // the list of bks shown in the dropdown
                'corresps'    : [],    // the list of corresps shown in the dropdown
                'advanced'    : false, // don't show advanced options menu
                'bk_id'       : tools.bk_id, // make it known to the template
                'spinner'     : false, // if set true shows a spinner
                'collating'   : false,

                'algorithm'            : tools.cap_collation_algorithms[tools.cap_collation_algorithms.length - 1],
                'levenshtein_distance' : 0,
                'levenshtein_ratio'    : 1.0,
                'segmentation'         : false,
                'joined'               : false, // same as segmentation?
                'transpositions'       : false,
                'normalizations'       : '',

                'algorithms'            : tools.cap_collation_algorithms,
                'levenshtein_distances' : [0, 1, 2, 3, 4, 5],
                'levenshtein_ratios'    : [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1],
            },
            'computed' : {
                // list of shown sigla in correct order
                'sigla' : function () {
                    return this.witnesses.map (w => w.siglum);
                },
                // list of selected sigla in correct order
                'selected' : function () {
                    return this.witnesses.filter (w => w.checked).map (w => w.siglum);
                },
            },
            'methods' : {
                /**
                 * Bundle all parameters for collate () and on_save_config ().
                 */
                ajax_params () {
                    const data = _.pick (
                        this.$data,
                        'bk', 'corresp', 'later_hands',
                        'levenshtein_distance', 'levenshtein_ratio',
                        'joined', 'segmentation', 'transpositions'
                    );
                    data.algorithm      = this.algorithm.key;
                    data.normalizations = this.normalizations.split ('\n');
                    data.witnesses      = this.selected;
                    return data;
                },
                /**
                 * Load the bk dropdown.  Called once during setup.
                 */
                async ajax_load_bks () {
                    const vm = this;

                    const response = await tools.api ('/data/capitularies.json/');
                    // list of { cap_id, transcriptions }
                    vm.bks = [];
                    for (const r of response) {
                        // Only include capitulars with at least 2
                        // transcriptions so we have something to collate.  Only
                        // include BK and Mordek.
                        if (r.transcriptions >= 2 && r.cap_id.match (/^BK|^Mordek/)) {
                            vm.bks.push (r.cap_id);
                        }
                    }
                    vm.bk = vm.bks[0] || '';

                    await vm.ajax_load_corresps ();
                    await vm.load_witnesses_carry_selection ();
                },
                /**
                 * Load the corresps dropdown.  Called if bk changes.
                 */
                async ajax_load_corresps () {
                    const vm = this;

                    const response = await tools.api (`/data/capitulary/${vm.bk}/chapters.json/`);
                    // list of { chapter, transcriptions }

                    vm.corresps = [];
                    for (const r of response) {
                        // Only include chapters with at least 2 transcriptions
                        // so we have something to collate.
                        if (r.transcriptions >= 2) {
                            vm.corresps.push (r.cap_id + (r.chapter ? `_${r.chapter}` : ''));
                        }
                    }

                    // set a default corresp if corresp is not in corresps
                    // in on_load_config () corresp will be set before corresps arrive
                    if (!vm.corresps.includes (vm.corresp)) {
                        vm.corresp  = vm.corresps[0] || '';
                    }
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
                        vm.witnesses = vm.witnesses.filter (w => { return w.type === 'original' });
                    }
                },
                /**
                 * Reload the witnesses table while keeping selected items intact (if possible).
                 */
                async load_witnesses_carry_selection () {
                    const vm = this;
                    const selected = vm.selected.slice ();

                    await vm.ajax_load_witnesses ();
                    vm.select_all = false;
                    vm.check_all (false);
                    vm.check_these (selected);
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
                 * Sort the witnesses in the list to the top of the table.
                 *
                 * @param sigla   List of sigla of the witnesses
                 */
                sort_like (sigla) {
                    const vm = this;
                    let elems = [];
                    for (const siglum of sigla) {
                        const index = vm.witnesses.findIndex (e => e.siglum === siglum);
                        if (index !== -1) { // found
                            elems = elems.concat (vm.witnesses.splice (index, 1));
                        }
                    }
                    vm.witnesses.unshift (... elems);
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
                    // much easier to implement this by hand than to figure out
                    // the vue.js timing of watched variables
                    this.later_hands = event.target.checked;
                    this.load_witnesses_carry_selection ();
                },
                on_select_all (event) {
                    // click on select all checkbox
                    // much easier to implement this by hand than to figure out
                    // the vue.js timing of watched variables
                    this.check_all (event.target.checked);
                },
                on_algorithm (event) {
                    // user selected algorithm
                    this.algorithm = this.algorithms[event.target.getAttribute ('data-index')];
                },
                on_ld (event) {
                    this.levenshtein_distance = event.target.getAttribute ('data-ld');
                },
                on_lr (event) {
                    this.levenshtein_ratio = event.target.getAttribute ('data-lr');
                },
                on_reordered (new_order) {
                    // the user reordered the witnesses in the results table
                    this.sort_like (new_order);
                    this.$refs.results.sort_like (new_order);
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

                            vm.bk             = json.bk;
                            vm.corresp        = json.corresp;
                            vm.later_hands    = json.later_hands;
                            vm.segmentation   = json.segmentation;
                            vm.joined         = json.joined || false;
                            vm.transpositions = json.transpositions;

                            $ ('#algorithm').val (json.algorithm);
                            $ ('#levenshtein_distance').val (json.levenshtein_distance);
                            $ ('#levenshtein_ratio').val (json.levenshtein_ratio);
                            $ ('#normalizations').val (json.normalizations.join ('\n'));

                            await vm.ajax_load_corresps ();
                            await vm.ajax_load_witnesses ();
                            vm.select_all = false;
                            vm.check_all (false);
                            vm.check_these (json.selected || []);

                            vm.on_collate ();
                        };
                        reader.readAsText (files[0]);
                    }
                    file_input.value = null;  // make it fire again even on the same file
                    return false; // don't submit form
                },
                /**
                 * Redirect click so we can use a normal bootstrap button.  The button
                 * type=file is not styleable.
                 */
                on_load_config_redirect (/* event */) {
                    $ ('#load-config').click ();
                },
                /**
                 * Save parameters to a user-local file.  Initialize a hidden <a> with a
                 * download link and fake a click on it.
                 */
                on_save_config () {
                    const params = this.ajax_params ();
                    const url = 'data:text/plain,' + encodeURIComponent (JSON.stringify (params, null, 2));
                    const $e = $ ('#save-fake-download');
                    $e.attr ({
                        'href'     : url,
                        'download' : 'save-' + tools.encodeRFC5987ValueChars (params.corresp.toLowerCase ()) + '.txt',
                    });
                    $e[0].click (); // trigger doesn't work
                },
            },
            mounted () {
                this.ajax_load_bks ();
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
                    'update'      : function (/* event, ui */) {
                        const new_order = $tbody.find ('tr[data-siglum]').map (function () {
                            return $ (this).attr ('data-siglum');
                        }).get ();
                        vm.sort_like (new_order);
                        vm.$refs.results.sort_like (new_order);
                    },
                });
            },
        });
    });
} (jQuery));
