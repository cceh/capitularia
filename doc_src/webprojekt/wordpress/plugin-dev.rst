.. _plugin-dev:

Plugin Development
==================

The Arcana of Wordpress Plugin Development

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

   webpack-dev-server --config webpack.dev.js

webpack-dev-server adds some code to your JS to enable HMR.  Once loaded into
Wordpress this code opens a socket to the webpack-dev-server and awaits
commands.  When webpack-dev-server detects a source code change it compiles the
changed modules into hot-update.js files and sends a reload command down the
socket.  The HMR code in your app then tries to reload the changed modules
preserving application state.  If it fails to do so it will fallback on
reloading the whole page (and losing application state).

Example webpack config:

.. literalinclude:: /../webpack.dev.js
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

There are 3 kinds of source files: PHP files, JS files and Vue single component
files.  PHP and JS files can be extracted using the GNU xgettext utility.

In JS files, use the :func:`__ ()` function:

.. code-block:: js

   const message = __ ('Message to translate', DOMAIN);


Vue Files
+++++++++

Vue single component files contain 3 sections: HTML, JS, and CSS.  The CSS
section does not need to be translated.

In the JS section of Vue files, use the :func:`$t ()` function:

.. code-block:: js

   const message = $t ('Message to translate');

This function tags the message for the string extractor and also translates
the string at runtime.

In The HTML template section of Vue files, you may use 3 different methods to
tag translatable strings:

.. code-block:: html

   <h2 v-translate>Header to translate</h2>
   <p>{{ 'Text to translate' | translate }}</p>
   <span title="$t ('Tooltip to translate')"></span>

To extract the strings from the Vue files we use
`easygettext <https://github.com/Polyconseil/easygettext>`_.


Translate
---------

Use poedit to translate the extracted strings.

To compile .po files into .json files in jed-format we use
`po2json <https://github.com/mikeedwards/po2json>`_.


Enqueue Translations
--------------------

Wordpress boilerplate to make translations available in PHP and JS files:

.. code-block:: php
   :caption: Wordpress boilerplate

   use cceh\capitularia\lib;

   const DOMAIN = 'my-text-domain';

   function enqueue_scripts ()
   {
       $key = 'my-module'; // key from manifest.json

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

See also:
https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/


Use translated strings
----------------------

In JS simply use the functions made available by the :file:`wp-i18n.js` library.

.. code-block:: js
   :caption: Javascript boilerplate

   const { __, _x, _n, _nx } = wp.i18n;
   const DOMAIN = 'my-text-domain';

   const message = __ ('Message to translate', DOMAIN);

Vue boilerplate to enable translations in HTML templates:
Put this in main.js before initializing your Vue app.


.. code-block:: js
   :caption: Vue.js boilerplate

   const DOMAIN = 'my-text-domain';

   // wrapper to call the Wordpress translate function
   function $t (text) {
       return wp.i18n.__ (text, DOMAIN);
   }

   // the vm.$t function
   Vue.prototype.$t = function (text) {
       return $t (text);
   };

   // the {{ 'text' | translate }} filter
   Vue.filter ('translate', function (text) {
       return $t (text);
   });

   // the v-translate directive
   Vue.directive ('translate', function (el) {
       el.innerText = $t (el.innerText.trim ()));
   });

   new Vue (...);
