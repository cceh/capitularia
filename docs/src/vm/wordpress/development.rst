.. _wordpress-development:


Developer Notes
===============

Description of our development environment for Wordpress customizations.

Skills needed: Wordpress, PHP, Javascript, Sass, Vue.js, jQuery, Bootstrap, Webpack,
GNU Make.

.. contents::
   :local:


webpack
~~~~~~~

We use webpack to compile all our JS and CSS modules.

Webpack generates a manifest file in :file:`dist/manifest.json`
that contains the public path to all compiled modules.

The theme and plugins load all JS code through the function:

.. code-block:: php

   \cceh\capitularia\lib\enqueue_from_manifest ($key, $dependencies = array ())

where :code:`$key` ist the key in the manifest file.

To build production files compile with:

.. code-block:: bash

   webpack --config webpack.prod.js

To build development files and enable hot module reloading (HMR) compile with:

.. code-block:: bash

   webpack serve --config webpack.dev.js

webpack serve adds some code to your JS to enable HMR.  Once loaded into
Wordpress this code opens a socket to the webpack-dev-server and awaits
commands.  When webpack-dev-server detects a source code change it compiles the
changed modules into hot-update.js files and sends a reload command down the
socket.  The HMR code in your app then tries to reload the changed modules
preserving application state.  If it fails to do so it will fallback on
reloading the whole page (and will lose application state).

Example webpack config:

.. literalinclude:: /../../webpack.dev.js
   :language: js


i18n of Javascript
~~~~~~~~~~~~~~~~~~

Internationalization consists of these steps:

1. Extract the strings to translate from the source files.

2. Translate the strings and compile them into a .json file (in jed format).

3. Make the .json file available to your JS module.

4. Use the Wordpress :file:`wp-i18n.js` library to translate the strings at
   runtime.


Extract
-------

There are 3 kinds of source files: PHP files, JS files and Vue single component files.
PHP files can be extracted using the GNU xgettext utility.  JS and Vue files are
extracted using the :program:`docs/cap-gettext-extractor.mjs` node utility.


PHP Files
+++++++++

In PHP files use the __ (), _x (), and _n () functions.


JS Files
++++++++

In JS files, do this:

.. code-block:: js

   /** The Wordpress Text Domain of the plugin. */
   const DOMAIN = 'cap-dynamic-menu';

   const message  = wp.i18n.__ ('Message to translate', DOMAIN);
   const xmessage = wp.i18n._x ('Message to translate', 'Hint to translators', DOMAIN);
   const nmessage = wp.i18n._n ('Singular', 'Plural', number, DOMAIN);

These functions translate the message at runtime and also tag the message for the
string extractor at compile time.


Vue Files
+++++++++

Vue single component files contain 3 sections: HTML, JS, and CSS.  The CSS
section does not need to be translated.

In the JS section of Vue files, use the :func:`$t ()` function:

.. code-block:: js

   const message = this.$t ('Message to translate');

This function tags the message for the string extractor and also translates
the string at runtime.

In the HTML template section of Vue files, you may use two different methods to
tag translatable strings:

.. code-block:: html

   <h2 v-translate>Header to translate</h2>
   <span title="$t ('Tooltip to translate')"></span>

This is the Vue 3 boilerplate that enables translations in Vue files: Put this
in main.js before initializing your Vue app.

.. code-block:: js
   :caption: Vue.js 3 boilerplate

   const DOMAIN = 'my-text-domain';
   const app    = createApp (App);

   // wrapper that calls the Wordpress translate function
   function $t (text) {
       return wp.i18n.__ (text, DOMAIN);
   }

   // make it available as this.$t on all instances
   app.config.globalProperties.$t = $t;

   // the v-translate directive
   app.directive ('translate', (el) => {
       el.innerText = wp.i18n.__ (el.innerText.trim (), DOMAIN);
   });

   app.mount ('...');


Translate
---------

Use poedit to translate the extracted strings.

To compile .po files into .json files we use a custom made
:program:`python/po2json.py`.


Enqueue Translations
--------------------

Wordpress boilerplate to make translations available in PHP and JS files:

.. code-block:: php
   :caption: Wordpress boilerplate

   use cceh\capitularia\lib;

   const DOMAIN = 'my-text-domain';

   function enqueue_scripts ()
   {
       $key = 'my-module'; // key from webpack.common.js

       // enqueue webpacked JS module
       lib\enqueue_from_manifest ("$key.js", [
           'another-module.js',
       ]);

       // enqueue extracted (minified) CSS
       lib\enqueue_from_manifest ("$key.css", [
           'another-module.css'
       ]);

       // translations in PHP files
       lib\load_textdomain (DOMAIN);

       // translations in JS files
       lib\wp_set_script_translations ("$key.js", DOMAIN);
   }

.. seealso::

    https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/
