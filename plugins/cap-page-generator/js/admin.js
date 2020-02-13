/**
 * @module plugins/page-generator
 */

/**
 * Some utility function for the Page Generator admin interface.
 * @file
 */
'use strict';

var cap_page_generator_admin = function ($) {
  // eslint-disable-line no-unused-vars

  /**
   * The inverse of the jQuery.param () function.
   *
   * @param s {string} A string in the form "p=1&q=2"
   * @return {Object} { p : 1, q : 2 }
   * @memberof module:plugins/page-generator
   */
  function deparam(s) {
    return s.split('&').reduce(function (params, param) {
      var paramSplit = param.split('=').map(function (value) {
        return decodeURIComponent(value.replace('+', ' '));
      });
      params[paramSplit[0]] = paramSplit[1];
      return params;
    }, {});
  }
  /**
   * Add action parameters to AJAX request data.
   *
   * @param {Object} data The AJAX request data.
   * @return {Object} The AJAX request data augmented.
   * @memberof module:plugins/page-generator
   */


  function add_ajax_action(data, action) {
    data.action = action;
    $.extend(data, cap_page_gen_admin_ajax_object); // eslint-disable-line no-undef

    return data;
  }
  /**
   * Perform an action on a TEI file.
   *
   * The user clicked somewhere inside the table row listing that file.
   *
   * @param {Element} e The element clicked
   * @param {string} action The AJAX action to perform
   * @memberof module:plugins/page-generator
   */


  function on_cap_action_file(e, action) {
    var $e = $(e);
    var $tr = $e.closest('tr');
    var $table = $e.closest('table');
    var $form = $e.closest('form');
    var data = {
      'user_action': action,
      'section': $tr.attr('data-section'),
      'filename': $tr.attr('data-filename'),
      'slug': $tr.attr('data-slug'),
      'paged': $form.attr('data-paged')
    };
    var msg_div = $('div.cap_page_dash_message');
    var status_div = $tr.find('td.column-status');
    var spinner = $('<div class="cap_page_spinner"></div>').progressbar({
      'value': false
    });
    spinner.hide().appendTo(status_div).fadeIn();
    $.ajax({
      'method': 'POST',
      'url': ajaxurl,
      'data': add_ajax_action(data, 'on_cap_action_file')
    }).done(function (response) {
      $table.find('tbody').html(response.rows);
    }).always(function (response) {
      spinner.fadeOut().remove();
      $(response.message).hide().appendTo(msg_div).slideDown();
      /* Adds a 'dismiss this notice' button. */

      $(document).trigger('wp-plugin-update-error');
    });
  }
  /**
   * Perform an action on a tab.
   *
   * The user clicked on a tab. The tab contents must now be loaded.
   *
   * @param {Event} event The click event
   * @memberof module:plugins/page-generator
   */


  function on_cap_load_section(event) {
    event.preventDefault();
    var $this = $(this);
    var $form = $this.closest('form');
    var q = deparam($this.attr('href').split('?')[1] || '');
    var data = {
      'section': $form.attr('data-section'),
      'paged': q.paged || 1
    };
    var status_div = $form.parent();
    var spinner = $('<div class="spinner-div"><span class="spinner is-active" /></div>');
    spinner.hide().appendTo(status_div).fadeIn();
    $.ajax({
      'method': 'POST',
      'url': ajaxurl,
      'data': add_ajax_action(data, 'on_cap_load_section')
    }).done(function (response) {
      $form.closest('div[role=tabpanel]').html(response);
    }).always(function () {
      spinner.fadeOut().remove();
    });
  }
  /**
   * Activate the 'select all' checkboxes on the tables.
   *
   * Check or uncheck all checkboxes when the user clicks on the "select all"
   * checkbox.  Stolen from wp-admin/js/common.js
   *
   * @param {Event} ev (unused) The tab loaded event emited by jQuery-ui
   * @param {Element} ui The tab element
   * @memberof module:plugins/page-generator
   */


  function make_cb_select_all(ev, ui) {
    ui.panel.find('thead, tfoot').find('.check-column :checkbox').on('click.wp-toggle-checkboxes', function (event) {
      var $this = $(this);
      var $table = $this.closest('table');
      var controlChecked = $this.prop('checked');
      var toggle = event.shiftKey || $this.data('wp-toggle');
      $table.children('tbody').filter(':visible').children().children('.check-column').find(':checkbox').prop('checked', function () {
        if ($(this).is(':hidden,:disabled')) {
          return false;
        }

        if (toggle) {
          return !$(this).prop('checked');
        }

        if (controlChecked) {
          return true;
        }

        return false;
      });
      $table.children('thead,  tfoot').filter(':visible').children().children('.check-column').find(':checkbox').prop('checked', function () {
        if (toggle) {
          return false;
        }

        if (controlChecked) {
          return true;
        }

        return false;
      });
    });
  }
  /**
   * Get a parameter from the URL in the browser location bar.
   *
   * @param {string} name The name of the parameter
   * @return {?string} The value of the parameter or null
   * @memberof module:plugins/page-generator
   */


  function get_url_parameter(name) {
    var search = window.location.search.substring(1);
    var params = search.split('&');

    for (var i = 0; i < params.length; i++) {
      var name_val = params[i].split('=');

      if (name_val[0] === name) {
        return name_val[1];
      }
    }

    return null;
  }
  /**
   * Initialize the jQuery tab interface.
   *
   * @memberof module:plugins/page-generator
   */


  function init_tabs() {
    var tabs = $('#tabs');
    tabs.tabs({
      /*
       * Display a Wordpress spinner.
       *
       * See: https://make.wordpress.org/core/2015/04/23/spinners-and-dismissible-admin-notices-in-4-2/
       */
      'beforeLoad': function beforeLoad(event, ui) {
        ui.panel.html('<div class="spinner-div"><span class="spinner is-active" /></div>');
      },
      'load': function load(event, ui) {
        make_cb_select_all(event, ui);
      }
    });
    /*
     * Remove lots of troublesome jQuery-ui styles that we would otherwise have
     * to undo in css because they clash with Wordpress style.
     */

    tabs.parent().find('*').removeClass('ui-widget-content ui-widget-header ui-tabs-panel ui-corner-all ui-corner-top ui-corner-bottom');
    /* open the right tab */

    var section = get_url_parameter('section');

    if (section) {
      var index = tabs.find('a[data-section="' + section + '"]').parent().index();
      tabs.tabs('option', 'active', index);
    }
  }

  $(document).ready(function () {
    init_tabs();
    $('body').on('click', 'div.tablenav-pages a', on_cap_load_section);
  });
  return {
    'on_cap_load_section': on_cap_load_section,
    'on_cap_action_file': on_cap_action_file
  };
}(jQuery);

//# sourceMappingURL=admin.js.map