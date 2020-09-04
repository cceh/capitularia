.. _plugin-dev:

Plugin Development
==================

.. contents::
   :local:

The Arcana of Wordpress Plugin Development


webpack
~~~~~~~

Use webpack to compile all your Javascript modules and css into one file.

Compile your JS with webpack-dev-server to enable hot module reloading.

webpack-dev-server adds some code to your JS to enable HMR.  Once loaded into
Wordpress this code opens a socket to the webpack-dev-server and awaits
commands.  When webpack-dev-server detects a source code change it compiles the
changes modules into a hot-update.js file sends a reload command down the
socket.  The HMR code in your app then tries to reload the changed modules
preserving application state.  If it fails it will fallback on reloading the
whole page (and losing application state).

Example webpack config:

.. code-block:: js

   const webpack   = require ('webpack');
   const { merge } = require ('webpack-merge');
   const common    = require ('./webpack.common.js');
   const chokidar  = require ('chokidar');

   const devPort = 8081;

   module.exports = merge (common, {
       mode: 'development',
       devtool: 'eval-source-map',
       output: {
           // This is where the HMR module looks for the hot-update files.
           // We actually serve nothing but the hot-update files from here.
           publicPath: `http://capitularia.fritz.box:${devPort}/`,

           // These files don't get removed, so at least give them stable names.
           hotUpdateChunkFilename: 'hot-update.js',
           hotUpdateMainFilename:  'hot-update.json',
       },
       devServer: {
           host: 'capitularia.fritz.box',
           port: devPort,
           contentBase: './build',  // not used

           // Enable hot module reloading (HMR).
           hot: true,
           liveReload: false,

           // Always write the files to disk because Wordpress needs to serve them
           // in case of page reload.
           writeToDisk: true,

           // Needed because we access port devPort from port 80.
           headers: { 'Access-Control-Allow-Origin': '*' },

           // Watch for changes to PHP files and reload the page when one changes.
           // See: https://mikeselander.com/hot-reloading-using-webpack-with-php-file-changes/
           before (app, server) {
               chokidar
                   .watch ('*.php', {
                       alwaysStat: true,
                       atomic: false,
                       followSymlinks: false,
                       ignoreInitial: true,
                       ignorePermissionErrors: true,
                       persistent: true,
                       usePolling: true
                   })
                   .on ('all', () => {
                       server.sockWrite (server.sockets, 'content-changed');
                   });
           },
       },
   });


i18n
~~~~

Internationalization consists of these steps:

1. Extract the strings to translate from the source files.

2. Translate the strings and compile them into a .json file (in jed format).

3. Make the .json file available to your JS module.

4. Use Wordpress i18n functions to translate the strings at runtime.

There are 3 kinds of source files: PHP files, JS files and Vue single component
files. PHP and JS files can be extracted using the GNU xgettext utility.

Vue single component files contain 3 sections: HTML, JS, and CSS.  The CSS
section does not need to be translated.

The JS section uses the :func:`$t` function to tag and translate strings.

.. code-block:: js

   const message = $t ('Message to translate');

The HTML template section uses different methods to tag
translatable strings:

.. code-block:: html

   <h2 v-translate>Header to translate</h2>
   <p>{{ 'Text to translate' | translate }}</p>
   <span title="$t ('Tooltip to translate')"></span>

To extract the strings from the Vue files we use
`easygettext <https://github.com/Polyconseil/easygettext>`_.

To compile .po files into .json files in jed-format we use
`po2json <https://github.com/mikeedwards/po2json>`_.

Wordpress boilerplate to make translations available:
See also: https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/

.. code-block:: php

   function on_enqueue_scripts ()
   {
       wp_register_script (
           'my-plugin-name',
           plugins_url ('js/plugin.js', __FILE__),
           array (
               'wp-i18n',
               'cap-vue',
           )
       );

       load_plugin_textdomain (
           'my-text-domain',
           false,
           basename (dirname (__FILE__)) . '/languages/'
       );

       wp_set_script_translations (
           'my-plugin-name',
           'my-text-domain',
           plugin_dir_path (__FILE__) . 'languages'
       );
   }


Vue boilerplate to enable translations in HTML templates:
Put this in main.js before initializing your Vue app.

.. code-block:: js

   // wrapper to call the Wordpress translate function
   function $t (text) {
       return wp.i18n.__ (text, 'my-text-domain');
   }

   // the vm.$t function
   Vue.prototype.$t = function (text) {
       return $t (text);
   };

   // the v-translate directive
   Vue.directive ('translate', function (el) {
       el.innerText = $t (el.innerText);
   });

   // the {{ 'text' | translate }} filter
   Vue.filter ('translate', function (text) {
       return $t (text);
   });
