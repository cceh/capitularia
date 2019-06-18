'use strict';

(function ($) {
    const ajaxurl = cap_collation_user_front_ajax_object.ajaxurl;

    let cap_vue = null;
    let mss_vue = null;
    let coll_vue = null;

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

    function add_ajax_action (data, action) {
        data.action = action;
        $.extend (data, cap_collation_user_front_ajax_object); // eslint-disable-line no-undef
        return data;
    }

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

    function handle_message (div, response) {
        if (response) {
            const msg = $ (response.message).hide ().prependTo (div);
            msg.fadeIn ();
            /* Adds a 'dismiss this notice' button. */
            $ (document).trigger ('wp-plugin-update-error');
        }
    }

    $ (document).ready (function () {
        /* The vue.js instance for the capitulary selection section. */

        cap_vue = new Vue ({
            'el'   : '#collation-bk',
            'data' : {
                'bk'          : '',
                'bks'         : [],
                'corresp'     : '',
                'corresps'    : [],
                'later_hands' : false,
                'all_copies'  : false,
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
                    this.load_corresps ();
                },
                'corresp' : function () {
                    this.load_manuscripts ();
                },
                'later_hands' : function () {
                    this.load_manuscripts ();
                },
                'all_copies' : function () {
                    this.load_manuscripts ();
                },
            },
            'methods' : {
                get_corresps_params () {
                    return _.pick (this.$data, 'bk');
                },
                get_manuscripts_params () {
                    return _.pick (this.$data, 'bk', 'corresp', 'later_hands', 'all_copies');
                },
                get_collation_params () {
                    const data = _.pick (
                        this.$data, 'levenshtein_distance', 'levenshtein_ratio',
                        'segmentation', 'transpositions'
                    );
                    data.algorithm      = this.algorithm.key;
                    data.normalizations = this.normalizations.split ('\n');
                    return data;
                },
                load_bks () {
                    const vm = this;

                    $.ajax ({
                        'method' : 'POST',
                        'url'    : ajaxurl,
                        'data'   : add_ajax_action ({}, 'on_cap_collation_user_load_bks'),
                    }).done (function (response) {
                        vm.bks = response.bks;
                        if (!vm.bk && vm.bks.length) {
                            vm.bk = vm.bks[0];
                        }
                    });
                },
                on_load_corresps (event) {
                    this.bk = $ (event.target).attr ('data-bk');
                    this.load_corresps ();
                },
                load_corresps () {
                    const vm = this;
                    const data = vm.get_corresps_params ();

                    $.ajax ({
                        'method' : 'POST',
                        'url'    : ajaxurl,
                        'data'   : add_ajax_action (data, 'on_cap_collation_user_load_corresps'),
                    }).done (function (response) {
                        const corresp = vm.corresp;
                        vm.corresps = response.corresps;
                        if (!vm.corresps.includes (corresp)) {
                            vm.corresp  = vm.corresps[0] || '';
                        }
                    });
                },
                on_load_manuscripts (event) {
                    const corresp = $ (event.target).attr ('data-corresp');
                    if (corresp) {
                        this.corresp = corresp;
                    }
                    this.load_manuscripts ();
                },
                load_manuscripts () {
                    mss_vue.load_manuscripts ();
                },
                /**
                 * Load parameters from a user-local file. Called from the file
                 * dialog ok button.
                 */
                on_load_file_chosen (event) {
                    const vm = this;
                    const file_input = event.target;
                    const files = file_input.files;
                    if (files.length === 1) {
                        const reader = new FileReader ();
                        reader.onload = function (e) {
                            const json = JSON.parse (e.target.result);
                            vm.bk          = json.bk;
                            vm.corresp     = json.corresp;
                            vm.later_hands = json.later_hands;
                            vm.all_copies  = json.all_copies;

                            mss_vue.checked = json.manuscripts;

                            $ ('#algorithm').val (json.algorithm);
                            $ ('#levenshtein_distance').val (json.levenshtein_distance);
                            $ ('#levenshtein_ratio').val (json.levenshtein_ratio);
                            $ ('#segmentation').prop ('checked', json.segmentation);
                            $ ('#transpositions').prop ('checked', json.transpositions);
                            $ ('#normalizations').val (json.normalizations.join ('\n'));
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
                on_load_params (event) {
                    $ ('#load-params').click ();
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
            },
            mounted () {
                this.load_bks ();
            },
        });

        /* The vue.js instance for the manuscript selection section. */

        mss_vue = new Vue ({
            'el'   : '#collation-manuscripts',
            'data' : {
                'corresp'     : '',
                'manuscripts' : [],  // list of [siglum, title] in order
                'checked'     : ['_bk-textzeuge'],  // list of checked sigla (unordered)
                'spinner'     : false,
            },
            'methods' : {
                load_manuscripts () {
                    const data = cap_vue.get_manuscripts_params ();
                    const vm = this;
                    vm.spinner = true;

                    $.ajax ({
                        'method' : 'POST',
                        'url'    : ajaxurl,
                        'data'   : add_ajax_action (data, 'on_cap_collation_user_load_manuscripts'),
                    }).done (function (response) {
                        vm.corresp = data.corresp;
                        vm.manuscripts = response.witnesses;
                    }).always (function () {
                        vm.spinner = false;
                    });
                },
                /**
                 * Activate the 'select all' checkboxes on the tables.
                 */
                make_cb_select_all () {
                    const vm = this;
                    const $el = $ (vm.$el);
                    const $cbs = $el.find ('thead, tfoot').find ('.check-column :checkbox');
                    $cbs.on ('click', function (event) { // eslint-disable-line no-unused-vars
                        const checked = $ (this).prop ('checked');
                        if (checked) {
                            vm.checked = vm.manuscripts.map (e => e.siglum);
                        } else {
                            vm.checked = [];
                        }
                    });
                },
                /**
                 * Get the new manuscript ordering after a user drag.
                 *
                 * Since sorting is still implemented with jquery-ui, vue.js has
                 * no idea the DOM changed.
                 *
                 * @returns List of sigla
                 */
                get_new_order () {
                    // Get the sigla of all manuscript in user-specified order
                    return this.$tbody.find ('tr[data-siglum]').map (function () {
                        return $ (this).attr ('data-siglum');
                    }).get ();
                },
                /**
                 * Return the checked items in the correct order.
                 *
                 * Unfortunately vue.js returns the checked items in random order.
                 *
                 * @returns List of sigla
                 */
                get_checked_sigla () {
                    return this.manuscripts
                        .filter (e => this.checked.includes (e.siglum))
                        .map (e => e.siglum);
                },

                /**
                 * Sort the sigla to the top of the table.
                 *
                 * @param sigla   List of sigla of the manuscripts
                 */

                sort_according_to_list (sigla) {
                    const vm = this;
                    let elems = [];
                    for (const siglum of sigla) {
                        const index = vm.manuscripts.findIndex (e => e.siglum === siglum);
                        if (index !== -1) { // found
                            elems = elems.concat (vm.manuscripts.splice (index, 1));
                        }
                    }
                    vm.manuscripts.unshift (... elems);
                },
                on_collate () {
                    coll_vue.collate ();
                },
                /**
                 * Save parameters to a user-local file.  Initialize a hidden <a> with a
                 * download link and fake a click on it.
                 */
                on_save_params () {
                    const params = coll_vue.get_collation_params ();
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
                this.$tbody = $ (this.$el).find ('table.manuscripts tbody');
                this.make_cb_select_all ();
            },
            updated () {
                const vm = this;
                vm.$tbody.disableSelection ().sortable ({
                    'items'       : 'tr[data-siglum]',
                    'axis'        : 'y',
                    'containment' : vm.$tbody.closest ('table'),
                    'update'      : function (event) {
                        vm.sort_according_to_list (vm.get_new_order ());
                        coll_vue.order = vm.get_checked_sigla ();
                    },
                });
            },
        });

        /* The vue.js instance for the collation output section. */

        coll_vue = new Vue ({
            'el'   : '#collation-results',
            'data' : {
                'witnesses' : {
                    'manuscripts' : [],
                    'table'       : [],
                },
                'corresp'         : '',
                'order'           : [],
                'unsorted_tables' : [],
                'tables'          : [],
                'hovered'         : null,
                'spinner'         : false,
            },
            'watch' : {
                'witnesses' : {
                    'deep'    : true,
                    'handler' : function (newVal) {
                        this.update_tables (newVal);
                    },
                },
                'order' : function (newVal) {
                    this.sort_rows (newVal);
                },
            },
            'methods' : {
                get_collation_params () {
                    const data = {
                        'manuscripts' : mss_vue.get_checked_sigla (),
                    };
                    return $.extend (
                        data,
                        cap_vue.get_manuscripts_params (),
                        cap_vue.get_collation_params ()
                    );
                },
                collate () {
                    const vm = this;
                    const data = vm.get_collation_params ();

                    vm.spinner = true;
                    vm.order   = [];
                    vm.corresp = '';

                    const p = $.ajax ({
                        'method' : 'POST',
                        'url'    : ajaxurl,
                        'data'   : add_ajax_action (data, 'on_cap_collation_user_load_collation'),
                    });
                    $.when (p).done (function () {
                        vm.witnesses = p.responseJSON.witnesses;
                        vm.order     = p.responseJSON.order;
                        vm.corresp   = p.responseJSON.corresp;
                    }).always (function () {
                        vm.spinner   = false;
                        const $div = $ ('#collation-results');
                        handle_message ($div, p.responseJSON);
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

                format_table (manuscripts, table, order) {
                    if (order.length === 0) {
                        return  [];
                    }
                    const sigla  = manuscripts.map (ms => ms.siglum);
                    const titles = manuscripts.map (ms => ms.title);
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
                    this.unsorted_tables = this
                        .split_table (witnesses.table, 80)
                        .map (table => this.transpose (table));
                },

                sort_rows (order) {
                    this.tables = this.unsorted_tables.map (table => this.format_table (
                        this.witnesses.manuscripts,
                        table,
                        order
                    ));
                    if (this.tables.length > 0) {
                        this.tables[0].class = 'first';
                        this.tables[this.tables.length - 1].class = 'last';
                    }
                },

                get_sigla (item) {
                    // Get the sigla of all manuscript to collate in user-specified order
                    return $ (item).closest ('table').find ('tr[data-siglum]').map (function () {
                        return $ (this).attr ('data-siglum');
                    })
                        .get ();
                },
                row_class (row) {
                    return this.hovered === row.siglum ? 'highlight-witness' : '';
                },
            },
            mounted () {
            },
            updated () {
                const vm = this;
                const $tbodies = $ (this.$el).find ('table.collation tbody');
                $tbodies.disableSelection ().sortable ({
                    'items'       : 'tr[data-siglum]',
                    'axis'        : 'y',
                    'containment' : 'parent',
                    'update'      : function (event, ui) {
                        const order = vm.get_sigla (ui.item);
                        vm.order = order;
                        mss_vue.sort_according_to_list (order);
                    },
                });
            },
        });
    });

    return {};
} (jQuery));
