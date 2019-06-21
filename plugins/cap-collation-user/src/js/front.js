'use strict';

/** cap_collation_user_front_ajax_object is set by wp_localize_script in function.php. */
/* global cap_collation_user_front_ajax_object */

(function ($) {
    /** The id of the "Obertext". */
    const bk_id = '_bk-textzeuge';

    /**
     * The collation algorithms we support.  The Needleman-Wunsch-Gotoh algorithm
     * is available only with our special patched version of CollateX.
     */
    const cap_collation_algorithms = [
        { 'key' : 'dekker',                 'name' : 'Dekker' },
        { 'key' : 'gst',                    'name' : 'Greedy String Tiling' },
        { 'key' : 'medite',                 'name' : 'MEDITE' },
        { 'key' : 'needleman-wunsch',       'name' : 'Needleman-Wunsch' },
        { 'key' : 'needleman-wunsch-gotoh', 'name' : 'Needleman-Wunsch-Gotoh' },
    ];

    /**
     * Encapsulate AJAX functionality
     */
    function ajax (action, data) {
        data.action = 'on_cap_collation_user_' + action;
        // add the nonce
        $.extend (data, cap_collation_user_front_ajax_object);
        return $.ajax ({
            'method' : 'POST',
            'url'    : cap_collation_user_front_ajax_object.ajaxurl,
            'data'   : data,
        });
        return p;
    }

    /**
     * Build a valid filename to save the config.
     */
    function encodeRFC5987ValueChars (str) {
        return encodeURIComponent (str)
        // Note that although RFC3986 reserves '!', RFC5987 does not,
        // so we do not need to escape it
            .replace (/['()]/g, escape) // i.e., %27 %28 %29
            .replace (/\*/g, '%2A')
        // The following are not required for percent-encoding per RFC5987,
        // so we can allow for a little better readability over the wire: |`^
            .replace (/%(?:7C|60|5E)/g, unescape);
    }

    /* The vue.js instance for the witness selection section. */
    Vue.component ('cap-collation-user-witnesses', {
        'props' : ['corresp', 'later_hands', 'order'],
        'data' : function () {
            return {
                'witnesses'  : [],     // list of all { siglum, title, checked } in order
                'pre_select' : [],     // list of sigla set by on_load_config
                'spinner'    : false,
                'select_all' : false,
                'bk_id'      : bk_id,
            }
        },
        'computed' : {
            'selected' : function () { return this.get_selected (); },
        },
        'watch' : {
            /* props */
            'corresp'     : function ()      { this.ajax_load_witnesses (); },
            'later_hands' : function ()      { this.ajax_load_witnesses (); },
            'order'       : function (order) { this.sort_like (order); },
            /* own authority */
            'select_all'  : function (val) { this.check_all (val); },
        },
        'methods' : {
            ajax_load_witnesses () {
                const data = this.$parent.ajax_params ();
                const vm = this;
                const pre_select = vm.pre_select;
                vm.spinner = true;
                vm.select_all = false;

                ajax ('load_witnesses', data).done (function (response) {
                    vm.witnesses  = response.witnesses;
                    vm.check_all (false);
                    vm.check_these (pre_select);
                    vm.pre_select = [];
                    vm.$emit ('reordered', vm.get_sigla ());
                }).always (function () {
                    vm.spinner = false;
                });
            },
            ajax_params () {
                return { 'selected' : this.get_selected () };
            },
            /**
             * Return the sigla of the loaded witnesses
             *
             * @returns List of sigla
             */
            get_sigla () {
                return this.witnesses.map (e => e.siglum);
            },
            /**
             * Return the sigla of the currently checked witnesses in the
             * correct order
             *
             * @returns List of sigla
             */
            get_selected () {
                return this.witnesses.filter (w => w.checked).map (w => w.siglum);
            },
            /**
             * Check all boxes in list but don't uncheck any.
             */
            check_these (sigla) {
                this.witnesses.map (w => { if (sigla.includes (w.siglum)) { w.checked = true; }} );
            },
            /**
             * Check or uncheck all boxes but never uncheck BK.
             */
            check_all (val) {
                this.witnesses.map (w => { w.checked = (val || w.siglum == bk_id) } );
            },
            /**
             * Sort the sigla in list to the top of the table.
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
             * The class(es) to apply to the table rows.
             */
            row_class (w, index) {
                const cls = [];
                if (w.siglum != bk_id) {
                    cls.push ('sortable');
                }
                return cls;
            },
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
                    vm.$emit ('reordered', vm.get_sigla ());
                },
            });
        },
    });

    /* The vue.js instance for the collation output section. */
    Vue.component ('cap-collation-user-results', {
        'props' : ['corresp', 'order'],
        'data' : function () {
            return {
                'witnesses' : {
                    'metadata' : [],
                    'table'    : [],
                },
                'unsorted_tables' : [],
                'tables'          : [],
                'hovered'         : null,  // siglum of hovered witness
                'spinner'         : false,
            }
        },
        'watch' : {
            'witnesses' : {
                'deep'    : true,
                'handler' : function (newVal) {
                    this.update_tables (newVal);
                    this.sort_like (this.order);
                },
            },
            'order' : function (newVal) {
                this.sort_like (newVal);
            },
            'corresp' : function () {
                this.unsorted_tables = [];
            },
        },
        'methods' : {
            collate () {
                const vm   = this;
                const data = this.$parent.ajax_params ();

                vm.spinner = true;

                const p = ajax ('load_collation', data);
                $.when (p).done (function () {
                    vm.witnesses = p.responseJSON.witnesses;
                }).always (function () {
                    vm.spinner   = false;
                });
            },
            /**
             * Transpose a table returned by CollateX
             *
             * Turn rows into columns and vice versa.
             *
             * @param array matrix The CollateX table
             *
             * @return array
             */

            transpose (matrix) {
                return _.zip (...matrix);
            },

            /**
             * Calculate the cell width in characters
             *
             * @param array $cell The array of tokens in the cell
             *
             * @return integer The width in characters
             */

            cell_width (cell) {
                const tokens = cell.map (token => token.t.trim ());
                return tokens.join (' ').length;
            },

            /**
             * Split a table in columns every n characters
             *
             * @param array   $in_table  The table to split
             * @param integer $max_width Split after this many characters
             *
             * @return array An array of tables
             */

            split_table (table, max_width) {
                const out_tables = [];
                let tmp_table = [];
                let width = 0;

                for (const column of table) {
                    const column_width = 2 + Math.max (... column.map (cell => this.cell_width (cell)));
                    if (width + column_width > max_width) {
                        // start a new table
                        out_tables.push (tmp_table.slice ());
                        tmp_table = [];
                        width = 0;
                    }
                    tmp_table.push (column);
                    width += column_width;
                }
                if (tmp_table.length > 0) {
                    out_tables.push (tmp_table);
                }
                return out_tables;
            },

            /**
             * Format a CollateX table into HTML
             *
             * @param string[] sigla The witnesses' sigla in table order
             * @param array    table The collation table in column-major orientation
             * @param string[] order The witnesses' sigla in the order they should be displayed
             *
             * @return string[] The rows of the formatted table
             *
             * @return void
             *
             * The Collate-X response:
             *
             * {
             *   "witnesses":["A","B"],
             *   "table":[
             *     [ [ {"t":"A","ref":123 } ],      [ {"t":"A" } ] ],
             *     [ [ {"t":"black","adj":true } ], [ {"t":"white","adj":true } ] ],
             *     [ [ {"t":"cat","id":"xyz" } ],   [ {"t":"kitten.","n":"cat" } ] ]
             *   ]
             * }
             */

            format_table (witnesses, table, order) {
                if (order.length === 0) {
                    return  [];
                }
                const sigla  = witnesses.map (ms => ms.siglum);
                const titles = witnesses.map (ms => ms.title);
                const out_table = {
                    'class' : '',
                    'rows'  : [],
                };
                let is_master = true;

                // first witness is the master text
                const master_text = table[sigla.indexOf (order[0])];

                // ouput the witnesses in the correct order
                for (const siglum of order) {
                    const index = sigla.indexOf (siglum);
                    if (index === -1) {
                        continue; // user messed with mss. list but didn't start another collation
                    }
                    const row = {
                        'siglum' : siglum,
                        'title'  : titles[index],
                        'class'  : '',
                        'cells'  : [],
                    };
                    const ms_text = table[index];

                    for (const [ms_set, master_set] of _.zip (ms_text, master_text)) {
                        let class_ = 'tokens';
                        const master = master_set.map (token => token.t).join (' ').trim ();
                        const text   = ms_set.map     (token => token.t).join (' ').trim ();
                        if (!is_master && (master.toLowerCase () === text.toLowerCase ())) {
                            class_ += ' equal';
                        }
                        if (text === '') {
                            class_ += ' missing';
                        }
                        row.cells.push ({ 'class' : class_, 'text' : text });
                    }
                    out_table.rows.push (row);
                    is_master = false;
                }
                return out_table;
            },

            update_tables (witnesses) {
                const max_width = 120 - Math.max (... witnesses.metadata.map (ms => ms.title.length));
                this.unsorted_tables = this
                    .split_table (witnesses.table, max_width)
                    .map (table => this.transpose (table));
            },

            sort_like (order) {
                this.tables = this.unsorted_tables.map (table => this.format_table (
                    this.witnesses.metadata,
                    table,
                    order
                ));
                if (this.tables.length > 0) {
                    this.tables[0].class = 'first';
                    this.tables[this.tables.length - 1].class = 'last';
                }
            },

            get_sigla (item) {
                // Get the sigla of all witnesses to collate in user-specified order
                return $ (item).closest ('table').find ('tr[data-siglum]').map (function () {
                    return $ (this).attr ('data-siglum');
                })
                    .get ();
            },
            row_class (row, index) {
                const cls = [];
                if (row.siglum != bk_id) {
                    cls.push ('sortable');
                }
                if (this.hovered === row.siglum) {
                    cls.push ('highlight-witness');
                }
                return cls;
            },
        },
        mounted () {
        },
        updated () {
            const vm = this;
            const $tbodies = $ (this.$el).find ('table.collation tbody');
            $tbodies.disableSelection ().sortable ({
                'items'       : 'tr.sortable',
                'handle'      : 'th.handle',
                'axis'        : 'y',
                'cursor'      : 'move',
                'containment' : 'parent',
                'update'      : function (event, ui) {
                    vm.$emit ('reordered', vm.get_sigla (ui.item));
                },
            });
        },
    });

    $ (document).ready (function () {
        /* The vue.js instance for the whole page. */
        new Vue ({
            'el'   : '#vm-cap-collation-user',
            'data' : {
                'bk'          : '',
                'corresp'     : '',
                'later_hands' : false,
                'order'       : [],     // list of sigla in correct order

                'bks'         : [],
                'corresps'    : [],
                'advanced'    : false, // don't show advanced options menu

                'algorithm'            : cap_collation_algorithms[cap_collation_algorithms.length - 1],
                'levenshtein_distance' : 0,
                'levenshtein_ratio'    : 1.0,
                'segmentation'         : false,
                'transpositions'       : false,
                'normalizations'       : '',

                'algorithms'            : cap_collation_algorithms,
                'levenshtein_distances' : [0, 1, 2, 3, 4, 5],
                'levenshtein_ratios'    : [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1],
            },
            'watch' : {
                'bk' : function () {
                    this.ajax_load_corresps ();
                },
            },
            'methods' : {
                /**
                 * Load the bk dropdown.  Called once during setup.
                 */
                ajax_load_bks () {
                    const vm = this;
                    ajax ('load_bks', {}).done (function (response) {
                        vm.bks = response.bks;
                        vm.bk  = vm.bks[0] || '';
                    });
                },
                ajax_load_corresps () {
                    const vm = this;
                    const data = this.ajax_params ();
                    const corresp = vm.corresp;

                    ajax ('load_corresps', data).done (function (response) {
                        vm.corresps = response.corresps;
                        // set a default corresp if corresp is not in corresps
                        // in on_load_config () corresp will be set before corresps arrive
                        if (!vm.corresps.includes (corresp)) {
                            vm.corresp  = vm.corresps[0] || '';
                        }
                    });
                },
                /**
                 * Bundle all useful params for ajax calls and save config.
                 */
                ajax_params () {
                    const data = _.pick (this.$data,
                                         'bk', 'corresp', 'later_hands',
                                         'levenshtein_distance', 'levenshtein_ratio',
                                         'segmentation', 'transpositions'
                                        );
                    data.algorithm      = this.algorithm.key;
                    data.normalizations = this.normalizations.split ('\n');
                    return $.extend (data, this.$refs.witnesses.ajax_params ());
                },

                on_select_bk (event) {
                    // click on button in dropdown
                    this.bk = $ (event.target).attr ('data-bk');
                },
                on_select_corresp (event) {
                    // click on button in dropdown
                    this.corresp = $ (event.target).attr ('data-corresp');
                },
                on_algorithm (event) {
                    const index = $ (event.target).attr ('data-index');
                    this.algorithm = this.algorithms[index];
                },
                on_ld (event) {
                    this.levenshtein_distance = $ (event.target).attr ('data-ld');
                },
                on_lr (event) {
                    this.levenshtein_ratio = $ (event.target).attr ('data-lr');
                },
                on_reordered (new_order) {
                    this.order = new_order;
                },
                on_collate () {
                    this.$refs.results.collate ();
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
                        reader.onload = function (e) {
                            const json = JSON.parse (e.target.result);

                            vm.bk             = json.bk;
                            vm.corresp        = json.corresp;
                            vm.later_hands    = json.later_hands;
                            vm.segmentation   = json.segmentation;
                            vm.transpositions = json.transpositions;

                            $ ('#algorithm').val (json.algorithm);
                            $ ('#levenshtein_distance').val (json.levenshtein_distance);
                            $ ('#levenshtein_ratio').val (json.levenshtein_ratio);
                            $ ('#normalizations').val (json.normalizations.join ('\n'));

                            const vmw = vm.$refs.witnesses;
                            vmw.pre_select = json.selected || [];
                            vmw.ajax_load_witnesses ();
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
                        'download' : 'save-' + encodeRFC5987ValueChars (params.corresp.toLowerCase ()) + '.txt',
                    });
                    $e[0].click (); // trigger doesn't work
                },
            },
            mounted () {
                this.ajax_load_bks ();
            },
        })
    });

} (jQuery));
