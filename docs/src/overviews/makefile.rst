.. _makefile:

Makefile Overview
=================

The :file:`Makefile` is the central controller in the project. It includes
other Makefiles as sub-components.

Different parts of the :file:`Makefile` are called by cron at various intervals.
cron runs as the :ref:`user capitularia <user>`.

.. seealso::

    - :ref:`transformations`
    - :ref:`html-generation-overview`
    - :ref:`fulltext-search-overview`


.. minilang:: uml
   :caption: Makefile Overview
   :svg-width: 100%

   database "Manuscript files\npubl/mss/*.xml"               as tei
   database "Manuscript files\npubl/cache/mss/*.html"        as html
   database "Extracted chapters\npubl/cache/collation/*.xml" as chapters
   database "Lists\npubl/cache/lists/*" as lists
   database "Database\n(Postgres)"      as pg
   database "Wordpress\n(mariadb)"      as wp
   database "Full-text search\n(Solr)"  as solr

   component xsl_mss [mss-header.xsl
                      mss-transcription.xsl
                      mss-footer.xsl]

   component xsl_lists [capit-list.xsl
                        mss-key.xsl
                        changes.xsl
                        corpus.xsl
                        ...]

   component xsl_chapters [mss-extract-chapters.xsl
                           mss-extract-chapters-txt.xsl]

   component "import_data.py"         as import_data
   component "import_solr.py"         as import_solr

   tei          --> xsl_mss
   xsl_mss      --> html

   tei          --> xsl_lists
   xsl_lists    --> lists

   tei          --> xsl_chapters
   xsl_chapters --> chapters
   chapters     --> import_data
   import_data  --> pg

   import_data  --> solr

   tei          --> import_solr
   wp           --> import_solr
   import_solr  --> solr


XSLT Dependencies
-----------------

The section of the Makefile that deals with the dependencies between manuscripts, xslt
stylesheets, and html files is generated by the Python script
:program:`python/xslt_dep.py`.

.. autoprogram:: python.xslt_dep:build_parser()
    :prog: xslt_dep.py
