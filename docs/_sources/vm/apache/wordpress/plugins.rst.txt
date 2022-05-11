.. _plugins:

Wordpress Plugins
=================

Active Plugins
--------------

We wrote various Wordpress plugins to implement functionality we needed.

.. toctree::
   :maxdepth: 2

   plugins/collation-tool
   plugins/meta-search
   plugins/file-includer
   plugins/page-generator
   plugins/dynamic-menu
   plugins/lib



Obsolete Plugins
----------------

- **Collation tool** The old collation tool that lived on a Wordpress admin
  page.  Was rewritten for the front, because the admin page was not accessible
  by the general public.

- **XSL processor** This plugin was rewrittem as the File Includer plugin.  XSLT
  is now done exclusively on the VM because we can use Saxon there while we were
  limited to xsltproc in the RRZK Web Project environment.
