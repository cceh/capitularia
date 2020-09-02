"use strict";

var _interopRequireWildcard = require("@babel/runtime/helpers/interopRequireWildcard");

var _interopRequireDefault = require("@babel/runtime/helpers/interopRequireDefault");

var _regenerator = _interopRequireDefault(require("@babel/runtime/regenerator"));

var _asyncToGenerator2 = _interopRequireDefault(require("@babel/runtime/helpers/asyncToGenerator"));

var tools = _interopRequireWildcard(require("tools"));

/** @module plugins/collation/selector  */

/**
 * @file
 */

/**
 * The vue.js instance that manages the section selector(s).
 * @class module:plugins/collation/selector.VueSelector
 */
Vue.component('cap-collation-selector', {
  data: function data() {
    return {
      'bk': '',
      'corresp': '',
      'later_hands': false,
      'witnesses': [],
      // list of sigla (urls in the form: skara-brae-42?hands=XYZ#2)
      'select_all': false,
      'bks': [],
      // the list of bks shown in the dropdown
      'corresps': [],
      // the list of corresps shown in the dropdown
      'bk_id': tools.bk_id,
      // id of bk-textzeuge, make it accessible to the template
      'spinner': false // if set true shows a spinner

    };
  },
  'props': {
    'config': Object // a config file section if loaded from config

  },
  'computed': {
    /** @returns The list of selected sigla in the correct order. */
    'selected': function selected() {
      return this.witnesses.filter(function (w) {
        return w.checked;
      }).map(function (w) {
        return w.siglum;
      });
    }
  },
  'watch': {
    config: function config() {
      this.ajax_load_bks();
    },
    select_all: function select_all(new_value) {
      this.check_all(new_value);
    }
  },

  /** @lends module:plugins/collation/front.VueFront.prototype */
  'methods': {
    /**
     * Load the bk dropdown.  Called once during setup.
     */
    ajax_load_bks: function ajax_load_bks() {
      var _this = this;

      return (0, _asyncToGenerator2.default)( /*#__PURE__*/_regenerator.default.mark(function _callee() {
        var vm, response;
        return _regenerator.default.wrap(function _callee$(_context) {
          while (1) {
            switch (_context.prev = _context.next) {
              case 0:
                vm = _this;
                _context.next = 3;
                return tools.api('/data/capitularies.json/');

              case 3:
                response = _context.sent;
                // list of { cap_id, title, transcriptions }
                // Do not show Ansegis etc.
                vm.bks = response.filter(function (r) {
                  return r.cap_id.match(/^BK|^Mordek/);
                }).map(function (r) {
                  return r.cap_id;
                });
                vm.bk = vm.config.bk || vm.bks[0] || '';
                _context.next = 8;
                return vm.ajax_load_corresps(vm.config);

              case 8:
                vm.later_hands = vm.config.later_hands || false;
                _context.next = 11;
                return vm.load_witnesses_carry_selection(vm.config);

              case 11:
              case "end":
                return _context.stop();
            }
          }
        }, _callee);
      }))();
    },

    /**
     * Load the corresps dropdown.  Called if bk changes.
     */
    ajax_load_corresps: function ajax_load_corresps() {
      var _arguments = arguments,
          _this2 = this;

      return (0, _asyncToGenerator2.default)( /*#__PURE__*/_regenerator.default.mark(function _callee2() {
        var config, vm, response;
        return _regenerator.default.wrap(function _callee2$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                config = _arguments.length > 0 && _arguments[0] !== undefined ? _arguments[0] : {};
                vm = _this2;
                _context2.next = 4;
                return tools.api("/data/capitulary/".concat(vm.bk, "/chapters.json/"));

              case 4:
                response = _context2.sent;
                // list of { chapter, transcriptions }
                vm.corresps = response.map(function (r) {
                  return r.cap_id + (r.chapter ? "_".concat(r.chapter) : '');
                });
                vm.corresp = config.corresp || vm.corresps[0] || '';

              case 7:
              case "end":
                return _context2.stop();
            }
          }
        }, _callee2);
      }))();
    },

    /**
     * Load the witnesses table.  Called if corresps changes.
     */
    ajax_load_witnesses: function ajax_load_witnesses() {
      var _this3 = this;

      return (0, _asyncToGenerator2.default)( /*#__PURE__*/_regenerator.default.mark(function _callee3() {
        var vm, response;
        return _regenerator.default.wrap(function _callee3$(_context3) {
          while (1) {
            switch (_context3.prev = _context3.next) {
              case 0:
                vm = _this3;
                vm.spinner = true;
                _context3.next = 4;
                return tools.api("/data/corresp/".concat(vm.corresp, "/manuscripts.json/"));

              case 4:
                response = _context3.sent;
                // list of { ms_id, n, type }
                vm.spinner = false;
                vm.witnesses = response.map(tools.parse_witness_response);
                vm.witnesses.sort(function (a, b) {
                  return a.sort_key.localeCompare(b.sort_key);
                });

                if (!vm.later_hands) {
                  vm.witnesses = vm.witnesses.filter(function (w) {
                    return w.type === 'original';
                  });
                }

              case 9:
              case "end":
                return _context3.stop();
            }
          }
        }, _callee3);
      }))();
    },

    /**
     * Reload the witnesses table while keeping selected items intact (if possible).
     */
    load_witnesses_carry_selection: function load_witnesses_carry_selection() {
      var _arguments2 = arguments,
          _this4 = this;

      return (0, _asyncToGenerator2.default)( /*#__PURE__*/_regenerator.default.mark(function _callee4() {
        var config, vm, selected;
        return _regenerator.default.wrap(function _callee4$(_context4) {
          while (1) {
            switch (_context4.prev = _context4.next) {
              case 0:
                config = _arguments2.length > 0 && _arguments2[0] !== undefined ? _arguments2[0] : {};
                vm = _this4;
                selected = vm.selected.slice();
                vm.select_all = false;
                _context4.next = 6;
                return vm.ajax_load_witnesses();

              case 6:
                vm.check_these(config.witnesses || selected);

              case 7:
              case "end":
                return _context4.stop();
            }
          }
        }, _callee4);
      }))();
    },

    /**
     * Check or uncheck all witnesses.
     */
    check_all: function check_all(val) {
      this.witnesses.map(function (w) {
        w.checked = val;
        return w;
      });
    },

    /**
     * Check all witnesses in list but don't uncheck any.
     */
    check_these: function check_these(sigla) {
      this.witnesses.map(function (w) {
        if (sigla.includes(w.siglum)) {
          w.checked = true;
        }

        return w;
      });
    },

    /**
     * The class(es) to apply to the witnesses table rows.
     */
    row_class: function row_class(dummy_w, dummy_index) {
      return ['sortable'];
    },

    /*
     * User Interface handlers
     */
    on_select_bk: function on_select_bk(event) {
      var _this5 = this;

      return (0, _asyncToGenerator2.default)( /*#__PURE__*/_regenerator.default.mark(function _callee5() {
        var vm;
        return _regenerator.default.wrap(function _callee5$(_context5) {
          while (1) {
            switch (_context5.prev = _context5.next) {
              case 0:
                // click on button in dropdown
                vm = _this5;
                vm.bk = event.target.getAttribute('data-bk');
                _context5.next = 4;
                return vm.ajax_load_corresps();

              case 4:
                _context5.next = 6;
                return vm.load_witnesses_carry_selection();

              case 6:
              case "end":
                return _context5.stop();
            }
          }
        }, _callee5);
      }))();
    },
    on_select_corresp: function on_select_corresp(event) {
      // click on button in dropdown
      this.corresp = event.target.getAttribute('data-corresp');
      this.load_witnesses_carry_selection();
    },
    on_later_hands: function on_later_hands(event) {
      // click on later hands checkbox
      // it is much easier to implement this by hand than to figure out
      // how to unwatch a variable while programmatically changing it
      // this.later_hands = event.target.checked;
      this.load_witnesses_carry_selection();
    }
  },
  mounted: function mounted() {
    var _this6 = this;

    return (0, _asyncToGenerator2.default)( /*#__PURE__*/_regenerator.default.mark(function _callee6() {
      var vm;
      return _regenerator.default.wrap(function _callee6$(_context6) {
        while (1) {
          switch (_context6.prev = _context6.next) {
            case 0:
              vm = _this6;
              _context6.next = 3;
              return vm.ajax_load_bks();

            case 3:
            case "end":
              return _context6.stop();
          }
        }
      }, _callee6);
    }))();
  },
  updated: function updated() {
    var vm = this;
    var $tbody = $(vm.$el).find('table.witnesses tbody');
    $tbody.disableSelection().sortable({
      'items': 'tr.sortable',
      'handle': 'th.handle',
      'axis': 'y',
      'cursor': 'move',
      'containment': 'parent'
    });
  }
});

//# sourceMappingURL=selector.js.map