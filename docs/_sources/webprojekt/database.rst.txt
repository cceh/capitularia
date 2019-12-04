.. _mysql:
.. _wp-db:

Database Structure (Wordpress)
==============================

The Wordpress Database for Capitularia.  This is a mysql database that is a part
of the "RRZK Webprojekt" package.

This is a standard Wordpress database.  See the `Wordpress database description
<https://codex.wordpress.org/Database_Description>`_.

The database is part of the package "RRZK Webprojekt".  The access parameters can
be found in
:file:`/afs/rrz.uni-koeln.de/vol/www/projekt/capitularia/http/docs/wp-config.php`.


Metadata
--------

Metadata we add to the wp_postmeta table:

tei-xml-id
   The xml:id of the TEI file transcluded into the page.

   The :ref:`Page Generator plugin<page-generator>` adds this metadata when it
   creates a page.
