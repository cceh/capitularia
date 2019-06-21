'use strict';
/** cap_collation_user_front_ajax_object is set by wp_localize_script in function.php. */

/* global cap_collation_user_front_ajax_object */

function _slicedToArray(arr, i) { return _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _nonIterableRest(); }

function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance"); }

function _iterableToArrayLimit(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"] != null) _i["return"](); } finally { if (_d) throw _e; } } return _arr; }

function _arrayWithHoles(arr) { if (Array.isArray(arr)) return arr; }

function _toConsumableArray(arr) { return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _nonIterableSpread(); }

function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance"); }

function _iterableToArray(iter) { if (Symbol.iterator in Object(iter) || Object.prototype.toString.call(iter) === "[object Arguments]") return Array.from(iter); }

function _arrayWithoutHoles(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = new Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } }

(function ($) {
  /** The id of the "Obertext". */
  var bk_id = '_bk-textzeuge';
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
  /**
   * Encapsulate AJAX functionality
   */

  function ajax(action, data) {
    data.action = 'on_cap_collation_user_' + action; // add the nonce

    $.extend(data, cap_collation_user_front_ajax_object);
    return $.ajax({
      'method': 'POST',
      'url': cap_collation_user_front_ajax_object.ajaxurl,
      'data': data
    });
    return p;
  }
  /**
   * Build a valid filename to save the config.
   */


  function encodeRFC5987ValueChars(str) {
    return encodeURIComponent(str) // Note that although RFC3986 reserves '!', RFC5987 does not,
    // so we do not need to escape it
    .replace(/['()]/g, escape) // i.e., %27 %28 %29
    .replace(/\*/g, '%2A') // The following are not required for percent-encoding per RFC5987,
    // so we can allow for a little better readability over the wire: |`^
    .replace(/%(?:7C|60|5E)/g, unescape);
  }
  /* The vue.js instance for the witness selection section. */


  Vue.component('cap-collation-user-witnesses', {
    'props': ['corresp', 'later_hands', 'order'],
    'data': function data() {
      return {
        'witnesses': [],
        // list of all { siglum, title, checked } in order
        'pre_select': [],
        // list of sigla set by on_load_config
        'spinner': false,
        'select_all': false,
        'bk_id': bk_id
      };
    },
    'computed': {
      'selected': function selected() {
        return this.get_selected();
      }
    },
    'watch': {
      /* props */
      'corresp': function corresp() {
        this.ajax_load_witnesses();
      },
      'later_hands': function later_hands() {
        this.ajax_load_witnesses();
      },
      'order': function order(_order) {
        this.sort_like(_order);
      },

      /* own authority */
      'select_all': function select_all(val) {
        this.check_all(val);
      }
    },
    'methods': {
      ajax_load_witnesses: function ajax_load_witnesses() {
        var data = this.$parent.ajax_params();
        var vm = this;
        var pre_select = vm.pre_select;
        vm.spinner = true;
        vm.select_all = false;
        ajax('load_witnesses', data).done(function (response) {
          vm.witnesses = response.witnesses;
          vm.check_all(false);
          vm.check_these(pre_select);
          vm.pre_select = [];
          vm.$emit('reordered', vm.get_sigla());
        }).always(function () {
          vm.spinner = false;
        });
      },
      ajax_params: function ajax_params() {
        return {
          'selected': this.get_selected()
        };
      },

      /**
       * Return the sigla of the loaded witnesses
       *
       * @returns List of sigla
       */
      get_sigla: function get_sigla() {
        return this.witnesses.map(function (e) {
          return e.siglum;
        });
      },

      /**
       * Return the sigla of the currently checked witnesses in the
       * correct order
       *
       * @returns List of sigla
       */
      get_selected: function get_selected() {
        return this.witnesses.filter(function (w) {
          return w.checked;
        }).map(function (w) {
          return w.siglum;
        });
      },

      /**
       * Check all boxes in list but don't uncheck any.
       */
      check_these: function check_these(sigla) {
        this.witnesses.map(function (w) {
          if (sigla.includes(w.siglum)) {
            w.checked = true;
          }
        });
      },

      /**
       * Check or uncheck all boxes but never uncheck BK.
       */
      check_all: function check_all(val) {
        this.witnesses.map(function (w) {
          w.checked = val || w.siglum == bk_id;
        });
      },

      /**
       * Sort the sigla in list to the top of the table.
       *
       * @param sigla   List of sigla of the witnesses
       */
      sort_like: function sort_like(sigla) {
        var _vm$witnesses;

        var vm = this;
        var elems = [];
        var _iteratorNormalCompletion = true;
        var _didIteratorError = false;
        var _iteratorError = undefined;

        try {
          var _loop = function _loop() {
            var siglum = _step.value;
            var index = vm.witnesses.findIndex(function (e) {
              return e.siglum === siglum;
            });

            if (index !== -1) {
              // found
              elems = elems.concat(vm.witnesses.splice(index, 1));
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

        (_vm$witnesses = vm.witnesses).unshift.apply(_vm$witnesses, _toConsumableArray(elems));
      },

      /**
       * The class(es) to apply to the table rows.
       */
      row_class: function row_class(w, index) {
        var cls = [];

        if (w.siglum != bk_id) {
          cls.push('sortable');
        }

        return cls;
      }
    },
    updated: function updated() {
      var vm = this;
      var $tbody = $(vm.$el).find('table.witnesses tbody');
      $tbody.disableSelection().sortable({
        'items': 'tr.sortable',
        'handle': 'th.handle',
        'axis': 'y',
        'cursor': 'move',
        'containment': 'parent',
        'update': function update()
        /* event, ui */
        {
          var new_order = $tbody.find('tr[data-siglum]').map(function () {
            return $(this).attr('data-siglum');
          }).get();
          vm.sort_like(new_order);
          vm.$emit('reordered', vm.get_sigla());
        }
      });
    }
  });
  /* The vue.js instance for the collation output section. */

  Vue.component('cap-collation-user-results', {
    'props': ['corresp', 'order'],
    'data': function data() {
      return {
        'witnesses': {
          'metadata': [],
          'table': []
        },
        'unsorted_tables': [],
        'tables': [],
        'hovered': null,
        // siglum of hovered witness
        'spinner': false
      };
    },
    'watch': {
      'witnesses': {
        'deep': true,
        'handler': function handler(newVal) {
          this.update_tables(newVal);
          this.sort_like(this.order);
        }
      },
      'order': function order(newVal) {
        this.sort_like(newVal);
      },
      'corresp': function corresp() {
        this.unsorted_tables = [];
      }
    },
    'methods': {
      collate: function collate() {
        var vm = this;
        var data = this.$parent.ajax_params();
        vm.spinner = true;
        var p = ajax('load_collation', data);
        $.when(p).done(function () {
          vm.witnesses = p.responseJSON.witnesses;
        }).always(function () {
          vm.spinner = false;
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
        var _this = this;

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
              return _this.cell_width(cell);
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
      format_table: function format_table(witnesses, table, order) {
        if (order.length === 0) {
          return [];
        }

        var sigla = witnesses.map(function (ms) {
          return ms.siglum;
        });
        var titles = witnesses.map(function (ms) {
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
        var _this2 = this;

        var max_width = 120 - Math.max.apply(Math, _toConsumableArray(witnesses.metadata.map(function (ms) {
          return ms.title.length;
        })));
        this.unsorted_tables = this.split_table(witnesses.table, max_width).map(function (table) {
          return _this2.transpose(table);
        });
      },
      sort_like: function sort_like(order) {
        var _this3 = this;

        this.tables = this.unsorted_tables.map(function (table) {
          return _this3.format_table(_this3.witnesses.metadata, table, order);
        });

        if (this.tables.length > 0) {
          this.tables[0]["class"] = 'first';
          this.tables[this.tables.length - 1]["class"] = 'last';
        }
      },
      get_sigla: function get_sigla(item) {
        // Get the sigla of all witnesses to collate in user-specified order
        return $(item).closest('table').find('tr[data-siglum]').map(function () {
          return $(this).attr('data-siglum');
        }).get();
      },
      row_class: function row_class(row, index) {
        var cls = [];

        if (row.siglum != bk_id) {
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
        'items': 'tr.sortable',
        'handle': 'th.handle',
        'axis': 'y',
        'cursor': 'move',
        'containment': 'parent',
        'update': function update(event, ui) {
          vm.$emit('reordered', vm.get_sigla(ui.item));
        }
      });
    }
  });
  $(document).ready(function () {
    /* The vue.js instance for the whole page. */
    new Vue({
      'el': '#vm-cap-collation-user',
      'data': {
        'bk': '',
        'corresp': '',
        'later_hands': false,
        'order': [],
        // list of sigla in correct order
        'bks': [],
        'corresps': [],
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
          this.ajax_load_corresps();
        }
      },
      'methods': {
        /**
         * Load the bk dropdown.  Called once during setup.
         */
        ajax_load_bks: function ajax_load_bks() {
          var vm = this;
          ajax('load_bks', {}).done(function (response) {
            vm.bks = response.bks;
            vm.bk = vm.bks[0] || '';
          });
        },
        ajax_load_corresps: function ajax_load_corresps() {
          var vm = this;
          var data = this.ajax_params();
          var corresp = vm.corresp;
          ajax('load_corresps', data).done(function (response) {
            vm.corresps = response.corresps; // set a default corresp if corresp is not in corresps
            // in on_load_config () corresp will be set before corresps arrive

            if (!vm.corresps.includes(corresp)) {
              vm.corresp = vm.corresps[0] || '';
            }
          });
        },

        /**
         * Bundle all useful params for ajax calls and save config.
         */
        ajax_params: function ajax_params() {
          var data = _.pick(this.$data, 'bk', 'corresp', 'later_hands', 'levenshtein_distance', 'levenshtein_ratio', 'segmentation', 'transpositions');

          data.algorithm = this.algorithm.key;
          data.normalizations = this.normalizations.split('\n');
          return $.extend(data, this.$refs.witnesses.ajax_params());
        },
        on_select_bk: function on_select_bk(event) {
          // click on button in dropdown
          this.bk = $(event.target).attr('data-bk');
        },
        on_select_corresp: function on_select_corresp(event) {
          // click on button in dropdown
          this.corresp = $(event.target).attr('data-corresp');
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
        },
        on_reordered: function on_reordered(new_order) {
          this.order = new_order;
        },
        on_collate: function on_collate() {
          this.$refs.results.collate();
        },

        /**
         * Load configuration from a user-local file.  Called from the
         * file dialog ok button.
         */
        on_load_config: function on_load_config(event) {
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
              vm.segmentation = json.segmentation;
              vm.transpositions = json.transpositions;
              $('#algorithm').val(json.algorithm);
              $('#levenshtein_distance').val(json.levenshtein_distance);
              $('#levenshtein_ratio').val(json.levenshtein_ratio);
              $('#normalizations').val(json.normalizations.join('\n'));
              var vmw = vm.$refs.witnesses;
              vmw.pre_select = json.selected || [];
              vmw.ajax_load_witnesses();
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
        on_load_config_redirect: function on_load_config_redirect()
        /* event */
        {
          $('#load-config').click();
        },

        /**
         * Save parameters to a user-local file.  Initialize a hidden <a> with a
         * download link and fake a click on it.
         */
        on_save_config: function on_save_config() {
          var params = this.ajax_params();
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
        this.ajax_load_bks();
      }
    });
  });
})(jQuery);

//# sourceMappingURL=front.js.map