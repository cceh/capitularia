.. _wordpress-database:


Wordpress Database Structure
============================

The Wordpress mysql Database for Capitularia.

This is a standard Wordpress database.  See the `Wordpress database description
<https://codex.wordpress.org/Database_Description>`_.

The access parameters can be found in
:file:`/var/www/capitularia.uni-koeln.de/wp-config.php`.


Metadata
--------

Metadata we add to the wp_postmeta table:

tei-xml-id
   The xml:id of the TEI file transcluded into the page.

   The :ref:`Page Generator plugin<page-generator>` adds this metadata when it
   creates a page.
