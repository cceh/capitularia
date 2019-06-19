'use strict';

function _slicedToArray(arr, i) { return _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _nonIterableRest(); }

function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance"); }

function _iterableToArrayLimit(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"] != null) _i["return"](); } finally { if (_d) throw _e; } } return _arr; }

function _arrayWithHoles(arr) { if (Array.isArray(arr)) return arr; }

function _toConsumableArray(arr) { return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _nonIterableSpread(); }

function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance"); }

function _iterableToArray(iter) { if (Symbol.iterator in Object(iter) || Object.prototype.toString.call(iter) === "[object Arguments]") return Array.from(iter); }

function _arrayWithoutHoles(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = new Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } }

(function ($) {
  var ajaxurl = cap_collation_user_front_ajax_object.ajaxurl;
  var cap_vue = null;
  var mss_vue = null;
  var coll_vue = null;
  /**
   * The collation algorithms we support.  The Needleman-Wunsch-Gotoh algorithm
   * is available only with our special patched version of CollateX.
   */

  var cap_collation_algorithms = [{
    'key': 'dekker',
    'name': 'Dekker'
  }, {
    'key': 'gst',
    'name': 'Greedy String Tiling'
  }, {
    'key': 'medite',
    'name': 'MEDITE'
  }, {
    'key': 'needleman-wunsch',
    'name': 'Needleman-Wunsch'
  }, {
    'key': 'needleman-wunsch-gotoh',
    'name': 'Needleman-Wunsch-Gotoh'
  }];

  function add_ajax_action(data, action) {
    data.action = action;
    $.extend(data, cap_collation_user_front_ajax_object); // eslint-disable-line no-undef

    return data;
  }

  function encodeRFC5987ValueChars(str) {
    return encodeURIComponent(str) // Note that although RFC3986 reserves '!', RFC5987 does not,
    // so we do not need to escape it
    .replace(/['()]/g, escape) // i.e., %27 %28 %29
    .replace(/\*/g, '%2A') // The following are not required for percent-encoding per RFC5987,
    // so we can allow for a little better readability over the wire: |`^
    .replace(/%(?:7C|60|5E)/g, unescape);
  }

  function handle_message(div, response) {
    if (response) {
      var msg = $(response.message).hide().prependTo(div);
      msg.fadeIn();
      /* Adds a 'dismiss this notice' button. */

      $(document).trigger('wp-plugin-update-error');
    }
  }

  $(document).ready(function () {
    /* The vue.js instance for the capitulary selection section. */
    cap_vue = new Vue({
      'el': '#collation-bk',
      'data': {
        'bk': '',
        'bks': [],
        'corresp': '',
        'corresps': [],
        'later_hands': false,
        'advanced': false,
        // don't show advanced options menu
        'algorithm': cap_collation_algorithms[cap_collation_algorithms.length - 1],
        'levenshtein_distance': 0,
        'levenshtein_ratio': 1.0,
        'segmentation': false,
        'transpositions': false,
        'normalizations': '',
        'algorithms': cap_collation_algorithms,
        'levenshtein_distances': [0, 1, 2, 3, 4, 5],
        'levenshtein_ratios': [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]
      },
      'watch': {
        'bk': function bk() {
          this.load_corresps();
        },
        'corresp': function corresp() {
          this.load_manuscripts();
        },
        'later_hands': function later_hands() {
          this.load_manuscripts();
        }
      },
      'methods': {
        get_corresps_params: function get_corresps_params() {
          return _.pick(this.$data, 'bk');
        },
        get_manuscripts_params: function get_manuscripts_params() {
          return _.pick(this.$data, 'bk', 'corresp', 'later_hands');
        },
        get_collation_params: function get_collation_params() {
          var data = _.pick(this.$data, 'levenshtein_distance', 'levenshtein_ratio', 'segmentation', 'transpositions');

          data.algorithm = this.algorithm.key;
          data.normalizations = this.normalizations.split('\n');
          return data;
        },
        load_bks: function load_bks() {
          var vm = this;
          $.ajax({
            'method': 'POST',
            'url': ajaxurl,
            'data': add_ajax_action({}, 'on_cap_collation_user_load_bks')
          }).done(function (response) {
            vm.bks = response.bks;

            if (!vm.bk && vm.bks.length) {
              vm.bk = vm.bks[0];
            }
          });
        },
        on_load_corresps: function on_load_corresps(event) {
          this.bk = $(event.target).attr('data-bk');
          this.load_corresps();
        },
        load_corresps: function load_corresps() {
          var vm = this;
          var data = vm.get_corresps_params();
          $.ajax({
            'method': 'POST',
            'url': ajaxurl,
            'data': add_ajax_action(data, 'on_cap_collation_user_load_corresps')
          }).done(function (response) {
            var corresp = vm.corresp;
            vm.corresps = response.corresps;

            if (!vm.corresps.includes(corresp)) {
              vm.corresp = vm.corresps[0] || '';
            }
          });
        },
        on_load_manuscripts: function on_load_manuscripts(event) {
          var corresp = $(event.target).attr('data-corresp');

          if (corresp) {
            this.corresp = corresp;
          }

          this.load_manuscripts();
        },
        load_manuscripts: function load_manuscripts() {
          mss_vue.load_manuscripts();
        },

        /**
         * Load parameters from a user-local file. Called from the file
         * dialog ok button.
         */
        on_load_file_chosen: function on_load_file_chosen(event) {
          var vm = this;
          var file_input = event.target;
          var files = file_input.files;

          if (files.length === 1) {
            var reader = new FileReader();

            reader.onload = function (e) {
              var json = JSON.parse(e.target.result);
              vm.bk = json.bk;
              vm.corresp = json.corresp;
              vm.later_hands = json.later_hands;
              mss_vue.checked = json.manuscripts;
              $('#algorithm').val(json.algorithm);
              $('#levenshtein_distance').val(json.levenshtein_distance);
              $('#levenshtein_ratio').val(json.levenshtein_ratio);
              $('#segmentation').prop('checked', json.segmentation);
              $('#transpositions').prop('checked', json.transpositions);
              $('#normalizations').val(json.normalizations.join('\n'));
            };

            reader.readAsText(files[0]);
          }

          file_input.value = null; // make it fire again even on the same file

          return false; // don't submit form
        },

        /**
         * Redirect click so we can use a normal bootstrap button.  The button
         * type=file is not styleable.
         */
        on_load_params: function on_load_params(event) {
          $('#load-config').click();
        },
        on_algorithm: function on_algorithm(event) {
          var index = $(event.target).attr('data-index');
          this.algorithm = this.algorithms[index];
        },
        on_ld: function on_ld(event) {
          this.levenshtein_distance = $(event.target).attr('data-ld');
        },
        on_lr: function on_lr(event) {
          this.levenshtein_ratio = $(event.target).attr('data-lr');
        }
      },
      mounted: function mounted() {
        this.load_bks();
      }
    });
    /* The vue.js instance for the manuscript selection section. */

    mss_vue = new Vue({
      'el': '#collation-manuscripts',
      'data': {
        'corresp': '',
        'manuscripts': [],
        // list of [siglum, title] in order
        'checked': ['_bk-textzeuge'],
        // list of checked sigla (unordered)
        'spinner': false
      },
      'methods': {
        load_manuscripts: function load_manuscripts() {
          var data = cap_vue.get_manuscripts_params();
          var vm = this;
          vm.spinner = true;
          $.ajax({
            'method': 'POST',
            'url': ajaxurl,
            'data': add_ajax_action(data, 'on_cap_collation_user_load_manuscripts')
          }).done(function (response) {
            vm.corresp = data.corresp;
            vm.manuscripts = response.witnesses;
          }).always(function () {
            vm.spinner = false;
          });
        },

        /**
         * Activate the 'select all' checkboxes on the tables.
         */
        make_cb_select_all: function make_cb_select_all() {
          var vm = this;
          var $el = $(vm.$el);
          var $cbs = $el.find('thead, tfoot').find('.check-column :checkbox');
          $cbs.on('click', function (event) {
            // eslint-disable-line no-unused-vars
            var checked = $(this).prop('checked');

            if (checked) {
              vm.checked = vm.manuscripts.map(function (e) {
                return e.siglum;
              });
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
        get_new_order: function get_new_order() {
          // Get the sigla of all manuscript in user-specified order
          return this.$tbody.find('tr[data-siglum]').map(function () {
            return $(this).attr('data-siglum');
          }).get();
        },

        /**
         * Return the checked items in the correct order.
         *
         * Unfortunately vue.js returns the checked items in random order.
         *
         * @returns List of sigla
         */
        get_checked_sigla: function get_checked_sigla() {
          var _this = this;

          return this.manuscripts.filter(function (e) {
            return _this.checked.includes(e.siglum);
          }).map(function (e) {
            return e.siglum;
          });
        },

        /**
         * Sort the sigla to the top of the table.
         *
         * @param sigla   List of sigla of the manuscripts
         */
        sort_according_to_list: function sort_according_to_list(sigla) {
          var _vm$manuscripts;

          var vm = this;
          var elems = [];
          var _iteratorNormalCompletion = true;
          var _didIteratorError = false;
          var _iteratorError = undefined;

          try {
            var _loop = function _loop() {
              var siglum = _step.value;
              var index = vm.manuscripts.findIndex(function (e) {
                return e.siglum === siglum;
              });

              if (index !== -1) {
                // found
                elems = elems.concat(vm.manuscripts.splice(index, 1));
              }
            };

            for (var _iterator = sigla[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
              _loop();
            }
          } catch (err) {
            _didIteratorError = true;
            _iteratorError = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion && _iterator["return"] != null) {
                _iterator["return"]();
              }
            } finally {
              if (_didIteratorError) {
                throw _iteratorError;
              }
            }
          }

          (_vm$manuscripts = vm.manuscripts).unshift.apply(_vm$manuscripts, _toConsumableArray(elems));
        },
        on_collate: function on_collate() {
          coll_vue.collate();
        },

        /**
         * Save parameters to a user-local file.  Initialize a hidden <a> with a
         * download link and fake a click on it.
         */
        on_save_params: function on_save_params() {
          var params = coll_vue.get_collation_params();
          var url = 'data:text/plain,' + encodeURIComponent(JSON.stringify(params, null, 2));
          var $e = $('#save-fake-download');
          $e.attr({
            'href': url,
            'download': 'save-' + encodeRFC5987ValueChars(params.corresp.toLowerCase()) + '.txt'
          });
          $e[0].click(); // trigger doesn't work
        }
      },
      mounted: function mounted() {
        this.$tbody = $(this.$el).find('table.manuscripts tbody');
        this.make_cb_select_all();
      },
      updated: function updated() {
        var vm = this;
        vm.$tbody.disableSelection().sortable({
          'items': 'tr[data-siglum]:not(:first-child)',
          'handle': 'th.handle',
          'axis': 'y',
          'cursor': 'move',
          'containment': 'parent',
          'update': function update(event) {
            vm.sort_according_to_list(vm.get_new_order());
            coll_vue.order = vm.get_checked_sigla();
          }
        });
      }
    });
    /* The vue.js instance for the collation output section. */

    coll_vue = new Vue({
      'el': '#collation-results',
      'data': {
        'witnesses': {
          'manuscripts': [],
          'table': []
        },
        'corresp': '',
        'order': [],
        'unsorted_tables': [],
        'tables': [],
        'hovered': null,
        'spinner': false
      },
      'watch': {
        'witnesses': {
          'deep': true,
          'handler': function handler(newVal) {
            this.update_tables(newVal);
          }
        },
        'order': function order(newVal) {
          this.sort_rows(newVal);
        }
      },
      'methods': {
        get_collation_params: function get_collation_params() {
          var data = {
            'manuscripts': mss_vue.get_checked_sigla()
          };
          return $.extend(data, cap_vue.get_manuscripts_params(), cap_vue.get_collation_params());
        },
        collate: function collate() {
          var vm = this;
          var data = vm.get_collation_params();
          vm.spinner = true;
          vm.order = [];
          vm.corresp = '';
          var p = $.ajax({
            'method': 'POST',
            'url': ajaxurl,
            'data': add_ajax_action(data, 'on_cap_collation_user_load_collation')
          });
          $.when(p).done(function () {
            vm.witnesses = p.responseJSON.witnesses;
            vm.order = p.responseJSON.order;
            vm.corresp = p.responseJSON.corresp;
          }).always(function () {
            vm.spinner = false;
            var $div = $('#collation-results');
            handle_message($div, p.responseJSON);
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
        transpose: function transpose(matrix) {
          var _ref;

          return (_ref = _).zip.apply(_ref, _toConsumableArray(matrix));
        },

        /**
         * Calculate the cell width in characters
         *
         * @param array $cell The array of tokens in the cell
         *
         * @return integer The width in characters
         */
        cell_width: function cell_width(cell) {
          var tokens = cell.map(function (token) {
            return token.t.trim();
          });
          return tokens.join(' ').length;
        },

        /**
         * Split a table in columns every n characters
         *
         * @param array   $in_table  The table to split
         * @param integer $max_width Split after this many characters
         *
         * @return array An array of tables
         */
        split_table: function split_table(table, max_width) {
          var _this2 = this;

          var out_tables = [];
          var tmp_table = [];
          var width = 0;
          var _iteratorNormalCompletion2 = true;
          var _didIteratorError2 = false;
          var _iteratorError2 = undefined;

          try {
            for (var _iterator2 = table[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
              var column = _step2.value;
              var column_width = 2 + Math.max.apply(Math, _toConsumableArray(column.map(function (cell) {
                return _this2.cell_width(cell);
              })));

              if (width + column_width > max_width) {
                // start a new table
                out_tables.push(tmp_table.slice());
                tmp_table = [];
                width = 0;
              }

              tmp_table.push(column);
              width += column_width;
            }
          } catch (err) {
            _didIteratorError2 = true;
            _iteratorError2 = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion2 && _iterator2["return"] != null) {
                _iterator2["return"]();
              }
            } finally {
              if (_didIteratorError2) {
                throw _iteratorError2;
              }
            }
          }

          if (tmp_table.length > 0) {
            out_tables.push(tmp_table);
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
        format_table: function format_table(manuscripts, table, order) {
          if (order.length === 0) {
            return [];
          }

          var sigla = manuscripts.map(function (ms) {
            return ms.siglum;
          });
          var titles = manuscripts.map(function (ms) {
            return ms.title;
          });
          var out_table = {
            'class': '',
            'rows': []
          };
          var is_master = true; // first witness is the master text

          var master_text = table[sigla.indexOf(order[0])]; // ouput the witnesses in the correct order

          var _iteratorNormalCompletion3 = true;
          var _didIteratorError3 = false;
          var _iteratorError3 = undefined;

          try {
            for (var _iterator3 = order[Symbol.iterator](), _step3; !(_iteratorNormalCompletion3 = (_step3 = _iterator3.next()).done); _iteratorNormalCompletion3 = true) {
              var siglum = _step3.value;
              var index = sigla.indexOf(siglum);

              if (index === -1) {
                continue; // user messed with mss. list but didn't start another collation
              }

              var row = {
                'siglum': siglum,
                'title': titles[index],
                'class': '',
                'cells': []
              };
              var ms_text = table[index];
              var _iteratorNormalCompletion4 = true;
              var _didIteratorError4 = false;
              var _iteratorError4 = undefined;

              try {
                for (var _iterator4 = _.zip(ms_text, master_text)[Symbol.iterator](), _step4; !(_iteratorNormalCompletion4 = (_step4 = _iterator4.next()).done); _iteratorNormalCompletion4 = true) {
                  var _step4$value = _slicedToArray(_step4.value, 2),
                      ms_set = _step4$value[0],
                      master_set = _step4$value[1];

                  var class_ = 'tokens';
                  var master = master_set.map(function (token) {
                    return token.t;
                  }).join(' ').trim();
                  var text = ms_set.map(function (token) {
                    return token.t;
                  }).join(' ').trim();

                  if (!is_master && master.toLowerCase() === text.toLowerCase()) {
                    class_ += ' equal';
                  }

                  if (text === '') {
                    class_ += ' missing';
                  }

                  row.cells.push({
                    'class': class_,
                    'text': text
                  });
                }
              } catch (err) {
                _didIteratorError4 = true;
                _iteratorError4 = err;
              } finally {
                try {
                  if (!_iteratorNormalCompletion4 && _iterator4["return"] != null) {
                    _iterator4["return"]();
                  }
                } finally {
                  if (_didIteratorError4) {
                    throw _iteratorError4;
                  }
                }
              }

              out_table.rows.push(row);
              is_master = false;
            }
          } catch (err) {
            _didIteratorError3 = true;
            _iteratorError3 = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion3 && _iterator3["return"] != null) {
                _iterator3["return"]();
              }
            } finally {
              if (_didIteratorError3) {
                throw _iteratorError3;
              }
            }
          }

          return out_table;
        },
        update_tables: function update_tables(witnesses) {
          var _this3 = this;

          var max_width = 120 - Math.max.apply(Math, _toConsumableArray(witnesses.manuscripts.map(function (ms) {
            return ms.title.length;
          })));
          this.unsorted_tables = this.split_table(witnesses.table, max_width).map(function (table) {
            return _this3.transpose(table);
          });
        },
        sort_rows: function sort_rows(order) {
          var _this4 = this;

          this.tables = this.unsorted_tables.map(function (table) {
            return _this4.format_table(_this4.witnesses.manuscripts, table, order);
          });

          if (this.tables.length > 0) {
            this.tables[0]["class"] = 'first';
            this.tables[this.tables.length - 1]["class"] = 'last';
          }
        },
        get_sigla: function get_sigla(item) {
          // Get the sigla of all manuscript to collate in user-specified order
          return $(item).closest('table').find('tr[data-siglum]').map(function () {
            return $(this).attr('data-siglum');
          }).get();
        },
        row_class: function row_class(row, index) {
          var cls = [];

          if (index > 0) {
            cls.push('sortable');
          }

          if (this.hovered === row.siglum) {
            cls.push('highlight-witness');
          }

          return cls;
        }
      },
      mounted: function mounted() {},
      updated: function updated() {
        var vm = this;
        var $tbodies = $(this.$el).find('table.collation tbody');
        $tbodies.disableSelection().sortable({
          'items': 'tr[data-siglum]:not(:first-child)',
          'handle': 'th.handle',
          'axis': 'y',
          'cursor': 'move',
          'containment': 'parent',
          'update': function update(event, ui) {
            var order = vm.get_sigla(ui.item);
            vm.order = order;
            mss_vue.sort_according_to_list(order);
          }
        });
      }
    });
  });
  return {};
})(jQuery);

//# sourceMappingURL=front.js.map