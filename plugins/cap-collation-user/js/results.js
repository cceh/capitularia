"use strict";

var _interopRequireWildcard = require("@babel/runtime/helpers/interopRequireWildcard");

var _interopRequireDefault = require("@babel/runtime/helpers/interopRequireDefault");

var _slicedToArray2 = _interopRequireDefault(require("@babel/runtime/helpers/slicedToArray"));

var _toConsumableArray2 = _interopRequireDefault(require("@babel/runtime/helpers/toConsumableArray"));

var tools = _interopRequireWildcard(require("tools"));

function _createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

/**
 * The vue.js instance that manages the collation output table.
 * @class module:plugins/collation/results.VueResults
 */
Vue.component('cap-collation-user-results', {
  'data': function data() {
    return {
      'api': null,
      // API server
      'corresp': '',
      'sigla': [],
      'witnesses': [],
      'unsorted_tables': [],
      'tables': [],
      'hovered': null,
      // siglum of hovered witness
      'spinner': false
    };
  },

  /** @lends module:plugins/collation/results.VueResults.prototype */
  'methods': {
    collate: function collate(data) {
      var vm = this;
      vm.tables = [];
      vm.corresp = data.corresp;
      vm.spinner = true;
      var p = $.ajax({
        'url': vm.api,
        'type': 'POST',
        'data': JSON.stringify(data),
        'contentType': 'application/json; charset=utf-8'
      });
      p.done(function () {
        vm.update_tables(p.responseJSON.witnesses, p.responseJSON.table);
        vm.sort_like(data.witnesses);
      }).always(function () {
        vm.spinner = false;
      });
      return p;
    },

    /**
     * Transpose a table returned by CollateX
     *
     * Turn rows into columns and vice versa.
     *
     * @param {array} matrix The CollateX table
     *
     * @return {array} The transposed table
     */
    transpose: function transpose(matrix) {
      var _ref;

      return (_ref = _).zip.apply(_ref, (0, _toConsumableArray2.default)(matrix));
    },

    /**
     * Calculate the cell width in characters
     *
     * @param {array} cell The array of tokens in the cell
     *
     * @return {integer} The width in characters
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
     * @param {array}   table     The table to split
     * @param {integer} max_width Split after this many characters
     *
     * @return {array} An array of tables
     */
    split_table: function split_table(table, max_width) {
      var _this = this;

      var out_tables = [];
      var tmp_table = [];
      var width = 0;

      var _iterator = _createForOfIteratorHelper(table),
          _step;

      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var column = _step.value;
          var column_width = 2 + Math.max.apply(Math, (0, _toConsumableArray2.default)(column.map(function (cell) {
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
        _iterator.e(err);
      } finally {
        _iterator.f();
      }

      if (tmp_table.length > 0) {
        out_tables.push(tmp_table);
      }

      return out_tables;
    },

    /**
     * Format a CollateX table into HTML
     *
     * The Collate-X response:
     *
     * .. code:: json
     *
     *    {
     *      "witnesses":["A","B"],
     *      "table":[
     *        [ [ {"t":"A","ref":123 } ],      [ {"t":"A" } ] ],
     *        [ [ {"t":"black","adj":true } ], [ {"t":"white","adj":true } ] ],
     *        [ [ {"t":"cat","id":"xyz" } ],   [ {"t":"kitten.","n":"cat" } ] ]
     *      ]
     *    }
     *
     * @param {string[]} sigla The witnesses' sigla in table order
     * @param {array}    table The collation table in column-major orientation
     * @param {string[]} order The witnesses' sigla in the order they should be displayed
     *
     * @return {Object} The rows of the formatted table
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
      var is_master = true; // first witness will become the master text

      var master_text = null; // ouput the witnesses in the correct order

      var _iterator2 = _createForOfIteratorHelper(order),
          _step2;

      try {
        for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
          var siglum = _step2.value;
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

          if (master_text === null) {
            master_text = table[index];
          }

          var ms_text = table[index];

          var _iterator3 = _createForOfIteratorHelper(_.zip(ms_text, master_text)),
              _step3;

          try {
            for (_iterator3.s(); !(_step3 = _iterator3.n()).done;) {
              var _step3$value = (0, _slicedToArray2.default)(_step3.value, 2),
                  ms_set = _step3$value[0],
                  master_set = _step3$value[1];

              var class_ = 'tokens';
              var master = master_set.map(function (token) {
                return token.t;
              }).join(' ').trim();
              var text = ms_set.map(function (token) {
                return token.t;
              }).join(' ').trim();
              var norm_master = master_set.map(function (token) {
                return token.n;
              }).join(' ').trim();
              var norm_text = ms_set.map(function (token) {
                return token.n;
              }).join(' ').trim();

              if (!is_master && norm_master.toLowerCase() === norm_text.toLowerCase()) {
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
            _iterator3.e(err);
          } finally {
            _iterator3.f();
          }

          out_table.rows.push(row);
          is_master = false;
        }
      } catch (err) {
        _iterator2.e(err);
      } finally {
        _iterator2.f();
      }

      return out_table;
    },
    update_tables: function update_tables(witnesses, table) {
      var _this2 = this;

      this.witnesses = witnesses.map(tools.parse_siglum);
      var max_width = 120 - Math.max.apply(Math, (0, _toConsumableArray2.default)(this.witnesses.map(function (ms) {
        return ms.title.length;
      })));
      this.unsorted_tables = this.split_table(table, max_width).map(function (table) {
        return _this2.transpose(table);
      });
    },
    sort_like: function sort_like(order) {
      var _this3 = this;

      this.tables = this.unsorted_tables.map(function (table) {
        return _this3.format_table(_this3.witnesses, table, order);
      });

      if (this.tables.length > 0) {
        this.tables[0].class = 'first';
        this.tables[this.tables.length - 1].class = 'last';
      }
    },
    get_sigla: function get_sigla(item) {
      // Get the sigla of all witnesses to collate in user-specified order
      return $(item).closest('table').find('tr[data-siglum]').map(function () {
        return this.getAttribute('data-siglum');
      }).get();
    },
    row_class: function row_class(row, dummy_index) {
      var cls = [];
      cls.push('sortable');

      if (this.hovered === row.siglum) {
        cls.push('highlight-witness');
      }

      return cls;
    }
  },
  mounted: function mounted() {
    this.api = tools.get_api_entrypoint() + '/collatex/collate';
  },
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

//# sourceMappingURL=results.js.map