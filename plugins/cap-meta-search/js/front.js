/** @module plugins/meta-search */

/**
 * The meta search applet.
 * @file
 */
'use strict';

(function ($) {
  /**
   * Initialize the help button in the widget.
   *
   * @alias module:plugins/meta-search.help_init
   */
  function help_init() {
    $('.cap-meta-search-help').on('click', function (dummy_event) {
      $('div.cap-meta-search-help-text').toggle();
    });
    $('div.cap-meta-search-box [title]').tooltip({
      'placement': 'bottom'
    });
  }
  /** @ignore */


  var collator = new Intl.Collator('de');
  /**
   * Initialize the places tree view in the widget.
   *
   * @alias module:plugins/meta-search.places_tree_init
   */

  function places_tree_init() {
    var container = $('#places');
    container.jstree({
      'plugins': ['checkbox', 'sort', 'state', 'wholerow'],
      'checkbox': {
        'three_state': false // 'cascade'     : 'down',

      },
      'sort': function sort(a, b) {
        return collator.compare(this.get_text(a), this.get_text(b));
      },
      'core': {
        'themes': {
          'icons': false,
          'dots': false
        },
        // See: https://www.jstree.com/docs/json/
        'data': function data(node, callback) {
          $.ajax(cap_lib.api_url + '/data/places.json/').then(function (response) {
            callback(response.map(function (r) {
              return {
                'id': r.geo_id,
                'parent': r.parent_id || '#',
                'text': r.geo_name
              };
            }));
          });
        }
      }
    });
    $('div.cap-meta-search-box form').submit(function (event) {
      var data = $(event.target).serializeArray();
      var jstree = $('#places').jstree(true);
      $.each(jstree.get_selected(true), function (i, node) {
        data.push({
          'name': 'places[]',
          'value': node.id
        }); // used by "You searched for: X"

        data.push({
          'name': 'placenames[]',
          'value': node.text
        });
      }); // submit to the wordpress search page

      window.location.href = '/?' + $.param(data);
      event.preventDefault();
    });
  }

  $(document).ready(function () {
    places_tree_init();
    help_init();
  });
})(jQuery);

//# sourceMappingURL=front.js.map